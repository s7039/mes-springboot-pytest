<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>工序管理</title>
    <meta name="renderer" content="webkit">
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
    <#include "${request.contextPath}/common/common.ftl">
</head>
<body>
<div class="splayui-container">
    <div class="splayui-main">
        <#-- 查询条件 -->
        <form id="js-search-form" class="layui-form" lay-filter="js-q-form-filter">
            <div class="layui-form-item">
                <div class="layui-inline">
                    <label class="layui-form-label">工序编号</label>
                    <div class="layui-input-inline">
                        <input type="text" name="operLike" autocomplete="off" class="layui-input" placeholder="请输入工序编号">
                    </div>
                </div>
                <div class="layui-inline">
                    <label class="layui-form-label">工序名称</label>
                    <div class="layui-input-inline">
                        <input type="text" name="operDescLike" autocomplete="off" class="layui-input" placeholder="请输入工序名称">
                    </div>
                </div>
                <div class="layui-inline">
                    <a class="layui-btn" lay-submit lay-filter="js-search-filter"><i
                                class="layui-icon layui-icon-search layuiadmin-button-btn"></i></a>
                </div>
            </div>
        </form>

        <#-- 分割线 -->
        <hr style="margin:5px 0;">

        <#-- 表格 -->
        <table class="layui-hide" id="js-record-table" lay-filter="js-record-table-filter"></table>
    </div>
</div>

<#-- 表格顶部工具栏 -->
<script type="text/html" id="js-record-table-toolbar-top">
    <div class="layui-btn-container">
        <@shiro.hasPermission name="user:add">
        <button class="layui-btn layui-btn-danger layui-btn-sm" lay-event="deleteBatch">
            <i class="layui-icon">&#xe640;</i>批量删除
        </button>
        </@shiro.hasPermission>
        <@shiro.hasPermission name="user:add">
        <button class="layui-btn layui-btn-sm" lay-event="add">
            <i class="layui-icon">&#xe61f;</i>新增工序
        </button>
        </@shiro.hasPermission>
    </div>
</script>

<#-- 行操作模板 -->
<script type="text/html" id="js-record-table-toolbar-right">
    <a class="layui-btn layui-btn-xs" lay-event="edit">
        <i class="layui-icon layui-icon-edit"></i> 编辑
    </a>
    <@shiro.hasPermission name="user:add">
    <a class="layui-btn layui-btn-danger layui-btn-xs" lay-event="delete">
        <i class="layui-icon layui-icon-delete"></i> 删除
    </a>
    </@shiro.hasPermission>
</script>

<#-- JS逻辑 -->
<script>
    layui.use(['form', 'table', 'spLayer', 'spTable', 'spLayui', 'layer'], function () {
        var form = layui.form,
            table = layui.table,
            spLayer = layui.spLayer,
            spLayui = layui.spLayui,
            spTable = layui.spTable,
            layer = layui.layer;

        <#-- 表格及数据初始化 -->
        var tableIns = spTable.render({
            url: '${request.contextPath}/basedata/sp-oper/page',
            toolbar: '#js-record-table-toolbar-top',
            page: true,
            limit: 15,
            limits: [10, 15, 20, 50, 100],
            cols: [[
                {type: 'checkbox', width: 50},
                {field: 'oper', title: '工序编号', width: 180, sort: true},
                {field: 'operDesc', title: '工序名称', width: 160},
                {field: 'workingHours', title: '工时', width: 100, sort: true,
                    templet: function (d) { return d.workingHours != null ? d.workingHours + ' h' : '-'; }
                },
                {field: 'manufacturingCycle', title: '制造周期', width: 100, sort: true,
                    templet: function (d) { return d.manufacturingCycle != null ? d.manufacturingCycle + ' h' : '-'; }
                },
                {field: 'remark', title: '备注', minWidth: 150},
                {fixed: 'right', field: 'operate', title: '操作', toolbar: '#js-record-table-toolbar-right', unresize: true, width: 200}
            ]],
            done: function (res, curr, count) {
            }
        });

        $(function () {
            form.render();
        });

        <#-- 搜索按钮事件 -->
        form.on('submit(js-search-filter)', function (data) {
            tableIns.reload({
                where: data.field,
                page: {curr: 1}
            });
            return false;
        });

        <#-- 头工具栏事件：新增 & 批量删除 -->
        table.on('toolbar(js-record-table-filter)', function (obj) {
            if (obj.event === 'add') {
                spLayer.open({
                    title: '新增工序信息',
                    area: ['720px', '580px'],
                    btn: [],
                    reload: false,
                    content: '${request.contextPath}/basedata/sp-oper/add-or-update-ui',
                    end: function () {
                        tableIns.reload();
                    }
                });
            }

            if (obj.event === 'deleteBatch') {
                var checkStatus = table.checkStatus('js-record-table'),
                    data = checkStatus.data;
                if (data.length > 0) {
                    layer.confirm('确认要删除选中的' + data.length + '条工序吗？', function (index) {
                        var ids = data.map(function (item) {
                            return item.id;
                        }).join(',');
                        $.post('${request.contextPath}/basedata/sp-oper/delete-batch', {ids: ids}, function (res) {
                            if (res.code === 0) {
                                layer.msg('删除成功', {icon: 1});
                                tableIns.reload();
                            } else {
                                layer.msg(res.msg, {icon: 5});
                            }
                        });
                        layer.close(index);
                    });
                } else {
                    layer.msg('请先选择需要删除的数据！');
                }
            }
        });

        <#-- 监听行工具事件：编辑 & 删除 -->
        table.on('tool(js-record-table-filter)', function (obj) {
            var data = obj.data;

            if (obj.event === 'edit') {
                spLayer.open({
                    title: '编辑工序信息 - ' + data.operDesc,
                    area: ['720px', '580px'],
                    btn: [],
                    reload: false,
                    spWhere: {id: data.id},
                    content: '${request.contextPath}/basedata/sp-oper/add-or-update-ui',
                    end: function () {
                        tableIns.reload();
                    }
                });
            }

            if (obj.event === 'delete') {
                layer.confirm(
                    '确定要删除工序「<span style="color:red;">' + data.operDesc + '</span>」吗？<br><small style="color:#999;">删除后将不可恢复</small>',
                    {icon: 3, title: '删除确认'},
                    function (index) {
                        spUtil.ajax({
                            url: '${request.contextPath}/basedata/sp-oper/delete',
                            type: 'POST',
                            showLoading: true,
                            serializable: false,
                            data: {id: data.id},
                            success: function () {
                                tableIns.reload();
                                layer.close(index);
                                layer.msg('删除成功', {icon: 1});
                            }
                        });
                    }
                );
            }
        });
    });
</script>
</body>
</html>
