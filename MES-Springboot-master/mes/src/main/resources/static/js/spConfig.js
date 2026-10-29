// 配置类
var spConfig = {};

// 系统角色字典：0 表示否，1 表示是
spConfig.sysRoleDict = {
  0: '否',
  1: '是'
};

// 逻辑删除字典：0 正常，2 异常
spConfig.isDeletedDict = {
  0: '正常',
  2: '异常'
};

// 设备状态字典：0 正常，1 禁用
spConfig.deviceStatusDict = {
  0: '正常',
  1: '禁用'
};

// 性别字典
spConfig.sexDict = {
  '0': '女',
  '1': '男',
  '2': '其他'
};

// 物料类型字典
spConfig.materialTypeDict = {
  'RM': '原材料',
  'FG': '成品',
  'PG': '半成品'
};

// 工单状态字典
spConfig.orderStatueDict = {
  1: '创建',
  2: '进行中',
  3: '结束',
  4: '终结'
};

// 工单类型字典
spConfig.orderTypeDict = {
  'P': '量产',
  'A': '验证',
  'F': '返工'
};

// 订单分类字典
spConfig.orderCategoryDict = {
  'DEMAND': '需求订单',
  'FORECAST': '预测订单'
};

// 审批状态字典
spConfig.approvalStatusDict = {
  '01': '待提交',
  '02': '待审批',
  '03': '已通过',
  '04': '已驳回'
};

// MRP配送状态字典
spConfig.dispatchStatusDict = {
  '01': '待下发',
  '02': '已下发'
};

// MRP入库状态字典
spConfig.storageStatusDict = {
  '01': '待生成',
  '02': '生成'
};