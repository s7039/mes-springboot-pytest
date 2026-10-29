<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>新增班组</title>
    <meta name="renderer" content="webkit">
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=0">
    <#include "${request.contextPath}/common/common.ftl">
</head>
<body>
<div class="splayui-container">
    <div class="splayui-main">
        <form class="layui-form splayui-form">
            <div class="layui-row">
                <div class="layui-col-xs6 layui-col-sm6 layui-col-md6">
                    <div class="layui-form-item">
                        <label for="js-code" class="layui-form-label sp-required">班组编号</label>
                        <div class="layui-input-inline">
                            <input type="text" id="js-code" name="code" autocomplete="off" class="layui-input" value="${(team.code)!}" readonly
                                   style="background:#f5f5f5; color:#666; font-weight:bold;">
                        </div>
                        <div class="layui-form-mid layui-word-aux">
                            <#if team.id?? && team.id?length gt 0>
                                <span style="color:green;">编辑状态，编号不可更改</span>
                            <#else>
                                <span style="color:#1E9FFF;">系统自动生成</span>
                            </#if>
                        </div>
                    </div>

                    <div class="layui-form-item">
                        <label for="js-name" class="layui-form-label sp-required">班组名称</label>
                        <div class="layui-input-inline">
                            <input type="text" id="js-name" name="name" lay-verify="required" autocomplete="off" class="layui-input" value="${(team.name)!}">
                        </div>
                    </div>

                    <div class="layui-form-item">
                        <label class="layui-form-label sp-required">状态</label>
                        <div class="layui-input-block" style="width: 310px;">
                            <input type="radio" name="isDeleted" value="0" title="正常"
                                   <#if team.isDeleted == "0" || !(team.isDeleted??)>checked</#if>>
                            <input type="radio" name="isDeleted" value="2" title="异常"
                                   <#if team.isDeleted == "2">checked</#if>>
                        </div>
                    </div>
                </div>

                <div class="layui-form-item layui-hide">
                    <div class="layui-input-block">
                        <input id="js-id" name="id" value="${(team.id)!}"/>
                        <button id="js-submit" class="layui-btn" lay-submit lay-filter="js-submit-filter">确定</button>
                    </div>
                </div>
            </div>
        </form>
    </div>
</div>
<script>
    layui.use(['form', 'util'], function () {
        var form = layui.form,
            util = layui.util;

        // 新增时自动获取系统生成的班组编号
        var isEdit = '${(team.id?? && team.id?length gt 0)?string("true", "false")}';
        if (isEdit === 'false') {
            $.ajax({
                url: '${request.contextPath}/admin/basedata/team/generate-code',
                type: 'GET',
                dataType: 'json',
                success: function (res) {
                    if (res.code === 0) {
                        $('#js-code').val(res.data);
                    }
                }
            });
        }

        //监听提交
        form.on('submit(js-submit-filter)', function (data) {
            spUtil.submitForm({
                url: "${request.contextPath}/admin/basedata/team/add-or-update",
                data: data.field
            });
            return false;
        });
    });
</script>
</body>
</html>
