<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>仓库管理</title>
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
                    <label class="layui-form-label">库房名称</label>
                    <div class="layui-input-inline">
                        <input type="text" name="warehouseNameLike" autocomplete="off" class="layui-input">
                    </div>
                </div>
                <div class="layui-inline">
                    <a class="layui-btn" lay-submit lay-filter="js-search-filter"><i
                                class="layui-icon layui-icon-search layuiadmin-button-btn"></i></a>
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
        <button class="layui-btn layui-btn-sm" lay-event="add"><i class="layui-icon">&#xe61f;</i>新建仓库</button>
        </@shiro.hasPermission>
    </div>
</script>

<!--行操作模板-->
<script type="text/html" id="js-record-table-toolbar-right">
    <a class="layui-btn layui-btn-xs layui-btn-normal" lay-event="location"><i class="layui-icon layui-icon-table"></i>库位</a>
    <a class="layui-btn layui-btn-xs" lay-event="edit"><i class="layui-icon layui-icon-edit"></i>编辑</a>
    <@shiro.hasPermission name="user:add"><a class="layui-btn layui-btn-danger layui-btn-xs" lay-event="delete"><i class="layui-icon layui-icon-delete"></i>删除</a></@shiro.hasPermission>
</script>

<script>
    layui.use(['form', 'table', 'spLayer', 'spTable'], function () {
        var form = layui.form,
            table = layui.table,
            spLayer = layui.spLayer,
            spTable = layui.spTable;

        var tableIns = spTable.render({
            url: '${request.contextPath}/warehouse/page',
            cols: [[
                {type: 'checkbox'}
                , {field: 'warehouseCode', title: '库房编号', width: 120}
                , {field: 'warehouseName', title: '库房名称', width: 180}
                , {field: 'capacity', title: '库房容量', width: 110, templet: function (d) {
                        return d.capacity == null ? 0 : d.capacity;
                    }}
                , {field: 'locationCount', title: '库位数量', width: 100, templet: function (d) {
                        return d.locationCount == null ? 0 : d.locationCount;
                    }}
                , {field: 'remark', title: '备注', width: 220}
                , {fixed: 'right', field: 'operate', title: '操作', toolbar: '#js-record-table-toolbar-right', unresize: true, width: 280}
            ]],
            done: function (res, curr, count) {
            }
        });

        $(function () {
            form.render();
        });

        form.on('submit(js-search-filter)', function (data) {
            tableIns.reload({
                where: data.field,
                page: {curr: 1}
            });
            return false;
        });

        table.on('toolbar(js-record-table-filter)', function (obj) {
            if (obj.event === 'add') {
                spLayer.open({
                    title: '新建仓库',
                    area: ['50%', '75%'],
                    content: '${request.contextPath}/warehouse/add-or-update-ui'
                });
            }
        });

        table.on('tool(js-record-table-filter)', function (obj) {
            var data = obj.data;

            if (obj.event === 'location') {
                // 查看该库房下的所有库位及容量
                spLayer.open({
                    title: '库位列表 - ' + data.warehouseCode + ' ' + data.warehouseName,
                    area: ['70%', '80%'],
                    spWhere: {warehouseCode: data.warehouseCode},
                    content: '${request.contextPath}/warehouse/location/list-ui'
                });
            }

            if (obj.event === 'edit') {
                spLayer.open({
                    title: '编辑仓库',
                    area: ['50%', '75%'],
                    spWhere: {id: data.id},
                    content: '${request.contextPath}/warehouse/add-or-update-ui'
                });
            }

            if (obj.event === 'delete') {
                layer.confirm('确认要删除该仓库吗？<br>将同步删除该库房下的所有库位，且编号可被回收复用。', function (index) {
                    spUtil.ajax({
                        url: '${request.contextPath}/warehouse/delete',
                        type: 'POST',
                        showLoading: true,
                        serializable: false,
                        data: {id: data.id},
                        success: function (res) {
                            tableIns.reload();
                            layer.close(index);
                        }
                    });
                });
            }
        });
    });
</script>
</body>
</html>
