<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/html">
<head>
    <meta charset="UTF-8">
    <title>维护设备信息</title>
    <meta name="renderer" content="webkit">
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
    <meta name="viewport"
          content="width=device-width, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=0">
    <#include "${request.contextPath}/common/common.ftl">
</head>
<body>
<div class="splayui-container">
    <div class="splayui-main">
        <form class="layui-form" style="margin: 0 auto;max-width: 460px;padding-top: 40px;">
            <div class="layui-form-item">
                <div class="layui-inline">
                    <label for="js-deviceCode" class="layui-form-label sp-required">设备编号</label>
                    <div class="layui-input-inline">
                        <input type="text" id="js-deviceCode" name="deviceCode" autocomplete="off"
                               class="layui-input" value="${result.deviceCode}" readonly
                               style="background:#f5f5f5; color:#666; font-weight:bold;">
                    </div>
                    <div class="layui-form-mid layui-word-aux">
                        <#if result.id?? && result.id?length gt 0>
                            <span style="color:green;">编辑状态，编号不可更改</span>
                        <#else>
                            <span style="color:#1E9FFF;">系统自动生成</span>
                        </#if>
                    </div>
                </div>
            </div>
            <div class="layui-form-item">
                <div class="layui-inline">
                    <label for="js-deviceName" class="layui-form-label sp-required">设备名称</label>
                    <div class="layui-input-inline">
                        <input type="text" id="js-deviceName" name="deviceName" lay-verify="required"
                               autocomplete="off"
                               class="layui-input" value="${result.deviceName}">
                    </div>
                </div>
            </div>
            <div class="layui-form-item">
                <div class="layui-inline">
                    <label for="js-deviceType" class="layui-form-label">设备类型</label>
                    <div class="layui-input-inline">
                        <input type="text" id="js-deviceType" name="deviceType" autocomplete="off"
                               class="layui-input" value="${result.deviceType}">
                    </div>
                </div>
            </div>
            <div class="layui-form-item">
                <label class="layui-form-label">备注</label>
                <div class="layui-input-block">
                    <textarea placeholder="备注" name="remark" class="layui-textarea">${result.remark}</textarea>
                </div>
            </div>
            <div class="layui-form-item">
                <label class="layui-form-label sp-required">状态</label>
                <div class="layui-input-block" style="width: 310px;">
                    <input type="radio" name="deleted" value="0" title="正常"
                           <#if result.deleted == "0" || !(result??)>checked</#if>>
                    <input type="radio" name="deleted" value="1" title="禁用"
                           <#if result.deleted == "1">checked</#if>>
                </div>
            </div>
            <div class="layui-form-item layui-hide">
                <div class="layui-input-block">
                    <input id="js-id" name="id" value="${result.id}"/>
                    <button id="js-submit" class="layui-btn" lay-submit
                            lay-filter="js-submit-filter">确定
                    </button>
                </div>
            </div>
        </form>
    </div>
</div>
<script>
    layui.use(['form', 'util', 'layer'], function () {
        var form = layui.form,
            layer = layui.layer;

        // 新增时自动获取系统生成的设备编号
        var isEdit = '${(result.id?? && result.id?length gt 0)?string("true", "false")}';
        if (isEdit === 'false') {
            $.ajax({
                url: '${request.contextPath}/admin/sys/device/generate-code',
                type: 'GET',
                dataType: 'json',
                success: function (res) {
                    if (res.code === 0) {
                        $('#js-deviceCode').val(res.data);
                    }
                }
            });
        }

        form.on('submit(js-submit-filter)', function (data) {
            spUtil.submitForm({
                url: "${request.contextPath}/admin/sys/device/add-or-update",
                data: data.field
            });
            return false;
        });
    });
</script>
</body>
</html>
