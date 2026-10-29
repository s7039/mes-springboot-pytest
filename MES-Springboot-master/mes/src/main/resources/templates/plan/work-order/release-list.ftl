<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>工单下达</title>
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
                    <label class="layui-form-label">工单编号</label>
                    <div class="layui-input-inline">
                        <input type="text" name="orderCode" autocomplete="off" class="layui-input">
                    </div>
                </div>
                <div class="layui-inline">
                    <label class="layui-form-label">物料编码</label>
                    <div class="layui-input-inline">
                        <input type="text" name="materielCode" autocomplete="off" class="layui-input">
                    </div>
                </div>
                <div class="layui-inline">
                    <label class="layui-form-label">工单类型</label>
                    <div class="layui-input-inline">
                        <select name="orderType">
                            <option value="">全部</option>
                            <option value="IN">入库</option>
                            <option value="OUT">出库</option>
                        </select>
                    </div>
                </div>
                <div class="layui-inline">
                    <label class="layui-form-label">状态</label>
                    <div class="layui-input-inline">
                        <select name="status">
                            <option value="">全部</option>
                            <option value="01">待确认</option>
                            <option value="02">已完成</option>
                        </select>
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
        <@shiro.hasPermission name="user:add">
        <button class="layui-btn layui-btn-sm layui-btn-normal" lay-event="addIn"><i class="layui-icon">&#xe62a;</i>添加入库工单</button>
        <button class="layui-btn layui-btn-sm layui-btn-warm" lay-event="addOut"><i class="layui-icon">&#xe65e;</i>添加出库工单</button>
        </@shiro.hasPermission>
    </div>
</script>

<!--行操作模板-->
<script type="text/html" id="js-record-table-toolbar-right">
    <a class="layui-btn layui-btn-xs" lay-event="edit"><i class="layui-icon layui-icon-edit"></i>编辑</a>
    {{# if(d.orderType === 'OUT'){ }}
    <a class="layui-btn layui-btn-xs layui-btn-normal" lay-event="requirement"><i class="layui-icon layui-icon-list"></i>物料需求</a>
    {{# } }}
    <@shiro.hasPermission name="user:add"><a class="layui-btn layui-btn-danger layui-btn-xs" lay-event="delete"><i class="layui-icon layui-icon-delete"></i>删除</a></@shiro.hasPermission>
</script>

<script>
    layui.use(['form', 'table', 'spLayer', 'spTable'], function () {
        var form = layui.form,
            table = layui.table,
            spLayer = layui.spLayer,
            spTable = layui.spTable;

        var tableIns = spTable.render({
            url: '${request.contextPath}/plan/work-order/page',
            cols: [[
                {type: 'checkbox'}
                , {field: 'orderCode', title: '工单编号', width: 150}
                , {field: 'materielCode', title: '物料编码', width: 140}
                , {field: 'materielDesc', title: '物料名称', width: 170}
                , {field: 'orderType', title: '工单类型', width: 90, templet: function (d) {
                        if (d.orderType === 'IN') {
                            return '<span style="color:green;">入库</span>';
                        }
                        return '<span style="color:#ffa00d;">出库</span>';
                    }}
                , {field: 'qty', title: '数量', width: 90}
                , {field: 'warehouseCode', title: '库房编号', width: 110, templet: function (d) {
                        return d.warehouseCode || '';
                    }}
                , {field: 'locationCode', title: '库位编号', width: 110, templet: function (d) {
                        return d.locationCode || '';
                    }}
                , {field: 'startTime', title: '开始时间', width: 170}
                , {field: 'endTime', title: '结束时间', width: 170}
                , {field: 'status', title: '状态', width: 90, templet: function (d) {
                        if (d.status === '02') {
                            return '<span style="color:green;">已完成</span>';
                        }
                        return '<span style="color:gray;">待确认</span>';
                    }}
                , {field: 'createTime', title: '创建时间', width: 170}
                , {fixed: 'right', field: 'operate', title: '操作', toolbar: '#js-record-table-toolbar-right', unresize: true, width: 280}
            ]],
            done: function (res, curr, count) {
            }
        });

        $(function () {
            form.render();
        });

        form.on('submit(js-search-filter)', function (data) {
            tableIns.reload({
                where: data.field,
                page: {curr: 1}
            });
            return false;
        });

        table.on('toolbar(js-record-table-filter)', function (obj) {
            if (obj.event === 'addIn') {
                spLayer.open({
                    title: '添加入库工单',
                    area: ['55%', '85%'],
                    spWhere: {orderType: 'IN'},
                    content: '${request.contextPath}/plan/work-order/add-or-update-ui'
                });
            }
            if (obj.event === 'addOut') {
                spLayer.open({
                    title: '添加出库工单',
                    area: ['55%', '85%'],
                    spWhere: {orderType: 'OUT'},
                    content: '${request.contextPath}/plan/work-order/add-or-update-ui'
                });
            }
        });

        table.on('tool(js-record-table-filter)', function (obj) {
            var data = obj.data;

            if (obj.event === 'edit') {
                spLayer.open({
                    title: '编辑工单',
                    area: ['55%', '85%'],
                    spWhere: {id: data.id},
                    content: '${request.contextPath}/plan/work-order/add-or-update-ui'
                });
            }

            if (obj.event === 'requirement') {
                spLayer.open({
                    title: '物料需求 - ' + data.orderCode,
                    area: ['70%', '80%'],
                    spWhere: {orderCode: data.orderCode},
                    content: '${request.contextPath}/plan/work-order/requirement-ui'
                });
            }

            if (obj.event === 'delete') {
                layer.confirm('确认要删除该工单吗？<br>待确认的出库工单删除后将同步释放已锁定库存。', function (index) {
                    spUtil.ajax({
                        url: '${request.contextPath}/plan/work-order/delete',
                        type: 'POST',
                        showLoading: true,
                        serializable: false,
                        data: {id: data.id},
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
