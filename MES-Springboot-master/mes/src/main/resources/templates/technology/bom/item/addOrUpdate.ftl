<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>维护BOM子项</title>
    <meta name="renderer" content="webkit">
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
    <#include "${request.contextPath}/common/common.ftl">
</head>
<body>
<div class="splayui-container">
    <div class="splayui-main">
        <form class="layui-form" style="margin: 0 auto;max-width: 520px;padding-top: 40px;">
            <div class="layui-form-item">
                <label class="layui-form-label">子项类型</label>
                <div class="layui-input-block">
                    <input type="radio" name="itemType" value="0" title="单纯物料" lay-filter="item-type"
                           <#if (result.itemType!'0') != '1'>checked</#if>>
                    <input type="radio" name="itemType" value="1" title="物料BOM" lay-filter="item-type"
                           <#if (result.itemType!'0') == '1'>checked</#if>>
                </div>
            </div>
            <div class="layui-form-item">
                <label class="layui-form-label sp-required">子项物料</label>
                <div style="display: flex; flex-direction: row;">
                    <button type="button" id="js-search-btn" class="layui-btn" style="height:37px">
                        <i class="layui-icon layui-icon-search"></i>
                    </button>
                    <input id="js-materiel-item-code" name="materielItemCode" readonly="true" lay-verify="required"
                           placeholder="搜索物料" autocomplete="off"
                           value="${result.materielItemCode!}"
                           class="layui-input" style="width: 150px">
                    <input id="js-materiel-item-desc" readonly="true" name="materielItemDesc"
                           value="${result.materielItemDesc!}"
                           class="layui-input" style="width: 150px;margin-left: 5px">
                </div>
            </div>
            <div class="layui-form-item" id="js-ref-bom-item" style="display: none;">
                <label class="layui-form-label">引用BOM</label>
                <div style="display: flex; flex-direction: row;">
                    <input id="js-ref-bom-code" readonly="true" placeholder="未选择BOM"
                           value="${refBomCode!}"
                           class="layui-input" style="width: 150px">
                    <input type="hidden" id="js-ref-bom-id" name="refBomId" value="${result.refBomId!}">
                </div>
            </div>
            <div class="layui-form-item">
                <div class="layui-inline">
                    <label class="layui-form-label sp-required">用量</label>
                    <div class="layui-input-inline">
                        <input type="text" name="itemNum" lay-verify="required" autocomplete="off"
                               class="layui-input" value="${result.itemNum!}">
                    </div>
                </div>
            </div>
            <div class="layui-form-item">
                <div class="layui-inline">
                    <label class="layui-form-label sp-required">单位</label>
                    <div class="layui-input-inline">
                        <input type="text" name="itemUnit" lay-verify="required" autocomplete="off"
                               class="layui-input" value="${result.itemUnit!}">
                    </div>
                </div>
            </div>
            <div class="layui-form-item layui-hide">
                <div class="layui-input-block">
                    <input id="js-id" name="id" value="${result.id!}"/>
                    <input id="js-bom-head-id" name="bomHeadId" value="${result.bomHeadId!bomHeadId}"/>
                    <button id="js-submit" class="layui-btn" lay-submit lay-filter="js-submit-filter">确定</button>
                </div>
            </div>
        </form>
    </div>
</div>
<script>
    layui.use(['form', 'layer', 'spLayer'], function () {
        var form = layui.form,
            layer = layui.layer,
            spLayer = layui.spLayer;

        // 切换子项类型显示
        function toggleType(type, clear) {
            if (type === '1') {
                $('#js-ref-bom-item').show();
                $('#js-materiel-item-code').attr('placeholder', '搜索物料BOM');
            } else {
                $('#js-ref-bom-item').hide();
                $('#js-materiel-item-code').attr('placeholder', '搜索物料');
            }
            if (clear) {
                $('#js-ref-bom-id').val('');
                $('#js-ref-bom-code').val('');
                $('#js-materiel-item-code').val('');
                $('#js-materiel-item-desc').val('');
            }
        }

        // 初始化显示（编辑时保留已有数据，不清空）
        toggleType($('input[name="itemType"]:checked').val() || '0', false);

        form.on('radio(item-type)', function (data) {
            toggleType(data.value, true);
        });

        form.on('submit(js-submit-filter)', function (data) {
            spUtil.submitForm({
                url: "${request.contextPath}/technology/bom/item/add-or-update",
                data: data.field
            });
            return false;
        });

        // 搜索：单纯物料时选物料，物料BOM时选BOM
        $('#js-search-btn').click(function () {
            var type = $('input[name="itemType"]:checked').val() || '0';
            if (type === '1') {
                spLayer.open({
                    type: 2,
                    area: ['900px', '500px'],
                    reload: false,
                    content: '${request.contextPath}/admin/common/ui/searchPanelBom',
                    spCallback: function (result) {
                        if (result.code === 0 && result.data.length > 0) {
                            var bom = result.data[0];
                            $('#js-ref-bom-id').val(bom.id);
                            $('#js-ref-bom-code').val(bom.bomCode);
                            $('#js-materiel-item-code').val(bom.materielCode);
                            $('#js-materiel-item-desc').val(bom.materielDesc);
                        }
                    }
                });
            } else {
                spLayer.open({
                    type: 2,
                    area: ['900px', '500px'],
                    reload: false,
                    content: '${request.contextPath}/admin/common/ui/searchPanelMaterile',
                    spCallback: function (result) {
                        if (result.code === 0 && result.data.length > 0) {
                            $('#js-materiel-item-code').val(result.data[0].materiel);
                            $('#js-materiel-item-desc').val(result.data[0].materielDesc);
                        }
                    }
                });
            }
        });
    });
</script>
</body>
</html>
