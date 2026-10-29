<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>添加用户</title>
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
                    <!-- 工号（系统自动生成，无需输入） -->
                    <div class="layui-form-item">
                        <label class="layui-form-label sp-required">工号</label>
                        <div class="layui-input-inline">
                            <input type="text" id="js-jobNo" name="jobNo" autocomplete="off" class="layui-input" value="${result.jobNo}" readonly
                                   style="background:#f5f5f5; color:#666; font-weight:bold;">
                        </div>
                        <div class="layui-form-mid layui-word-aux">
                            <#if result.id?? && result.id?length gt 0>
                                <span style="color:green;">编辑状态，工号不可更改</span>
                            <#else>
                                <span style="color:#1E9FFF;">系统自动生成</span>
                            </#if>
                        </div>
                    </div>

                    <!-- 姓名 -->
                    <div class="layui-form-item">
                        <label class="layui-form-label sp-required">姓名</label>
                        <div class="layui-input-inline">
                            <input type="text" id="js-name" name="name" lay-verify="required" autocomplete="off" class="layui-input" value="${result.name}">
                        </div>
                    </div>

                    <!-- 用户名 -->
                    <div class="layui-form-item">
                        <label class="layui-form-label sp-required">用户名</label>
                        <div class="layui-input-inline">
                            <input type="text" id="js-username" name="username" lay-verify="required" autocomplete="off" class="layui-input" value="${result.username}">
                        </div>
                    </div>

                    <!-- 密码 -->
                    <div class="layui-form-item">
                        <label class="layui-form-label sp-required">密码</label>
                        <div class="layui-input-inline">
                            <input type="text" id="js-password" name="password" lay-verify="required" autocomplete="off" class="layui-input" value="${result.passwordPlain}">
                        </div>
                    </div>

                    <!-- 确认密码 -->
                    <div class="layui-form-item">
                        <label class="layui-form-label sp-required">确认密码</label>
                        <div class="layui-input-inline">
                            <input type="text" id="js-repassword" name="repassword" lay-verify="required" autocomplete="off" class="layui-input" value="${result.passwordPlain}">
                        </div>
                    </div>

                    <!-- 性别 -->
                    <div class="layui-form-item">
                        <label class="layui-form-label sp-required">性别</label>
                        <div class="layui-input-block" id="js-sex">
                            <input type="radio" name="sex" value="0" title="女" <#if result.sex == "0" || !(result??)>checked</#if>>
                            <input type="radio" name="sex" value="1" title="男" <#if result.sex == "1">checked</#if>>
                            <input type="radio" name="sex" value="2" title="其他" <#if result.sex == "2">checked</#if>>
                        </div>
                    </div>

                    <!-- 联系方式（原手机号） -->
                    <div class="layui-form-item">
                        <label class="layui-form-label sp-required">联系方式</label>
                        <div class="layui-input-inline">
                            <input type="text" id="js-mobile" name="mobile" lay-verify="required|number" autocomplete="off" class="layui-input" value="${result.mobile}">
                        </div>
                    </div>

                    <!-- 证件号码（原身份证） -->
                    <div class="layui-form-item">
                        <label class="layui-form-label">证件号码</label>
                        <div class="layui-input-inline">
                            <input type="text" id="js-id-card" name="idCard" lay-verify="" autocomplete="off" class="layui-input" value="${result.idCard}">
                        </div>
                    </div>

                    <!-- 邮箱 -->
                    <div class="layui-form-item">
                        <label class="layui-form-label">邮箱</label>
                        <div class="layui-input-inline">
                            <input type="text" id="js-email" name="email" lay-verify="" autocomplete="off" class="layui-input" value="${result.email}">
                        </div>
                    </div>
                </div>

                <div class="layui-col-xs6 layui-col-sm6 layui-col-md6">
                    <!-- 出生日期 + 自动年龄 -->
                    <div class="layui-form-item">
                        <label class="layui-form-label">出生日期</label>
                        <div class="layui-input-inline" style="width: 150px;">
                            <input type="text" id="js-birthday" name="birthday" lay-verify="date" autocomplete="off" class="layui-input" value="${result.birthday}">
                        </div>
                        <div class="layui-form-mid layui-word-aux" id="js-age" style="padding-left: 10px;"></div>
                    </div>

                    <!-- 籍贯 -->
                    <div class="layui-form-item">
                        <label class="layui-form-label">籍贯</label>
                        <div class="layui-input-inline">
                            <input type="text" id="js-province" name="province" lay-verify="" autocomplete="off" class="layui-input" value="${result.province}">
                        </div>
                    </div>

                    <!-- 联系地址 -->
                    <div class="layui-form-item">
                        <label class="layui-form-label">联系地址</label>
                        <div class="layui-input-inline">
                            <input type="text" id="js-city" name="city" lay-verify="" autocomplete="off" class="layui-input" value="${result.city}">
                        </div>
                    </div>

                    <!-- 备注（原描述） -->
                    <div class="layui-form-item">
                        <label class="layui-form-label">备注</label>
                        <div class="layui-input-inline">
                            <textarea id="js-descr" name="descr" lay-verify="" autocomplete="off" class="layui-textarea">${result.descr}</textarea>
                        </div>
                    </div>

                    <!-- 状态（选项：正常、冻结） -->
                    <div class="layui-form-item">
                        <label class="layui-form-label sp-required">状态</label>
                        <div class="layui-input-block" id="js-is-deleted">
                            <input type="radio" name="deleted" value="0" title="正常" <#if result.deleted == "0" || !(result??)>checked</#if>>
                            <input type="radio" name="deleted" value="2" title="异常" <#if result.deleted == "2">checked</#if>>
                        </div>
                    </div>
                </div>

                <!-- 分配权限 -->
                <div class="layui-col-xs12 layui-col-sm12 layui-col-md12">
                    <div class="layui-form-item" pane="">
                        <label class="layui-form-label">分配权限</label>
                        <div class="layui-input-block">
                            <#list sysRoles as sysRole>
                                <input type="checkbox" name="sysRoleIds[]" title="${sysRole.name}<#if sysRole.deleted == '2'>（已禁用）</#if>" value="${sysRole.id}" <#if sysRole.checked >checked</#if> <#if sysRole.deleted == '2'>disabled</#if>>
                            </#list>
                        </div>
                    </div>
                </div>

                <div class="layui-form-item layui-hide">
                    <div class="layui-input-block">
                        <input id="js-id" name="id" value="${result.id}"/>
                        <button id="js-submit" class="layui-btn" lay-submit lay-filter="js-submit-filter">确定</button>
                    </div>
                </div>
            </div>
        </form>
    </div>
