<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>工序管理</title>
    <meta name="renderer" content="webkit">
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
    <meta name="viewport"
          content="width=device-width, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=0">
    <#include "${request.contextPath}/common/common.ftl">
</head>
<body>
<div class="splayui-container">
    <div class="splayui-main">
        <form class="layui-form splayui-form" lay-filter="js-form-filter">
            <div class="layui-row">
                <div class="layui-col-xs6 layui-col-sm6 layui-col-md10">
                    <#-- 工序编号（系统自动生成，新增时只读） -->
                    <div class="layui-form-item">
                        <label for="js-oper" class="layui-form-label sp-required">工序编号</label>
                        <div class="layui-input-inline">
                            <input type="text" id="js-oper" name="oper" lay-verify="required" autocomplete="off"
                                   class="layui-input" value="${result.oper!}" readonly
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

                    <#-- 工序名称 -->
                    <div class="layui-form-item">
                        <label for="js-operDesc" class="layui-form-label sp-required">工序名称</label>
                        <div class="layui-input-inline">
                            <input type="text" id="js-operDesc" name="operDesc" lay-verify="required"
                                   autocomplete="off" class="layui-input" value="${result.operDesc!}"
                                   placeholder="请输入工序名称">
                        </div>
                    </div>

                    <#-- 工时 -->
                    <div class="layui-form-item">
                        <label for="js-workingHours" class="layui-form-label sp-required">工时</label>
                        <div class="layui-input-inline">
                            <input type="number" id="js-workingHours" name="workingHours" lay-verify="required"
                                   autocomplete="off" class="layui-input" value="${result.workingHours!}" step="0.01" min="0"
                                   placeholder="0.00">
                        </div>
                        <div class="layui-form-mid layui-word-aux">单位：小时</div>
                    </div>

                    <#-- 制造周期 -->
                    <div class="layui-form-item">
                        <label for="js-manufacturingCycle" class="layui-form-label">制造周期</label>
                        <div class="layui-input-inline">
                            <input type="number" id="js-manufacturingCycle" name="manufacturingCycle"
                                   autocomplete="off" class="layui-input" value="${result.manufacturingCycle!}" step="0.01" min="0"
                                   placeholder="留空则默认等于工时">
                        </div>
                        <div class="layui-form-mid layui-word-aux">单位：小时，一般要大于工时</div>
                    </div>

                    <#-- 备注 -->
                    <div class="layui-form-item">
                        <label for="js-remark" class="layui-form-label">备注</label>
                        <div class="layui-input-inline">
                            <textarea id="js-remark" name="remark" autocomplete="off"
                                      class="layui-textarea" placeholder="选填" style="height:100px;">${result.remark!}</textarea>
                        </div>
                    </div>

                    <#-- 隐藏字段 -->
                    <div class="layui-form-item layui-hide">
                        <div class="layui-input-block">
                            <input id="js-id" name="id" value="${result.id!}"/>
                            <button id="js-submit-btn" class="layui-btn" lay-submit lay-filter="js-submit-filter">确定</button>
                        </div>
                    </div>
                </div>
            </div>

            <#-- 底部操作栏 -->
            <div class="layui-form-item" style="text-align:center; margin-top:20px;">
                <div class="layui-input-block" style="margin-left:0;">
                    <button type="button" class="layui-btn" lay-submit lay-filter="js-submit-filter">
                        <i class="layui-icon layui-icon-ok"></i> 确认保存
                    </button>
                    <button type="button" class="layui-btn layui-btn-primary" onclick="parent.layer.close(parent.layer.getFrameIndex(window.name));">
                        <i class="layui-icon layui-icon-close"></i> 取消
                    </button>
                </div>
            </div>
        </form>
    </div>
</div>
<script>
    layui.use(['form', 'layer'], function () {
        var form = layui.form;
        var isEdit = ${(result.id?? && result.id?length gt 0)?string('true', 'false')};

        // 新增时自动获取系统生成的工序编号
        if (!isEdit) {
            $.ajax({
                url: '${request.contextPath}/basedata/sp-oper/generate-code',
                type: 'GET',
                dataType: 'json',
                success: function (res) {
                    if (res.code === 0) {
                        $('#js-oper').val(res.data);
                    }
                }
            });
        }

        // 监听提交
        form.on('submit(js-submit-filter)', function (data) {
            var fieldData = data.field;
            // 制造周期为空时默认等于工时
            if (!fieldData.manufacturingCycle && fieldData.workingHours) {
                fieldData.manufacturingCycle = fieldData.workingHours;
            }
            spUtil.submitForm({
                url: '${request.contextPath}/basedata/sp-oper/add-or-update',
                data: fieldData,
                success: function (result) {
                    if (result.code === 0) {
                        var index = parent.layer.getFrameIndex(window.name);
                        parent.layer.close(index);
                        parent.layer.msg('保存成功', {icon: 1});
                    } else {
                        layer.msg(result.msg || '保存失败', {icon: 2});
                    }
                }
            });
            return false;
        });
    });
</script>
</body>
</html>
