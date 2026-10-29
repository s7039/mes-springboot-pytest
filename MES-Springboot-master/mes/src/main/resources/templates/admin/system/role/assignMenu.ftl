<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>分配权限</title>
    <meta name="renderer" content="webkit">
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=0">
    <#include "${request.contextPath}/common/common.ftl">
    <style>
        .menu-tree-container {
            padding: 15px;
            max-height: 400px;
            overflow-y: auto;
        }
        .menu-tree-container ul {
            padding-left: 20px;
        }
        .menu-tree-container li {
            list-style: none;
            line-height: 32px;
        }
        .menu-tree-container .tree-node {
            cursor: pointer;
            user-select: none;
            display: flex;
            align-items: center;
        }
        .menu-tree-container .tree-node:hover {
            background-color: #f2f2f2;
        }
        .menu-tree-container .tree-node input[type="checkbox"] {
            margin-right: 6px;
        }
        .menu-tree-container .tree-node .node-icon {
            margin-right: 4px;
            color: #999;
        }
        .menu-tree-container .tree-node .node-name {
            font-size: 14px;
        }
        .menu-tree-container .tree-node .node-permission {
            font-size: 12px;
            color: #999;
            margin-left: 8px;
        }
        .menu-tree-container .expand-btn {
            cursor: pointer;
            margin-right: 4px;
            color: #999;
            font-size: 12px;
            width: 16px;
            display: inline-block;
            text-align: center;
        }
        .menu-tree-container .expand-btn:hover {
            color: #333;
        }
    </style>
</head>
<body>
<div class="splayui-container">
    <div class="splayui-main">
        <div style="padding: 10px 15px; border-bottom: 1px solid #e6e6e6; background: #f8f8f8;">
            <div style="margin-bottom: 8px;">
                <label>
                    <input type="checkbox" id="js-expand-all"> 展开/折叠所有
                </label>
                <label style="margin-left: 15px;">
                    <input type="checkbox" id="js-check-all"> 全选/取消全选
                </label>
            </div>
        </div>
        <div class="menu-tree-container" id="js-menu-tree">
            <div style="text-align: center; padding: 30px; color: #999;">
                <i class="layui-icon layui-icon-loading layui-anim layui-anim-rotate layui-anim-loop"></i> 加载中...
            </div>
        </div>
        <div class="layui-form-item layui-hide">
            <div class="layui-input-block">
                <input id="js-role-id" type="hidden" value="${roleId}"/>
                <button id="js-submit" class="layui-btn" lay-submit lay-filter="js-submit-filter">确定</button>
            </div>
        </div>
    </div>
