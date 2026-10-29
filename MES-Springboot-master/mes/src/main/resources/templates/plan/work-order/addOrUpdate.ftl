<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/html">
<head>
    <meta charset="UTF-8">
    <title>维护工单</title>
    <meta name="renderer" content="webkit">
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
    <meta name="viewport"
          content="width=device-width, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=0">
    <#include "${request.contextPath}/common/common.ftl">
</head>
<body>
<div class="splayui-container">
    <div class="splayui-main">
        <form class="layui-form" style="margin: 0 auto;max-width: 520px;padding-top: 25px;">
            <#if result?? && result.id??>
            <div class="layui-form-item">
                <div class="layui-inline">
                    <label class="layui-form-label">工单编号</label>
                    <div class="layui-input-inline">
                        <input type="text" name="orderCode" readonly autocomplete="off" class="layui-input" value="${result.orderCode}">
                    </div>
                </div>
            </div>
            </#if>
            <div class="layui-form-item">
                <div class="layui-inline">
                    <label for="js-materielCode" class="layui-form-label sp-required">物料编码</label>
                    <div class="layui-input-inline">
                        <input type="text" id="js-materielCode" name="materielCode" lay-verify="required"
                               autocomplete="off" class="layui-input" value="${result.materielCode}">
                    </div>
                    <button type="button" class="layui-btn layui-btn-normal" id="js-selectMateriel"><i class="layui-icon layui-icon-search"></i></button>
                </div>
            </div>
            <div class="layui-form-item">
                <div class="layui-inline">
                    <label class="layui-form-label">物料名称</label>
                    <div class="layui-input-inline">
                        <input type="text" id="js-materielDesc" name="materielDesc" readonly autocomplete="off"
                               class="layui-input" value="${result.materielDesc}">
                    </div>
                </div>
            </div>
            <div class="layui-form-item" id="js-bom-block" <#if result?? && result.orderType?? && result.orderType == "IN">style="display:none;"</#if><#if orderType?? && orderType == "IN">style="display:none;"</#if>>
                <div class="layui-inline">
                    <label class="layui-form-label">工艺BOM</label>
                    <div class="layui-input-inline">
                        <select name="bomId" id="js-bomId">
                            <option value="">不使用BOM（默认使用物料）</option>
                        </select>
                    </div>
                </div>
            </div>
            <div class="layui-form-item">
                <div class="layui-inline">
                    <label class="layui-form-label">工单类型</label>
                    <div class="layui-input-inline">
                        <input type="text" name="orderType" readonly autocomplete="off" class="layui-input"
                               value="<#if result?? && result.orderType??>${result.orderType}<#else>${orderType}</#if>">
                    </div>
                </div>
            </div>
            <div class="layui-form-item">
                <div class="layui-inline">
                    <label for="js-qty" class="layui-form-label sp-required">数量</label>
                    <div class="layui-input-inline">
                        <input type="number" id="js-qty" name="qty" lay-verify="required|qty"
                               autocomplete="off" min="1" class="layui-input" value="${result.qty}">
                    </div>
                </div>
            </div>
            <div class="layui-form-item" id="js-time-block" <#if result?? && result.orderType?? && result.orderType == "IN">style="display:none;"</#if><#if orderType?? && orderType == "IN">style="display:none;"</#if>>
                <div class="layui-inline">
                    <label class="layui-form-label">开始时间</label>
                    <div class="layui-input-inline">
                        <input type="text" id="js-startTime" name="startTimeStr" autocomplete="off" placeholder="yyyy-MM-dd"
                               class="layui-input" value="<#if startTimeStr??>${startTimeStr}<#else></#if>">
                    </div>
                </div>
            </div>
            <div class="layui-form-item" id="js-time-block-end" <#if result?? && result.orderType?? && result.orderType == "IN">style="display:none;"</#if><#if orderType?? && orderType == "IN">style="display:none;"</#if>>
                <div class="layui-inline">
                    <label class="layui-form-label">结束时间</label>
                    <div class="layui-input-inline">
                        <input type="text" id="js-endTime" name="endTimeStr" autocomplete="off" placeholder="yyyy-MM-dd"
                               class="layui-input" value="<#if endTimeStr??>${endTimeStr}<#else></#if>">
                    </div>
                </div>
            </div>
            <div class="layui-form-item" id="js-warehouse-block" <#if result?? && result.orderType?? && result.orderType == "OUT">style="display:none;"</#if><#if orderType?? && orderType == "OUT">style="display:none;"</#if>>
                <div class="layui-inline">
                    <label class="layui-form-label sp-required">库房编号</label>
                    <div class="layui-input-inline">
                        <select name="warehouseCode" id="js-warehouseCode" lay-filter="js-warehouse-filter" lay-verify="warehouseReq">
                            <option value="">请选择库房</option>
                        </select>
                    </div>
                </div>
            </div>
            <div class="layui-form-item" id="js-location-block" <#if result?? && result.orderType?? && result.orderType == "OUT">style="display:none;"</#if><#if orderType?? && orderType == "OUT">style="display:none;"</#if>>
                <div class="layui-inline">
                    <label class="layui-form-label">库位编号</label>
                    <div class="layui-input-inline">
                        <select name="locationCode" id="js-locationCode">
                            <option value="">（空）仓库级库存</option>
                        </select>
                    </div>
                </div>
            </div>
            <div class="layui-form-item">
                <label class="layui-form-label">备注</label>
                <div class="layui-input-block">
                    <textarea placeholder="备注" name="remark" class="layui-textarea">${result.remark}</textarea>
                </div>
            </div>
            <div class="layui-form-item layui-hide">
                <div class="layui-input-block">
                    <input id="js-id" name="id" value="${result.id}"/>
                    <input id="js-status" name="status" value="<#if result?? && result.status??>${result.status}<#else>01</#if>"/>
                    <button id="js-submit" class="layui-btn" lay-submit lay-filter="js-submit-filter">确定</button>
                </div>
            </div>
        </form>
    </div>
