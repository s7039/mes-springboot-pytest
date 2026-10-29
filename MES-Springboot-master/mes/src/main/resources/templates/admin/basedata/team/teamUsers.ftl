<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>班组员工管理</title>
    <meta name="renderer" content="webkit">
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=0">
    <#include "${request.contextPath}/common/common.ftl">
</head>
<body>
<div class="splayui-container">
    <div class="splayui-main">
        <!-- 班组信息 -->
        <div style="padding: 10px 0; font-size: 16px; font-weight: bold;">
            班组：${(team.code)!} - ${(team.name)!}
        </div>
        <input type="hidden" id="js-team-id" value="${(team.id)!}"/>

        <!-- 操作按钮 -->
        <div style="padding: 10px 0;">
            <button class="layui-btn layui-btn-sm" id="js-add-user-btn"><i class="layui-icon">&#xe61f;</i>添加员工</button>
        </div>

        <!--表格-->
        <table class="layui-hide" id="js-record-table" lay-filter="js-record-table-filter"></table>

        <form class="layui-form splayui-form">
            <div class="layui-row">
                <div class="layui-form-item layui-hide">
                    <div class="layui-input-block">
                        <button id="js-submit" class="layui-btn" lay-submit lay-filter="js-submit-filter">确定</button>
                    </div>
                </div>
            </div>
        </form>
    </div>
</div>

<!--行操作模板-->
<script type="text/html" id="js-record-table-toolbar-right">
    <@shiro.hasPermission name="user:add"><a class="layui-btn layui-btn-danger layui-btn-xs" lay-event="delete"><i class="layui-icon layui-icon-delete"></i>移除</a></@shiro.hasPermission>
</script>

<!--js逻辑-->
<script>
    layui.use(['form', 'table', 'spLayer', 'spTable'], function () {
        var form = layui.form,
            $ = layui.jquery,
            table = layui.table,
            layer = layui.layer,
            spLayer = layui.spLayer,
            spTable = layui.spTable;

        var teamId = $('#js-team-id').val();

        // 表格及数据初始化
        var tableIns = spTable.render({
            toolbar: '',
            url: '${request.contextPath}/admin/basedata/team/team-user/list',
            where: {teamId: teamId},
            page: false,
            parseData: function (res) {
                return {
                    "code": res.code,
                    "msg": res.msg,
                    "count": res.data ? res.data.length : 0,
                    "data": res.data || []
                };
            },
            cols: [
                [{
                    type: 'checkbox'
                }, {
                    field: 'userJobNo', title: '工号', width: 120
                }, {
                    field: 'userName', title: '姓名', width: 120
                }, {
                    field: 'userUsername', title: '用户名', width: 150
                }, {
                    field: 'createTime', title: '添加时间', width: 180
                }, {
                    fixed: 'right', field: 'operate', title: '操作', toolbar: '#js-record-table-toolbar-right', unresize: true, width: 120
                }]
            ],
            done: function (res, curr, count) {
            }
        });

        // 监听提交 (用于关闭弹窗)
        form.on('submit(js-submit-filter)', function (data) {
            window.spChildFrameResult = {
                msg: '操作成功',
                code: 0
            };
            return false;
        });

        // 添加员工 - 使用用户搜索面板
        $('#js-add-user-btn').click(function () {
            spLayer.open({
                type: 2,
                area: ['680px', '500px'],
                reload: false,
                title: '选择员工',
                content: '${request.contextPath}/admin/common/ui/spSearchPanel4SysUser',
                spCallback: function (result) {
                    if (result.code === 0 && result.data.length > 0) {
                        var users = result.data;
                        var addedCount = 0;
                        var existCount = 0;
                        var total = users.length;

                        function addNext(idx) {
                            if (idx >= total) {
                                var msg = '操作完成：成功添加 ' + addedCount + ' 人';
                                if (existCount > 0) {
                                    msg += '，' + existCount + ' 人已存在';
                                }
                                layer.msg(msg);
                                tableIns.reload();
                                return;
                            }
                            $.ajax({
                                type: 'POST',
                                url: '${request.contextPath}/admin/basedata/team/team-user/add',
                                data: {
                                    teamId: teamId,
                                    userId: users[idx].id
                                },
                                dataType: 'json',
                                success: function (res) {
                                    if (res.code === 0) {
                                        addedCount++;
                                    } else {
                                        existCount++;
                                    }
                                },
                                error: function () {
                                    existCount++;
                                },
                                complete: function () {
                                    addNext(idx + 1);
                                }
                            });
                        }

                        if (total > 0) {
                            addNext(0);
                        }
                    }
                }
            });
        });

        /**
         * 监听行工具事件
         */
        table.on('tool(js-record-table-filter)', function (obj) {
            var data = obj.data;

            // 移除
            if (obj.event === 'delete') {
                layer.confirm('确认要移除此员工吗？', function (index) {
                    $.ajax({
                        type: 'POST',
                        url: '${request.contextPath}/admin/basedata/team/team-user/delete',
                        data: {id: data.id},
                        dataType: 'json',
                        success: function (result) {
                            if (result.code === 0) {
                                layer.msg('移除成功');
                                tableIns.reload();
                            }
                        }
                    });
                    layer.close(index);
                });
            }
        });
    });
</script>
</body>
</html>
