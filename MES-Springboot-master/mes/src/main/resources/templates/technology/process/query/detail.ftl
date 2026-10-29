<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>产品工艺查询明细</title>
    <meta name="renderer" content="webkit">
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
    <meta name="viewport"
          content="width=device-width, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=0">
    <#include "${request.contextPath}/common/common.ftl">
    <style>
        .query-container { display: flex; height: calc(100vh - 60px); padding: 10px; gap: 10px; }
        .tree-panel { width: 40%; min-width: 320px; background: #f8f8f8; border-radius: 4px; padding: 15px; overflow-y: auto; border: 1px solid #e6e6e6; }
        .info-panel { flex: 1; background: #fff; border-radius: 4px; padding: 20px; overflow-y: auto; border: 1px solid #e6e6e6; }

        /* BOM树样式 */
        .bom-tree { list-style: none; padding-left: 0; margin: 0; }
        .bom-tree ul { list-style: none; padding-left: 24px; }
        .bom-tree li { margin: 4px 0; }
        .bom-tree li .node-item {
            display: flex; align-items: center; gap: 8px;
            padding: 8px 12px; background: #fff; border: 1px solid #e6e6e6;
            border-radius: 4px; cursor: pointer; transition: all .2s;
        }
        .bom-tree li .node-item:hover { border-color: #009688; background: #f0faf8; }
        .bom-tree li .node-item.active { border-color: #009688; background: #e8f8f5; }
        .bom-tree li .node-item .checkmark {
            display: inline-flex; align-items: center; justify-content: center;
            width: 22px; height: 22px; border-radius: 50%; font-size: 14px; flex-shrink: 0;
        }
        .bom-tree li .node-item .checkmark.done { background: #5FB878; color: #fff; }
        .bom-tree li .node-item .checkmark.missing { background: #e6e6e6; color: #999; }
        .bom-tree li .node-item .node-label { font-size: 13px; flex: 1; }
        .bom-tree li .node-item .node-label .code { color: #999; font-size: 12px; }
        .bom-tree li .node-item .node-label .qty { color: #999; font-size: 12px; margin-left: 8px; }
        .bom-tree li .node-item .oper-badge {
            font-size: 11px; padding: 1px 8px; border-radius: 10px;
        }
        .bom-tree li .node-item .oper-badge.has { background: #e8f8e8; color: #5FB878; }
        .bom-tree li .node-item .oper-badge.none { background: #f8f8f8; color: #ccc; }

        /* 工艺信息面板 */
        .info-header { margin-bottom: 20px; padding-bottom: 15px; border-bottom: 2px solid #009688; }
        .info-header h3 { margin: 0; color: #333; font-size: 18px; }
        .info-header .materiel-info { color: #999; font-size: 13px; margin-top: 5px; }
        .info-section { margin-bottom: 20px; }
        .info-section .section-title {
            font-size: 15px; font-weight: bold; color: #333;
            padding-bottom: 8px; margin-bottom: 12px; border-bottom: 1px solid #e6e6e6;
        }
        .info-section .section-title .icon { margin-right: 6px; }
        .info-field { margin-bottom: 10px; }
        .info-field .field-label { color: #999; font-size: 12px; margin-bottom: 4px; }
        .info-field .field-value { color: #333; font-size: 14px; line-height: 1.6; }
        .info-field .field-value img { max-width: 200px; max-height: 200px; margin: 5px; border: 1px solid #e6e6e6; border-radius: 4px; }
        .no-selection { text-align: center; padding-top: 80px; color: #ccc; }
        .no-selection .icon { font-size: 64px; }
        .no-selection p { margin-top: 15px; font-size: 14px; }
        .no-process { text-align: center; padding-top: 60px; color: #ccc; }
        .no-process .icon { font-size: 48px; }
        .no-process p { margin-top: 10px; font-size: 14px; }
    </style>
</head>
<body>
<div class="splayui-container">
    <div class="splayui-main">
        <#-- 隐藏域 -->
        <input type="hidden" id="js-content-id" value="${(content.id)!}">
        <input type="hidden" id="js-bom-id" value="${(bomId)!}">

        <div class="query-container">
            <#-- 左侧：BOM树 -->
            <div class="tree-panel">
                <div style="font-weight:bold;margin-bottom:12px;color:#333;">
                    <i class="layui-icon layui-icon-app"></i> 产品BOM结构
                    <span style="font-size:12px;color:#999;margin-left:8px;">
                        <span style="color:#5FB878;">●</span> 有工艺
                        <span style="color:#ccc;margin-left:8px;">○</span> 无工艺
                    </span>
                </div>
                <div id="js-bom-tree-container">
                    <div style="text-align:center;padding:40px;color:#aaa;">
                        <i class="layui-icon layui-icon-loading layui-anim layui-anim-rotate layui-anim-loop" style="font-size:32px;"></i>
                        <p style="margin-top:10px;">正在加载产品BOM结构...</p>
                    </div>
                </div>
            </div>

            <#-- 右侧：工艺信息 -->
            <div class="info-panel" id="js-info-panel">
                <div class="no-selection" id="js-no-selection">
                    <div class="icon"><i class="layui-icon layui-icon-app"></i></div>
                    <p>请点击左侧BOM树中的组件节点<br>查看对应的工艺信息</p>
                </div>
                <div id="js-process-info" style="display:none;"></div>
            </div>
        </div>
    </div>
</div>

<script>
    layui.use(['layer'], function () {
        var layer = layui.layer,
            $ = layui.jquery;

        var contentId = $('#js-content-id').val();
        var bomId = $('#js-bom-id').val();

        // ============== 加载BOM工艺树 ==============
        function loadProcessTree() {
            if (!bomId) {
                $('#js-bom-tree-container').html('<div style="text-align:center;padding:40px;color:#FF5722;">BOM ID缺失</div>');
                return;
            }

            spUtil.ajax({
                url: '${request.contextPath}/technology/process/query/process-tree',
                type: 'POST',
                showLoading: true,
                serializable: false,
                data: { bomId: bomId, contentId: contentId },
                success: function (res) {
                    if (res.code === 0 && res.data) {
                        renderBomTree(res.data);
                    } else {
                        $('#js-bom-tree-container').html('<div style="text-align:center;padding:40px;color:#FF5722;">加载BOM工艺信息失败</div>');
                    }
                }
            });
        }

        // ============== 渲染BOM树 ==============
        var treeNodes = [];

        function renderBomTree(rootNode) {
            var container = $('#js-bom-tree-container');
            container.empty();
            treeNodes = [];

            var html = '<ul class="bom-tree">';
            html += renderTreeNode(rootNode, 0);
            html += '</ul>';
            container.html(html);

            // 默认选中根节点
            var firstItem = container.find('.node-item[data-index="0"]');
            if (firstItem.length > 0) {
                firstItem.addClass('active');
                showProcessInfo(treeNodes[0]);
            }
        }

        function renderTreeNode(node, level) {
            var hasChildren = node.children && node.children.length > 0;
            var hasProcess = node.hasProcess === true;
            var isRoot = level === 0;
            var index = treeNodes.length;
            treeNodes.push(node);

            var html = '<li>';
            html += '<div class="node-item" data-index="' + index + '">';
            // 打勾图标
            if (hasProcess) {
                html += '<span class="checkmark done"><i class="layui-icon layui-icon-ok"></i></span>';
            } else {
                html += '<span class="checkmark missing">-</span>';
            }
            // 节点标签
            html += '<span class="node-label">';
            html += '<strong>' + (node.materielDesc || '产品') + '</strong>';
            html += ' <span class="code">[' + (node.materielCode || '') + ']</span>';
            if (!isRoot && node.itemNum) {
                html += ' <span class="qty">×' + node.itemNum + ' ' + (node.itemUnit || '') + '</span>';
            }
            html += '</span>';
            // 工艺状态标签
            if (hasProcess) {
                html += '<span class="oper-badge has"><i class="layui-icon layui-icon-ok-circle"></i> ' + (node.operDesc || '有工艺') + '</span>';
            } else {
                html += '<span class="oper-badge none">无工艺</span>';
            }
            html += '</div>';

            // 子节点
            if (hasChildren) {
                html += '<ul>';
                $.each(node.children, function (i, child) {
                    html += renderTreeNode(child, level + 1);
                });
                html += '</ul>';
            }

            html += '</li>';
            return html;
        }

        // ============== 显示工艺信息 ==============
        function showProcessInfo(node) {
            if (!node) return;

            $('#js-no-selection').hide();
            var infoContainer = $('#js-process-info');
            infoContainer.show();

            if (node.hasProcess !== true) {
                infoContainer.html(
                    '<div class="no-process">' +
                    '<div class="icon"><i class="layui-icon layui-icon-close"></i></div>' +
                    '<p>该组件暂未编制工艺</p>' +
                    '</div>'
                );
                return;
            }

            var html = '';

            // 头部信息
            html += '<div class="info-header">';
            html += '<h3><i class="layui-icon layui-icon-ok-circle" style="color:#5FB878;"></i> ' + (node.materielDesc || '') + '</h3>';
            html += '<div class="materiel-info">';
            html += '物料编码：' + (node.materielCode || '') + '　';
            html += '工序名称：' + (node.operDesc || '') + '　';
            if (node.itemNum) {
                html += '用量：' + node.itemNum + ' ' + (node.itemUnit || '');
            }
            html += '</div>';
            html += '</div>';

            // 工序主信息
            html += '<div class="info-section">';
            html += '<div class="section-title"><span class="icon"><i class="layui-icon layui-icon-about"></i></span>工序主信息</div>';
            html += '<div class="info-field">';
            html += '<div class="field-label">工序名称</div>';
            html += '<div class="field-value">' + (node.operDesc || '-') + '</div>';
            html += '</div>';
            html += '<div class="info-field">';
            html += '<div class="field-label">关联物料</div>';
            html += '<div class="field-value">' + (node.materielCode || '') + ' ' + (node.materielDesc || '') + '</div>';
            html += '</div>';
            html += '</div>';

            // 工序内容
            html += '<div class="info-section">';
            html += '<div class="section-title"><span class="icon"><i class="layui-icon layui-icon-slate"></i></span>工序内容</div>';
            html += '<div class="info-field">';
            html += '<div class="field-label">作业工序内容</div>';
            html += '<div class="field-value">' + ((node.contentText || '').replace(/\n/g, '<br>') || '<span style="color:#ccc;">暂无内容</span>') + '</div>';
            html += '</div>';
            html += '</div>';

            // 工序要求（图片）
            html += '<div class="info-section">';
            html += '<div class="section-title"><span class="icon"><i class="layui-icon layui-icon-picture"></i></span>工序要求</div>';
            html += '<div class="info-field">';
            html += '<div class="field-label">工序参考图片</div>';
            html += '<div class="field-value" id="js-process-images">';
            try {
                var images = node.images ? JSON.parse(node.images) : [];
                if (images.length > 0) {
                    $.each(images, function (i, url) {
                        html += '<img src="' + url + '" onerror="this.style.display=\'none\'">';
                    });
                } else {
                    html += '<span style="color:#ccc;">暂无图片</span>';
                }
            } catch (e) {
                html += '<span style="color:#ccc;">暂无图片</span>';
            }
            html += '</div>';
            html += '</div>';
            html += '</div>';

            infoContainer.html(html);
        }

        // ============== 事件绑定 ==============
        $(document).on('click', '.node-item', function () {
            $('.node-item').removeClass('active');
            $(this).addClass('active');
            var index = parseInt($(this).data('index'));
            if (!isNaN(index) && treeNodes[index]) {
                showProcessInfo(treeNodes[index]);
            }
        });

        // ============== 初始化 ==============
        loadProcessTree();
    });
</script>
</body>
</html>
