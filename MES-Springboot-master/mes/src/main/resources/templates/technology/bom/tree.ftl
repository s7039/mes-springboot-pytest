<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>产品分解结构图</title>
    <meta name="renderer" content="webkit">
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
    <#include "${request.contextPath}/common/common.ftl">
    <style>
        .tree-container {
            padding: 20px;
            overflow: auto;
        }
        .tree-header {
            text-align: center;
            padding: 10px 0 20px 0;
            border-bottom: 2px solid #e6e6e6;
            margin-bottom: 20px;
        }
        .tree-header h3 {
            font-size: 18px;
            color: #333;
        }
        .tree-actions {
            margin-top: 10px;
        }
        .tree-actions .layui-btn {
            margin: 0 5px;
        }
        .tree-loading, .tree-empty {
            text-align: center;
            padding: 80px 0;
            color: #999;
        }
        .tree-loading .layui-icon {
            font-size: 40px;
        }

        /* ===== 树结构样式 ===== */
        .tree-root {
            display: flex;
            flex-direction: row;
            align-items: flex-start;
        }

        /* 节点卡片 */
        .node-card {
            display: inline-flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            min-width: 120px;
            max-width: 140px;
            padding: 8px 12px;
            border-radius: 6px;
            font-size: 12px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.12);
            cursor: default;
            position: relative;
            z-index: 2;
            transition: box-shadow 0.2s;
            word-break: break-word;
            text-align: center;
        }
        .node-card:hover {
            box-shadow: 0 4px 16px rgba(0,0,0,0.18);
        }
        .node-card.node-head {
            background: linear-gradient(135deg, #67c23a, #95d475);
            color: #fff;
        }
        .node-card.node-material {
            background: linear-gradient(135deg, #909399, #b7b9bd);
            color: #fff;
        }
        .node-card .node-code {
            font-weight: bold;
            font-size: 13px;
        }
        .node-card .node-desc {
            font-size: 11px;
            opacity: 0.9;
            margin-top: 3px;
        }
        .node-card .node-meta {
            font-size: 11px;
            opacity: 0.8;
            margin-top: 2px;
        }

        /* 根节点特殊样式 */
        .root-wrapper {
            display: flex;
            flex-direction: row;
            align-items: flex-start;
            margin-right: 10px;
        }
        .root-wrapper .node-card {
            background: linear-gradient(135deg, #1e9fff, #5fb8ff);
            color: #fff;
            min-width: 150px;
            max-width: 200px;
            padding: 10px 20px;
        }

        /* 子层级 - 垂直排列（水平布局中的列） */
        .children-wrapper {
            display: flex;
            flex-direction: column;
            align-items: flex-start;
            position: relative;
            padding-left: 30px;
            min-height: 100%;
        }
        /* 层级标签 */
        .level-label {
            position: absolute;
            top: -30px;
            left: 0;
            font-size: 12px;
            color: #999;
            font-weight: bold;
            white-space: nowrap;
        }
        /* 垂直线 - 左侧连接线 */
        .children-wrapper::before {
            content: '';
            position: absolute;
            left: 0;
            top: 10px;
            bottom: 10px;
            width: 2px;
            background: #dcdfe6;
        }

        /* 每个子项 */
        .child-item {
            display: flex;
            flex-direction: row;
            align-items: flex-start;
            margin: 0 0 20px 0;
            position: relative;
            min-width: 110px;
            max-width: none;
        }
        .child-item .node-card {
            flex-shrink: 0;
        }
        /* 水平线 - 从左侧垂直线到子节点 */
        .child-item::before {
            content: '';
            position: absolute;
            left: -30px;
            top: 50%;
            width: 30px;
            height: 2px;
            background: #dcdfe6;
            transform: translateY(-50%);
        }

        /* 折叠状态 */
        .children-wrapper.folded {
            display: none;
        }
        .fold-toggle {
            cursor: pointer;
            margin-left: 4px;
            font-size: 12px;
        }
        .fold-toggle:hover {
            opacity: 0.7;
        }

        /* 水平滚动容器 */
        .tree-scroll {
            overflow-x: auto;
            overflow-y: auto;
            padding-bottom: 10px;
            min-height: 400px;
        }
        .tree-scroll > div {
            min-width: max-content;
        }
    </style>
</head>
<body>
<div class="splayui-container">
    <div class="splayui-main">
        <div class="tree-container">
            <div class="tree-header">
                <h3>产品分解结构图 - ${bom.materielCode!} ${bom.materielDesc!}</h3>
                <div class="tree-actions">
                    <button type="button" class="layui-btn layui-btn-sm layui-btn-normal" id="js-add-item-btn">
                        <i class="layui-icon layui-icon-add-1"></i> 添加子项物料
                    </button>
                    <button type="button" class="layui-btn layui-btn-sm" id="js-refresh-btn">
                        <i class="layui-icon layui-icon-refresh"></i> 刷新结构图
                    </button>
                </div>
            </div>
            <div class="tree-scroll">
                <div id="js-tree-content">
                    <div class="tree-loading">
                        <i class="layui-icon layui-icon-loading layui-anim layui-anim-rotate layui-anim-loop"></i>
                        <p style="margin-top:10px;">正在加载结构图...</p>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
    layui.use(['layer', 'spLayer'], function () {
        var layer = layui.layer,
            spLayer = layui.spLayer;

        var bomId = '${bomId}';

        // 加载并渲染结构图
        function loadTree() {
            $('#js-tree-content').html(
                '<div class="tree-loading"><i class="layui-icon layui-icon-loading layui-anim layui-anim-rotate layui-anim-loop"></i><p style="margin-top:10px;">正在加载结构图...</p></div>'
            );

            $.ajax({
                url: '${request.contextPath}/technology/bom/tree',
                type: 'POST',
                data: { bomId: bomId },
                dataType: 'json',
                success: function (res) {
                    if (res.code === 0 && res.data) {
                        // 第一层是根节点，直接用根节点卡片渲染，不外包child-item
                        var root = res.data;
                        var html = renderRoot(root);
                        $('#js-tree-content').html('<div class="tree-root">' + html + '</div>');
                        // 默认展开第一级
                        initExpand();
                    } else {
                        $('#js-tree-content').html('<div class="tree-empty">暂无BOM数据</div>');
                    }
                },
                error: function () {
                    $('#js-tree-content').html('<div class="tree-empty">加载失败，请刷新重试</div>');
                }
            });
        }

        // 渲染根节点（特殊样式）
        function renderRoot(node) {
            if (!node) return '';
            var toggleIcon = (node.children && node.children.length > 0)
                ? '<span class="fold-toggle layui-icon layui-icon-right" data-code="' + node.materielCode + '"></span>'
                : '';

            var html = '<div class="root-wrapper">' +
                '<div class="node-card">' +
                '<div class="node-code">' + (node.materielCode || '') + ' ' + toggleIcon + '</div>' +
                '<div class="node-desc">' + (node.materielDesc || '') + '</div>' +
                '<div class="node-meta">产品</div>' +
                '</div>';

            if (node.children && node.children.length > 0) {
                html += '<div class="children-wrapper" id="children-' + (node.materielCode || 'root') + '">' +
                    '<div class="level-label">一级</div>';
                for (var i = 0; i < node.children.length; i++) {
                    html += renderChild(node.children[i], 2);
                }
                html += '</div>';
            }

            html += '</div>';
            return html;
        }

        // 渲染子节点（递归）
        function renderChild(node, level) {
            if (!node) return '';

            var typeLabel = node.isBomHead ? '半成品' : '原材料';
            var qtyText = '';
            if (node.itemNum) {
                qtyText = '用量: ' + node.itemNum;
                if (node.itemUnit) qtyText += node.itemUnit;
            }

            var cardClass = node.isBomHead ? 'node-head' : 'node-material';
            var hasChildren = node.children && node.children.length > 0;
            var toggleIcon = hasChildren
                ? '<span class="fold-toggle layui-icon layui-icon-right" data-code="' + node.materielCode + '"></span>'
                : '';

            var html = '<div class="child-item" data-code="' + (node.materielCode || '') + '">' +
                '<div class="node-card ' + cardClass + '">' +
                '<div class="node-code">' + (node.materielCode || '') + ' ' + toggleIcon + '</div>' +
                '<div class="node-desc">' + (node.materielDesc || '') + '</div>' +
                '<div class="node-meta">' + typeLabel + ' | ' + qtyText + '</div>' +
                '</div>';

            if (hasChildren) {
                
                html += '<div class="children-wrapper" id="children-' + (node.materielCode || node.id) + '">' +
                    '<div class="level-label">'  + '</div>';
                for (var i = 0; i < node.children.length; i++) {
                    html += renderChild(node.children[i], level + 1);
                }
                html += '</div>';
            }

            html += '</div>';
            return html;
        }

        // 默认展开第一级子节点
        function initExpand() {
            // 默认所有展开，所以无需额外操作
        }

        // 折叠/展开
        $(document).on('click', '.fold-toggle', function () {
            var $icon = $(this);
            var $wrapper = $icon.closest('.root-wrapper, .child-item').find('> .children-wrapper');
            if ($wrapper.length > 0) {
                var isFolded = $wrapper.hasClass('folded');
                if (isFolded) {
                    $wrapper.removeClass('folded');
                    $icon.addClass('layui-icon-right').removeClass('layui-icon-down');
                } else {
                    $wrapper.addClass('folded');
                    $icon.addClass('layui-icon-down').removeClass('layui-icon-right');
                }
            }
        });

        // 添加子项 - 利用spLayer默认行为自动刷新
        $('#js-add-item-btn').click(function () {
            spLayer.open({
                title: '添加子项物料',
                area: ['1000px', '600px'],
                content: '${request.contextPath}/technology/bom/item/add-or-update-ui',
                spWhere: {bomHeadId: bomId}
            });
        });
       

        // 刷新
        $('#js-refresh-btn').click(function () {
            loadTree();
        });

        // 初始加载
        loadTree();
    });
</script>
</body>
</html>