</div>
<script>
    layui.use(['form', 'util', 'laydate'], function () {
        var form = layui.form,
            util = layui.util,
            laydate = layui.laydate;

        // 新增时自动获取系统生成的工号
        var isEdit = '${(result.id?? && result.id?length gt 0)?string("true", "false")}';
        if (isEdit === 'false') {
            $.ajax({
                url: '${request.contextPath}/admin/sys/user/generate-code',
                type: 'GET',
                dataType: 'json',
                success: function (res) {
                    if (res.code === 0) {
                        $('#js-jobNo').val(res.data);
                    }
                }
            });
        }

        //出生日期日期选择器
        laydate.render({
            elem: '#js-birthday',
            type: 'date',
            format: 'yyyy-MM-dd',
            max: 0,
            done: function (value) {
                calculateAge(value);
            }
        });

        // 计算年龄
        function calculateAge(birthday) {
            if (!birthday) {
                $('#js-age').text('');
                return;
            }
            var birthDate = new Date(birthday);
            var today = new Date();
            var age = today.getFullYear() - birthDate.getFullYear();
            var monthDiff = today.getMonth() - birthDate.getMonth();
            if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birthDate.getDate())) {
                age--;
            }
            if (age >= 0) {
                $('#js-age').text(age + '岁');
            } else {
                $('#js-age').text('');
            }
        }

        // 页面加载时已有生日则计算年龄
        var initBirthday = '${result.birthday}';
        if (initBirthday) {
            calculateAge(initBirthday);
        }

        //失去焦点时判断值为空不验证，一旦填写必须验证
        $('input[name="email"]').blur(function () {
            if ($('input[name="email"]').val()) {
                $('input[name="email"]').attr('lay-verify', 'email');
            } else {
                $('input[name="email"]').removeAttr('lay-verify');
            }
        });

        //监听提交
        form.on('submit(js-submit-filter)', function (data) {
            // 校验：被禁用的角色无法分配给用户
            var disabledRole = $('input[name="sysRoleIds[]"]:disabled:checked').first();
            if (disabledRole.length > 0) {
                layer.msg('角色【' + disabledRole.attr('title') + '】已被禁用，无法分配给用户！', {icon: 5});
                return false;
            }
            spUtil.submitForm({
                url: "${request.contextPath}/admin/sys/user/add-or-update",
                data: data.field
            });
            return false;
        });
    });
</script>
</body>
</html>