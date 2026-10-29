<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>编辑工艺规划</title>
    <meta name="renderer" content="webkit">
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
    <meta name="viewport"
          content="width=device-width, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=0">
    <#include "${request.contextPath}/common/common.ftl">
    <style>
        .bom-tree-container {
            padding: 10px;
            background: #f8f8f8;
            border-radius: 4px;
            min-height: 200px;
        }
        .bom-tree-container ul {
            list-style: none;
            padding-left: 20px;
        }
        .bom-tree-container ul:first-child {
            padding-left: 0;
        }
        .bom-tree-container li {
            margin: 5px 0;
            padding: 8px 12px;
            background: #fff;
            border: 1px solid #e6e6e6;
            border-radius: 4px;
            position: relative;
        }
        .bom-tree-container li .node-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            flex-wrap: wrap;
            gap: 8px;
        }
        .bom-tree-container li .node-info {
            display: flex;
            align-items: center;
            gap: 10px;
            flex-wrap: wrap;
        }
        .bom-tree-container li .node-info .level-tag {
            display: inline-block;
            padding: 1px 8px;
            border-radius: 10px;
            font-size: 12px;
            font-weight: bold;
        }
        .bom-tree-container li .node-info .level-tag.level-0 {
            background: #1E9FFF;
            color: #fff;
        }
        .bom-tree-container li .node-info .level-tag.level-1 {
            background: #5FB878;
            color: #fff;
        }
        .bom-tree-container li .node-info .level-tag.level-2 {
            background: #FFB800;
            color: #fff;
        }
        .bom-tree-container li .node-info .level-tag.level-3 {
            background: #FF5722;
            color: #fff;
        }
        .bom-tree-container li .node-info .level-tag.level-4 {
            background: #9F7BEF;
            color: #fff;
        }
        .bom-tree-container li .node-info .level-tag.level-5 {
            background: #FF6EB4;
            color: #fff;
        }
        .bom-tree-container li .oper-select {
            min-width: 150px;
        }
        .bom-tree-container li .parent-oper-info {
            font-size: 12px;
            color: #888;
            margin-left: 10px;
        }
        .selected-flow-info {
            background: #f0f9f0;
            border: 1px solid #5FB878;
            padding: 10px 15px;
            border-radius: 4px;
            margin: 10px 0;
        }
        .selected-flow-info .flow-timeline {
            color: #5FB878;
            font-weight: bold;
        }
        .flow-select-container {
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .lock-notice {
            color: #FF5722;
            font-weight: bold;
            padding: 5px 10px;
            background: #fff3f0;
            border: 1px solid #FF5722;
            border-radius: 4px;
            margin-bottom: 10px;
        }
    </style>
</head>
<body>
<div class="splayui-container">
    <div class="splayui-main">
        <form class="layui-form splayui-form" lay-filter="js-process-form">
            <#-- 锁定提示 -->
            <#if process?? && process.locked == '1'>
            <div class="lock-notice">
                <i class="layui-icon layui-icon-lock"></i> 该产品工艺规划已锁定，无法编辑
            </div>
            </#if>

            <#-- 隐藏域 -->
            <input type="hidden" id="js-id" name="id" value="${(process.id)!}">

            <#-- 第一行：选择BOM和流程 -->
            <div class="layui-form-item">
                <div class="layui-inline" style="width: 45%;">
                    <label class="layui-form-label sp-required">选择产品</label>
                    <div class="layui-input-inline" style="width: 70%;">
                        <select id="js-bom-select" name="bomId" lay-filter="js-bom-filter" <#if process?? && process.locked == '1'>disabled</#if>>
                            <option value="">请选择产品（BOM）</option>
                            <#if process?? && process.bomId??>
                                <option value="${process.bomId}" selected>${process.materielCode} - ${process.materielDesc}</option>
                            </#if>
                        </select>
                    </div>
                    <input type="hidden" id="js-bom-code" name="bomCode" value="${(process.bomCode)!}">
                    <input type="hidden" id="js-materiel-code" name="materielCode" value="${(process.materielCode)!}">
                    <input type="hidden" id="js-materiel-desc" name="materielDesc" value="${(process.materielDesc)!}">
                </div>
                <div class="layui-inline" style="width: 45%;">
                    <label class="layui-form-label sp-required">选择路线</label>
                    <div class="layui-input-inline" style="width: 70%;">
                        <select id="js-flow-select" name="flowId" lay-filter="js-flow-filter" <#if process?? && process.locked == '1'>disabled</#if>>
                            <option value="">请选择工艺路线</option>
                            <#if flowList??>
                                <#list flowList as flow>
                                <option value="${flow.id}" data-flow="${flow.flow}" data-flow-desc="${flow.flowDesc}" data-process="${flow.process!}"
                                    <#if process?? && process.flowId == flow.id>selected</#if>>${flow.flow} - ${flow.flowDesc}</option>
                                </#list>
                            </#if>
                        </select>
                    </div>
                    <input type="hidden" id="js-flow" name="flow" value="${(process.flow)!}">
                    <input type="hidden" id="js-flow-desc" name="flowDesc" value="${(process.flowDesc)!}">
                </div>
            </div>

            <#-- 已选流程信息展示 -->
            <div class="layui-form-item" id="js-flow-info-container" style="<#if !(process?? && process.flowId??)>display:none;</#if>">
                <div class="layui-inline" style="width: 92%;">
                    <label class="layui-form-label">路线时序</label>
                    <div class="layui-input-inline selected-flow-info" style="width: 80%;">
                        已选路线：<strong id="js-flow-desc-display">${(process.flowDesc)!}</strong>
                        <span id="js-flow-process-display" class="flow-timeline">${(process.flowDesc)!}</span>
                    </div>
                </div>
            </div>

            <#-- BOM结构树 + 工序分配区域 -->
            <div class="layui-form-item">
                <fieldset class="layui-elem-field layui-field-title">
                    <legend>产品BOM结构与工序分配</legend>
                </fieldset>
                <div class="bom-tree-container" id="js-bom-tree-container">
                    <div style="text-align:center; padding:40px; color:#aaa;">
                        <i class="layui-icon layui-icon-app" style="font-size:48px;"></i>
                        <p style="margin-top:10px;">请先在上方选择产品（BOM）</p>
                    </div>
                </div>
            </div>

            <#-- 提交按钮（隐藏，由弹层确定按钮触发） -->
            <div class="layui-form-item layui-hide">
                <div class="layui-input-block">
                    <#if !(process?? && process.locked == '1')>
                    <button id="js-submit" class="layui-btn" lay-submit lay-filter="js-submit-filter">
                        <i class="layui-icon layui-icon-ok"></i>保存
                    </button>
                    <#else>
                    <button id="js-submit" class="layui-btn layui-btn-disabled" disabled lay-submit lay-filter="js-submit-filter"><i class="layui-icon layui-icon-lock"></i>已锁定，无法保存</button>
                    </#if>
                </div>
            </div>
        </form>
    </div>
</div>

<script>
    layui.use(['form', 'jquery', 'layer', 'util'], function () {
        var form = layui.form,
            $ = layui.jquery,
            layer = layui.layer,
            util = layui.util;

        // 存储已加载的工序数据
        var processItemsData = [];

        <#if items?? && items?size gt 0>
        // 从后端加载已保存的工序数据
        processItemsData = [
            <#list items as item>
            {
                id: '${item.id!}',
                processId: '${item.processId!}',
                parentId: '${item.parentId!}',
                bomItemId: '${item.bomItemId!}',
                bomLevel: ${item.bomLevel!0},
                materielItemCode: '${item.materielItemCode!}',
                materielItemDesc: '${item.materielItemDesc!}',
                operId: '${item.operId!}',
                oper: '${item.oper!}',
                operDesc: '${item.operDesc!}',
                sortNum: ${item.sortNum!0}
            }<#sep>,</#sep>
            </#list>
        ];
        </#if>

        // =============== BOM选择 ===============
        // 加载BOM列表
        function loadBomList() {
            spUtil.ajax({
                url: '${request.contextPath}/technology/process/plan/bom-list',
                type: 'POST',
                async: false,
                showLoading: false,
                serializable: false,
                success: function (res) {
                    if (res.code === 0 && res.data) {
                        var select = $('#js-bom-select');
                        select.empty();
                        select.append('<option value="">请选择产品（BOM）</option>');
                        $.each(res.data, function (i, bom) {
                            var selected = (bom.id === '${(process.bomId)!}') ? 'selected' : '';
                            select.append('<option value="' + bom.id + '" data-bom-code="' + bom.bomCode + '" data-materiel-code="' + bom.materielCode + '" data-materiel-desc="' + bom.materielDesc + '" ' + selected + '>' + bom.materielCode + ' - ' + bom.materielDesc + '</option>');
                        });
                        form.render('select');

                        // 编辑时自动加载BOM树
                        <#if process?? && process.bomId??>
                        var bomId = '${process.bomId}';
                        if (bomId) {
                            loadBomTree(bomId);
                        }
                        </#if>
                    }
                }
            });
        }

        // 加载BOM树
        function loadBomTree(bomId) {
            if (!bomId) return;

            spUtil.ajax({
                url: '${request.contextPath}/technology/bom/tree',
                type: 'POST',
                async: true,
                showLoading: true,
                serializable: false,
                data: {bomId: bomId},
                success: function (res) {
                    if (res.code === 0 && res.data) {
                        renderBomTree(res.data);
                    } else {
                        $('#js-bom-tree-container').html('<div style="text-align:center; padding:40px; color:#FF5722;">加载BOM结构失败</div>');
                    }
                },
                error: function () {
                    $('#js-bom-tree-container').html('<div style="text-align:center; padding:40px; color:#FF5722;">加载BOM结构失败</div>');
                }
            });
        }

        // 获取已保存的工序数据
        function getSavedOperByBomItemId(bomItemId, bomLevel) {
            var result = [];
            $.each(processItemsData, function (i, item) {
                if (item.bomLevel === bomLevel) {
                    // 根节点（bomLevel=0）匹配该层次第一条；子项按 bomItemId 匹配
                    if (bomLevel === 0) {
                        result.push(item);
                    } else if (item.bomItemId === bomItemId) {
                        result.push(item);
                    }
                }
            });
            return result.length > 0 ? result[0] : null;
        }

        // 渲染BOM树
        function renderBomTree(rootNode) {
            var container = $('#js-bom-tree-container');
            container.empty();

            var html = '<ul>';
            html += renderBomTreeNode(rootNode, 0, null);
            html += '</ul>';
            container.html(html);

            // 渲染操作下拉选择框
            form.render('select');
        }

        // 递归渲染BOM树节点
        function renderBomTreeNode(node, level, parentNode) {
            var hasChildren = node.children && node.children.length > 0;
            var isRoot = level === 0;
            var nodeId = node.id || 'node-' + level + '-' + (node.materielCode || 'root');

            // 查找已保存的数据
            var savedData = null;
            if (isRoot) {
                savedData = getSavedOperByBomItemId(null, 0);
            } else {
                savedData = getSavedOperByBomItemId(node.id, level);
            }

            var parentOperDesc = '';
            if (parentNode) {
                var parentSaved = null;
                if (parentNode._level === 0) {
                    parentSaved = getSavedOperByBomItemId(null, 0);
                } else {
                    parentSaved = getSavedOperByBomItemId(parentNode.id, parentNode._level);
                }
                if (parentSaved && parentSaved.operDesc) {
                    parentOperDesc = '上级工艺：' + parentSaved.operDesc;
                } else {
                    parentOperDesc = '上级工艺：未设置';
                }
            }

            var levelTag = 'L' + level;
            var levelColors = ['level-0', 'level-1', 'level-2', 'level-3', 'level-4', 'level-5'];
            var levelColor = levelColors[Math.min(level, 5)];

            var html = '<li data-level="' + level + '" data-parent-id="' + (parentNode ? (parentNode.id || '') : '') + '">';
            html += '<div class="node-header">';
            html += '<div class="node-info">';
            html += '<span class="level-tag ' + levelColor + '">' + levelTag + '</span>';
            html += '<strong>' + (node.materielDesc || node.materielCode || '产品') + '</strong>';
            html += '<span style="color:#999;font-size:12px;">[' + (node.materielCode || '') + ']</span>';
            if (!isRoot && node.itemNum) {
                html += '<span style="color:#999;font-size:12px;">用量：' + node.itemNum + ' ' + (node.itemUnit || '') + '</span>';
            }
            html += '</div>';

            // 工序选择
            html += '<div style="display:flex;align-items:center;gap:8px;flex-wrap:wrap;">';
            if (parentOperDesc) {
                html += '<span class="parent-oper-info"><i class="layui-icon layui-icon-about"></i> ' + parentOperDesc + '</span>';
            }
            html += '<select class="oper-select" name="operSelect" data-node-id="' + nodeId + '" data-level="' + level + '" data-bom-item-id="' + (node.id || '') + '" data-materiel-code="' + (node.materielCode || '') + '" data-materiel-desc="' + (node.materielDesc || '') + '" data-saved-oper-id="' + (savedData ? (savedData.operId || '') : '') + '" lay-filter="js-oper-select" ' + ('${(process.locked)!}' === '1' ? 'disabled' : '') + '>';
            html += '<option value="">-- 请选择工序 --</option>';

            // 从已选流程中加载工序
            var flowId = $('#js-flow-select').val();
            var loadedOpers = window._loadedFlowOpers || [];

            $.each(loadedOpers, function (i, oper) {
                var selected = (savedData && savedData.operId === oper.value) ? 'selected' : '';
                html += '<option value="' + oper.value + '" data-oper="' + (oper.title || '') + '" data-oper-desc="' + (oper.operDesc || '') + '" ' + selected + '>' + (oper.title || '') + '</option>';
            });
            html += '</select>';
            html += '</div>';
            html += '</div>';

            // 子节点
            if (hasChildren) {
                html += '<ul>';
                var _parentNode = $.extend({}, node);
                _parentNode._level = level;
                $.each(node.children, function (i, child) {
                    html += renderBomTreeNode(child, level + 1, _parentNode);
                });
                html += '</ul>';
            }

            return html;
        }

        // =============== 流程选择 ===============
        function loadFlowOpers(flowId) {
            if (!flowId) {
                window._loadedFlowOpers = [];
                return;
            }

            // 查找选中的option中的流程信息
            var selectedOption = $('#js-flow-select').find('option:selected');
            var flowDesc = selectedOption.data('flow-desc') || '';
            var processFlow = selectedOption.data('process') || '';

            // 显示流程信息
            $('#js-flow-desc-display').text(flowDesc);
            if (processFlow) {
                $('#js-flow-process-display').text(processFlow);
            } else {
                $('#js-flow-process-display').text(flowDesc);
            }
            $('#js-flow-info-container').show();

            // 更新隐藏域
            $('#js-flow').val(selectedOption.data('flow') || '');
            $('#js-flow-desc').val(flowDesc);

            // 加载流程下的工序列表
            spUtil.ajax({
                url: '${request.contextPath}/technology/process/plan/flow-opers',
                type: 'POST',
                async: true,
                showLoading: true,
                serializable: false,
                data: {flowId: flowId},
                success: function (res) {
                    if (res.code === 0) {
                        window._loadedFlowOpers = res.data || [];
                        // 重新渲染BOM树中的工序下拉框
                        refreshOperSelects();
                    }
                }
            });
        }

        // 刷新所有工序下拉框
        function refreshOperSelects() {
            var opers = window._loadedFlowOpers || [];
            $('select.oper-select').each(function () {
                var $this = $(this);
                // 优先使用已保存的工序ID回显，其次使用当前选中值
                var savedOperId = $this.data('saved-oper-id') || '';
                var currentVal = $this.val();
                var matchVal = savedOperId || currentVal;
                $this.empty();
                $this.append('<option value="">-- 请选择工序 --</option>');
                $.each(opers, function (i, oper) {
                    var selected = (oper.value === matchVal) ? 'selected' : '';
                    $this.append('<option value="' + oper.value + '" data-oper="' + (oper.title || '') + '" data-oper-desc="' + (oper.operDesc || '') + '" ' + selected + '>' + (oper.title || '') + '</option>');
                });
            });
            form.render('select');
        }

        // =============== 事件绑定 ===============

        // BOM选择变更
        form.on('select(js-bom-filter)', function (data) {
            var $option = $(data.elem).find('option:selected');
            var bomId = data.value;
            var bomCode = $option.data('bom-code') || '';
            var materielCode = $option.data('materiel-code') || '';
            var materielDesc = $option.data('materiel-desc') || '';

            $('#js-bom-code').val(bomCode);
            $('#js-materiel-code').val(materielCode);
            $('#js-materiel-desc').val(materielDesc);

            if (bomId) {
                loadBomTree(bomId);
            } else {
                $('#js-bom-tree-container').html('<div style="text-align:center; padding:40px; color:#aaa;"><i class="layui-icon layui-icon-app" style="font-size:48px;"></i><p style="margin-top:10px;">请先在上方选择产品（BOM）</p></div>');
            }
        });

        // 流程选择变更
        form.on('select(js-flow-filter)', function (data) {
            var flowId = data.value;
            if (flowId) {
                loadFlowOpers(flowId);
            } else {
                $('#js-flow-info-container').hide();
                $('#js-flow').val('');
                $('#js-flow-desc').val('');
                window._loadedFlowOpers = [];
                refreshOperSelects();
            }
        });

        // =============== 编辑时初始化 ===============
        // 加载BOM列表
        loadBomList();

        // 编辑时加载流程工序
        <#if process?? && process.flowId??>
        var initFlowId = '${process.flowId}';
        if (initFlowId) {
            // 延迟加载，等BOM树渲染完成后再加载工序
            setTimeout(function () {
                loadFlowOpers(initFlowId);
            }, 500);
        }
        </#if>

        // =============== 表单提交 ===============
        form.on('submit(js-submit-filter)', function (data) {
            // 校验
            var bomId = $('#js-bom-select').val();
            if (!bomId) {
                layer.msg('请选择产品（BOM）');
                return false;
            }

            var flowId = $('#js-flow-select').val();
            if (!flowId) {
                layer.msg('请选择工艺路线');
                return false;
            }

            // 收集工序数据
            var itemList = [];
            $('select.oper-select').each(function () {
                var $this = $(this);
                var operId = $this.val();
                if (operId) {
                    var level = parseInt($this.data('level')) || 0;
                    var bomItemId = $this.data('bom-item-id') || '';
                    var materielCode = $this.data('materiel-code') || '';
                    var materielDesc = $this.data('materiel-desc') || '';
                    var $selected = $this.find('option:selected');
                    var operNo = $selected.text() || '';          // 工序编号
                    var operName = $selected.data('oper-desc') || ''; // 工序名称

                    itemList.push({
                        bomLevel: level,
                        bomItemId: bomItemId,
                        materielItemCode: materielCode,
                        materielItemDesc: materielDesc,
                        operId: operId,
                        oper: operNo,
                        operDesc: operName,
                        sortNum: level
                    });
                }
            });

            if (itemList.length === 0) {
                layer.msg('请至少为产品分配一道工序');
                return false;
            }

            // 构建提交数据
            var submitData = {
                id: $('#js-id').val() || '',
                bomId: bomId,
                bomCode: $('#js-bom-code').val(),
                materielCode: $('#js-materiel-code').val(),
                materielDesc: $('#js-materiel-desc').val(),
                flowId: flowId,
                flow: $('#js-flow').val(),
                flowDesc: $('#js-flow-desc').val(),
                itemList: itemList
            };

            var submitBtn = $('#js-submit');
            submitBtn.text('保存中...').prop('disabled', true);

            spUtil.submitForm({
                contentType: 'application/json;charset=UTF-8',
                url: '${request.contextPath}/technology/process/plan/add-or-update',
                data: JSON.stringify(submitData),
                success: function (res) {
                    if (res.code === 0) {
                        layer.msg('产品工艺规划保存成功', {icon: 1, time: 1500}, function () {
                            // 刷新父页面
                            parent.layui.table ? parent.layui.table.reload('record-table') : null;
                            // 关闭当前弹窗
                            var index = parent.layer.getFrameIndex(window.name);
                            parent.layer.close(index);
                        });
                    } else {
                        layer.msg(res.msg || '保存失败');
                        submitBtn.text('保存').prop('disabled', false);
                    }
                },
                error: function () {
                    layer.msg('保存失败，请重试');
                    submitBtn.text('保存').prop('disabled', false);
                }
            });

            return false;
        });
    });
</script>
</body>
</html>
