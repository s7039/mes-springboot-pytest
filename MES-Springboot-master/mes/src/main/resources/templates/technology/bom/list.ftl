<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>bom管理</title>
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
                    <label class="layui-form-label">BOM编号</label>
                    <div class="layui-input-inline">
                        <input type="text" name="bomCodeLike" autocomplete="off" class="layui-input">
                    </div>
                </div>
                <div class="layui-inline">
                    <label class="layui-form-label">物料编码</label>
                    <div class="layui-input-inline">
                        <input type="text" name="materielCodeLike" autocomplete="off" class="layui-input">
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
            <button class="layui-btn layui-btn-sm" lay-event="add"><i class="layui-icon">&#xe61f;</i>添加</button>
        </@shiro.hasPermission>
    </div>
</script>

<!--行操作模板-->
<script type="text/html" id="js-record-table-toolbar-right">
    <a class="layui-btn layui-btn-xs" lay-event="edit"><i class="layui-icon layui-icon-edit"></i>编辑</a>
    <a class="layui-btn layui-btn-xs layui-btn-normal" lay-event="item"><i class="layui-icon layui-icon-list"></i>子项</a>
    <a class="layui-btn layui-btn-xs layui-btn-warm" lay-event="tree"><i class="layui-icon layui-icon-tree"></i>结构图</a>
    <@shiro.hasPermission name="user:add"><a class="layui-btn layui-btn-danger layui-btn-xs" lay-event="delete"><i class="layui-icon layui-icon-delete"></i>删除</a></@shiro.hasPermission>
</script>

<!--js逻辑-->
<script>
    layui.use(['form', 'table', 'spLayer', 'spTable', 'spLayui'], function () {
        var form = layui.form,
            table = layui.table,
            spLayer = layui.spLayer,
            spLayui = layui.spLayui,
            spTable = layui.spTable;

        // 表格及数据初始化
        var tableIns = spTable.render({
            url: '${request.contextPath}/technology/bom/page',
            cols: [
                [{
                    type: 'radio'
                }, {
                    field: 'bomCode', title: 'BOM编号'
                }, {
                    field: 'materielCode', title: '物料编码'
                }, {
                    field: 'materielDesc', title: '物料名称'
                }, {
                    field: 'remark', title: '备注'
                }, {
                    fixed: 'right',
                    field: 'operate',
                    title: '操作',
                    toolbar: '#js-record-table-toolbar-right',
                    unresize: true,
                    width: 300
                }]
            ],
            done: function (res, curr, count) {
            }
        });

        /*
         * 数据表格中form表单元素是动态插入,所以需要更新渲染下
         * http://www.layui.com/doc/modules/form.html#render
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
                    // 重新从第 1 页开始
                    curr: 1
                }
            });

            // 阻止表单跳转。如果需要表单跳转，去掉这段即可。
            return false;
        });

        /**
         * 头工具栏事件
         */
        table.on('toolbar(js-record-table-filter)', function (obj) {

            // 添加
            if (obj.event === 'add') {
                var index = spLayer.open({
                    title: '添加',
                    area: ['70%', '90%'],
                    content: '${request.contextPath}/technology/bom/add-or-update-ui'
                });
                //新开一个TAB标签 url  标题名称 图标
                //spLayui.createTableItem('/technology/bom/add-or-update-ui?mpi=bom-1','BOM信息','fa fa-dropbox');
            }
        });

        /**
         * 监听行工具事件
         */
        table.on('tool(js-record-table-filter)', function (obj) {
            var data = obj.data;

            // 编辑
            if (obj.event === 'edit') {
                spLayer.open({
                    title: '编辑',
                    area: ['80%', '90%'],
                    // 请求url参数
                    spWhere: {id: data.id},
                    content: '${request.contextPath}/technology/bom/add-or-update-ui'
                });
            }

            // 删除
            if (obj.event === 'delete') {
                layer.confirm('确认要删除吗？', function (index) {
                    spUtil.ajax({
                        url: '${request.contextPath}/technology/bom/delete',
                        async: false,
                        type: 'POST',
                        // 是否显示 loading
                        showLoading: true,
                        // 是否序列化参数
                        serializable: false,
                        // 参数
                        data: {
                            id: data.id
                        },
                        success: function (data) {
                            tableIns.reload();
                            layer.close(index);
                        },
                        error: function () {
                        }
                    });
                });
            }

            // 子项管理
            if (obj.event === 'item') {
                spLayer.open({
                    title: 'BOM子项管理 - ' + data.bomCode,
                    area: ['85%', '85%'],
                    btn: [],
                    spWhere: {bomHeadId: data.id},
                    content: '${request.contextPath}/technology/bom/item/list-ui'
                });
            }

            // 产品分解结构图
            if (obj.event === 'tree') {
                spLayer.open({
                    title: '产品分解结构图 - ' + data.bomCode,
                    area: ['90%', '85%'],
                    btn: [],
                    spWhere: {bomId: data.id},
                    content: '${request.contextPath}/technology/bom/tree-ui'
                });
            }
        });
    });
</script>
</body>
</html>