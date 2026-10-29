<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>添加用户</title>
    <meta name="renderer" content="webkit">
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
    <meta name="viewport"
          content="width=device-width, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=0">
    <#include "${request.contextPath}/common/common.ftl">
    <link href="${request.contextPath}/css/effect.css" rel="stylesheet" type="text/css"/>
    <style>
        .flowProcss {
            font-size: 25px;
            margin-left: 310PX;
            display: flex;
            justify-content: flex-start;
            flex-direction: row;
        }

    </style>

</head>
<body>
<div class="splayui-container">
    <div class="splayui-main">
        <form class="layui-form splayui-form" lay-filter="formTest">
            <div class="layui-row">
                <div class="layui-col-xs6 layui-col-sm6 layui-col-md10">
                    <div class="layui-form-item">
                        <label for="js-materiel" class="layui-form-label sp-required">物料编码
                        </label>
                        <div class="layui-input-inline">
                            <input type="text" id="js-materiel" name="materiel" autocomplete="off"
                                   class="layui-input" value="${result.materiel}" disabled>
                            <#if result.id?? && result.id?length gt 0>
                                <input type="hidden" name="materiel" value="${result.materiel}">
                            </#if>
                        </div>
                        <div class="layui-form-mid layui-word-aux">
                            <#if result.id?? && result.id?length gt 0>系统自动生成，不可修改</#if>
                            <#if !(result.id?? && result.id?length gt 0)>系统自动生成</#if>
                        </div>
                    </div>
                    <div class="layui-form-item">
                        <label for="js-materielDesc" class="layui-form-label sp-required">物料名称
                        </label>
                        <div class="layui-input-inline">
                            <input type="text" id="js-materielDesc" name="materielDesc" lay-verify="required"
                                   autocomplete="off" class="layui-input" value="${result.materielDesc}">
                        </div>
                    </div>
                    <div class="layui-form-item">
                        <label for="js-materielSource" class="layui-form-label sp-required">物料来源
                        </label>
                        <div class="layui-input-inline">
                            <select id="js-materielSource" name="materielSource" lay-verify="required">
                                <option value="">请选择</option>
                                <option value="自制" <#if result.materielSource == "自制">selected</#if>>自制</option>
                                <option value="外购" <#if result.materielSource == "外购">selected</#if>>外购</option>
                                <option value="委外" <#if result.materielSource == "委外">selected</#if>>委外</option>
                            </select>
                        </div>
                    </div>
                    <div class="layui-form-item">
                        <label for="js-matType" class="layui-form-label sp-required">物料类型
                        </label>
                        <div class="layui-input-inline">
                            <select id="js-matType" name="matType" lay-filter="matType-filter" lay-verify="required">
                            </select>
                        </div>
                    </div>
                    <div class="layui-form-item">
                        <label for="js-unit" class="layui-form-label sp-required">单位
                        </label>
                        <div class="layui-input-inline">
                            <input type="text" id="js-unit" name="unit" lay-verify="required" autocomplete="off"
                                   class="layui-input" value="${result.unit}">
                        </div>
                    </div>
                    <div class="layui-form-item">
                        <label for="js-model" class="layui-form-label sp-required">规格型号
                        </label>
                        <div class="layui-input-inline">
                            <input type="text" id="js-model" name="model" lay-verify="required"
                                   autocomplete="off"
                                   class="layui-input" value="${result.model}">
                        </div>
                    </div>
                    <div class="layui-form-item">
                        <label for="js-size" class="layui-form-label ">尺寸
                        </label>
                        <div class="layui-input-inline">
                            <input type="text" id="js-size" name="size" autocomplete="off"
                                   class="layui-input" value="${result.size}">
                        </div>
                    </div>
                    <div class="layui-form-item">
                        <label for="js-flowId" class="layui-form-label ">工艺路线
                        </label>
                        <div class="layui-input-inline">
                            <select id="js-flowId" name="flowId" lay-filter="flow-filter">
                            </select>
                        </div>
                        <div class=" text-effect flowProcss  " id="js-flowProcess" name="flowProcss">
                        </div>
                    </div>
                    <div class="layui-form-item">
                        <label class="layui-form-label">物料图片</label>
                        <div class="layui-input-inline">
                            <div id="js-picture-upload">
                                <button type="button" class="layui-btn layui-btn-sm" id="js-upload-btn">
                                    <i class="layui-icon layui-icon-upload"></i>上传图片
                                </button>
                            </div>
                            <input type="hidden" id="js-picture" name="picture" value="${result.picture}">
                            <div id="js-picture-preview" style="margin-top:8px;">
                                <#if result.picture?? && result.picture?length gt 0>
                                    <img src="${result.picture}" style="max-width:120px;max-height:120px;border-radius:4px;border:1px solid #e2e2e2">
                                </#if>
                            </div>
                        </div>
                    </div>
                    <div class="layui-form-item">
                        <label for="js-componentNotes" class="layui-form-label">备注
                        </label>
                        <div class="layui-input-inline">
                            <textarea id="js-componentNotes" name="componentNotes" autocomplete="off"
                                      class="layui-textarea" style="min-height:80px;">${result.componentNotes}</textarea>
                        </div>
                    </div>
                </div>
                <div class="layui-form-item layui-hide">
                    <div class="layui-input-block">
                        <input id="js-id" name="id" value="${result.id}"/>
                        <button id="js-submit" class="layui-btn" lay-submit lay-filter="js-submit-filter">确定
                        </button>
                    </div>
                </div>
            </div>

        </form>
    </div>
