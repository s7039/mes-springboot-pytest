<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>工艺规划管理</title>
    <meta name="renderer" content="webkit">
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
    <#include "${request.contextPath}/common/common.ftl">
</head>
<body>
<div class="splayui-container">
    <div class="splayui-main">
        <!--查询参数-->
        <form id="js-search-form" class="layui-form" lay-filter="js-q-form-filter">
            <div class="layui-form-item">
                <div class="layui-inline">
                    <label class="layui-form-label">物料编码</label>
                    <div class="layui-input-inline">
                        <input type="text" name="materielCodeLike" autocomplete="off" class="layui-input">
                    </div>
                </div>
                <div class="layui-inline">
                    <label class="layui-form-label">物料名称</label>
                    <div class="layui-input-inline">
                        <input type="text" name="materielDescLike" autocomplete="off" class="layui-input">
                    </div>
                </div>
                <div class="layui-inline">
                    <label class="layui-form-label">BOM编号</label>
                    <div class="layui-input-inline">
                        <input type="text" name="bomCodeLike" autocomplete="off" class="layui-input">
                    </div>
                </div>
                <div class="layui-inline">
                    <a class="layui-btn" lay-submit lay-filter="js-search-filter"><i
                                class="layui-icon layui-icon-search layuiadmin-button-btn"></i></a>
                </div>
            </div>
        </form>

        <!--表格-->
        <table class="layui-hide" id="js-record-table" lay-filter="js-record-table-filter"></table>
    </div>
</div>

<!--表格头操作模板-->
<script type="text/html" id="js-record-table-toolbar-top">
    <div class="layui-btn-container">
        <button class="layui-btn layui-btn-sm" lay-event="add"><i class="layui-icon">&#xe61f;</i>添加工艺规划</button>
    </div>
</script>