</div>
<script>
    layui.use(['form', 'util'], function () {
        var form = layui.form,
            util = layui.util;

        var roleId = $('#js-role-id').val();
        var allMenuData = [];
        var checkedMenuIds = [];

        // 加载菜单树
        function loadMenuTree() {
            $.ajax({
                url: '${request.contextPath}/admin/sys/role/menu-tree',
                type: 'POST',
                dataType: 'json',
                success: function (res) {
                    if (res.code === 0) {
                        allMenuData = res.data;
                        // 加载已分配的菜单ID
                        loadCheckedMenuIds();
                    } else {
                        $('#js-menu-tree').html('<div style="text-align:center;padding:30px;color:#999;">加载菜单失败</div>');
                    }
                },
                error: function () {
                    $('#js-menu-tree').html('<div style="text-align:center;padding:30px;color:#999;">加载菜单失败</div>');
                }
            });
        }

        // 加载已分配的菜单ID
        function loadCheckedMenuIds() {
            $.ajax({
                url: '${request.contextPath}/admin/sys/role/list-menu-ids',
                type: 'POST',
                data: {roleId: roleId},
                dataType: 'json',
                success: function (res) {
                    if (res.code === 0) {
                        checkedMenuIds = res.data || [];
                        renderMenuTree(allMenuData);
                    } else {
                        $('#js-menu-tree').html('<div style="text-align:center;padding:30px;color:#999;">加载权限数据失败</div>');
                    }
                },
                error: function () {
                    $('#js-menu-tree').html('<div style="text-align:center;padding:30px;color:#999;">加载权限数据失败</div>');
                }
            });
        }

        // 渲染菜单树
        function renderMenuTree(menuList) {
            var html = buildTreeHtml(menuList, true);
            $('#js-menu-tree').html(html);
            bindTreeEvents();
        }

        // 构建树HTML
        function buildTreeHtml(menuList, expanded) {
            if (!menuList || menuList.length === 0) {
                return '<div style="text-align:center;padding:20px;color:#999;">暂无菜单数据</div>';
            }
            var html = '<ul>';
            for (var i = 0; i < menuList.length; i++) {
                var item = menuList[i];
                var hasChild = item.children && item.children.length > 0;
                var isChecked = checkedMenuIds.indexOf(item.id) !== -1;
                var typeLabel = '';
                if (item.type === '0') typeLabel = '[目录]';
                else if (item.type === '1') typeLabel = '[菜单]';
                else if (item.type === '2') typeLabel = '[按钮]';

                html += '<li>';
                html += '<div class="tree-node" data-id="' + item.id + '" data-pid="' + (item.pid || '') + '">';
                if (hasChild) {
                    html += '<span class="expand-btn ' + (expanded ? 'expanded' : '') + '">' + (expanded ? '▼' : '▶') + '</span>';
                } else {
                    html += '<span class="expand-btn" style="visibility:hidden;">▶</span>';
                }
                html += '<input type="checkbox" class="menu-checkbox" value="' + item.id + '" ' + (isChecked ? 'checked' : '') + '>';
                html += '<span class="node-icon">' + (item.icon ? '<i class="fa ' + item.icon + '"></i>' : '') + '</span>';
                html += '<span class="node-name">' + typeLabel + ' ' + (item.name || '') + '</span>';

                html += '</div>';
                if (hasChild) {
                    html += '<div class="child-container" style="' + (expanded ? '' : 'display:none;') + '">';
                    html += buildTreeHtml(item.children, expanded);
                    html += '</div>';
                }
                html += '</li>';
            }
            html += '</ul>';
            return html;
        }

        // 绑定树事件
        function bindTreeEvents() {
            // 展开/折叠
            $('.expand-btn').off('click').on('click', function () {
                var $btn = $(this);
                var $childContainer = $btn.closest('li').find('> .child-container');
                if ($childContainer.is(':visible')) {
                    $childContainer.slideUp();
                    $btn.text('▶').removeClass('expanded');
                } else {
                    $childContainer.slideDown();
                    $btn.text('▼').addClass('expanded');
                }
            });

            // 复选框点击 - 级联选择子节点
            $('.menu-checkbox').off('change').on('change', function () {
                var $cb = $(this);
                var checked = $cb.is(':checked');
                var $li = $cb.closest('li');

                // 级联子节点
                $li.find('.menu-checkbox').prop('checked', checked);

                // 级联父节点
                cascadeParent($li);
            });
        }

        // 级联父节点选中状态
        function cascadeParent($li) {
            var $parentLi = $li.parent().closest('li');
            if ($parentLi.length === 0) return;

            var $parentCb = $parentLi.find('> .tree-node .menu-checkbox');
            var $siblingCbs = $parentLi.find('> .child-container .menu-checkbox');
            var allChecked = true;
            $siblingCbs.each(function () {
                if (!$(this).is(':checked')) {
                    allChecked = false;
                    return false;
                }
            });
            $parentCb.prop('checked', allChecked);
            cascadeParent($parentLi);
        }

        // 展开/折叠所有
        $('#js-expand-all').on('change', function () {
            var expand = $(this).is(':checked');
            if (expand) {
                $('.child-container').slideDown();
                $('.expand-btn').text('▼').addClass('expanded');
            } else {
                $('.child-container').slideUp();
                $('.expand-btn').text('▶').removeClass('expanded');
            }
        });

        // 全选/取消全选
        $('#js-check-all').on('change', function () {
            var checked = $(this).is(':checked');
            $('.menu-checkbox').prop('checked', checked);
        });

        // 监听提交
        form.on('submit(js-submit-filter)', function (data) {
            var menuIds = [];
            $('.menu-checkbox:checked').each(function () {
                menuIds.push($(this).val());
            });

            // 手动构建参数，确保Spring MVC能正确接收数组
            var postData = 'roleId=' + encodeURIComponent(roleId);
            for (var i = 0; i < menuIds.length; i++) {
                postData += '&menuIds=' + encodeURIComponent(menuIds[i]);
            }

            // 使用同步请求，确保spLayer能正确读取spChildFrameResult
            $.ajax({
                url: '${request.contextPath}/admin/sys/role/assign-menus',
                type: 'POST',
                async: false,
                data: postData,
                dataType: 'json',
                success: function (result) {
                    window.spChildFrameResult = result;
                },
                error: function () {
                    window.spChildFrameResult = {code: 1, msg: '系统错误，请联系管理员'};
                }
            });

            return false;
        });

        // 初始化加载
        loadMenuTree();
    });
</script>
</body>
</html>