</div>
<script>
    layui.use(['form', 'util', 'upload'], function () {
        var form = layui.form,
            util = layui.util,
            upload = layui.upload;
        var flowRows = [];
        //流程添加下拉框
        getFlowData();
        //物料类型
        getMatTypeData();

        //图片上传
        upload.render({
            elem: '#js-upload-btn',
            url: '${request.contextPath}/basedata/materile/upload-picture',
            accept: 'images',
            size: 2048, // 限制2MB
            field: 'file',
            before: function () {
                layer.load(1);
            },
            done: function (res) {
                layer.closeAll('loading');
                if (res.code === 0) {
                    // 保存图片路径
                    $('#js-picture').val(res.data);
                    // 显示预览
                    $('#js-picture-preview').html(
                        '<img src="' + res.data + '" style="max-width:120px;max-height:120px;border-radius:4px;border:1px solid #e2e2e2">'
                    );
                    layer.msg('上传成功');
                } else {
                    layer.msg(res.msg || '上传失败');
                }
            },
            error: function () {
                layer.closeAll('loading');
                layer.msg('上传失败，请重试');
            }
        });

        /**
         * 初始化物料类型数据
         */
        function getMatTypeData() {
            spUtil.ajax({
                url: '${request.contextPath}/basedata/dict/list/material_type',
                async: false,
                type: 'GET',
                // 是否显示 loading
                // showLoading: true,
                // 是否序列化参数
                serializable: false,
                // 参数
                data: {},
                success: function (data) {
                    $.each(data.data, function (index, item) {
                        $('#js-matType').append(new Option(item.name, item.value));
                    });
                }
            });

        }


        /**
         * 初始化流程数据
         */
        function getFlowData() {
            spUtil.ajax({
                url: '${request.contextPath}/basedata/flow/list',
                async: false,
                type: 'GET',
                // 是否显示 loading
                showLoading: true,
                // 是否序列化参数
                serializable: false,
                // 参数
                data: {},
                success: function (data) {
                    flowRows = data.data;
                }
            });

            $.each(flowRows, function (index, item) {
                $('#js-flowId').append(new Option(item.flowDesc, item.id));
            });
            //编辑时候根据回显的ID 绘制流程
            flowProssbyId("${result.flowId}")
        }

        //下拉框选择 绘制流程时序图
        form.on('select(flow-filter)', function (data) {
            flowProssbyId(data.value)
        });

        //通过ID 获取流程时序 绘制
        function flowProssbyId(flowId) {
            var newArr = flowRows.filter(function (obj) {
                return obj.id == flowId;
            });
            if (newArr.length > 0) {
                procssArr = newArr[0].process.split("->")
                $("#js-flowProcess").empty();
                $.each(procssArr, function (i, val) {

                    if (i == procssArr.length - 1) {
                        $("#js-flowProcess").append("<span style='display: inline-flex;' >" + val + "</span>");
                    } else {
                        $("#js-flowProcess").append("<span style='display: inline-flex;' >" + val + '->' + "</span>");
                    }
                });
            }
        }

        //给表单赋值
        form.val("formTest", { //formTest 即 class="layui-form" 所在元素属性 lay-filter="" 对应的值
            "flowId": "${result.flowId}",
            "matType": "${result.matType}"
        });

        //监听提交
        form.on('submit(js-submit-filter)', function (data) {
            // 如果物料编码被disabled，使用隐藏域的值
            var fieldData = data.field;
            spUtil.submitForm({
                url: "${request.contextPath}/basedata/materile/add-or-update",
                data: fieldData
            });
            return false;
        });

    });
</script>
</body>
</html>