<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>库位列表</title>
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
                    <label class="layui-form-label">库位编号</label>
                    <div class="layui-input-inline">
                        <input type="text" name="locationCodeLike" autocomplete="off" class="layui-input">
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

<script>
    layui.use(['form', 'table', 'spTable'], function () {
        var form = layui.form,
            table = layui.table,
            spTable = layui.spTable;

        var tableIns = spTable.render({
            url: '${request.contextPath}/warehouse/location/page',
            where: {warehouseCode: '${warehouseCode}'},
            cols: [[
                {type: 'numbers', title: '序号'}
                , {field: 'locationCode', title: '库位编号', width: 150}
                , {field: 'warehouseCode', title: '所属库房编号', width: 130}
                , {field: 'warehouseName', title: '所属库房名称', width: 180}
                , {field: 'capacity', title: '库位容量', width: 110, templet: function (d) {
                        return d.capacity == null ? 0 : d.capacity;
                    }}
                , {field: 'remark', title: '备注', width: 220}
            ]],
            done: function (res, curr, count) {
            }
        });

        $(function () {
            form.render();
        });

        form.on('submit(js-search-filter)', function (data) {
            var where = data.field;
            where.warehouseCode = '${warehouseCode}';
            tableIns.reload({
                where: where,
                page: {curr: 1}
            });
            return false;
        });
    });
</script>
</body>
</html>
