<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>设备管理</title>
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
                    <label class="layui-form-label">设备编号</label>
                    <div class="layui-input-inline">
                        <input type="text" name="deviceCodeLike" autocomplete="off" class="layui-input">
                    </div>
                </div>
                <div class="layui-inline">
                    <label class="layui-form-label">设备名称</label>
                    <div class="layui-input-inline">
                        <input type="text" name="deviceNameLike" autocomplete="off" class="layui-input">
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
        <button class="layui-btn layui-btn-danger layui-btn-sm" lay-event="deleteBatch">
            <i class="layui-icon">&#xe640;</i>批量删除
        </button>
        </@shiro.hasPermission>
        <button class="layui-btn layui-btn-sm" lay-event="add"><i class="layui-icon">&#xe61f;</i>新增设备</button>
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

        var tableIns = spTable.render({
            url: '${request.contextPath}/admin/sys/device/page',
            cols: [[
                {type: 'checkbox'}
                , {field: 'deviceCode', title: '设备编号', width: 140}
                , {field: 'deviceName', title: '设备名称', width: 160}
                , {field: 'deviceType', title: '设备类型', width: 120}
                , {field: 'remark', title: '备注', width: 200}
                , {field: 'deleted', title: '状态', width: 80, templet: function (d) {
                        return (spConfig.deviceStatusDict && spConfig.deviceStatusDict[d.deleted]) || '正常';
                    }}
                , {fixed: 'right', field: 'operate', title: '操作', toolbar: '#js-record-table-toolbar-right', unresize: true, width: 150}
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
                    title: '新增设备',
                    area: ['60%', '80%'],
                    content: '${request.contextPath}/admin/sys/device/add-or-update-ui'
                });
            }

            if (obj.event === 'deleteBatch') {
                var checkStatus = table.checkStatus('js-record-table'),
                    data = checkStatus.data;
                if (data.length > 0) {
                    layer.confirm('确认要删除选中的' + data.length + '台设备吗？', function (index) {
                        var ids = data.map(function (item) {
                            return item.id;
                        }).join(',');
                        $.post('${request.contextPath}/admin/sys/device/delete-batch', {ids: ids}, function (res) {
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
        });

        table.on('tool(js-record-table-filter)', function (obj) {
            var data = obj.data;

            if (obj.event === 'edit') {
                spLayer.open({
                    title: '编辑设备',
                    area: ['60%', '80%'],
                    spWhere: {id: data.id},
                    content: '${request.contextPath}/admin/sys/device/add-or-update-ui'
                });
            }

            if (obj.event === 'delete') {
                layer.confirm('确认要删除该设备吗？', function (index) {
                    spUtil.ajax({
                        url: '${request.contextPath}/admin/sys/device/delete',
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
