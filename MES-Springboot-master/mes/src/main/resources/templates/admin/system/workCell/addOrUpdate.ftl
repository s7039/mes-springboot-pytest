<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/html">
<head>
    <meta charset="UTF-8">
    <title>维护加工单元</title>
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
                    <label for="js-workCellCode" class="layui-form-label sp-required">加工单元代码</label>
                    <div class="layui-input-inline">
                        <input type="text" id="js-workCellCode" name="workCellCode" autocomplete="off"
                               class="layui-input" value="${result.workCellCode}" readonly
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
                    <label for="js-workCellName" class="layui-form-label sp-required">加工单元名称</label>
                    <div class="layui-input-inline">
                        <input type="text" id="js-workCellName" name="workCellName" lay-verify="required"
                               autocomplete="off"
                               class="layui-input" value="${result.workCellName}">
                    </div>
                </div>
            </div>
            <div class="layui-form-item">
                <div class="layui-inline">
                    <label class="layui-form-label sp-required">加工单元类型</label>
                    <div class="layui-input-inline">
                        <select name="workCellType" lay-verify="required" autocomplete="off" class="layui-input">
                            <option value="">请选择</option>
                            <option value="加工中心" <#if result.workCellType == "加工中心">selected</#if>>加工中心</option>
                            <option value="生产线" <#if result.workCellType == "生产线">selected</#if>>生产线</option>
                            <option value="工作站" <#if result.workCellType == "工作站">selected</#if>>工作站</option>
                            <option value="装配线" <#if result.workCellType == "装配线">selected</#if>>装配线</option>
                        </select>
                    </div>
                </div>
            </div>
            <div class="layui-form-item">
                <div class="layui-inline">
                    <label for="js-standardCapacity" class="layui-form-label">标准产能（每小时）</label>
                    <div class="layui-input-inline">
                        <input type="number" id="js-standardCapacity" name="standardCapacity" autocomplete="off"
                               min="0" step="0.01" class="layui-input" value="${result.standardCapacity!}">
                    </div>
                </div>
            </div>
            <div class="layui-form-item">
                <label class="layui-form-label sp-required">是否有线边库</label>
                <div class="layui-input-block" style="width: 310px;">
                    <input type="radio" name="hasLineSideWarehouse" value="1" title="是"
                           <#if result.hasLineSideWarehouse == "1">checked</#if>>
                    <input type="radio" name="hasLineSideWarehouse" value="0" title="否"
                           <#if result.hasLineSideWarehouse == "0" || !(result.hasLineSideWarehouse??)>checked</#if>>
                </div>
            </div>
            <div class="layui-form-item">
                <label class="layui-form-label sp-required">状态</label>
                <div class="layui-input-block" style="width: 310px;">
                    <input type="radio" name="deleted" value="0" title="正常"
                           <#if result.deleted == "0" || !(result??)>checked</#if>>
                    <input type="radio" name="deleted" value="2" title="异常"
                           <#if result.deleted == "2">checked</#if>>
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

        // 新增时自动获取系统生成的加工单元代码
        var isEdit = '${(result.id?? && result.id?length gt 0)?string("true", "false")}';
        if (isEdit === 'false') {
            $.ajax({
                url: '${request.contextPath}/admin/sys/workCell/generate-code',
                type: 'GET',
                dataType: 'json',
                success: function (res) {
                    if (res.code === 0) {
                        $('#js-workCellCode').val(res.data);
                    }
                }
            });
        }

        form.on('submit(js-submit-filter)', function (data) {
            // 标准产能不能为负数
            var cap = parseFloat(data.field.standardCapacity);
            if (!isNaN(cap) && cap < 0) {
                layer.msg('标准产能不能为负数');
                return false;
            }
            spUtil.submitForm({
                url: "${request.contextPath}/admin/sys/workCell/add-or-update",
                data: data.field
            });
            return false;
        });
    });
</script>
</body>
</html>