</div>

<script>
    layui.use(['form', 'util', 'laydate', 'spLayer'], function () {
        var form = layui.form,
            laydate = layui.laydate,
            spLayer = layui.spLayer,
            $ = layui.$;

        // 判断当前工单类型
        var currentOrderType = '<#if result?? && result.orderType??>${result.orderType}<#else>${orderType}</#if>';
        if (!currentOrderType) {
            currentOrderType = '${orderType}';
        }

        // 时间控件：出库工单仅需年月日，入库工单不需要时间（默认datetime兜底）
        var timeType = (currentOrderType === 'OUT') ? 'date' : 'datetime';
        laydate.render({elem: '#js-startTime', type: timeType, format: 'yyyy-MM-dd'});
        laydate.render({elem: '#js-endTime', type: timeType, format: 'yyyy-MM-dd'});

        // 自定义校验：数量必须为正整数
        form.verify({
            qty: function (value) {
                if (!/^[1-9]\d*$/.test(value)) {
                    return '数量必须为正整数';
                }
            },
            warehouseReq: function (value) {
                var type = $('input[name="orderType"]').val();
                if (type === 'IN' && !value) {
                    return '入库工单必须选择库房';
                }
            }
        });

        // 加载库房下拉（仅入库工单）
        if (currentOrderType === 'IN') {
            spUtil.ajax({
                url: '${request.contextPath}/warehouse/all-list',
                type: 'POST',
                showLoading: false,
                serializable: false,
                success: function (res) {
                    var html = '<option value="">请选择库房</option>';
                    var selectedWh = '${result.warehouseCode}';
                    $.each(res.data, function (i, item) {
                        var selected = (selectedWh && item.warehouseCode === selectedWh) ? 'selected' : '';
                        html += '<option value="' + item.warehouseCode + '" ' + selected + '>' + item.warehouseCode + ' - ' + item.warehouseName + '</option>';
                    });
                    $('#js-warehouseCode').html(html);
                    form.render('select');
                    // 回显库位
                    if (selectedWh) {
                        loadLocations(selectedWh, '${result.locationCode}');
                    }
                }
            });
        }

        // 库房切换时加载库位
        form.on('select(js-warehouse-filter)', function (data) {
            loadLocations(data.value, '');
        });

        function loadLocations(warehouseCode, selectedLocation) {
            spUtil.ajax({
                url: '${request.contextPath}/warehouse/location-list',
                type: 'POST',
                showLoading: false,
                serializable: false,
                data: {warehouseCode: warehouseCode},
                success: function (res) {
                    var html = '<option value="">（空）仓库级库存</option>';
                    $.each(res.data, function (i, item) {
                        var selected = (selectedLocation && item.locationCode === selectedLocation) ? 'selected' : '';
                        html += '<option value="' + item.locationCode + '" ' + selected + '>' + item.locationCode + '（容量' + (item.capacity == null ? 0 : item.capacity) + '）</option>';
                    });
                    $('#js-locationCode').html(html);
                    form.render('select');
                }
            });
        }

        // 选择物料（独立页面搜索选择）
        $('#js-selectMateriel').on('click', function () {
            spLayer.open({
                title: '选择物料',
                area: ['70%', '80%'],
                btn: [],
                content: '${request.contextPath}/plan/work-order/material-select-ui'
            });
        });

        // 出库工单：按物料加载可选的工艺BOM（多种BOM时供用户选择）
        function loadBomList(materielCode, selectedBomId) {
            if (currentOrderType !== 'OUT') {
                return;
            }
            var $bom = $('#js-bomId');
            if (!materielCode) {
                $bom.html('<option value="">不使用BOM（默认使用物料）</option>');
                form.render('select');
                return;
            }
            spUtil.ajax({
                url: '${request.contextPath}/plan/work-order/bom-list',
                type: 'POST',
                showLoading: false,
                serializable: false,
                data: {materielCode: materielCode},
                success: function (res) {
                    var list = res.data || [];
                    // 默认不使用BOM，即直接出库物料本身
                    var html = '<option value="">不使用BOM（默认使用物料）</option>';
                    $.each(list, function (i, item) {
                        var selected = (selectedBomId && item.id === selectedBomId) ? 'selected' : '';
                        html += '<option value="' + item.id + '" ' + selected + '>' + item.bomCode
                            + (item.materielDesc ? ' - ' + item.materielDesc : '') + '</option>';
                    });
                    $bom.html(html);
                    form.render('select');
                }
            });
        }

        // 物料编码变化：带出物料名称，并刷新工艺BOM下拉
        function onMaterielChanged() {
            var code = $('#js-materielCode').val();
            if (!code) {
                return;
            }
            spUtil.ajax({
                url: '${request.contextPath}/plan/work-order/material-detail',
                type: 'POST',
                showLoading: false,
                serializable: false,
                errNoTip: true,
                data: {materielCode: code},
                success: function (res) {
                    if (res.data) {
                        $('#js-materielDesc').val(res.data.materielDesc);
                    }
                }
            });
            loadBomList(code, '');
        }

        $('#js-materielCode').on('change', onMaterielChanged);

        // 编辑出库工单时回显已选工艺BOM
        if (currentOrderType === 'OUT') {
            loadBomList('${result.materielCode!}', '${result.bomId!}');
        }

        form.on('submit(js-submit-filter)', function (data) {
            spUtil.submitForm({
                url: "${request.contextPath}/plan/work-order/add-or-update",
                data: data.field
            });
            return false;
        });
    });
</script>
</body>
</html>
