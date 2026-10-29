<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/html">
<head>
    <meta charset="UTF-8">
    <title>设备管理</title>
    <meta name="renderer" content="webkit">
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
    <meta name="viewport"
          content="width=device-width, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=0">
    <#include "${request.contextPath}/common/common.ftl">
</head>
<body>
<div class="splayui-container">
    <div class="splayui-main" style="padding: 15px;">
        <input type="hidden" id="js-group-id" value="${result.id}">

        <!--已关联设备-->
        <fieldset class="layui-elem-field layui-field-title" style="margin-top: 10px;">
            <legend>已关联设备</legend>
        </fieldset>
        <table class="layui-hide" id="js-group-device-table" lay-filter="js-group-device-table-filter"></table>

        <!--添加新设备-->
        <fieldset class="layui-elem-field layui-field-title" style="margin-top: 20px;">
            <legend>添加设备</legend>
        </fieldset>
        <div class="layui-form">
            <div class="layui-form-item">
                <div class="layui-inline">
                    <label class="layui-form-label">选择设备</label>
                    <div class="layui-input-inline" style="width: 300px;">
                        <select id="js-available-device" lay-verify="required" lay-filter="js-available-device-filter">
                            <option value="">请选择设备</option>
                        </select>
                    </div>
                    <div class="layui-inline">
                        <a class="layui-btn layui-btn-sm" id="js-add-device-btn"><i class="layui-icon">&#xe61f;</i>新增</a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<!--确定按钮触发隐藏的提交-->
<button id="js-submit" style="display:none;"></button>

<script>
    // 确定按钮：通知父窗口关闭弹窗
    $('#js-submit').on('click', function () {
        window.spChildFrameResult = {code: 0, msg: '操作成功'};
    });
</script>

<!--已关联设备行操作模板-->
<script type="text/html" id="js-record-table-toolbar-right">
    <a class="layui-btn layui-btn-danger layui-btn-xs" lay-event="remove"><i class="layui-icon layui-icon-delete"></i>移除</a>
</script>

<script>
    layui.use(['form', 'table', 'spLayer', 'layer'], function () {
        var form = layui.form,
            table = layui.table,
            spLayer = layui.spLayer,
            layer = layui.layer,
            $ = layui.$;

        var groupId = $('#js-group-id').val();

        // 渲染已关联设备表格
        var tableIns = table.render({
            elem: '#js-group-device-table',
            url: '${request.contextPath}/admin/sys/deviceGroup/group-device-page',
            method: 'POST',
            where: {groupId: groupId},
            cols: [[
                {type: 'radio'}
                , {field: 'deviceCode', title: '设备编号', width: 140}
                , {field: 'deviceName', title: '设备名称', width: 160}
                , {field: 'deviceType', title: '设备类型', width: 120}
                , {field: 'remark', title: '备注', width: 200}
                , {fixed: 'right', field: 'operate', title: '操作', toolbar: '#js-record-table-toolbar-right', unresize: true, width: 100}
            ]]
        });

        // 加载可用设备下拉
        function loadAvailableDevices() {
            spUtil.ajax({
                url: '${request.contextPath}/admin/sys/deviceGroup/available-device-page',
                type: 'POST',
                showLoading: false,
                serializable: false,
                data: {groupId: groupId},
                success: function (res) {
                    var html = '<option value="">请选择设备</option>';
                    if (res.data) {
                        for (var i = 0; i < res.data.length; i++) {
                            var d = res.data[i];
                            html += '<option value="' + d.id + '">' + d.deviceCode + ' - ' + d.deviceName + '</option>';
                        }
                    }
                    $('#js-available-device').html(html);
                    form.render('select');
                }
            });
        }
        loadAvailableDevices();

        // 新增设备到编组
        $('#js-add-device-btn').on('click', function () {
            var deviceId = $('#js-available-device').val();
            if (!deviceId) {
                layer.msg('请先选择设备');
                return;
            }

            spUtil.ajax({
                url: '${request.contextPath}/admin/sys/deviceGroup/add-device',
                type: 'POST',
                showLoading: true,
                serializable: false,
                data: {groupId: groupId, deviceId: deviceId},
                success: function (res) {
                    if (res.code === 0) {
                        layer.msg('添加成功');
                        tableIns.reload({where: {groupId: groupId}});
                        loadAvailableDevices();
                    } else {
                        layer.msg(res.msg || '添加失败', {icon: 5});
                    }
                }
            });
        });

        // 移除设备
        table.on('tool(js-group-device-table-filter)', function (obj) {
            var data = obj.data;
            if (obj.event === 'remove') {
                layer.confirm('确认要从该编组中移除设备【' + data.deviceCode + '】吗？', function (index) {
                    spUtil.ajax({
                        url: '${request.contextPath}/admin/sys/deviceGroup/remove-device',
                        type: 'POST',
                        showLoading: true,
                        serializable: false,
                        data: {groupId: groupId, deviceId: data.id},
                        success: function (res) {
                            layer.msg('移除成功');
                            tableIns.reload({where: {groupId: groupId}});
                            loadAvailableDevices();
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
