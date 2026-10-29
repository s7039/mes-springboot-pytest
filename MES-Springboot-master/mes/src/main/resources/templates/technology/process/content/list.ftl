<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>工艺内容编制</title>
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

<!--表格头操作模板-->
<script type="text/html" id="js-record-table-toolbar-top">
    <div class="layui-btn-container">
        <button class="layui-btn layui-btn-sm" lay-event="add"><i class="layui-icon">&#xe61f;</i>新增编制</button>
    </div>
</script>

<!--行操作模板-->
<script type="text/html" id="js-record-table-toolbar-right">
    <a class="layui-btn layui-btn-xs" lay-event="edit"><i class="layui-icon layui-icon-edit"></i>开始编制</a>
    <@shiro.hasPermission name="user:add"><a class="layui-btn layui-btn-danger layui-btn-xs" lay-event="delete"><i class="layui-icon layui-icon-delete"></i>删除</a></@shiro.hasPermission>
</script>

<script>
    layui.use(['form', 'table', 'spLayer', 'spTable'], function () {
        var form = layui.form,
            table = layui.table,
            spLayer = layui.spLayer,
            spTable = layui.spTable;

        var tableIns = spTable.render({
            url: '${request.contextPath}/technology/process/content/page',
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
                    field: 'status', title: '编制状态', templet: function (d) {
                        if (d.status === '1') {
                            return '<span style="color:green;"><i class="layui-icon layui-icon-ok-circle"></i> 已完成</span>';
                        }
                        return '<span style="color:orange;"><i class="layui-icon layui-icon-time"></i> 编制中</span>';
                    }
                }, {
                    fixed: 'right',
                    field: 'operate',
                    title: '操作',
                    toolbar: '#js-record-table-toolbar-right',
                    unresize: true,
                    width: 240
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

        // 新增编制 - 先选择工艺规划
        table.on('toolbar(js-record-table-filter)', function (obj) {
            if (obj.event === 'add') {
                // 加载已锁定的工艺规划列表供选择
                spUtil.ajax({
                    url: '${request.contextPath}/technology/process/content/available-process',
                    type: 'POST',
                    showLoading: true,
                    success: function (res) {
                        if (res.code === 0 && res.data) {
                            var html = '<div style="padding:20px;">';
                            html += '<div style="margin-bottom:10px;font-weight:bold;">选择要编制工艺内容的产品（工艺规划需已锁定）：</div>';
                            html += '<table class="layui-table">';
                            html += '<thead><tr><th style="width:40px;"></th><th>物料编码</th><th>物料名称</th><th>流程描述</th></tr></thead><tbody>';
                            $.each(res.data, function (i, p) {
                                html += '<tr>';
                                html += '<td><input type="radio" name="selProcess" value="' + p.id + '" data-code="' + p.materielCode + '" data-desc="' + p.materielDesc + '"></td>';
                                html += '<td>' + (p.materielCode || '') + '</td>';
                                html += '<td>' + (p.materielDesc || '') + '</td>';
                                html += '<td>' + (p.flowDesc || '') + '</td>';
                                html += '</tr>';
                            });
                            html += '</tbody></table>';
                            html += '<div style="text-align:center;margin-top:15px;">';
                            html += '<button class="layui-btn" id="js-start-compile-btn"><i class="layui-icon layui-icon-ok"></i> 确定编制</button>';
                            html += '</div></div>';

                            var idx = layer.open({
                                title: '选择工艺规划',
                                area: ['700px', '500px'],
                                type: 1,
                                content: html
                            });

                            $('#js-start-compile-btn').on('click', function () {
                                var selected = $('input[name="selProcess"]:checked');
                                if (selected.length === 0) {
                                    layer.msg('请选择一个工艺规划');
                                    return;
                                }
                                var processId = selected.val();
                                var matCode = selected.data('code');
                                var matDesc = selected.data('desc');
                                layer.close(idx);

                                // 开始编制
                                spUtil.ajax({
                                    url: '${request.contextPath}/technology/process/content/start',
                                    type: 'POST',
                                    showLoading: true,
                                    serializable: false,
                                    data: { processId: processId },
                                    success: function (res2) {
                                        if (res2.code === 0 && res2.data) {
                                            // 打开编制窗口
                                            spLayer.open({
                                                title: '工艺内容编制 - ' + matCode + ' ' + matDesc,
                                                area: ['90%', '92%'],
                                                btn: [],
                                                spWhere: { id: res2.data.id },
                                                content: '${request.contextPath}/technology/process/content/edit-ui'
                                            });
                                        }
                                    }
                                });
                            });
                        } else {
                            layer.msg('没有可编制的工艺规划，请先锁定工艺规划');
                        }
                    }
                });
            }
        });

        table.on('tool(js-record-table-filter)', function (obj) {
            var data = obj.data;

            if (obj.event === 'edit') {
                spLayer.open({
                    title: '工艺内容编制 - ' + data.materielDesc,
                    area: ['90%', '92%'],
                    btn: [],
                    spWhere: { id: data.id },
                    content: '${request.contextPath}/technology/process/content/edit-ui'
                });
            }

            if (obj.event === 'delete') {
                layer.confirm('确认要删除该工艺编制记录吗？', function (index) {
                    spUtil.ajax({
                        url: '${request.contextPath}/technology/process/content/delete',
                        type: 'POST',
                        showLoading: true,
                        serializable: false,
                        data: { id: data.id },
                        success: function () {
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
