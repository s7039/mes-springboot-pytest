<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>库存管理</title>
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
                    <label class="layui-form-label">物料编码</label>
                    <div class="layui-input-inline">
                        <input type="text" name="materielCode" autocomplete="off" class="layui-input">
                    </div>
                </div>
                <div class="layui-inline">
                    <label class="layui-form-label">物料名称</label>
                    <div class="layui-input-inline">
                        <input type="text" name="materielDesc" autocomplete="off" class="layui-input">
                    </div>
                </div>
                <div class="layui-inline">
                    <label class="layui-form-label">库房编号</label>
                    <div class="layui-input-inline">
                        <input type="text" name="warehouseCode" autocomplete="off" class="layui-input">
                    </div>
                </div>
                <div class="layui-inline">
                    <label class="layui-form-label">库位编号</label>
                    <div class="layui-input-inline">
                        <input type="text" name="locationCode" autocomplete="off" class="layui-input">
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

<!--行操作模板-->
<script type="text/html" id="js-record-table-toolbar-right">
    <@shiro.hasPermission name="user:add"><a class="layui-btn layui-btn-danger layui-btn-xs" lay-event="delete"><i class="layui-icon layui-icon-delete"></i>删除</a></@shiro.hasPermission>
</script>

<script>
    layui.use(['form', 'table', 'spTable'], function () {
        var form = layui.form,
            table = layui.table,
            spTable = layui.spTable;

        var tableIns = spTable.render({
            url: '${request.contextPath}/warehouse/inventory/page',
            cols: [[
                {field: 'materielCode', title: '物料编码', width: 150}
                , {field: 'materielDesc', title: '物料名称', width: 180}
                , {field: 'warehouseCode', title: '库房编号', width: 120}
                , {field: 'locationCode', title: '库位编号', width: 140, templet: function (d) {
                        return d.locationCode ? d.locationCode : '<span style="color:#999;">仓库级库存</span>';
                    }}
                , {field: 'qty', title: '实际库存数量', width: 120}
                , {field: 'lockedQty', title: '锁定数量(订单预占)', width: 150, templet: function (d) {
                        return d.lockedQty == null ? 0 : d.lockedQty;
                    }}
                , {field: 'availableQty', title: '可用数量', width: 110}
                , {field: 'version', title: '版本号', width: 80}
                , {field: 'updateTime', title: '更新时间', width: 180}
                , {fixed: 'right', field: 'operate', title: '操作', toolbar: '#js-record-table-toolbar-right', unresize: true, width: 90}
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

        table.on('tool(js-record-table-filter)', function (obj) {
            var data = obj.data;

            if (obj.event === 'delete') {
                layer.confirm('确认要删除该库存记录吗？（仅当实际与锁定数量均为0时允许）', function (index) {
                    spUtil.ajax({
                        url: '${request.contextPath}/warehouse/inventory/delete',
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
