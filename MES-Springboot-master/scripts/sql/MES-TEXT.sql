-- 若数据库存在则删除
DROP DATABASE IF EXISTS sparchetype;

-- 重新创建数据库，默认字符集utf8mb4、排序规则utf8mb4_unicode_ci（适配emoji、最全中文兼容）
CREATE DATABASE IF NOT EXISTS sparchetype
DEFAULT CHARACTER SET utf8mb4
DEFAULT COLLATE utf8mb4_unicode_ci;

-- 切换到新建数据库
USE sparchetype;
-- =============================================
-- MySQL-20210225.sql
-- 基础数据库（初始表结构+种子数据）
-- =============================================
/*
 Navicat Premium Data Transfer
 Source Server         : aliyunmes
 Source Server Type    : MySQL
 Source Server Version : 80016
 Source Host           : rm-8vb0sazu4d9g0u290eo.mysql.zhangbei.rds.aliyuncs.com:3306
 Source Schema         : sparchetype
 Target Server Type    : MySQL
 Target Server Version : 80016
 File Encoding         : 65001
 Date: 21/07/2020 08:56:18
*/
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for sp_bom
-- ----------------------------
DROP TABLE IF EXISTS `sp_bom`;
CREATE TABLE `sp_bom`  (
  `id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '主键id',
  `bom_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'bom编号',
  `materiel_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '物料ID',
  `materiel_desc` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '物料描述',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `create_time` datetime(0) NOT NULL COMMENT '创建时间',
  `create_username` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '创建人',
  `update_time` datetime(0) NOT NULL COMMENT '最后更新时间',
  `update_username` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '最后更新人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'BOM主信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sp_bom_item
-- ----------------------------
DROP TABLE IF EXISTS `sp_bom_item`;
CREATE TABLE `sp_bom_item`  (
  `id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '主键id',
  `bom_head_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'bom编号',
  `materiel_item_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '物料ID',
  `materiel_item_desc` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '物料描述',
  `item_num` decimal(10, 0) NULL DEFAULT 0 COMMENT '用量',
  `item_unit` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '子项基本单位',
  `item_type` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '子项类型（0-单纯物料，1-物料BOM）',
  `ref_bom_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '引用的BOM头ID',
  `parent_item_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '父级BOM子项ID',
  `bom_level` int NULL DEFAULT 1 COMMENT 'BOM层级',
  `create_time` datetime(0) NOT NULL COMMENT '创建时间',
  `create_username` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '创建人',
  `update_time` datetime(0) NOT NULL COMMENT '最后更新时间',
  `update_username` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '最后更新人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'BOM子项表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sp_flow
-- ----------------------------
DROP TABLE IF EXISTS `sp_flow`;
CREATE TABLE `sp_flow`  (
  `id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '主键id',
  `flow` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '流程',
  `flow_desc` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '线体描述',
  `process` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '流程绘制 A——>B——>C',
  `create_time` datetime(0) NOT NULL COMMENT '创建时间',
  `create_username` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '创建人',
  `update_time` datetime(0) NOT NULL COMMENT '最后更新时间',
  `update_username` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '最后更新人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '流程表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sp_flow_oper_relation
-- ----------------------------
DROP TABLE IF EXISTS `sp_flow_oper_relation`;
CREATE TABLE `sp_flow_oper_relation`  (
  `id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '主键id',
  `flow_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '流程ID',
  `flow` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '流程代码',
  `per_oper_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '前道工序ID',
  `per_oper` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '前道工序代码',
  `oper_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '当前工序ID',
  `oper` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '当前工序\r\n',
  `next_oper_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '下道工序ID',
  `next_oper` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '下道工序',
  `sort_num` int(11) NOT NULL COMMENT '排序',
  `oper_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '工序类型（首道工序firstOper;最后一道工序lastOper）',
  `create_time` datetime(0) NOT NULL COMMENT '创建时间',
  `create_username` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '创建人',
  `update_time` datetime(0) NOT NULL COMMENT '最后更新时间',
  `update_username` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '最后更新人',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `flow_id_index`(`flow_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '流程与工序关系表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sp_materile
-- ----------------------------
DROP TABLE IF EXISTS `sp_materile`;
CREATE TABLE `sp_materile`  (
  `id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '主键id',
  `materiel` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '物料编码',
  `materiel_desc` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '物料描述',
  `unit` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '基本单位',
  `product_group` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '产品组',
  `mat_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '物料类型',
  `materiel_source` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '物料来源：自制/委外/外购',
  `model` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '型号',
  `size` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '尺寸',
  `flow_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '流程',
  `flow_desc` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '流程描述',
  `picture` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '物料图片',
  `characteristics` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '特性/规格参数',
  `inspection_std` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '检验标准',
  `component_notes` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '零部件备注',
  `create_time` datetime(0) NOT NULL COMMENT '创建时间',
  `create_username` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '创建人',
  `update_time` datetime(0) NOT NULL COMMENT '最后更新时间',
  `update_username` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '最后更新人',
  `is_deleted` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '逻辑删除：1 表示删除，0 表示未删除，2 表示禁用',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '基础物料表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sp_oper
-- ----------------------------
DROP TABLE IF EXISTS `sp_oper`;
CREATE TABLE `sp_oper`  (
  `id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '主键id',
  `oper` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '工序\r\n',
  `oper_desc` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '工序描述',
  `create_time` datetime(0) NOT NULL COMMENT '创建时间',
  `create_username` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '创建人',
  `update_time` datetime(0) NOT NULL COMMENT '最后更新时间',
  `update_username` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '最后更新人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '工序表' ROW_FORMAT = Dynamic;
ALTER TABLE `sp_oper`
  ADD COLUMN `working_hours` decimal(10,2) DEFAULT NULL COMMENT '工时',
  ADD COLUMN `manufacturing_cycle` decimal(10,2) DEFAULT NULL COMMENT '制造周期',
  ADD COLUMN `generate_plan` varchar(2) DEFAULT '1' COMMENT '是否生成生产计划：0否 1是',
  ADD COLUMN `is_deleted` varchar(2) DEFAULT '0' COMMENT '逻辑删除：1删除 0未删除 2禁用',
  ADD COLUMN `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  ADD INDEX `idx_oper` (`oper`) USING BTREE;

-- ----------------------------
-- Table structure for sp_sys_dict
-- ----------------------------
DROP TABLE IF EXISTS `sp_sys_dict`;
CREATE TABLE `sp_sys_dict`  (
  `id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '主键id',
  `name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '标签名',
  `value` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '数据值',
  `type` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '类型',
  `descr` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '\"\"' COMMENT '描述',
  `sort_num` int(11) NOT NULL COMMENT '排序（升序）',
  `parent_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '\"\"' COMMENT '父级id',
  `is_deleted` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '逻辑删除：1 表示删除，0 表示未删除，2 表示禁用',
  `create_time` datetime(0) NOT NULL COMMENT '创建时间',
  `create_username` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '创建人',
  `update_time` datetime(0) NOT NULL COMMENT '最后更新时间',
  `update_username` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '最后更新人',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_sp_sys_dict_name`(`type`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '系统字典表' ROW_FORMAT = Dynamic;
-- ----------------------------
-- Records of sp_sys_dict
-- ----------------------------
INSERT INTO `sp_sys_dict` VALUES ('CSQ-DICT-001', '原材料', 'RM', 'material_type', '物料类型', 1, '\"\"', '0', '2026-06-01 08:00:00', 'admin', '2026-06-01 08:00:00', 'admin');
INSERT INTO `sp_sys_dict` VALUES ('CSQ-DICT-002', '成品', 'FG', 'material_type', '物料类型', 2, '\"\"', '0', '2026-06-01 08:00:00', 'admin', '2026-06-01 08:00:00', 'admin');
INSERT INTO `sp_sys_dict` VALUES ('CSQ-DICT-003', '半成品', 'PG', 'material_type', '物料类型', 3, '\"\"', '0', '2026-06-01 08:00:00', 'admin', '2026-06-01 08:00:00', 'admin');

-- ----------------------------
-- Table structure for sp_sys_menu
-- ----------------------------
DROP TABLE IF EXISTS `sp_sys_menu`;
CREATE TABLE `sp_sys_menu`  (
  `id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '主键id',
  `code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '菜单名称',
  `url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '菜单URL',
  `parent_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '父菜单ID，一级菜单设为0',
  `grade` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '层级：1级、2级、3级......',
  `sort_num` int(11) NOT NULL COMMENT '排序',
  `type` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '类型：0 目录；1 菜单；2 按钮',
  `permission` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '\"\"' COMMENT '授权(多个用逗号分隔，如：sys:menu:list,sys:menu:create)',
  `icon` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '\"\"' COMMENT '菜单图标',
  `descr` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '\"\"' COMMENT '描述',
  `create_time` datetime(0) NOT NULL COMMENT '创建时间',
  `create_username` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '创建人',
  `update_time` datetime(0) NOT NULL COMMENT '最后更新时间',
  `update_username` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '最后更新人',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `idx_sp_sys_menu_name`(`name`) USING BTREE,
  UNIQUE INDEX `idx_sp_sys_menu_code`(`code`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '系统菜单表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sp_sys_menu
-- ----------------------------
INSERT INTO `sp_sys_menu` VALUES ('1', 'currency', '常规管理', '#', '0', '1', 1, '0', 'user:add', 'fa fa-address-book', '', '2019-10-18 11:18:29', 'SongPeng', '2020-03-13 14:07:09', 'admin');
INSERT INTO `sp_sys_menu` VALUES ('10', 'system', '系统管理', '#', '1', '2', 1, '0', 'user:add', 'fa fa-gears', '', '2019-10-18 11:18:29', 'SongPeng', '2019-10-18 11:18:29', 'SongPeng');
INSERT INTO `sp_sys_menu` VALUES ('101', 'menu', '菜单管理', '/admin/sys/menu/list-ui', '10', '3', 1, '0', 'user:add', 'fa fa-bars', '', '2019-10-18 11:18:29', 'SongPeng', '2019-10-18 11:18:29', 'SongPeng');
INSERT INTO `sp_sys_menu` VALUES ('102', 'user', '用户管理', '/admin/sys/user/list-ui', '10', '3', 2, '0', 'user:add', 'fa fa-user', '', '2019-10-18 11:18:29', 'SongPeng', '2019-10-18 11:18:29', 'SongPeng');
INSERT INTO `sp_sys_menu` VALUES ('103', 'role', '角色管理', '/admin/sys/role/list-ui', '10', '3', 3, '0', 'user:add', 'fa fa-child', '', '2019-10-18 11:18:29', 'SongPeng', '2019-10-18 11:18:29', 'SongPeng');
INSERT INTO `sp_sys_menu` VALUES ('105', 'basedata', '基础数据管理', '/basedata/manager/list-ui', '1', '2', 2, '0', 'user:add', 'fa fa-cog', '', '2019-10-18 11:18:29', 'SongPeng', '2019-10-18 11:18:29', 'SongPeng');
INSERT INTO `sp_sys_menu` VALUES ('107', 'team', '班组员工管理', '/admin/basedata/team/list-ui', '105', '3', 4, '0', 'user:add', 'fa fa-users', '', '2026-08-17 15:20:23', 'admin', '2026-08-17 15:20:23', 'admin');
INSERT INTO `sp_sys_menu` VALUES ('108', 'devicegroup', '编组设备管理', '/admin/sys/deviceGroup/list-ui', '105', '3', 6, '0', '', 'fa fa-object-group', '', '2026-08-17 15:20:23', 'admin', '2026-08-17 15:20:23', 'admin');
INSERT INTO `sp_sys_menu` VALUES ('109', 'device', '设备管理', '/admin/sys/device/list-ui', '105', '3', 5, '0', '', 'fa fa-microchip', '', '2026-08-17 15:20:23', 'admin', '2026-08-17 15:20:23', 'admin');
INSERT INTO `sp_sys_menu` VALUES ('110', 'workcell', '加工单元管理', '/admin/sys/workCell/list-ui', '105', '3', 7, '0', '', 'fa fa-cube', '', '2026-08-17 15:20:23', 'admin', '2026-08-17 15:20:23', 'admin');
INSERT INTO `sp_sys_menu` VALUES ('12', 'order', '计划管理', '', '1', '2', 4, '0', 'user:add', 'fa fa-calendar', '', '2019-10-18 11:18:29', 'Wangziyang', '2021-02-21 14:59:56', 'admin');
INSERT INTO `sp_sys_menu` VALUES ('121', 'orderRelease', '工单下达', '/plan/work-order/release-list-ui', '12', '3', 1, '0', 'user:add', 'fa fa-flag-o', '', '2019-10-18 11:18:29', 'Wangziyang', '2019-10-18 11:18:29', 'Wangziyang');
INSERT INTO `sp_sys_menu` VALUES ('126', 'workOrderConfirm', '工单确认', '/plan/work-order/confirm-list-ui', '12', '3', 2, '0', 'user:add', 'fa fa-check-circle-o', '工单确认管理', '2026-08-16 00:00:00', 'admin', '2026-08-16 00:00:00', 'admin');
INSERT INTO `sp_sys_menu` VALUES ('13', 'materiel', '存储管理', '#', '1', '2', 2, '0', 'user:add', 'fa fa-cubes', '', '2019-10-18 11:18:29', 'Wangziyang', '2019-10-18 11:18:29', 'Wangziyang');
INSERT INTO `sp_sys_menu` VALUES ('132', 'warehouse', '仓库管理', '/warehouse/list-ui', '13', '3', 2, '0', 'user:add', 'fa fa-building-o', '仓库管理（库房库位及容量）', '2021-03-01 00:00:00', 'admin', '2021-03-01 00:00:00', 'admin');
INSERT INTO `sp_sys_menu` VALUES ('133', 'inventoryQuery', '库存管理', '/warehouse/inventory/list-ui', '13', '3', 3, '0', 'user:add', 'fa fa-cubes', '库存管理', '2021-03-01 00:00:00', 'admin', '2021-03-01 00:00:00', 'admin');
INSERT INTO `sp_sys_menu` VALUES ('135', 'inventoryFlow', '流水管理', '/warehouse/flow/list-ui', '13', '3', 5, '0', 'user:add', 'fa fa-exchange', '库存变动流水管理', '2026-08-16 00:00:00', 'admin', '2026-08-16 00:00:00', 'admin');
INSERT INTO `sp_sys_menu` VALUES ('15', 'ProcessManage', '工艺管理', '', '1', '2', 3, '0', 'user:add', 'fa fa-wrench', '', '2019-10-18 11:18:29', 'Wangziyang', '2021-02-21 15:01:47', 'admin');
INSERT INTO `sp_sys_menu` VALUES ('151', 'flowProcess', '工艺路线管理', '/basedata/flow/process/list-ui', '15', '3', 1, '0', 'user:add', 'fa fa-retweet', '', '2019-10-18 11:18:29', 'Wangziyang', '2019-10-18 11:18:29', 'Wangziyang');
INSERT INTO `sp_sys_menu` VALUES ('152', 'bom', '工艺BOM管理', '/technology/bom/list-ui', '15', '3', 2, '0', 'user:add', 'fa fa-file-text-o', '', '2019-10-18 11:18:29', 'Wangziyang', '2019-10-18 11:18:29', 'Wangziyang');
INSERT INTO `sp_sys_menu` VALUES ('17', 'DigitalSimulation', '黑科数字孪生', '#', '1', '2', 7, '0', 'user:add', 'fa fa-ravelry', '', '2019-10-18 11:18:29', 'Wangziyang', '2019-10-18 11:18:29', 'Wangziyang');
INSERT INTO `sp_sys_menu` VALUES ('171', 'DigitalSimulationFrom', '数字仿真3D仓库', '/digital/simulation/list-ui', '17', '3', 1, '0', 'user:add', 'fa fa-codepen', '', '2019-10-18 11:18:29', 'Wangziyang', '2019-10-18 11:18:29', 'Wangziyang');
INSERT INTO `sp_sys_menu` VALUES ('1ca30d6c9a0c11f1bf621c8341cc83a0', 'materileDef', '物料管理', '/basedata/materile/list-ui', '105', '3', 1, '1', 'materile:view', 'fa fa-cube', '物料管理', '2026-08-17 15:20:23', 'admin', '2026-08-17 15:20:23', 'admin');
INSERT INTO `sp_sys_menu` VALUES ('1cac203f9a0c11f1bf621c8341cc83a0', 'operDef', '工序管理', '/basedata/sp-oper/list-ui', '105', '3', 2, '1', 'oper:view,oper:add,oper:edit,oper:delete', 'fa fa-tasks', '工序管理', '2026-08-17 15:20:23', 'admin', '2026-08-17 15:20:23', 'admin');
INSERT INTO `sp_sys_menu` VALUES ('1d330dab9a0c11f1bf621c8341cc83a0', 'productProcess', '工艺规划管理', '/technology/process/plan/list-ui', '15', '3', 1, '1', 'productProcess:view,productProcess:add,productProcess:edit,productProcess:delete,productProcess:lock', 'fa fa-cogs', '工艺规划管理', '2026-08-17 15:20:24', 'admin', '2026-08-17 15:20:24', 'admin');
INSERT INTO `sp_sys_menu` VALUES ('1d62b67b9a0c11f1bf621c8341cc83a0', 'processContent', '工艺内容编制', '/technology/process/content/list-ui', '15', '3', 2, '1', 'processContent:view,processContent:add,processContent:edit,processContent:delete', 'fa fa-edit', '工艺内容编制', '2026-08-17 15:20:24', 'admin', '2026-08-17 15:20:24', 'admin');
INSERT INTO `sp_sys_menu` VALUES ('1d63c9e29a0c11f1bf621c8341cc83a0', 'processQuery', '产品工艺查询', '/technology/process/query/list-ui', '15', '3', 3, '1', 'processQuery:view', 'fa fa-search', '产品工艺查询', '2026-08-17 15:20:24', 'admin', '2026-08-17 15:20:24', 'admin');

SET FOREIGN_KEY_CHECKS = 1;

-- ----------------------------
-- Table structure for sp_sys_role
-- ----------------------------
DROP TABLE IF EXISTS `sp_sys_role`;
CREATE TABLE `sp_sys_role`  (
  `id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '主键id',
  `name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '角色名称',
  `code` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '角色编码',
  `descr` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '\"\"' COMMENT '角色描述',
  `is_deleted` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '逻辑删除：1 表示删除，0 表示未删除，2 表示禁用',
  `is_sys_role` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '0' COMMENT '是否系统内置角色：0 否，1 是',
  `create_time` datetime(0) NOT NULL COMMENT '创建时间',
  `create_username` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '创建人',
  `update_time` datetime(0) NOT NULL COMMENT '最后更新时间',
  `update_username` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '最后更新人',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `idx_sp_sys_role_name`(`name`) USING BTREE,
  UNIQUE INDEX `idx_sp_sys_role_code`(`code`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '角色表' ROW_FORMAT = Dynamic;
-- ----------------------------
-- Records of sp_sys_role
-- ----------------------------
INSERT INTO `sp_sys_role` VALUES ('1185025876737396738', '超级管理员', 'admin', '超级管理员', '0', '1', '2019-10-18 10:52:40', 'SongPeng', '2020-03-13 14:06:43', 'admin');
INSERT INTO `sp_sys_role` VALUES ('2089612729779847170', '工单下达', '1', '测试', '0', '0', '2026-08-18 15:17:53', 'admin', '2026-08-18 15:17:53', 'admin');
INSERT INTO `sp_sys_role` VALUES ('2089612824571117570', '工单确认', '2', '测试', '0', '0', '2026-08-18 15:18:15', 'admin', '2026-08-18 15:18:15', 'admin');
INSERT INTO `sp_sys_role` VALUES ('2089619368293502978', '无权限', 'no', '无权限', '0', '0', '2026-08-18 15:44:15', 'admin', '2026-08-18 15:44:15', 'admin');

-- ----------------------------
-- Table structure for sp_sys_role_menu
-- ----------------------------
DROP TABLE IF EXISTS `sp_sys_role_menu`;
CREATE TABLE `sp_sys_role_menu`  (
  `id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '主键id',
  `role_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '角色id',
  `menu_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '菜单id',
  `create_time` datetime(0) NOT NULL COMMENT '创建时间',
  `create_username` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '创建人',
  `update_time` datetime(0) NOT NULL COMMENT '最后更新时间',
  `update_username` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '最后更新人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '角色对应的菜单表' ROW_FORMAT = Dynamic;
-- ----------------------------
-- Records of sp_sys_role_menu
-- ----------------------------
INSERT INTO `sp_sys_role_menu` VALUES ('2089251287650095105', '1185025876737396738', '1', '2026-08-17 15:21:38', 'admin', '2026-08-17 15:21:38', 'admin');
INSERT INTO `sp_sys_role_menu` VALUES ('2089251287650095106', '1185025876737396738', '10', '2026-08-17 15:21:38', 'admin', '2026-08-17 15:21:38', 'admin');
INSERT INTO `sp_sys_role_menu` VALUES ('2089251287650095107', '1185025876737396738', '101', '2026-08-17 15:21:38', 'admin', '2026-08-17 15:21:38', 'admin');
INSERT INTO `sp_sys_role_menu` VALUES ('2089251287650095108', '1185025876737396738', '102', '2026-08-17 15:21:38', 'admin', '2026-08-17 15:21:38', 'admin');
INSERT INTO `sp_sys_role_menu` VALUES ('2089251287650095109', '1185025876737396738', '103', '2026-08-17 15:21:38', 'admin', '2026-08-17 15:21:38', 'admin');
INSERT INTO `sp_sys_role_menu` VALUES ('2089251287650095110', '1185025876737396738', '105', '2026-08-17 15:21:38', 'admin', '2026-08-17 15:21:38', 'admin');
INSERT INTO `sp_sys_role_menu` VALUES ('2089251287650095111', '1185025876737396738', '107', '2026-08-17 15:21:38', 'admin', '2026-08-17 15:21:38', 'admin');
INSERT INTO `sp_sys_role_menu` VALUES ('2089251287650095112', '1185025876737396738', '108', '2026-08-17 15:21:38', 'admin', '2026-08-17 15:21:38', 'admin');
INSERT INTO `sp_sys_role_menu` VALUES ('2089251287650095113', '1185025876737396738', '109', '2026-08-17 15:21:38', 'admin', '2026-08-17 15:21:38', 'admin');
INSERT INTO `sp_sys_role_menu` VALUES ('2089251287713009665', '1185025876737396738', '110', '2026-08-17 15:21:38', 'admin', '2026-08-17 15:21:38', 'admin');
INSERT INTO `sp_sys_role_menu` VALUES ('2089251287713009666', '1185025876737396738', '1ca30d6c9a0c11f1bf621c8341cc83a0', '2026-08-17 15:21:38', 'admin', '2026-08-17 15:21:38', 'admin');
INSERT INTO `sp_sys_role_menu` VALUES ('2089251287713009667', '1185025876737396738', '1cac203f9a0c11f1bf621c8341cc83a0', '2026-08-17 15:21:38', 'admin', '2026-08-17 15:21:38', 'admin');
INSERT INTO `sp_sys_role_menu` VALUES ('2089251287713009668', '1185025876737396738', '12', '2026-08-17 15:21:38', 'admin', '2026-08-17 15:21:38', 'admin');
INSERT INTO `sp_sys_role_menu` VALUES ('2089251287713009669', '1185025876737396738', '121', '2026-08-17 15:21:38', 'admin', '2026-08-17 15:21:38', 'admin');
INSERT INTO `sp_sys_role_menu` VALUES ('2089251287713009670', '1185025876737396738', '126', '2026-08-17 15:21:38', 'admin', '2026-08-17 15:21:38', 'admin');
INSERT INTO `sp_sys_role_menu` VALUES ('2089251287713009671', '1185025876737396738', '13', '2026-08-17 15:21:38', 'admin', '2026-08-17 15:21:38', 'admin');
INSERT INTO `sp_sys_role_menu` VALUES ('2089251287713009672', '1185025876737396738', '132', '2026-08-17 15:21:38', 'admin', '2026-08-17 15:21:38', 'admin');
INSERT INTO `sp_sys_role_menu` VALUES ('2089251287713009673', '1185025876737396738', '133', '2026-08-17 15:21:38', 'admin', '2026-08-17 15:21:38', 'admin');
INSERT INTO `sp_sys_role_menu` VALUES ('2089251287713009674', '1185025876737396738', '135', '2026-08-17 15:21:38', 'admin', '2026-08-17 15:21:38', 'admin');
INSERT INTO `sp_sys_role_menu` VALUES ('2089251287713009675', '1185025876737396738', '15', '2026-08-17 15:21:38', 'admin', '2026-08-17 15:21:38', 'admin');
INSERT INTO `sp_sys_role_menu` VALUES ('2089251287713009676', '1185025876737396738', '151', '2026-08-17 15:21:38', 'admin', '2026-08-17 15:21:38', 'admin');
INSERT INTO `sp_sys_role_menu` VALUES ('2089251287713009677', '1185025876737396738', '152', '2026-08-17 15:21:38', 'admin', '2026-08-17 15:21:38', 'admin');
INSERT INTO `sp_sys_role_menu` VALUES ('2089251287775924225', '1185025876737396738', '1d330dab9a0c11f1bf621c8341cc83a0', '2026-08-17 15:21:38', 'admin', '2026-08-17 15:21:38', 'admin');
INSERT INTO `sp_sys_role_menu` VALUES ('2089251287775924226', '1185025876737396738', '1d62b67b9a0c11f1bf621c8341cc83a0', '2026-08-17 15:21:38', 'admin', '2026-08-17 15:21:38', 'admin');
INSERT INTO `sp_sys_role_menu` VALUES ('2089251287775924227', '1185025876737396738', '1d63c9e29a0c11f1bf621c8341cc83a0', '2026-08-17 15:21:38', 'admin', '2026-08-17 15:21:38', 'admin');
INSERT INTO `sp_sys_role_menu` VALUES ('2089251287775924228', '1185025876737396738', '17', '2026-08-17 15:21:38', 'admin', '2026-08-17 15:21:38', 'admin');
INSERT INTO `sp_sys_role_menu` VALUES ('2089251287775924229', '1185025876737396738', '171', '2026-08-17 15:21:38', 'admin', '2026-08-17 15:21:38', 'admin');
INSERT INTO `sp_sys_role_menu` VALUES ('2089612938886873089', '2089612729779847170', '121', '2026-08-18 15:18:42', 'admin', '2026-08-18 15:18:42', 'admin');
INSERT INTO `sp_sys_role_menu` VALUES ('2089613031417413634', '2089612824571117570', '126', '2026-08-18 15:19:04', 'admin', '2026-08-18 15:19:04', 'admin');

-- ----------------------------
-- Table structure for sp_sys_user
-- ----------------------------
DROP TABLE IF EXISTS `sp_sys_user`;
CREATE TABLE `sp_sys_user`  (
  `id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '主键id',
  `job_no` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '""' COMMENT '工号',
  `name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '姓名',
  `username` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '用户名',
  `password` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '密码(加密存储)',
  `password_plain` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '\"\"' COMMENT '密码(明文)',
  `email` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '\"\"' COMMENT '邮箱',
  `mobile` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '联系方式',
  `sex` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '性别(0:女;1:男;2:其他)',
  `birthday` datetime(0) NULL DEFAULT NULL COMMENT '出生日期',
  `id_card` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '\"\"' COMMENT '证件号码',
  `province` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '\"\"' COMMENT '籍贯',
  `city` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '\"\"' COMMENT '联系地址',
  `descr` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '\"\"' COMMENT '备注',
  `is_deleted` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '状态：0正常，2异常',
  `create_time` datetime(0) NOT NULL COMMENT '创建时间',
  `create_username` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '创建人',
  `update_time` datetime(0) NOT NULL COMMENT '最后更新时间',
  `update_username` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '最后更新人',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `idx_sp_sys_user_username`(`username`) USING BTREE COMMENT '用户名唯一索引',
  UNIQUE INDEX `idx_sp_sys_user_mobile`(`mobile`) USING BTREE COMMENT '用户联系方式唯一索引',
  INDEX `idx_sp_sys_user_email`(`email`) USING BTREE COMMENT '用户邮箱唯一索引',
  INDEX `idx_sp_sys_user_id_card`(`id_card`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户信息表' ROW_FORMAT = Dynamic;
-- ----------------------------
-- Records of sp_sys_user
-- ----------------------------
INSERT INTO `sp_sys_user` VALUES ('1184019107907227649', 'YG00001', '超级管理员', 'admin', '9d7281eeaebded0b091340cfa658a7e8', '123', '123@qq.com', '123', '1', '2000-01-01', '789654321', 'A省B市', 'C县D街道', '超级管理员', '0', '2026-08-17 15:20:23', 'admin', '2026-08-17 15:20:23', 'admin');
INSERT INTO `sp_sys_user` VALUES ('2089611978470948866', 'YG00002', '测试-工单下达', '测试1', '0571742e44e1cb204f0e735dcdd5d3d0', '123456', NULL, '666666', '1', '2026-08-18 00:00:00', NULL, NULL, NULL, NULL, '0', '2026-08-18 15:14:53', 'admin', '2026-08-18 15:19:31', 'admin');
INSERT INTO `sp_sys_user` VALUES ('2089612142581481473', 'YG00003', '测试-工单确认', '测试2', 'af47adeea464932206c3cd7f462dfdaa', '123456', NULL, '555555', '0', '2026-08-18 00:00:00', NULL, NULL, NULL, NULL, '0', '2026-08-18 15:15:33', 'admin', '2026-08-18 15:19:27', 'admin');
INSERT INTO `sp_sys_user` VALUES ('2089618835717558274', 'YG00004', '初始1', '初始1', '1698057c460349bbeaf91f0709627f67', '456', NULL, '456', '0', '2026-08-18 00:00:00', NULL, NULL, NULL, NULL, '0', '2026-08-18 15:42:08', 'admin', '2026-08-18 15:44:34', 'admin');
INSERT INTO `sp_sys_user` VALUES ('2089619029704118273', 'YG00005', '初始2', '初始2', '3a90ee08ebccd3a1f1232722e40e96c9', '456', NULL, '4567', '0', '2026-08-18 00:00:00', NULL, NULL, NULL, NULL, '0', '2026-08-18 15:42:55', 'admin', '2026-08-18 15:44:28', 'admin');
INSERT INTO `sp_sys_user` VALUES ('2089619111237193729', 'YG00006', '初始3', '初始3', '6d2fde4229fcfb8300c2c6fb0b3ea9db', '456', NULL, '45678', '0', '2026-08-18 00:00:00', NULL, NULL, NULL, NULL, '0', '2026-08-18 15:43:14', 'admin', '2026-08-18 15:44:25', 'admin');
INSERT INTO `sp_sys_user` VALUES ('2089619194192138241', 'YG00007', '初始4', '初始4', '8e6c85b6235f33b56433e0140821769b', '456', NULL, '456789', '0', '2026-08-18 00:00:00', NULL, NULL, NULL, NULL, '0', '2026-08-18 15:43:34', 'admin', '2026-08-18 15:44:22', 'admin');

-- ----------------------------
-- Table structure for sp_sys_user_role
-- ----------------------------
DROP TABLE IF EXISTS `sp_sys_user_role`;
CREATE TABLE `sp_sys_user_role`  (
  `id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '主键id',
  `user_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '用户id',
  `role_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '角色id',
  `create_time` datetime(0) NOT NULL COMMENT '创建时间',
  `create_username` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '创建人',
  `update_time` datetime(0) NOT NULL COMMENT '最后更新时间',
  `update_username` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '最后更新人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户对应的角色表' ROW_FORMAT = Dynamic;
-- ----------------------------
-- Records of sp_sys_user_role
-- ----------------------------
INSERT INTO `sp_sys_user_role` VALUES ('1242287110472966146', '1184019107907227649', '1185025876737396738', '2020-03-24 11:08:22', 'admin', '2020-03-24 11:08:22', 'admin');
INSERT INTO `sp_sys_user_role` VALUES ('2089613126091243521', '2089612142581481473', '2089612824571117570', '2026-08-18 15:19:27', 'admin', '2026-08-18 15:19:27', 'admin');
INSERT INTO `sp_sys_user_role` VALUES ('2089613144663621634', '2089611978470948866', '2089612729779847170', '2026-08-18 15:19:31', 'admin', '2026-08-18 15:19:31', 'admin');
INSERT INTO `sp_sys_user_role` VALUES ('2089619395984297986', '2089619194192138241', '2089619368293502978', '2026-08-18 15:44:22', 'admin', '2026-08-18 15:44:22', 'admin');
INSERT INTO `sp_sys_user_role` VALUES ('2089619410244931585', '2089619111237193729', '2089619368293502978', '2026-08-18 15:44:25', 'admin', '2026-08-18 15:44:25', 'admin');
INSERT INTO `sp_sys_user_role` VALUES ('2089619423477960705', '2089619029704118273', '2089619368293502978', '2026-08-18 15:44:28', 'admin', '2026-08-18 15:44:28', 'admin');
INSERT INTO `sp_sys_user_role` VALUES ('2089619447431630849', '2089618835717558274', '2089619368293502978', '2026-08-18 15:44:34', 'admin', '2026-08-18 15:44:34', 'admin');

-- ----------------------------
-- Table structure for sp_table_manager
-- ----------------------------
DROP TABLE IF EXISTS `sp_table_manager`;
CREATE TABLE `sp_table_manager`  (
  `id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '主键',
  `table_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '表名称',
  `table_desc` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '表描述',
  `create_time` datetime(0) NOT NULL COMMENT '创建时间',
  `create_username` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '创建人',
  `update_time` datetime(0) NOT NULL COMMENT '最后更新时间',
  `update_username` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '最后更新人',
  `is_deleted` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '逻辑删除：1 表示删除，0 表示未删除，2 表示禁用',
  `permission` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '\"\"' COMMENT '授权(多个用逗号分隔，如：sys:menu:list,sys:menu:create)',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `index1`(`table_name`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '主数据通用管理' ROW_FORMAT = Dynamic;
-- ----------------------------
-- Records of sp_table_manager
-- ----------------------------
INSERT INTO `sp_table_manager` VALUES ('CSQ-TM-001', 'sp_bom', '工艺BOM主数据', '2026-06-01 08:00:00', 'admin', '2026-06-01 08:00:00', 'admin', '0', '\"\"');
INSERT INTO `sp_table_manager` VALUES ('CSQ-TM-002', 'sp_materile', '物料管理', '2026-06-01 08:00:00', 'admin', '2026-06-01 08:00:00', 'admin', '0', '\"\"');

-- ----------------------------
-- Table structure for sp_table_manager_item
-- ----------------------------
DROP TABLE IF EXISTS `sp_table_manager_item`;
CREATE TABLE `sp_table_manager_item`  (
  `id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '主键',
  `table_name_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '表名称id',
  `field` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '字段',
  `field_desc` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '字段描述',
  `must_fill` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '是否必填',
  `sort_num` int(11) NOT NULL COMMENT '排序',
  `create_time` datetime(0) NOT NULL COMMENT '创建时间',
  `create_username` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '创建人',
  `update_time` datetime(0) NOT NULL COMMENT '最后更新时间',
  `update_username` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '最后更新人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '主数据基础数据明细表' ROW_FORMAT = Dynamic;
-- ----------------------------
-- Records of sp_table_manager_item
-- ----------------------------
INSERT INTO `sp_table_manager_item` VALUES ('CSQ-TMI-001', 'CSQ-TM-001', 'materiel_code', '物料编码', 'Y', 1, '2026-06-01 08:00:00', 'admin', '2026-06-01 08:00:00', 'admin');
INSERT INTO `sp_table_manager_item` VALUES ('CSQ-TMI-002', 'CSQ-TM-001', 'materiel_desc', '物料描述', 'Y', 2, '2026-06-01 08:00:00', 'admin', '2026-06-01 08:00:00', 'admin');
INSERT INTO `sp_table_manager_item` VALUES ('CSQ-TMI-003', 'CSQ-TM-001', 'version', '版本号', 'Y', 3, '2026-06-01 08:00:00', 'admin', '2026-06-01 08:00:00', 'admin');
INSERT INTO `sp_table_manager_item` VALUES ('CSQ-TMI-004', 'CSQ-TM-002', 'materiel_code', '物料编码', 'Y', 1, '2026-06-01 08:00:00', 'admin', '2026-06-01 08:00:00', 'admin');
INSERT INTO `sp_table_manager_item` VALUES ('CSQ-TMI-005', 'CSQ-TM-002', 'materiel_desc', '物料描述', 'Y', 2, '2026-06-01 08:00:00', 'admin', '2026-06-01 08:00:00', 'admin');

-- ----------------------------
-- Table structure for sp_bz_team
-- ----------------------------
DROP TABLE IF EXISTS `sp_bz_team`;
CREATE TABLE `sp_bz_team` (
  `id` varchar(64) NOT NULL COMMENT '主键id',
  `code` varchar(64) NOT NULL COMMENT '班组编号',
  `name` varchar(255) NOT NULL COMMENT '班组名称',
  `is_deleted` varchar(1) NOT NULL DEFAULT '0' COMMENT '状态：0正常，2异常',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `create_username` varchar(64) NOT NULL COMMENT '创建人',
  `update_time` datetime NOT NULL COMMENT '最后更新时间',
  `update_username` varchar(64) NOT NULL COMMENT '最后更新人',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='班组表';

-- ----------------------------
-- Table structure for sp_bz_team_user
-- ----------------------------
DROP TABLE IF EXISTS `sp_bz_team_user`;
CREATE TABLE `sp_bz_team_user` (
  `id` varchar(64) NOT NULL COMMENT '主键id',
  `team_id` varchar(64) NOT NULL COMMENT '班组ID',
  `user_id` varchar(64) NOT NULL COMMENT '用户ID（员工ID）',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `create_username` varchar(64) NOT NULL COMMENT '创建人',
  `update_time` datetime NOT NULL COMMENT '最后更新时间',
  `update_username` varchar(64) NOT NULL COMMENT '最后更新人',
  PRIMARY KEY (`id`),
  KEY `idx_team_id` (`team_id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='班组-员工关联表';

-- ----------------------------
-- Table structure for sp_device
-- ----------------------------
DROP TABLE IF EXISTS `sp_device`;
CREATE TABLE `sp_device`  (
  `id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '主键id',
  `device_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '设备编号',
  `device_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '设备名称',
  `device_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '设备类型',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `is_deleted` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '状态：0正常，1禁用',
  `create_time` datetime(0) NOT NULL COMMENT '创建时间',
  `create_username` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '创建人',
  `update_time` datetime(0) NOT NULL COMMENT '最后更新时间',
  `update_username` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '最后更新人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '设备定义表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sp_device_group
-- ----------------------------
DROP TABLE IF EXISTS `sp_device_group`;
CREATE TABLE `sp_device_group`  (
  `id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '主键id',
  `group_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '编组代码',
  `group_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '编组名称',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `is_deleted` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '状态：0正常，2异常',
  `create_time` datetime(0) NOT NULL COMMENT '创建时间',
  `create_username` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '创建人',
  `update_time` datetime(0) NOT NULL COMMENT '最后更新时间',
  `update_username` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '最后更新人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '设备编组表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sp_device_group_item
-- ----------------------------
DROP TABLE IF EXISTS `sp_device_group_item`;
CREATE TABLE `sp_device_group_item`  (
  `id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '主键id',
  `group_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '编组ID',
  `device_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '设备ID',
  `create_time` datetime(0) NOT NULL COMMENT '创建时间',
  `create_username` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '创建人',
  `update_time` datetime(0) NOT NULL COMMENT '最后更新时间',
  `update_username` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '最后更新人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '设备编组明细表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sp_work_cell
-- ----------------------------
DROP TABLE IF EXISTS `sp_work_cell`;
CREATE TABLE `sp_work_cell` (
  `id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '主键id',
  `work_cell_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '加工单元代码',
  `work_cell_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '加工单元名称',
  `standard_capacity` decimal(10,2) DEFAULT NULL COMMENT '标准产能（小时）',
  `work_cell_type` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '加工单元类型',
  `has_line_side_warehouse` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '是否有线边库：0否 1是',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '备注',
  `is_deleted` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '状态：0正常，2异常',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `create_username` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '创建人',
  `update_time` datetime NOT NULL COMMENT '最后更新时间',
  `update_username` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '最后更新人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '加工单元定义表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sp_work_cell_team
-- ----------------------------
DROP TABLE IF EXISTS `sp_work_cell_team`;
CREATE TABLE `sp_work_cell_team` (
  `id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '主键id',
  `work_cell_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '加工单元ID',
  `team_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '班组ID',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `create_username` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '创建人',
  `update_time` datetime NOT NULL COMMENT '最后更新时间',
  `update_username` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '最后更新人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '加工单元班组关联表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sp_work_cell_device_group
-- ----------------------------
DROP TABLE IF EXISTS `sp_work_cell_device_group`;
CREATE TABLE `sp_work_cell_device_group` (
  `id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '主键id',
  `work_cell_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '加工单元ID',
  `device_group_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '编组设备ID',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `create_username` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '创建人',
  `update_time` datetime NOT NULL COMMENT '最后更新时间',
  `update_username` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '最后更新人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '加工单元编组设备关联表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sp_warehouse
-- ----------------------------
DROP TABLE IF EXISTS `sp_warehouse`;
CREATE TABLE `sp_warehouse` (
  `id` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '主键',
  `warehouse_code` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL COMMENT '库房编号(KF001、KF002...)',
  `warehouse_name` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL COMMENT '库房名称',
  `capacity` int(11) DEFAULT NULL COMMENT '库房容量（正整数）',
  `location_count` int(11) DEFAULT 0 COMMENT '库位数量（非负整数）',
  `warehouse_type` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL COMMENT '库房类型（如：零件库、半成品库、成品库等，3D仿真展示用）',
  `spec` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL COMMENT '库房规格（3D仿真展示用）',
  `remark` varchar(500) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL COMMENT '备注',
  `is_deleted` varchar(2) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT '0' COMMENT '状态(00:删除;01:正常;02:禁用)',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `create_username` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL COMMENT '创建人',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `update_username` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_warehouse_code` (`warehouse_code`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='库房表';

-- ----------------------------
-- Table structure for sp_warehouse_location   
-- ----------------------------
DROP TABLE IF EXISTS `sp_warehouse_location`;
CREATE TABLE `sp_warehouse_location` (
  `id` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '主键',
  `location_code` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL COMMENT '库位编码(KF001-1、KF001-2...)',
  `location_name` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL COMMENT '库位名称',
  `warehouse_id` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL COMMENT '所属库房ID',
  `warehouse_code` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL COMMENT '所属库房编号',
  `warehouse_name` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL COMMENT '所属库房名称',
  `materiel_code` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL COMMENT '存放物料编码',
  `materiel_desc` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL COMMENT '存放物料描述',
  `capacity` int(11) DEFAULT NULL COMMENT '容量（库房容量/库位数量，向下取整）',
  `remark` varchar(500) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL COMMENT '备注',
  `is_deleted` varchar(2) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT '0' COMMENT '状态(00:删除;01:正常;02:禁用)',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `create_username` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL COMMENT '创建人',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `update_username` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `idx_location_code` (`location_code`) USING BTREE,
  KEY `idx_warehouse_id` (`warehouse_id`) USING BTREE,
  KEY `idx_materiel_code` (`materiel_code`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='库位表';

-- ----------------------------
-- Table structure for sp_inventory
-- ----------------------------
DROP TABLE IF EXISTS `sp_inventory`;
CREATE TABLE `sp_inventory` (
  `id` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '主键',
  `materiel_code` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL COMMENT '物料编码',
  `materiel_desc` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL COMMENT '物料描述',
  `qty` decimal(18,2) DEFAULT 0 COMMENT '实际库存数量',
  `locked_qty` decimal(18,2) DEFAULT 0 COMMENT '锁定数量（订单预占）',
  `unit` varchar(32) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL COMMENT '单位',
  `warehouse_id` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL COMMENT '库房ID',
  `warehouse_code` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL COMMENT '库房编号',
  `warehouse_name` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL COMMENT '库房名称',
  `location_id` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL COMMENT '库位ID',
  `location_code` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT '' COMMENT '库位编码（空表示仓库级库存）',
  `status` varchar(2) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT '01' COMMENT '状态：01 可用 02 冻结',
  `version` int(11) DEFAULT 0 COMMENT '版本号（库存扣减时用乐观锁）',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `create_username` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL COMMENT '创建人',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `update_username` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `uk_inventory` (`materiel_code`, `warehouse_code`, `location_code`) USING BTREE,
  KEY `idx_materiel_code` (`materiel_code`) USING BTREE,
  KEY `idx_warehouse_id` (`warehouse_id`) USING BTREE,
  KEY `idx_location_id` (`location_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='库存表';

-- ----------------------------
-- Table structure for sp_inventory_flow
-- ----------------------------
DROP TABLE IF EXISTS `sp_inventory_flow`;
CREATE TABLE `sp_inventory_flow` (
  `id` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '主键',
  `flow_code` varchar(32) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL COMMENT '流水编号(LS00000001...)',
  `materiel_code` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL COMMENT '物料编码',
  `materiel_desc` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL COMMENT '物料描述',
  `warehouse_code` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL COMMENT '库房编号',
  `location_code` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT '' COMMENT '库位编号（空表示仓库级库存）',
  `change_type` varchar(16) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL COMMENT '变动类型：IN 入库 / OUT 出库',
  `change_qty` decimal(18,2) DEFAULT NULL COMMENT '变动数量（正负：入库为正、出库为负）',
  `before_qty` decimal(18,2) DEFAULT NULL COMMENT '变动前数量',
  `after_qty` decimal(18,2) DEFAULT NULL COMMENT '变动后数量',
  `order_code` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL COMMENT '工单编号',
  `remark` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL COMMENT '备注',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `create_username` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL COMMENT '创建人',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `update_username` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `uk_flow_code` (`flow_code`) USING BTREE,
  KEY `idx_flow_materiel_code` (`materiel_code`) USING BTREE,
  KEY `idx_flow_order_code` (`order_code`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='库存流水表';

-- ----------------------------
-- Table structure for sp_work_order
-- ----------------------------
DROP TABLE IF EXISTS `sp_work_order`;
CREATE TABLE `sp_work_order` (
  `id` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '主键',
  `order_code` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL COMMENT '工单编号(GD00000001...)',
  `materiel_code` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL COMMENT '物料编码',
  `materiel_desc` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL COMMENT '物料名称',
  `order_type` varchar(16) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL COMMENT '工单类型：IN 入库 / OUT 出库',
  `qty` int(11) DEFAULT NULL COMMENT '数量（正整数）',
  `start_time` datetime DEFAULT NULL COMMENT '开始时间',
  `end_time` datetime DEFAULT NULL COMMENT '结束时间',
  `status` varchar(2) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT '01' COMMENT '状态：01 待确认 02 已完成',
  `warehouse_code` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL COMMENT '库房编号（入库工单）',
  `location_code` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL COMMENT '库位编号（入库工单可空）',
  `bom_id` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL COMMENT '出库使用的工艺BOM头ID',
  `remark` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL COMMENT '备注',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `create_username` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL COMMENT '创建人',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `update_username` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `uk_order_code` (`order_code`) USING BTREE,
  KEY `idx_order_materiel_code` (`materiel_code`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='工单表';

-- ----------------------------
-- Table structure for sp_work_order_requirement
-- ----------------------------
DROP TABLE IF EXISTS `sp_work_order_requirement`;
CREATE TABLE `sp_work_order_requirement` (
  `id` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '主键',
  `order_code` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL COMMENT '工单编号',
  `materiel_code` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL COMMENT '物料编码',
  `materiel_desc` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL COMMENT '物料描述',
  `required_qty` decimal(18,2) DEFAULT NULL COMMENT '需求数量（=已锁定数量）',
  `unit` varchar(32) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL COMMENT '单位',
  `inventory_id` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL COMMENT '锁定的库存记录ID',
  `warehouse_code` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL COMMENT '锁定库房编号',
  `location_code` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT '' COMMENT '锁定库位编号',
  `status` varchar(2) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT '01' COMMENT '状态：01 已锁定 02 已发放',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `create_username` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL COMMENT '创建人',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `update_username` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_req_order_code` (`order_code`) USING BTREE,
  KEY `idx_req_materiel_code` (`materiel_code`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='工单物料需求表';

-- ----------------------------
-- Table structure for sp_product_process
-- ----------------------------
DROP TABLE IF EXISTS `sp_product_process`;
CREATE TABLE `sp_product_process` (
  `id` varchar(64) NOT NULL COMMENT '主键',
  `bom_id` varchar(64) DEFAULT NULL COMMENT 'BOM头ID',
  `bom_code` varchar(255) DEFAULT NULL COMMENT 'BOM编号',
  `materiel_code` varchar(255) DEFAULT NULL COMMENT '物料编码',
  `materiel_desc` varchar(255) DEFAULT NULL COMMENT '物料描述',
  `flow_id` varchar(64) DEFAULT NULL COMMENT '关联流程ID',
  `flow` varchar(255) DEFAULT NULL COMMENT '关联流程编码',
  `flow_desc` varchar(255) DEFAULT NULL COMMENT '关联流程描述',
  `locked` varchar(2) DEFAULT '0' COMMENT '锁定状态：0未锁定 1已锁定',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `create_username` varchar(64) DEFAULT NULL COMMENT '创建人',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `update_username` varchar(64) DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_bom_id` (`bom_id`) USING BTREE,
  KEY `idx_materiel_code` (`materiel_code`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='产品工艺规划头表';

-- ----------------------------
-- Table structure for sp_product_process_item
-- ----------------------------
DROP TABLE IF EXISTS `sp_product_process_item`;
CREATE TABLE `sp_product_process_item` (
  `id` varchar(64) NOT NULL COMMENT '主键',
  `process_id` varchar(64) DEFAULT NULL COMMENT '工艺规划头ID',
  `parent_id` varchar(64) DEFAULT NULL COMMENT '上级工艺项ID（对应BOM层次关系）',
  `bom_item_id` varchar(64) DEFAULT NULL COMMENT 'BOM子项ID',
  `bom_level` int(11) DEFAULT '0' COMMENT 'BOM层次',
  `materiel_item_code` varchar(255) DEFAULT NULL COMMENT '子项物料编码',
  `materiel_item_desc` varchar(255) DEFAULT NULL COMMENT '子项物料描述',
  `oper_id` varchar(64) DEFAULT NULL COMMENT '工序ID',
  `oper` varchar(255) DEFAULT NULL COMMENT '工序编号',
  `oper_desc` varchar(255) DEFAULT NULL COMMENT '工序名称',
  `sort_num` int(11) DEFAULT '0' COMMENT '排序号',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `create_username` varchar(64) DEFAULT NULL COMMENT '创建人',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `update_username` varchar(64) DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_process_id` (`process_id`) USING BTREE,
  KEY `idx_parent_id` (`parent_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='产品工艺规划明细表';

-- ----------------------------
-- Table structure for sp_process_content
-- ----------------------------
DROP TABLE IF EXISTS `sp_process_content`;
CREATE TABLE `sp_process_content` (
  `id` varchar(64) NOT NULL COMMENT '主键',
  `process_id` varchar(64) DEFAULT NULL COMMENT '工艺规划ID',
  `bom_id` varchar(64) DEFAULT NULL COMMENT 'BOM头ID',
  `bom_code` varchar(255) DEFAULT NULL COMMENT 'BOM编号',
  `materiel_code` varchar(255) DEFAULT NULL COMMENT '物料编码',
  `materiel_desc` varchar(255) DEFAULT NULL COMMENT '物料描述',
  `status` varchar(2) DEFAULT '0' COMMENT '编制状态：0编制中 1已完成',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `create_username` varchar(64) DEFAULT NULL COMMENT '创建人',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `update_username` varchar(64) DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_process_id` (`process_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='工艺编制头表';

-- ----------------------------
-- Table structure for sp_process_content_oper
-- ----------------------------
DROP TABLE IF EXISTS `sp_process_content_oper`;
CREATE TABLE `sp_process_content_oper` (
  `id` varchar(64) NOT NULL COMMENT '主键',
  `content_id` varchar(64) DEFAULT NULL COMMENT '工艺编制头ID',
  `process_item_id` varchar(64) DEFAULT NULL COMMENT '工艺规划明细ID（工序项）',
  `oper_id` varchar(64) DEFAULT NULL COMMENT '工序ID',
  `oper` varchar(255) DEFAULT NULL COMMENT '工序编号',
  `oper_desc` varchar(255) DEFAULT NULL COMMENT '工序名称',
  `bom_level` int(11) DEFAULT '0' COMMENT 'BOM层次',
  `materiel_item_code` varchar(255) DEFAULT NULL COMMENT '关联物料编码',
  `materiel_item_desc` varchar(255) DEFAULT NULL COMMENT '关联物料描述',
  `content_text` text COMMENT '作业工序内容',
  `images` text COMMENT '工序图片（JSON数组存储多个图片URL）',
  `sort_num` int(11) DEFAULT '0' COMMENT '排序号',
  `status` varchar(2) DEFAULT '0' COMMENT '编制状态：0未编制 1已编制',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `create_username` varchar(64) DEFAULT NULL COMMENT '创建人',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `update_username` varchar(64) DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_content_id` (`content_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='工艺编制工序内容表';

-- ----------------------------
-- Table structure for sp_process_content_device
-- ----------------------------
DROP TABLE IF EXISTS `sp_process_content_device`;
CREATE TABLE `sp_process_content_device` (
  `id` varchar(64) NOT NULL COMMENT '主键',
  `content_id` varchar(64) DEFAULT NULL COMMENT '工艺编制头ID',
  `content_oper_id` varchar(64) DEFAULT NULL COMMENT '工序内容ID',
  `device_id` varchar(64) DEFAULT NULL COMMENT '设备ID',
  `device_code` varchar(255) DEFAULT NULL COMMENT '设备编号',
  `device_name` varchar(255) DEFAULT NULL COMMENT '设备名称',
  `required_qty` int(11) DEFAULT '1' COMMENT '需求数量',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `create_username` varchar(64) DEFAULT NULL COMMENT '创建人',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `update_username` varchar(64) DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_content_oper_id` (`content_oper_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='工序使用工装设备表';

-- ----------------------------
-- Table structure for sp_sequence
-- 业务编号序列表：工单号等编号的原子自增来源，避免并发下“查最大号+1”撞号
-- ----------------------------
DROP TABLE IF EXISTS `sp_sequence`;
CREATE TABLE `sp_sequence` (
  `seq_name` varchar(64) NOT NULL COMMENT '序列名',
  `seq_value` bigint NOT NULL DEFAULT 0 COMMENT '当前值',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`seq_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='业务编号序列表';
