<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>工艺内容编制</title>
    <meta name="renderer" content="webkit">
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
    <meta name="viewport"
          content="width=device-width, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=0">
    <#include "${request.contextPath}/common/common.ftl">
    <link rel="stylesheet" href="${request.contextPath}/js/layuimodule/step-lay/step.css" media="all">
    <style>
        .step-container { padding: 15px; }
        .step-content { min-height: 400px; padding: 20px 0; }
        .oper-list { display: flex; flex-wrap: wrap; gap: 10px; margin-bottom: 20px; }
        .oper-card {
            padding: 10px 18px;
            border: 2px solid #e6e6e6;
            border-radius: 6px;
            cursor: pointer;
            transition: all .2s;
            background: #fafafa;
            min-width: 120px;
            text-align: center;
        }
        .oper-card:hover { border-color: #5FB878; background: #f0f9f0; }
        .oper-card.active { border-color: #009688; background: #e8f8f5; font-weight: bold; }
        .oper-card .oper-level {
            display: block;
            font-size: 12px;
            color: #999;
            margin-bottom: 4px;
        }
        .oper-card .oper-name { font-size: 14px; }
        .oper-card .oper-status {
            display: inline-block;
            width: 8px; height: 8px;
            border-radius: 50%;
            margin-left: 6px;
        }
        .oper-card .oper-status.done { background: #5FB878; }
        .oper-card .oper-status.pending { background: #FFB800; }
        .oper-detail-form { background: #fff; padding: 20px; border-radius: 6px; border: 1px solid #e6e6e6; }
        .oper-detail-form .oper-info { margin-bottom: 15px; color: #666; }
        .oper-detail-form .oper-info span { margin-right: 20px; }
        .oper-detail-form .oper-info .label { color: #999; }
        .image-upload-area { display: flex; gap: 10px; flex-wrap: wrap; margin-top: 10px; }
        .image-upload-area .img-item {
            width: 120px; height: 120px;
            border: 1px solid #e6e6e6;
            border-radius: 4px;
            overflow: hidden;
            position: relative;
            background: #f8f8f8;
        }
        .image-upload-area .img-item img { width: 100%; height: 100%; object-fit: cover; }
        .image-upload-area .img-item .img-del {
            position: absolute;
            top: 2px; right: 2px;
            width: 20px; height: 20px;
            background: rgba(0,0,0,0.5);
            color: #fff;
            border-radius: 50%;
            text-align: center;
            line-height: 20px;
            cursor: pointer;
            font-size: 12px;
        }
        .image-upload-area .img-add {
            width: 120px; height: 120px;
            border: 2px dashed #e6e6e6;
            border-radius: 4px;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            color: #ccc;
            font-size: 32px;
            transition: all .2s;
        }
        .image-upload-area .img-add:hover { border-color: #009688; color: #009688; }
        .device-table { margin-top: 15px; }
        .nav-buttons { text-align: center; padding: 20px 0; }
        .nav-buttons .layui-btn { margin: 0 10px; }
        .step-item-title { font-size: 16px; font-weight: bold; margin-bottom: 15px; color: #333; }
        .material-checklist { margin-top: 15px; }
    </style>
</head>
<body>
<div class="splayui-container">
    <div class="splayui-main">
        <div class="step-container">
            <#-- 隐藏域 -->
            <input type="hidden" id="js-content-id" value="${(content.id)!}">
            <input type="hidden" id="js-process-id" value="${(process.id)!}">

            <#-- 工序选择卡片（所有步骤共享，每一步都可以选择工序进行编制） -->
            <div class="oper-list" id="js-oper-list">
                <#if items??>
                    <#list items as item>
                    <div class="oper-card" data-oper-id="${item.operId}" data-content-oper-id="${processItemToContentOperMap[item.id]!''}">
                        <span class="oper-level">L${item.bomLevel} ${item.materielItemDesc!}</span>
                        <span class="oper-name">${item.operDesc!}</span>
                        <span class="oper-status pending" id="js-status-${item.operId}"></span>
                    </div>
                    </#list>
                </#if>
            </div>

            <#-- 步骤条 -->
            <div id="stepForm">
                    <#-- 步骤1：作业工序内容 -->
                    <div>
                        <div class="step-content">
                            <div class="step-item-title">一、填写作业内容</div>

                            <#-- 当前工序详情 -->
                            <div class="oper-detail-form" id="js-oper-detail">
                                <div class="oper-info">
                                    <span><span class="label">当前工序：</span><strong id="js-current-oper-name">请选择工序</strong></span>
                                    <span><span class="label">BOM层次：</span><span id="js-current-bom-level">-</span></span>
                                    <span><span class="label">关联物料：</span><span id="js-current-materiel">-</span></span>
                                </div>
                                <div class="layui-form-item">
                                    <label class="layui-form-label">作业内容</label>
                                    <div class="layui-input-block">
                                        <textarea id="js-content-text" class="layui-textarea" style="min-height:200px;" placeholder="请填写该工序的作业工序内容..."></textarea>
                                    </div>
                                </div>
                                <div class="layui-form-item">
                                    <label class="layui-form-label">工序图片</label>
                                    <div class="layui-input-block">
                                        <button type="button" class="layui-btn layui-btn-sm layui-btn-normal" id="js-upload-btn">
                                            <i class="layui-icon layui-icon-upload"></i>上传图片
                                        </button>
                                        <div class="image-upload-area" id="js-image-area"></div>
                                    </div>
                                </div>
                                <div style="text-align:right;">
                                    <button class="layui-btn layui-btn-sm" id="js-save-oper-btn"><i class="layui-icon layui-icon-ok"></i>保存当前工序</button>
                                </div>
                            </div>
                        </div>
                    </div>

                    <#-- 步骤2：工装设备 -->
                    <div style="display:none;">
                        <div class="step-content">
                            <div class="step-item-title">二、工装设备配置</div>
                            <div style="margin-bottom:10px;">
                                <span style="color:#999;">当前工序：</span>
                                <strong id="js-device-current-oper">-</strong>
                                <input type="hidden" id="js-device-current-oper-id">
                            </div>
                            <table class="layui-hide" id="js-device-table" lay-filter="js-device-table-filter"></table>
                            <div style="margin-top:10px;text-align:right;">
                                <button class="layui-btn layui-btn-sm" id="js-device-add-btn"><i class="layui-icon layui-icon-add-1"></i>新增设备</button>
                            </div>
                        </div>
                    </div>

                    <#-- 步骤3：工序物料 -->
                    <div style="display:none;">
                        <div class="step-content">
                            <div class="step-item-title">三、工序使用物料</div>
                            <div style="margin-bottom:10px;">
                                <span style="color:#999;">当前工序：</span>
                                <strong id="js-material-current-oper">-</strong>
                            </div>
                            <table class="layui-hide" id="js-material-table" lay-filter="js-material-table-filter"></table>
                        </div>
                    </div>

                    <#-- 步骤4：完成 -->
                    <div style="display:none;">
                        <div class="step-content" style="text-align:center;padding-top:80px;">
                            <i class="layui-icon layui-icon-ok-circle" style="font-size:64px;color:#5FB878;"></i>
                            <h2 style="margin:20px 0;color:#333;">工艺内容编制即将完成</h2>
                            <p style="color:#999;margin-bottom:30px;">请确保已填写所有内容，确认无误后点击"完成编制"结束当前工艺编制</p>
    
                            <button class="layui-btn layui-btn-lg layui-btn-normal" id="js-complete-btn"><i class="layui-icon layui-icon-ok-circle"></i> 完成编制</button>
                        </div>
                    </div>
                </div>

            <div class="nav-buttons">
                <button class="layui-btn layui-btn-primary" id="js-prev-btn" style="display:none;"><i class="layui-icon layui-icon-left"></i> 上一步</button>
                <button class="layui-btn" id="js-next-btn">下一步 <i class="layui-icon layui-icon-right"></i></button>
            </div>
        </div>
    </div>
</div>

<script>
    layui.use(['form', 'upload', 'table', 'layer'], function () {
        var form = layui.form,
            upload = layui.upload,
            table = layui.table,
            layer = layui.layer,
            $ = layui.jquery;

        var contentId = $('#js-content-id').val();
        var currentOperId = null;
        var currentContentOperId = null;
        var currentStep = 0;
        var totalSteps = 4;
        var imageList = [];
        var step = null;

        // ============== 工序卡片选择 ==============
        function selectOper(operId) {
            currentOperId = operId;
            currentContentOperId = $('.oper-card[data-oper-id="' + operId + '"]').data('content-oper-id');

            $('.oper-card').removeClass('active');
            $('.oper-card[data-oper-id="' + operId + '"]').addClass('active');

            // 更新工序信息
            var card = $('.oper-card[data-oper-id="' + operId + '"]');
            $('#js-current-oper-name').text(card.find('.oper-name').text());
            $('#js-device-current-oper').text(card.find('.oper-name').text());
            $('#js-device-current-oper-id').val(currentContentOperId);
            $('#js-material-current-oper').text(card.find('.oper-name').text());

            // 加载工序内容
            loadOperContent(operId);

            // 同步刷新工装设备、工序物料表格（若已渲染）
            if (currentContentOperId) {
                try {
                    table.reload('js-device-table-id', {where: {contentOperId: currentContentOperId}});
                } catch (e) {
                }
                try {
                    table.reload('js-material-table-id', {where: {contentOperId: currentContentOperId}});
                } catch (e) {
                }
            }
        }

        function loadOperContent(operId) {
            var card = $('.oper-card[data-oper-id="' + operId + '"]');
            // BOM level 和物料信息从卡片的 data 属性获取
            var levelText = card.find('.oper-level').text();
            $('#js-current-bom-level').text(levelText);

            var matelText = levelText.replace(/L\d+\s*/, '');
            $('#js-current-materiel').text(matelText);

            // 加载工序内容
            $.ajax({
                url: '${request.contextPath}/technology/process/content/get-oper?id=' + currentContentOperId,
                type: 'GET',
                dataType: 'json',
                success: function (res) {
                    if (res.code === 0 && res.data) {
                        var oper = res.data;
                        $('#js-content-text').val(oper.contentText || '');
                        imageList = [];
                        try {
                            imageList = JSON.parse(oper.images || '[]');
                        } catch (e) {
                            imageList = [];
                        }
                        renderImages();

                        if (oper.status === '1') {
                            $('#js-status-' + operId).removeClass('pending').addClass('done');
                        } else {
                            $('#js-status-' + operId).removeClass('done').addClass('pending');
                        }
                    }
                }
            });
        }

        // ============== 图片 ==============
        function renderImages() {
            var area = $('#js-image-area');
            area.empty();
            $.each(imageList, function (i, url) {
                area.append(
                    '<div class="img-item">' +
                    '<div class="img-del" data-url="' + url + '">×</div>' +
                    '<img src="' + url + '" onerror="this.src=\'${request.contextPath}/image/default.png\'">' +
                    '</div>'
                );
            });
            area.append('<div class="img-add" id="js-img-add-trigger">+</div>');

            // 删除图片事件
            $('.img-del').on('click', function () {
                var url = $(this).data('url');
                imageList = $.grep(imageList, function (v) { return v !== url; });
                renderImages();
            });
        }

        // 上传图片（使用静态按钮）
        upload.render({
            elem: '#js-upload-btn',
            url: '${request.contextPath}/technology/process/content/upload-image',
            accept: 'images',
            size: 5120,
            field: 'file',
            done: function (res) {
                if (res.code === 0) {
                    imageList.push(res.data);
                    renderImages();
                    layer.msg('上传成功');
                } else {
                    layer.msg(res.msg || '上传失败');
                }
            }
        });

        // 动态"+"图标点击触发上传
        $(document).on('click', '#js-img-add-trigger', function () {
            $('#js-upload-btn').click();
        });

        // ============== 工序卡片点击 ==============
        $(document).on('click', '.oper-card', function () {
            selectOper($(this).data('oper-id'));
        });

        // ============== 保存工序 ==============
        $('#js-save-oper-btn').on('click', function () {
            if (!currentContentOperId) {
                layer.msg('请先选择工序');
                return;
            }
            var contentText = $('#js-content-text').val();
            spUtil.ajax({
                url: '${request.contextPath}/technology/process/content/save-oper',
                type: 'POST',
                showLoading: true,
                serializable: false,
                contentType: 'application/json',
                data: JSON.stringify({
                    id: currentContentOperId,
                    contentText: contentText,
                    images: JSON.stringify(imageList),
                    status: contentText ? '1' : '0'
                }),
                success: function () {
                    layer.msg('保存成功');
                    // 更新状态指示
                    if (contentText) {
                        $('#js-status-' + currentOperId).removeClass('pending').addClass('done');
                    }
                }
            });
        });

        // ============== 设备表格 ==============
        function loadDeviceTable(contentOperId) {
            if (!contentOperId) {
                layer.msg('请先选择工序');
                return;
            }
            if (table) {
                table.reload('js-device-table-id', {
                    where: { contentOperId: contentOperId },
                    url: '${request.contextPath}/technology/process/content/device-list'
                });
            }
        }

        var deviceTableIns = table.render({
            id: 'js-device-table-id',
            elem: '#js-device-table',
            url: '${request.contextPath}/technology/process/content/device-list',
            method: 'POST',
            where: { contentOperId: '' },
            cols: [[
                { field: 'deviceCode', title: '设备编号' },
                { field: 'deviceName', title: '设备名称' },
                { field: 'requiredQty', title: '需求数量' },
                { field: 'remark', title: '备注' },
                { fixed: 'right', title: '操作', width: 100, toolbar: '#js-device-toolbar' }
            ]],
            page: false,
            height: 300
        });

        // 设备行操作
        table.on('tool(js-device-table-filter)', function (obj) {
            if (obj.event === 'delete') {
                layer.confirm('确认删除该设备？', function (idx) {
                    spUtil.ajax({
                        url: '${request.contextPath}/technology/process/content/device-delete',
                        type: 'POST',
                        showLoading: true,
                        serializable: false,
                        data: { id: obj.data.id },
                        success: function () {
                            obj.del();
                            layer.close(idx);
                        }
                    });
                });
            }
        });

        // 新增设备
        $('#js-device-add-btn').on('click', function () {
            var contentOperId = $('#js-device-current-oper-id').val();
            if (!contentOperId) {
                layer.msg('请先在步骤一中选择工序');
                return;
            }

            // 加载所有设备供选择
            spUtil.ajax({
                url: '${request.contextPath}/technology/process/content/device-all',
                type: 'POST',
                showLoading: true,
                success: function (res) {
                    if (res.code === 0 && res.data) {
                        var html = '<div style="padding:20px;">';
                        html += '<table class="layui-table">';
                        html += '<thead><tr><th style="width:40px;"></th><th>设备编号</th><th>设备名称</th><th>需求数量</th></tr></thead><tbody>';
                        $.each(res.data, function (i, d) {
                            html += '<tr>';
                            html += '<td><input type="radio" name="selDevice" value="' + d.id + '" data-code="' + (d.deviceCode || '') + '" data-name="' + (d.deviceName || '') + '"></td>';
                            html += '<td>' + (d.deviceCode || '') + '</td>';
                            html += '<td>' + (d.deviceName || '') + '</td>';
                            html += '<td><input type="number" class="layui-input" id="js-device-qty-' + d.id + '" value="1" style="width:80px;height:30px;"></td>';
                            html += '</tr>';
                        });
                        html += '</tbody></table>';
                        html += '<div style="text-align:center;margin-top:15px;">';
                        html += '<button class="layui-btn" id="js-device-confirm-add">确认添加</button>';
                        html += '</div></div>';

                        var idx = layer.open({
                            title: '选择工装设备',
                            area: ['600px', '450px'],
                            type: 1,
                            content: html
                        });

                        $('#js-device-confirm-add').on('click', function () {
                            var selected = $('input[name="selDevice"]:checked');
                            if (selected.length === 0) {
                                layer.msg('请选择设备');
                                return;
                            }
                            var deviceId = selected.val();
                            var deviceCode = selected.data('code');
                            var deviceName = selected.data('name');
                            var qty = $('#js-device-qty-' + deviceId).val() || 1;

                            spUtil.ajax({
                                url: '${request.contextPath}/technology/process/content/device-add',
                                type: 'POST',
                                showLoading: true,
                                contentType: 'application/json',
                                data: JSON.stringify({
                                    contentId: contentId,
                                    contentOperId: contentOperId,
                                    deviceId: deviceId,
                                    deviceCode: deviceCode,
                                    deviceName: deviceName,
                                    requiredQty: parseInt(qty)
                                }),
                                success: function () {
                                    layer.close(idx);
                                    table.reload('js-device-table-id', {
                                        where: { contentOperId: contentOperId }
                                    });
                                }
                            });
                        });
                    }
                }
            });
        });

        // ============== 物料表格 ==============
        var materialTableIns = table.render({
            id: 'js-material-table-id',
            elem: '#js-material-table',
            url: '${request.contextPath}/technology/process/content/material-list',
            method: 'POST',
            where: { contentOperId: '' },
            cols: [[
                { field: 'materielCode', title: '物料编码' },
                { field: 'materielDesc', title: '物料名称' },
                { field: 'unit', title: '单位' },
                { field: 'requiredQty', title: '需求数量' }
            ]],
            page: false,
            height: 300
        });

        // ============== 步骤导航 ==============
        // 手动实现步骤导航（不使用step.js以避免兼容问题）
        var stepItems = [
            { title: '作业工序内容' },
            { title: '工装设备' },
            { title: '工序物料' },
            { title: '完成' }
        ];

        function renderStepBar() {
            var html = '<div style="display:flex;justify-content:center;margin-bottom:20px;">';
            $.each(stepItems, function (i, item) {
                var cls = i === currentStep ? 'active' : (i < currentStep ? 'done' : '');
                var icon = i < currentStep ? '&#xe605;' : (i === currentStep ? '&#xe63c;' : '&#xe621;');
                html += '<div style="text-align:center;flex:1;position:relative;">';
                if (i > 0) {
                    html += '<div style="position:absolute;top:14px;left:-50%;width:100%;height:2px;background:' + (i <= currentStep ? '#009688' : '#e6e6e6') + ';z-index:0;"></div>';
                }
                html += '<div style="width:30px;height:30px;border-radius:50%;background:' + (i <= currentStep ? '#009688' : '#e6e6e6') + ';color:#fff;line-height:30px;margin:0 auto;position:relative;z-index:1;font-size:14px;">' + icon + '</div>';
                html += '<div style="margin-top:6px;font-size:12px;color:' + (i <= currentStep ? '#009688' : '#999') + ';">' + item.title + '</div>';
                html += '</div>';
            });
            html += '</div>';
            return html;
        }

        function showStep(step) {
            currentStep = step;
            // 隐藏所有步骤内容
            $('#stepForm > div').hide();
            // 显示当前步骤
            $('#stepForm > div:eq(' + step + ')').show();

            // 更新步骤条（只保留一个）
            $('.step-bar').remove();
            $('#stepForm').before('<div class="step-bar">' + renderStepBar() + '</div>');

            // 按钮状态
            $('#js-prev-btn').toggle(step > 0);
            if (step >= totalSteps - 1) {
                $('#js-next-btn').hide();
            } else {
                $('#js-next-btn').show().html('下一步 <i class="layui-icon layui-icon-right"></i>');
            }

            // 步骤进入时刷新数据
            if (step === 1) {
                var operId = $('#js-device-current-oper-id').val();
                if (operId) {
                    table.reload('js-device-table-id', { where: { contentOperId: operId } });
                }
            }
            if (step === 2) {
                var operId2 = $('#js-device-current-oper-id').val();
                if (operId2) {
                    table.reload('js-material-table-id', { where: { contentOperId: operId2 } });
                }
            }
            if (step === 3) {
                renderSummary();
            }
        }

        // 汇总
        function renderSummary() {
            var html = '';
            $('.oper-card').each(function () {
                var name = $(this).find('.oper-name').text();
                var status = $(this).find('.oper-status').hasClass('done') ? '<span style="color:green;">已编制</span>' : '<span style="color:orange;">未编制</span>';
                html += '<tr><td>' + name + '</td><td>' + status + '</td></tr>';
            });
            $('#js-summary-tbody').html(html);
        }

        // 上一步
        $('#js-prev-btn').on('click', function () {
            if (currentStep > 0) {
                showStep(currentStep - 1);
            }
        });

        // 下一步
        $('#js-next-btn').on('click', function () {
            if (currentStep === 0) {
                // 验证是否有内容
                if (!currentOperId) {
                    layer.msg('请先选择一个工序');
                    return;
                }
            }
            if (currentStep < totalSteps - 1) {
                showStep(currentStep + 1);
            }
        });

        // ============== 完成编制 ==============
        $('#js-complete-btn').on('click', function () {
            layer.confirm('确认完成工艺内容编制？', function (idx) {
                spUtil.ajax({
                    url: '${request.contextPath}/technology/process/content/complete',
                    type: 'POST',
                    showLoading: true,
                    serializable: false,
                    data: { id: contentId },
                    success: function () {
                        layer.msg('工艺编制已完成', { icon: 1, time: 1500 }, function () {
                            var index = parent.layer.getFrameIndex(window.name);
                            parent.layer.close(index);
                        });
                    }
                });
            });
        });

        // ============== 初始化 ==============
        // 默认选中第一个工序
        var firstCard = $('.oper-card').first();
        if (firstCard.length > 0) {
            selectOper(firstCard.data('oper-id'));
        }

        // 初始显示步骤0
        showStep(0);

        <#if contentOpers??>
        // 更新已编制状态
        <#list contentOpers as oper>
        $('#js-status-${oper.operId}').removeClass('pending').addClass('done');
        </#list>
        </#if>
    });
</script>

<script type="text/html" id="js-device-toolbar">
    <@shiro.hasPermission name="user:add"><a class="layui-btn layui-btn-danger layui-btn-xs" lay-event="delete"><i class="layui-icon layui-icon-delete"></i>删除</a></@shiro.hasPermission>
</script>
</body>
</html>
