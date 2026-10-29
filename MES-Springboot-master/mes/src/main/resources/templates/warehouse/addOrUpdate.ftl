<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/html">
<head>
    <meta charset="UTF-8">
    <title>维护仓库信息</title>
    <meta name="renderer" content="webkit">
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
    <meta name="viewport"
          content="width=device-width, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=0">
    <#include "${request.contextPath}/common/common.ftl">
</head>
<body>
<div class="splayui-container">
    <div class="splayui-main">
        <form class="layui-form" style="margin: 0 auto;max-width: 460px;padding-top: 30px;">
            <#if result?? && result.id??>
            <div class="layui-form-item">
                <div class="layui-inline">
                    <label for="js-warehouseCode" class="layui-form-label">库房编号</label>
                    <div class="layui-input-inline">
                        <input type="text" id="js-warehouseCode" name="warehouseCode" readonly
                               autocomplete="off" class="layui-input" value="${result.warehouseCode}">
                    </div>
                </div>
            </div>
            </#if>
            <div class="layui-form-item">
                <div class="layui-inline">
                    <label for="js-warehouseName" class="layui-form-label sp-required">库房名称</label>
                    <div class="layui-input-inline">
                        <input type="text" id="js-warehouseName" name="warehouseName" lay-verify="required"
                               autocomplete="off"
                               class="layui-input" value="${result.warehouseName}">
                    </div>
                </div>
            </div>
            <div class="layui-form-item">
                <div class="layui-inline">
                    <label for="js-capacity" class="layui-form-label sp-required">库房容量</label>
                    <div class="layui-input-inline">
                        <input type="number" id="js-capacity" name="capacity" lay-verify="required|capacity"
                               autocomplete="off" min="1" class="layui-input" value="${result.capacity}">
                    </div>
                </div>
            </div>
            <#if result?? && result.id??>
            <div class="layui-form-item">
                <div class="layui-inline">
                    <label class="layui-form-label">库位数量</label>
                    <div class="layui-input-inline">
                        <input type="text" readonly autocomplete="off" class="layui-input" value="${result.locationCount}">
                        <div style="color:#999;font-size:12px;">已创建的库位数量不可修改</div>
                    </div>
                </div>
            </div>
            <#else>
            <div class="layui-form-item">
                <div class="layui-inline">
                    <label for="js-locationCount" class="layui-form-label">库位数量</label>
                    <div class="layui-input-inline">
                        <input type="number" id="js-locationCount" name="locationCount" lay-verify="locationCount"
                               autocomplete="off" min="0" class="layui-input" value="0">
                        <div style="color:#999;font-size:12px;">必须为非负整数，留空默认为0；每个库位容量=库房容量÷库位数量（向下取整）</div>
                    </div>
                </div>
            </div>
            </#if>
            <div class="layui-form-item">
                <label class="layui-form-label">备注</label>
                <div class="layui-input-block">
                    <textarea placeholder="备注" name="remark" class="layui-textarea">${result.remark}</textarea>
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

        // 自定义校验：库房容量必须为正整数
        form.verify({
            capacity: function (value) {
                if (!/^[1-9]\d*$/.test(value)) {
                    return '库房容量必须为正整数';
                }
            },
            locationCount: function (value) {
                if (value === '' || value === null || value === undefined) {
                    return; // 留空默认为0
                }
                if (!/^\d+$/.test(value)) {
                    return '库位数量必须为整数且不能为负数';
                }
            }
        });

        form.on('submit(js-submit-filter)', function (data) {
            spUtil.submitForm({
                url: "${request.contextPath}/warehouse/add-or-update",
                data: data.field
            });
            return false;
        });
    });
</script>
</body>
</html>
