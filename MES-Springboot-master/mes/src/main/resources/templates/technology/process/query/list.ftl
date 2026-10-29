<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>产品工艺查询</title>
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
                        <input type="text" name="materielCodeLike" autocomplete="off" class="layui-input">
                    </div>
                </div>
                <div class="layui-inline">
                    <label class="layui-form-label">物料名称</label>
                    <div class="layui-input-inline">
                        <input type="text" name="materielDescLike" autocomplete="off" class="layui-input">
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
    <a class="layui-btn layui-btn-xs layui-btn-normal" lay-event="detail"><i class="layui-icon layui-icon-app"></i>查看工艺</a>
</script>

<!--js逻辑-->
<script>
    layui.use(['form', 'table', 'spLayer', 'spTable'], function () {
        var form = layui.form,
            table = layui.table,
            spLayer = layui.spLayer,
            spTable = layui.spTable;

        var tableIns = spTable.render({
            url: '${request.contextPath}/technology/process/query/page',
            cols: [
                [{
                    type: 'radio'
                }, {
                    field: 'materielCode', title: '物料编码'
                }, {
                    field: 'materielDesc', title: '物料名称'
                }, {
                    field: 'bomCode', title: 'BOM编号'
                }, {
                    fixed: 'right',
                    field: 'operate',
                    title: '操作',
                    toolbar: '#js-record-table-toolbar-right',
                    unresize: true,
                    width: 120
                }]
            ],
            done: function (res, curr, count) {
            }
        });

        $(function () {
            form.render();
        });

        form.on('submit(js-search-filter)', function (data) {
            tableIns.reload({
                where: data.field,
                page: { curr: 1 }
            });
            return false;
        });

        table.on('tool(js-record-table-filter)', function (obj) {
            var data = obj.data;

            // 查看工艺明细
            if (obj.event === 'detail') {
                spLayer.open({
                    title: '产品工艺查询 - ' + data.materielDesc,
                    area: ['90%', '92%'],
                    spWhere: { id: data.id },
                    content: '${request.contextPath}/technology/process/query/detail-ui'
                });
            }
        });
    });
</script>
</body>
</html>
