<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>班组员工管理</title>
    <meta name="renderer" content="webkit">
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
    <#include "${request.contextPath}/common/common.ftl">
</head>
<body>
<div class="splayui-container">
    <div class="splayui-main">
        <!--查询参数-->
        <form id="js-search-form" class="layui-form" lay-filter="js-q-form-filter">
            <div class="layui-form-item">
                <div class="layui-inline">
                    <label class="layui-form-label">班组编号</label>
                    <div class="layui-input-inline">
                        <input type="text" name="code" autocomplete="off" class="layui-input">
                    </div>
                </div>
                <div class="layui-inline">
                    <label class="layui-form-label">班组名称</label>
                    <div class="layui-input-inline">
                        <input type="text" name="name" autocomplete="off" class="layui-input">
                    </div>
                </div>
                <div class="layui-inline">
                    <a class="layui-btn" lay-submit lay-filter="js-search-filter"><i class="layui-icon layui-icon-search"></i></a>
                </div>
            </div>
        </form>

        <!--表格-->
        <table class="layui-hide" id="js-record-table" lay-filter="js-record-table-filter"></table>
    </div>
</div>

<!--表格头操作模板-->
<script type="text/html" id="js-record-table-toolbar-top">
    <div class="layui-btn-container">
        <@shiro.hasPermission name="user:add">
        <button class="layui-btn layui-btn-danger layui-btn-sm" lay-event="deleteBatch">
            <i class="layui-icon">&#xe640;</i>批量删除
        </button>
        </@shiro.hasPermission>
        <@shiro.hasPermission name="user:add">
            <button class="layui-btn layui-btn-sm" lay-event="add"><i class="layui-icon">&#xe61f;</i>新增班组</button>
        </@shiro.hasPermission>
    </div>
</script>

<!--行操作模板-->
<script type="text/html" id="js-record-table-toolbar-right">
    <a class="layui-btn layui-btn-xs" lay-event="edit"><i class="layui-icon layui-icon-edit"></i>编辑</a>
    <@shiro.hasPermission name="user:add"><a class="layui-btn layui-btn-danger layui-btn-xs" lay-event="delete"><i class="layui-icon layui-icon-delete"></i>删除</a></@shiro.hasPermission>
    <a class="layui-btn layui-btn-normal layui-btn-xs" lay-event="teamUser"><i class="layui-icon layui-icon-user"></i>班组员工管理</a>
</script>

<!--js逻辑-->
<script>
    layui.use(['form', 'table', 'spLayer', 'spTable'], function () {
        var form = layui.form,
            table = layui.table,
            spLayer = layui.spLayer,
            spTable = layui.spTable;

        // 表格及数据初始化
        var tableIns = spTable.render({
            url: '${request.contextPath}/admin/basedata/team/page',
            cols: [
                [{
                    type: 'checkbox'
                }, {
                    field: 'code', title: '班组编号', width: 150
                }, {
                    field: 'name', title: '班组名称', width: 200
                }, {
                    field: 'isDeleted', title: '状态', width: 90, templet: function (d) {
                        return spConfig.isDeletedDict[d.isDeleted] || '正常';
                    }
                }, {
                    field: 'createTime', title: '创建时间', width: 180
                }, {
                    fixed: 'right', field: 'operate', title: '操作', toolbar: '#js-record-table-toolbar-right', unresize: true, width: 280
                }]
            ],
            done: function (res, curr, count) {
            }
        });

        /*
         * 数据表格中form表单元素是动态插入,所以需要更新渲染下
         */
        $(function () {
            form.render();
        });

        /**
         * 搜索按钮事件
         */
        form.on('submit(js-search-filter)', function (data) {
            tableIns.reload({
                where: data.field,
                page: {
                    curr: 1
                }
            });
            return false;
        });

        /**
         * 头工具栏事件
         */
        table.on('toolbar(js-record-table-filter)', function (obj) {
            // 批量删除
            if (obj.event === 'deleteBatch') {
                var checkStatus = table.checkStatus('js-record-table'),
                    data = checkStatus.data;
                if (data.length > 0) {
                    layer.confirm('确认要删除选中的' + data.length + '个班组吗？', function (index) {
                        var ids = data.map(function (item) {
                            return item.id;
                        }).join(',');
                        $.post('${request.contextPath}/admin/basedata/team/delete-batch', {ids: ids}, function (res) {
                            if (res.code === 0) {
                                layer.msg('删除成功');
                                tableIns.reload();
                            } else {
                                layer.msg(res.msg, {icon: 5});
                            }
                        });
                        layer.close(index);
                    });
                } else {
                    layer.msg('请先选择需要删除的数据！');
                }
            }

            // 新增班组
            if (obj.event === 'add') {
                spLayer.open({
                    title: '新增班组',
                    area: ['600px', '400px'],
                    content: '${request.contextPath}/admin/basedata/team/add-or-update-ui'
                });
            }
        });

        /**
         * 监听行工具事件
         */
        table.on('tool(js-record-table-filter)', function (obj) {
            var data = obj.data;

            // 编辑
            if (obj.event === 'edit') {
                spLayer.open({
                    title: '编辑班组',
                    area: ['600px', '400px'],
                    spWhere: {id: data.id},
                    content: '${request.contextPath}/admin/basedata/team/add-or-update-ui'
                });
            }

            // 删除
            if (obj.event === 'delete') {
                layer.confirm('确认要删除该班组吗？', function (index) {
                    spUtil.ajax({
                        url: '${request.contextPath}/admin/basedata/team/delete',
                        type: 'POST',
                        data: {id: data.id},
                        success: function (result) {
                            if (result.code === 0) {
                                layer.msg('删除成功');
                                tableIns.reload();
                            } else {
                                layer.msg(result.msg || '删除失败');
                            }
                        }
                    });
                    layer.close(index);
                });
            }

            // 班组员工管理
            if (obj.event === 'teamUser') {
                spLayer.open({
                    title: '班组员工管理 - ' + data.name,
                    area: ['800px', '600px'],
                    spWhere: {id: data.id},
                    content: '${request.contextPath}/admin/basedata/team/team-user-ui'
                });
            }
        });
    });
</script>
</body>
</html>
