<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/html">
<head>
    <meta charset="UTF-8">
    <title>班组编组管理</title>
    <meta name="renderer" content="webkit">
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
    <meta name="viewport"
          content="width=device-width, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=0">
    <#include "${request.contextPath}/common/common.ftl">
</head>
<body>
<div class="splayui-container">
    <div class="splayui-main" style="padding: 15px;">
        <input type="hidden" id="js-work-cell-id" value="${result.id}">

        <!--已关联班组-->
        <fieldset class="layui-elem-field layui-field-title" style="margin-top: 10px;">
            <legend>已关联班组</legend>
        </fieldset>
        <table class="layui-hide" id="js-work-cell-team-table" lay-filter="js-work-cell-team-table-filter"></table>

        <!--添加新班组-->
        <fieldset class="layui-elem-field layui-field-title" style="margin-top: 20px;">
            <legend>添加班组</legend>
        </fieldset>
        <div class="layui-form">
            <div class="layui-form-item">
                <div class="layui-inline">
                    <label class="layui-form-label">选择班组</label>
                    <div class="layui-input-inline" style="width: 300px;">
                        <select id="js-available-team" lay-verify="required" lay-filter="js-available-team-filter">
                            <option value="">请选择班组</option>
                        </select>
                    </div>
                    <div class="layui-inline">
                        <a class="layui-btn layui-btn-sm" id="js-add-team-btn"><i class="layui-icon">&#xe61f;</i>新增</a>
                    </div>
                </div>
            </div>
        </div>

        <!--已关联编组设备-->
        <fieldset class="layui-elem-field layui-field-title" style="margin-top: 30px;">
            <legend>已关联编组设备</legend>
        </fieldset>
        <table class="layui-hide" id="js-work-cell-group-table" lay-filter="js-work-cell-group-table-filter"></table>

        <!--添加编组设备-->
        <fieldset class="layui-elem-field layui-field-title" style="margin-top: 20px;">
            <legend>添加编组设备</legend>
        </fieldset>
        <div class="layui-form">
            <div class="layui-form-item">
                <div class="layui-inline">
                    <label class="layui-form-label">选择编组设备</label>
                    <div class="layui-input-inline" style="width: 300px;">
                        <select id="js-available-group" lay-verify="required" lay-filter="js-available-group-filter">
                            <option value="">请选择编组设备</option>
                        </select>
                    </div>
                    <div class="layui-inline">
                        <a class="layui-btn layui-btn-sm" id="js-add-group-btn"><i class="layui-icon">&#xe61f;</i>新增</a>
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

<!--已关联班组行操作模板-->
<script type="text/html" id="js-record-table-toolbar-right">
    <a class="layui-btn layui-btn-danger layui-btn-xs" lay-event="remove"><i class="layui-icon layui-icon-delete"></i>移除</a>
</script>

<!--已关联编组设备行操作模板-->
<script type="text/html" id="js-group-table-toolbar-right">
    <a class="layui-btn layui-btn-danger layui-btn-xs" lay-event="remove"><i class="layui-icon layui-icon-delete"></i>移除</a>
</script>