<!--行操作模板-->
<script type="text/html" id="js-record-table-toolbar-right">
    <a class="layui-btn layui-btn-xs" lay-event="edit"><i class="layui-icon layui-icon-edit"></i>编辑工艺规划</a>
    {{# if(d.locked === '1'){ }}
    <a class="layui-btn layui-btn-xs layui-btn-warm" lay-event="unlock"><i class="layui-icon layui-icon-unlock"></i>解锁</a>
    {{# } else { }}
    <a class="layui-btn layui-btn-xs layui-btn-danger" lay-event="lock"><i class="layui-icon layui-icon-lock"></i>锁定</a>
    {{# } }}
    <a class="layui-btn layui-btn-xs layui-btn-normal" lay-event="view"><i class="layui-icon layui-icon-app"></i>查看工序</a>
    <@shiro.hasPermission name="user:add"><a class="layui-btn layui-btn-danger layui-btn-xs" lay-event="delete"><i class="layui-icon layui-icon-delete"></i>删除</a></@shiro.hasPermission>
</script>

<!--js逻辑-->
<script>
    layui.use(['form', 'table', 'spLayer', 'spTable'], function () {
        var form = layui.form,
            table = layui.table,
            spLayer = layui.spLayer,
            spTable = layui.spTable;

        // 表格及数据初始化
        var tableIns = spTable.render({
            url: '${request.contextPath}/technology/process/plan/page',
            cols: [
                [{
                    type: 'radio'
                }, {
                    field: 'materielCode', title: '物料编码'
                }, {
                    field: 'materielDesc', title: '物料名称'
                }, {
                    field: 'bomCode', title: 'BOM编号'
                }, {
                    field: 'flow', title: '路线编码'
                }, {
                    field: 'flowDesc', title: '路线描述'
                }, {
                    field: 'locked', title: '锁定状态', templet: function (d) {
                        return d.locked === '1' ? '<span style="color:red;"><i class="layui-icon layui-icon-lock"></i> 已锁定</span>' : '<span style="color:green;"><i class="layui-icon layui-icon-unlock"></i> 未锁定</span>';
                    }
                }, {
                    fixed: 'right',
                    field: 'operate',
                    title: '操作',
                    toolbar: '#js-record-table-toolbar-right',
                    unresize: true,
                    width: 350
                }]
            ],
            done: function (res, curr, count) {
            }
        });

        /*
         * 数据表格中form表单元素是动态插入,所以需要更新渲染下
         */
        $(function () {
            form.render();
        });

        /**
         * 搜索按钮事件
         */
        form.on('submit(js-search-filter)', function (data) {
            tableIns.reload({
                where: data.field,
                page: {
                    curr: 1
                }
            });
            return false;
        });

        /**
         * 头工具栏事件
         */
        table.on('toolbar(js-record-table-filter)', function (obj) {
            var checkStatus = table.checkStatus(obj.config.id);

            // 编辑工艺规划（新增）
            if (obj.event === 'add') {
                spLayer.open({
                    title: '添加工艺规划',
                    area: ['85%', '90%'],
                    content: '${request.contextPath}/technology/process/plan/add-or-update-ui'
                });
            }
        });

        /**
         * 监听行工具事件
         */
        table.on('tool(js-record-table-filter)', function (obj) {
            var data = obj.data;

            // 编辑工艺规划
            if (obj.event === 'edit') {
                spLayer.open({
                    title: '编辑工艺规划 - ' + data.materielDesc,
                    area: ['85%', '90%'],
                    spWhere: {id: data.id},
                    content: '${request.contextPath}/technology/process/plan/add-or-update-ui'
                });
            }

            // 锁定
            if (obj.event === 'lock') {
                layer.confirm('确认锁定该产品工艺规划？锁定后将无法对该工艺进行新增、编辑、删除操作。', function (index) {
                    spUtil.ajax({
                        url: '${request.contextPath}/technology/process/plan/lock',
                        type: 'POST',
                        showLoading: true,
                        serializable: false,
                        data: {
                            id: data.id,
                            locked: '1'
                        },
                        success: function (res) {
                            layer.msg('产品工艺规划锁定成功');
                            tableIns.reload();
                            layer.close(index);
                        }
                    });
                });
            }

            // 解锁
            if (obj.event === 'unlock') {
                layer.confirm('确认解锁该产品工艺规划？', function (index) {
                    spUtil.ajax({
                        url: '${request.contextPath}/technology/process/plan/lock',
                        type: 'POST',
                        showLoading: true,
                        serializable: false,
                        data: {
                            id: data.id,
                            locked: '0'
                        },
                        success: function (res) {
                            layer.msg('产品工艺规划解锁成功');
                            tableIns.reload();
                            layer.close(index);
                        }
                    });
                });
            }

            // 查看工序
            if (obj.event === 'view') {
                // 加载该工艺规划下的工序信息
                spUtil.ajax({
                    url: '${request.contextPath}/technology/process/plan/process-items',
                    type: 'POST',
                    showLoading: true,
                    serializable: false,
                    data: {processId: data.id},
                    success: function (res) {
                        if (res.code === 0 && res.data) {
                            var html = '<table class="layui-table" style="margin:10px;">';
                            html += '<thead><tr><th>BOM层次</th><th>物料编码</th><th>物料名称</th><th>工序编号</th><th>工序名称</th></tr></thead>';
                            html += '<tbody>';
                            var items = res.data;
                            if (items.length > 0) {
                                for (var i = 0; i < items.length; i++) {
                                    var item = items[i];
                                    html += '<tr>';
                                    html += '<td>' + (item.bomLevel || 0) + '</td>';
                                    html += '<td>' + (item.materielItemCode || '') + '</td>';
                                    html += '<td>' + (item.materielItemDesc || '') + '</td>';
                                    html += '<td>' + (item.oper || '') + '</td>';
                                    html += '<td>' + (item.operDesc || '') + '</td>';
                                    html += '</tr>';
                                }
                            } else {
                                html += '<tr><td colspan="5" style="text-align:center;">暂未配置工序信息</td></tr>';
                            }
                            html += '</tbody></table>';
                            layer.open({
                                title: '工艺流程信息 - ' + data.materielDesc,
                                area: ['70%', '70%'],
                                type: 1,
                                content: html
                            });
                        }
                    }
                });
            }

            // 删除
            if (obj.event === 'delete') {
                layer.confirm('确认要删除该产品工艺规划吗？', function (index) {
                    spUtil.ajax({
                        url: '${request.contextPath}/technology/process/plan/delete',
                        type: 'POST',
                        showLoading: true,
                        serializable: false,
                        data: {
                            id: data.id
                        },
                        success: function (res) {
                            tableIns.reload();
                            layer.close(index);
                        }
                    });
                });
            }
        });
    });
</script>
</body>
</html>
