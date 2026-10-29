<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>流水管理</title>
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
                    <label class="layui-form-label">流水编号</label>
                    <div class="layui-input-inline">
                        <input type="text" name="flowCode" autocomplete="off" class="layui-input">
                    </div>
                </div>
                <div class="layui-inline">
                    <label class="layui-form-label">物料编码</label>
                    <div class="layui-input-inline">
                        <input type="text" name="materielCode" autocomplete="off" class="layui-input">
                    </div>
                </div>
                <div class="layui-inline">
                    <label class="layui-form-label">库房编号</label>
                    <div class="layui-input-inline">
                        <input type="text" name="warehouseCode" autocomplete="off" class="layui-input">
                    </div>
                </div>
                <div class="layui-inline">
                    <label class="layui-form-label">变动类型</label>
                    <div class="layui-input-inline">
                        <select name="changeType">
                            <option value="">全部</option>
                            <option value="IN">入库</option>
                            <option value="OUT">出库</option>
                        </select>
                    </div>
                </div>
                <div class="layui-inline">
                    <label class="layui-form-label">工单编号</label>
                    <div class="layui-input-inline">
                        <input type="text" name="orderCode" autocomplete="off" class="layui-input">
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
            url: '${request.contextPath}/warehouse/flow/page',
            cols: [[
                {type: 'numbers', title: '序号'}
                , {field: 'flowCode', title: '流水编号', width: 150}
                , {field: 'materielCode', title: '物料编码', width: 140}
                , {field: 'materielDesc', title: '物料名称', width: 160}
                , {field: 'warehouseCode', title: '库房编号', width: 110}
                , {field: 'locationCode', title: '库位编号', width: 120, templet: function (d) {
                        return d.locationCode ? d.locationCode : '<span style="color:#999;">仓库级</span>';
                    }}
                , {field: 'changeType', title: '变动类型', width: 90, templet: function (d) {
                        if (d.changeType === 'IN') {
                            return '<span style="color:green;">入库</span>';
                        }
                        return '<span style="color:red;">出库</span>';
                    }}
                , {field: 'changeQty', title: '变动数量', width: 100, templet: function (d) {
                        var qty = Number(d.changeQty);
                        if (qty > 0) {
                            return '<span style="color:green;">+' + qty + '</span>';
                        }
                        return '<span style="color:red;">' + qty + '</span>';
                    }}
                , {field: 'beforeQty', title: '变动前数量', width: 100}
                , {field: 'afterQty', title: '变动后数量', width: 100}
                , {field: 'orderCode', title: '工单编号', width: 150}
                , {field: 'remark', title: '备注', width: 140}
                , {field: 'createTime', title: '创建时间', width: 180}
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
    });
</script>
</body>
</html>