<script>
    layui.use(['form', 'table', 'spLayer', 'layer'], function () {
        var form = layui.form,
            table = layui.table,
            spLayer = layui.spLayer,
            layer = layui.layer,
            $ = layui.$;

        var workCellId = $('#js-work-cell-id').val();

        // 渲染已关联班组表格
        var teamTableIns = table.render({
            elem: '#js-work-cell-team-table',
            url: '${request.contextPath}/admin/sys/workCell/team-list',
            method: 'POST',
            where: {workCellId: workCellId},
            cols: [[
                {type: 'radio'}
                , {field: 'teamCode', title: '班组编号', width: 140}
                , {field: 'teamName', title: '班组名称', width: 160}
                , {field: 'createTime', title: '添加时间', width: 180}
                , {fixed: 'right', field: 'operate', title: '操作', toolbar: '#js-record-table-toolbar-right', unresize: true, width: 100}
            ]]
        });

        // 加载可用班组下拉
        function loadAvailableTeams() {
            spUtil.ajax({
                url: '${request.contextPath}/admin/sys/workCell/available-team-page',
                type: 'POST',
                showLoading: false,
                serializable: false,
                data: {workCellId: workCellId},
                success: function (res) {
                    var html = '<option value="">请选择班组</option>';
                    if (res.data) {
                        for (var i = 0; i < res.data.length; i++) {
                            var d = res.data[i];
                            html += '<option value="' + d.id + '">' + d.code + ' - ' + d.name + '</option>';
                        }
                    }
                    $('#js-available-team').html(html);
                    form.render('select');
                }
            });
        }
        loadAvailableTeams();

        // 新增班组到加工单元
        $('#js-add-team-btn').on('click', function () {
            var teamId = $('#js-available-team').val();
            if (!teamId) {
                layer.msg('请先选择班组');
                return;
            }

            spUtil.ajax({
                url: '${request.contextPath}/admin/sys/workCell/add-team',
                type: 'POST',
                showLoading: true,
                serializable: false,
                data: {workCellId: workCellId, teamId: teamId},
                success: function (res) {
                    if (res.code === 0) {
                        layer.msg('添加成功');
                        teamTableIns.reload({where: {workCellId: workCellId}});
                        loadAvailableTeams();
                    } else {
                        layer.msg(res.msg || '添加失败', {icon: 5});
                    }
                }
            });
        });

        // 移除班组
        table.on('tool(js-work-cell-team-table-filter)', function (obj) {
            var data = obj.data;
            if (obj.event === 'remove') {
                layer.confirm('确认要从该加工单元中移除班组【' + data.teamName + '】吗？', function (index) {
                    spUtil.ajax({
                        url: '${request.contextPath}/admin/sys/workCell/remove-team',
                        type: 'POST',
                        showLoading: true,
                        serializable: false,
                        data: {workCellId: workCellId, teamId: data.teamId},
                        success: function (res) {
                            layer.msg('移除成功');
                            teamTableIns.reload({where: {workCellId: workCellId}});
                            loadAvailableTeams();
                            layer.close(index);
                        }
                    });
                });
            }
        });

        // 渲染已关联编组设备表格
        var groupTableIns = table.render({
            elem: '#js-work-cell-group-table',
            url: '${request.contextPath}/admin/sys/workCell/device-group-list',
            method: 'POST',
            where: {workCellId: workCellId},
            cols: [[
                {type: 'radio'}
                , {field: 'groupCode', title: '编组设备代码', width: 140}
                , {field: 'groupName', title: '编组设备名称', width: 160}
                , {field: 'createTime', title: '添加时间', width: 180}
                , {fixed: 'right', field: 'operate', title: '操作', toolbar: '#js-group-table-toolbar-right', unresize: true, width: 100}
            ]]
        });

        // 加载可用编组设备下拉
        function loadAvailableGroups() {
            spUtil.ajax({
                url: '${request.contextPath}/admin/sys/workCell/available-device-group-page',
                type: 'POST',
                showLoading: false,
                serializable: false,
                data: {workCellId: workCellId},
                success: function (res) {
                    var html = '<option value="">请选择编组设备</option>';
                    if (res.data) {
                        for (var i = 0; i < res.data.length; i++) {
                            var d = res.data[i];
                            html += '<option value="' + d.id + '">' + d.groupCode + ' - ' + d.groupName + '</option>';
                        }
                    }
                    $('#js-available-group').html(html);
                    form.render('select');
                }
            });
        }
        loadAvailableGroups();

        // 新增编组设备到加工单元
        $('#js-add-group-btn').on('click', function () {
            var deviceGroupId = $('#js-available-group').val();
            if (!deviceGroupId) {
                layer.msg('请先选择编组设备');
                return;
            }

            spUtil.ajax({
                url: '${request.contextPath}/admin/sys/workCell/add-device-group',
                type: 'POST',
                showLoading: true,
                serializable: false,
                data: {workCellId: workCellId, deviceGroupId: deviceGroupId},
                success: function (res) {
                    if (res.code === 0) {
                        layer.msg('添加成功');
                        groupTableIns.reload({where: {workCellId: workCellId}});
                        loadAvailableGroups();
                    } else {
                        layer.msg(res.msg || '添加失败', {icon: 5});
                    }
                }
            });
        });

        // 移除编组设备
        table.on('tool(js-work-cell-group-table-filter)', function (obj) {
            var data = obj.data;
            if (obj.event === 'remove') {
                layer.confirm('确认要从该加工单元中移除编组设备【' + data.groupName + '】吗？', function (index) {
                    spUtil.ajax({
                        url: '${request.contextPath}/admin/sys/workCell/remove-device-group',
                        type: 'POST',
                        showLoading: true,
                        serializable: false,
                        data: {workCellId: workCellId, deviceGroupId: data.deviceGroupId},
                        success: function (res) {
                            layer.msg('移除成功');
                            groupTableIns.reload({where: {workCellId: workCellId}});
                            loadAvailableGroups();
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
