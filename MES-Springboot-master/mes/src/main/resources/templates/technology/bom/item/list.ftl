<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>BOM子项管理</title>
    <meta name="renderer" content="webkit">
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
    <#include "${request.contextPath}/common/common.ftl">
</head>
<body>
<div class="splayui-container">
    <div class="splayui-main">
        <input type="hidden" id="js-bom-head-id" value="${bomHeadId}">

        <!--表格-->
        <table class="layui-hide" id="js-record-table" lay-filter="js-record-table-filter"></table>
    </div>
</div>

<!--表格头操作模板-->
<script type="text/html" id="js-record-table-toolbar-top">
    <div class="layui-btn-container">
        <button class="layui-btn layui-btn-sm" lay-event="add"><i class="layui-icon">&#xe61f;</i>添加子项物料</button>
    </div>
</script>

<!--行操作模板-->
<script type="text/html" id="js-record-table-toolbar-right">
    <a class="layui-btn layui-btn-xs" lay-event="edit"><i class="layui-icon layui-icon-edit"></i>编辑</a>
    <@shiro.hasPermission name="user:add"><a class="layui-btn layui-btn-danger layui-btn-xs" lay-event="delete"><i class="layui-icon layui-icon-delete"></i>删除</a></@shiro.hasPermission>
</script>

<script>
    layui.use(['form', 'table', 'spLayer', 'spTable'], function () {
        var form = layui.form,
            table = layui.table,
            spLayer = layui.spLayer,
            spTable = layui.spTable;

        var bomHeadId = $('#js-bom-head-id').val();

        var tableIns = spTable.render({
            url: '${request.contextPath}/technology/bom/item/page',
            where: {bomHeadId: bomHeadId},
            cols: [[
                {type: 'radio'}
                , {field: 'materielItemCode', title: '子项物料编码', width: 150}
                , {field: 'materielItemDesc', title: '子项物料名称', width: 180}
                , {field: 'itemType', title: '类型', width: 100, templet: function (d) {
                    return d.itemType === '1' ? '物料BOM' : '物料';
                }}
                , {field: 'itemNum', title: '用量', width: 80}
                , {field: 'itemUnit', title: '单位', width: 70}
                , {fixed: 'right', field: 'operate', title: '操作', toolbar: '#js-record-table-toolbar-right', unresize: true, width: 150}
            ]],
            done: function (res, curr, count) {
            }
        });

        table.on('toolbar(js-record-table-filter)', function (obj) {
            if (obj.event === 'add') {
                spLayer.open({
                    title: '添加子项物料',
                    area: ['90%', '88%'],
                    spWhere: {bomHeadId: bomHeadId},
                    content: '${request.contextPath}/technology/bom/item/add-or-update-ui'
                });
            }
        });

        table.on('tool(js-record-table-filter)', function (obj) {
            var data = obj.data;

            if (obj.event === 'edit') {
                spLayer.open({
                    title: '编辑子项物料',
                    area: ['90%', '88%'],
                    spWhere: {id: data.id},
                    content: '${request.contextPath}/technology/bom/item/add-or-update-ui'
                });
            }

            if (obj.event === 'delete') {
                layer.confirm('确认要删除该子项物料吗？', function (index) {
                    spUtil.ajax({
                        url: '${request.contextPath}/technology/bom/item/delete',
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
