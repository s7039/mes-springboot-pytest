<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>选择物料</title>
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
                    <a class="layui-btn" lay-submit lay-filter="js-search-filter"><i
                                class="layui-icon layui-icon-search layuiadmin-button-btn"></i>搜索</a>
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
            id: 'materielTable',
            url: '${request.contextPath}/plan/work-order/material-search',
            cols: [[
                {type: 'numbers', title: '序号'}
                , {field: 'materiel', title: '物料编码', width: 200}
                , {field: 'materielDesc', title: '物料名称', width: 240}
                , {field: 'componentNotes', title: '备注', width: 260, templet: function (d) {
                        return d.componentNotes || '';
                    }}
            ]],
            page: true,
            limits: [10, 20, 50],
            done: function (res, curr, count) {
            }
        });

        $(function () {
            form.render();
        });

        // 搜索
        form.on('submit(js-search-filter)', function (data) {
            tableIns.reload({
                where: data.field,
                page: {curr: 1}
            });
            return false;
        });

        // 点击行选择物料并回填父页面（工单表单）
        table.on('row(js-record-table-filter)', function (obj) {
            var win = window.parent;
            if (win) {
                var doc = win.document;
                var codeInput = doc.getElementById('js-materielCode');
                var descInput = doc.getElementById('js-materielDesc');
                if (codeInput) {
                    codeInput.value = obj.data.materiel;
                    // 通知父页面物料已变化，联动加载工艺BOM下拉
                    codeInput.dispatchEvent(new Event('change', {bubbles: true}));
                }
                if (descInput) {
                    descInput.value = obj.data.materielDesc;
                }
                var index = win.layer.getFrameIndex(window.name);
                win.layer.close(index);
            }
        });
    });
</script>
</body>
</html>
