<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>物料需求</title>
    <meta name="renderer" content="webkit">
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
    <#include "${request.contextPath}/common/common.ftl">
</head>
<body>
<div class="splayui-container">
    <div class="splayui-main">
        <!--表格-->
        <table class="layui-hide" id="js-record-table" lay-filter="js-record-table-filter"></table>
    </div>
</div>

<script>
    layui.use(['table', 'spTable'], function () {
        var table = layui.table,
            spTable = layui.spTable;

        spTable.render({
            url: '${request.contextPath}/plan/work-order/requirement-page',
            where: {orderCode: '${orderCode}'},
            cols: [[
                {type: 'numbers', title: '序号'}
                , {field: 'materielCode', title: '物料编码', width: 170}
                , {field: 'materielDesc', title: '物料名称', width: 190}
                , {field: 'requiredQty', title: '需求数量(已锁定)', width: 140}
                , {field: 'unit', title: '单位', width: 80}
                , {field: 'warehouseCode', title: '库房编号', width: 120}
                , {field: 'locationCode', title: '库位编号', width: 130, templet: function (d) {
                        return d.locationCode ? d.locationCode : '<span style="color:#999;">仓库级</span>';
                    }}
                , {field: 'status', title: '状态', width: 90, templet: function (d) {
                        if (d.status === '02') {
                            return '<span style="color:green;">已发放</span>';
                        }
                        return '<span style="color:#ffa00d;">已锁定</span>';
                    }}
            ]]
        });
    });
</script>
</body>
</html>
