# MES-Springboot 二次开发说明

本仓库基于开源项目 [MES-Springboot](https://gitee.com/wangziyangyang/MES-Springboot)（作者：王子杨）学习改造，遵循 GNU AGPLv3 开源协议。

当前基于 **Spring Boot 2.7.18 / Java 17 / MyBatis-Plus 3.5 / Shiro 1.11 + Redis / MySQL 8+ / FreeMarker + Layui** 运行，共 34 张表，覆盖存储、计划、工艺、设备等模块，并补充了测试用例与接口自动化工程。

> **范围说明**：除文末「附：原项目 README」外，本文其余内容（技术栈升级、模块改造、缺陷修复、测试用例与自动化）均为本人二次开发与测试工作。

## 目录

| 章节 | 内容 |
|---|---|
| [一、与原项目的差异](#一与原项目的差异) | 规模、技术栈、新增模块、删除内容、数据库与配置的逐项对比 |
| [二、核心实现要点](#二核心实现要点) | 库存双锁、编号规则、BOM 展开与防环、会话与权限、容量校验 |
| [三、改造与测试记录](#三改造与测试记录) | 功能改造、缺陷修复（BUG-004/005）、测试方法、启动与运行 |
| [附：原项目 README](#附原项目-readme) | **上游原始内容，非本人开发** |

---

## 一、与原项目的差异
### 1.1 规模对比

| 维度 | 原项目 | 当前项目 |
|---|---|---|
| Java 源文件 | 151 个 / 9,427 行 | **244 个 / 17,621 行** |
| FreeMarker 模板 | 48 个 | **76 个** |
| 数据库表 | 19 张 | **34 张** |
| 新增文件 | — | 151 个 |
| 修改文件 | — | 82 个 |
| 删除文件 | — | 24 个 |

### 1.2 技术栈升级

| 组件 | 原项目 | 当前项目 |
|---|---|---|
| Spring Boot | 2.1.7.RELEASE | **2.7.18** |
| Java | 1.8 | **17** |
| MyBatis-Plus | 3.1.2 | **3.5.3.1** |
| MyBatis-Plus Generator | 3.2.0 | 3.5.3.1（代码生成器已移除） |
| Shiro（spring / web / ehcache） | 1.4.0 | **1.11.0** |
| Druid | 1.1.9 | **1.2.20** |
| Hutool | 5.1.5 | **5.8.25** |
| Jedis | 2.9.0 | **3.9.0** |
| MySQL 驱动 | mysql-connector-java | **mysql-connector-j** |

### 1.3 新增模块

| 模块 | 包路径 | 主要类 | 关键表 |
|---|---|---|---|
| 存储管理 | `warehouse` | SpWarehouseController / SpInventoryController / SpInventoryFlowController | sp_warehouse、sp_warehouse_location、sp_inventory、sp_inventory_flow |
| 计划管理 | `plan` | SpWorkOrderController | sp_work_order、sp_work_order_requirement |
| 工艺规划与编制 | `technology` | SpProductProcessController / SpProcessContentController / SpProcessQueryController | sp_product_process(_item)、sp_process_content(_oper / _device) |
| 设备管理 | `basedata/device` | SpDeviceController / SpDeviceGroupController | sp_device、sp_device_group(_item) |
| 班组管理 | `basedata/team` | BzTeamController | sp_bz_team(_user) |
| 工作中心 | `basedata/workcell` | WorkCellController | sp_work_cell(_team / _device_group) |
| 角色分配菜单 | `system` | SysRoleController.assignMenu + assignMenu.ftl | sp_sys_role_menu |
| 全局异常 | `common` | GlobalExceptionHandler（处理 Shiro 越权异常） | — |

### 1.4 删除的内容（24 个文件）

- **`order` 模块（原生产工单）**：SpOrderController、SpOrder、SpOrderMapper、ISpOrderService、SpOrderServiceImpl、SpOrderMapper.xml、production 模板 2 个
- **部门管理**：SysDepartmentController、SysDepartment、SysDepartmentMapper、SysDepartmentPageReq、ISysDepartmentService、SysDepartmentServiceImpl、SysIDepartmentMapper.xml、department 模板 2 个
- **主数据明细**：SpTableManagerItemController + manageritem 模板 2 个
- **代码生成器**：`common/util/CodeGenerator.java`
- **其他**：`.gitee` 的 ISSUE / PR 模板；旧建库脚本 `MySQL-20210225.sql`（改为 `scripts/sql/MES-TEXT.sql`）

### 1.5 数据库变更

19 张 → **34 张**：新增 20 张、删除 5 张。

**新增（20）**
| 分组 | 表 |
|---|---|
| 存储 | sp_warehouse、sp_warehouse_location、sp_inventory、sp_inventory_flow |
| 计划 | sp_work_order、sp_work_order_requirement、sp_sequence |
| 工艺 | sp_product_process、sp_product_process_item、sp_process_content、sp_process_content_oper、sp_process_content_device |
| 设备 | sp_device、sp_device_group、sp_device_group_item |
| 班组 | sp_bz_team、sp_bz_team_user |
| 工作中心 | sp_work_cell、sp_work_cell_team、sp_work_cell_device_group |

**删除（5）**：`sp_factroy`（工厂）、`sp_line`（线体）、`sp_work_shop`（车间）、`sp_order`（原生产工单）、`sp_sys_department`（部门）

**字段变更**

- `sp_bom_item` 新增 `item_type`（0-单纯物料 / 1-物料BOM）、`ref_bom_id`（引用的 BOM 头 ID）
- `sp_work_order` 新增 `bom_id`（出库所选工艺 BOM）

### 1.6 配置变更

| 项 | 原项目 | 当前项目 |
|---|---|---|
| 会话 / 缓存 | `spring.cache.type: ehcache` | **redis**（可切回 ehcache） |
| 测试支撑开关 | — | `mes.test.captcha-bypass`（仅 dev 开启） |
| 端口 / 数据库 | 9090 / sparchetype | 不变 |

---

## 二、核心实现要点

### 2.1 库存：三字段 + 双锁

`sp_inventory` 用「实际库存 qty / 锁定数量 locked_qty / 可用数量 qty-locked_qty」三个口径；锁定与扣减同时使用 `SELECT ... FOR UPDATE`（行锁）与 `version` 条件更新（乐观锁），并叠加 `qty - locked_qty >= n` 条件，防止并发超扣。扣到 0 且无锁定时自动删除记录。

### 2.2 编号：KF / GD / LS 三套规则

| 编号 | 规则 | 并发处理 |
|---|---|---|
| 库房 `KF001` | 取最小未使用编号，删除后可回收复用 | 单号冲突概率低 |
| 工单 `GD00000001` | **数据库序列表 `sp_sequence` 原子自增** | `UPDATE ... LAST_INSERT_ID`，天然不撞号 |
| 流水 `LS00000001` | 最大号 +1 | `uk_flow_code` 唯一索引 + 自动重试 5 次 |

### 2.3 BOM：两种子项类型与防环

子项分「单纯物料」与「物料BOM」两类（`item_type`），后者按 `ref_bom_id` 展开下级；维护时校验自引用与间接循环（`isBomContains` 递归），展开时再用 `visited` 路径集合兜底。出库取数有两套分支：成品自身有可用库存则直接锁自身，否则按 BOM 递归展开并按用量乘法累计，缺料时抛出缺料清单。

### 2.4 会话与权限

Shiro 拦截全部请求（`/** = authc`），Ajax 请求未登录返回 401、普通请求 302 跳登录页；会话与缓存可走 Redis（`spring.cache.type=redis`）。写接口用 `@RequiresPermissions("user:add")` 控制，越权异常由 `GlobalExceptionHandler` 转成 `{code:1, msg:"您没有此操作的权限"}`。角色通过「分配菜单」页面绑定菜单，菜单即权限。

### 2.5 容量校验

入库工单校验目标位置容量：库位级统计该库位下**全部物料**，库房级统计该库房下**所有库位 + 库房级**库存，避免换物料或换位置绕过上限。

### 2.6 其他

- 物料搜索独立弹层（编码/名称分栏搜索、行点击回填父页面）
- 物料批量删除（修复前端取错表 ID + 后端 `/delete-batch`）
- 3D 数字孪生库区 Zone 排列规则调整（坐标限制在四面墙内、最大库区数 25 → 10）

---

## 三、改造与测试记录

> 本章节记录再次开发的改造过程、缺陷修复、测试方法与启动运行说明。

### 工艺BOM 子项改造记录
日期：2026-10-28
#### 一、需求

工艺BOM 添加子项时，可选择两种方式：

1. **单纯添加物料**：只把物料作为子项，不再展开下级 BOM。
2. **添加物料的BOM**：选择某个物料对应的 BOM，作为子项并展开其下级结构。

原实现没有显式的类型区分，只要子项物料编码能匹配到 `sp_bom` 中的 BOM 就自动展开，无法选择。

#### 二、数据库变更（已有环境需执行）

> 2026-10-28 已在本机 `sparchetype` 库执行完成。

`sp_bom_item` 新增两列：

```sql
ALTER TABLE `sp_bom_item`
  ADD COLUMN `item_type` varchar(2) NULL DEFAULT '0' COMMENT '子项类型（0-单纯物料，1-物料BOM）' AFTER `item_unit`,
  ADD COLUMN `ref_bom_id` varchar(64) NULL DEFAULT NULL COMMENT '引用的BOM头ID' AFTER `item_type`;
```

历史数据兼容（把原来“按物料编码自动展开BOM”的子项，转换为显式的物料BOM引用）：

```sql
UPDATE `sp_bom_item` i
JOIN `sp_bom` b ON b.materiel_code = i.materiel_item_code
SET i.item_type = '1', i.ref_bom_id = b.id
WHERE i.item_type = '0';
```

同时已更新 `scripts/sql/MES-TEXT.sql` 中 `sp_bom_item` 的建表语句和示例数据（主板子项改为显式引用 BOM00002）。

#### 三、后端改动

1. `mes/src/main/java/com/wangziyang/mes/technology/entity/SpBomItem.java`
   - 新增字段 `itemType`（子项类型：0-单纯物料，1-物料BOM）、`refBomId`（引用的BOM头ID）及 getter/setter。

2. `mes/src/main/java/com/wangziyang/mes/technology/controller/SpBomItemController.java`
   - 注入 `ISpBomService`。
   - `addOrUpdateUI`：子项为物料BOM时，回显所引用 BOM 的编号（`refBomCode`）。
   - `addOrUpdate` 新增业务校验：
     - 类型为物料BOM时，校验 `refBomId` 非空、BOM存在、不能引用自身、不能形成循环引用；
     - 子项物料编码/名称以所选 BOM 的物料为准；
     - 类型为单纯物料时，`refBomId` 置为空串（便于更新时清除原引用关系）。

3. `mes/src/main/java/com/wangziyang/mes/technology/service/ISpBomService.java`
   - 新增 `isBomContains(bomId, targetBomId)`，用于循环引用校验。

4. `mes/src/main/java/com/wangziyang/mes/technology/service/impl/SpBomServiceImpl.java`
   - `buildBomTree` 增加已访问 BOM 集合，防止循环引用导致死循环。
   - `buildChildren` 改为按 `itemType` 判断：
     - `1`：按 `refBomId` 展开下级；
     - `0`：单纯物料，不展开；
     - 为空：兼容历史数据，仍按物料编码自动匹配 BOM。
   - 新增 `isBomContains` / `containsBom` 循环引用检测。

5. `mes/src/main/java/com/wangziyang/mes/plan/service/impl/SpWorkOrderServiceImpl.java`
   - `expandBom` 展开子项时，`itemType=0` 的单纯物料直接计入需求，不再继续展开下级 BOM，与 BOM 结构图保持一致。

#### 四、前端改动

1. `mes/src/main/resources/templates/technology/bom/item/addOrUpdate.ftl`
   - 新增“子项类型”单选：单纯物料 / 物料BOM。
   - 类型为单纯物料时，搜索按钮打开原物料选择面板；类型为物料BOM时，打开新增的 BOM 选择面板。
   - 选择 BOM 后自动填充引用BOM编号、物料编码、物料名称，并提交隐藏字段 `refBomId`。
   - 切换类型时清空已选对象，避免物料与 BOM 混用。

2. `mes/src/main/resources/templates/common/searchPanelBom.ftl`（新增）
   - BOM 选择弹层，复用 `/technology/bom/page` 分页接口，支持按 BOM编号、物料编码查询。
   - 通过公共路由 `/admin/common/ui/searchPanelBom` 访问，无需新增 Controller。

3. `mes/src/main/resources/templates/technology/bom/item/list.ftl`
   - 子项列表新增“类型”列，显示“物料”或“物料BOM”。

#### 五、验证

- 已执行 Maven 编译：`mvn -DskipTests compile`，编译通过。
- 手工验证建议：
  1. 在 BOM 子项页添加“单纯物料”，结构图中该节点不应展开下级；
  2. 添加“物料BOM”，结构图中该节点应显示为半成品并展开所引用 BOM 的下级；
  3. 选择当前 BOM 自身或其下级 BOM，应提示循环引用；
  4. 工单物料需求展开时，单纯物料不再继续拆解。

---

### 出库选择工艺BOM改造记录

日期：2026-10-28

#### 一、需求

出库时，如果所选物料存在多种工艺BOM，允许用户选择使用哪一套 BOM 进行展开和库存锁定。

原实现 `expandBom` 按 `materiel_code + LIMIT 1` 随机取一条 BOM，多条 BOM 时结果不确定。

#### 二、数据库变更（已执行）

`sp_work_order` 新增一列：

```sql
ALTER TABLE `sp_work_order`
  ADD COLUMN `bom_id` varchar(64) NULL DEFAULT NULL COMMENT '出库使用的工艺BOM头ID' AFTER `location_code`;
```

同时已更新 `scripts/sql/MES-TEXT.sql` 中 `sp_work_order` 的建表语句和示例数据。

#### 三、后端改动

1. `mes/src/main/java/com/wangziyang/mes/plan/entity/SpWorkOrder.java`
   - 新增 `bomId`（出库使用的工艺BOM头ID）及 getter/setter。

2. `mes/src/main/java/com/wangziyang/mes/plan/controller/SpWorkOrderController.java`
   - 新增接口 `POST /plan/work-order/bom-list`，入参 `materielCode`，按 BOM 编号升序返回该物料的全部工艺BOM。
   - 注入 `ISpBomService`。

3. `mes/src/main/java/com/wangziyang/mes/plan/service/impl/SpWorkOrderServiceImpl.java`
   - `createOrder`：出库时若 `bomId` 非空，校验 BOM 存在且与工单物料匹配，并按所选 BOM 展开需求量；未指定 BOM 时不展开，默认直接出库物料本身。
   - `expandBom` 重构：
     - 新增按 BOM 头展开的方法，`visited` 改为记录已展开的 BOM 头ID，避免同一物料不同 BOM 被误判为循环引用；
     - 子项 `itemType=1` 时按 `refBomId` 展开下级，`itemType=0` 直接作为物料需求，历史空值按物料编码兜底。

#### 四、前端改动

1. `mes/src/main/resources/templates/plan/work-order/addOrUpdate.ftl`
   - 出库工单新增“工艺BOM”下拉框（入库工单隐藏），提交字段 `bomId`。
   - 物料编码变化时自动调用 `/plan/work-order/bom-list` 加载该物料的 BOM，下拉第一项为“不使用BOM（默认使用物料）”。
   - 工艺BOM 为可选项：不选择时直接出库物料本身；选择后按该 BOM 展开需求。下拉不会自动选中，编辑时回显已选 BOM。

2. `mes/src/main/resources/templates/plan/work-order/material-select.ftl`
   - 选择物料后向父页面物料编码输入框派发 `change` 事件，触发工艺BOM下拉联动加载。

#### 五、验证

- 已执行 Maven 编译，编译通过。
- 已在本机 `sparchetype` 库新增 `sp_work_order.bom_id` 字段。
- 手工验证建议：
  1. 新建出库工单，选择存在多条 BOM 的物料，下拉应列出全部 BOM，且默认选中“不使用BOM”；
  2. 不选择 BOM 提交，物料需求应为该物料本身；
  3. 选择某条 BOM 后提交，物料需求应按该 BOM 展开；
  4. 选择没有 BOM 的物料，默认按物料本身出库。

---

### 入库容量校验修正记录（BUG-004）

日期：2026-10-28

#### 一、问题

入库工单的容量校验口径过窄，可以被绕过：

1. **跨物料叠加**：库房容量 100，物料 A 入库 100 后，换物料 B 仍可再入库 100，库房实际存放 200。
2. **跨库位不汇总**：库房容量 100、3 个库位各 33（合计 99），再以“只选库房、不选库位”的方式入库 100 仍被放行，库房实际存放 199。

#### 二、根因

`SpWorkOrderServiceImpl.validateInboundCapacity` 统计“已存放量”时带了两个精确条件：

- `materiel_code = 当前物料`：只统计单个物料，其他物料不参与计算；
- `location_code = 目标位置`：库房级校验时只统计 `location_code = ''` 的记录，库位内的库存完全不计入。

结果“容量”实际只等于“单个物料在单个位置的数量上限”，与“库房能放多少”的业务语义不符。

#### 三、修改内容

文件：`mes/src/main/java/com/wangziyang/mes/plan/service/impl/SpWorkOrderServiceImpl.java`
方法：`validateInboundCapacity`

1. 去掉 `materiel_code` 条件，改为按位置统计**全部物料**；
2. 库房级校验（未选库位）不再限制 `location_code`，改为统计该库房下所有库存（各级库位 + 库房级）；
3. 库位级校验（选了库位）仍按 `location_code` 过滤，但统计该库位下全部物料；
4. 提示文案同步调整：由「库房[KF001]中物料[M001]已存放80」改为「库房[KF001]已存放80，本次入库物料[M001]30」，避免把总量说成单物料数量。

修改前：

```java
QueryWrapper<SpInventory> invQw = new QueryWrapper<>();
invQw.eq("materiel_code", order.getMaterielCode());
invQw.eq("warehouse_code", order.getWarehouseCode());
invQw.eq("location_code", locationCode);
```

修改后：

```java
QueryWrapper<SpInventory> invQw = new QueryWrapper<>();
invQw.eq("warehouse_code", order.getWarehouseCode());
if (StringUtils.isNotBlank(order.getLocationCode())) {
    invQw.eq("location_code", order.getLocationCode());
}
```

#### 四、影响范围

- 只影响入库工单「新增/修改」时的容量校验；出库、库存扣减、流水逻辑均未改动。
- 属于收紧校验：历史数据中已存在的“超容库存”不会被自动清理，但后续入库会被拦截。
- 未改动数据库结构，无需执行 SQL。

#### 五、验证（回归用例）

| 用例 | 场景 | 预期 |
|---|---|---|
| WO-014 | 库房容量 100，物料 A 入 100 后换物料 B 再入 100 | 第二次被拒：已存放 100 + 本次 100 > 100 |
| WO-015 | 三个库位各 33 后，再以“只选库房”方式入 100 | 被拒：已存放 99 + 本次 100 > 100 |
| WO-003 | 库房级：已存 80 再入 30 | 仍被拒（提示文案改为新格式） |
| WO-013 | 库位级：KF001-1 容量 33，入 100 | 仍被拒（提示文案改为新格式） |
| WH-001 / WH-002 / WH-005 / WH-006 | 仓库与库位基础功能 | 不受影响，应保持通过 |

> 注意：WO-003、WO-013 的提示文案随本次修改调整，回归时以**新文案**为准。

**回归结果（2026-10-28）：** WO-003、WO-013、WO-014、WO-015 全部通过。
- WO-014：物料 A 入 100 后换物料 B 再入 100，已被拒绝；
- WO-015：三个库位各 33 后以库房级入 100，已被拒绝；
- WO-003 / WO-013：超容仍被拦截，提示文案为新格式（库房/库位已存放 N，本次入库物料[X]M）。
容量绕过路径已封堵。

#### 六、遗留

- `WH-007`：容量 100 ÷ 3 个库位 = 每库位 33，三库位合计 99，比库房容量少 1。属于分配取整损失，需产品确认是否把余数补给最后一个库位。
- 若后续引入“体积/重量”等多维容量，当前实现需再扩展为按维度分别校验。

---

### 并发创建工单取号冲突修正记录（BUG-005）

日期：2026-10-28

#### 一、问题

并发创建工单时，部分请求直接返回数据库异常：

```
### Error updating database. Cause: java.sql.SQLIntegrityConstraintViolationException:
Duplicate entry 'GD000000xx' for key 'sp_work_order.uk_order_code'
```

实测结果（同一库房、同物料、qty=1）：

| 并发数 | 成功 | 失败 |
|---|---|---|
| 20 | 5 | 15 |
| 10 | 2 | 8 |

数据库中没有出现重复单号（唯一索引守住了数据），但失败请求把 SQL 异常原文返回给了前端，用户看到的是数据库报错。

#### 二、根因

`SpWorkOrderServiceImpl.generateOrderCode()` 用「查当前最大编号 + 1」取号：

- 并发请求在同一时刻读到相同最大值，算出相同编号；
- `uk_order_code` 唯一索引触发冲突，事务回滚；
- 异常未被处理，直接抛到前端；
- 对比 `SpInventoryFlowServiceImpl.saveFlow()`：流水号有 5 次重试兜底，工单编号没有。

#### 三、修改内容

文件：`mes/src/main/java/com/wangziyang/mes/plan/controller/SpWorkOrderController.java`

1. `addOrUpdate` 新增分支对唯一键冲突做有限重试（最多 5 次）：每次重试清空主键与编号，由 `createOrder` 重新取号、重新展开/锁定；失败后按 15/30/45/60ms 退避，错开并发窗口。
2. 新增私有方法 `isDuplicateKey(Throwable)`：沿异常链判断 `DuplicateKeyException`、`SQLIntegrityConstraintViolationException`，或消息含 `Duplicate entry`。
3. 重试耗尽时返回友好提示「工单编号生成冲突，请重试」，不再把 SQL 异常原文返回前端。

关键代码：

```java
final int maxRetry = 5;
for (int attempt = 0; ; attempt++) {
    try {
        iSpWorkOrderService.createOrder(spWorkOrder, username);
        break;
    } catch (Exception e) {
        if (!isDuplicateKey(e) || attempt >= maxRetry - 1) {
            throw e;
        }
        spWorkOrder.setId(null);
        spWorkOrder.setOrderCode(null);
        Thread.sleep(15L * (attempt + 1));
    }
}
```

#### 四、影响范围

- 只影响工单**新增**（`id` 为空）路径；编辑、删除、确认均未改动。
- 重试是整单重来：`createOrder` 为独立事务，冲突回滚后不会残留物料需求或锁定库存。
- 未改动数据库结构，无需执行 SQL。

#### 五、验证（回归用例）

| 用例 | 场景 | 预期 |
|---|---|---|
| CON-004 | 20 并发创建工单 | 单号无重复；失败数显著下降（理想为 0），且不再返回 SQL 异常原文 |

回归时建议复跑两次，观察成功/失败比例是否从“5/15”变成“20/0”或明显改善。

#### 六、遗留

- 单机重试能覆盖绝大多数冲突；多实例部署仍建议改为 Redis `INCR` 或数据库序列表取号。
- 其他接口（如库存、仓库）仍可能把 SQL 异常原文返回前端，建议统一在 `GlobalExceptionHandler` 兜底。

#### 七、方案升级：改为数据库序列取号

首版只加了重试，实测 20 并发仍是「**成功明显变多，但失败提示变成『工单编号生成冲突，请重试』**」——说明重试能兜住大部分冲突，却没解决根因：N 个线程在同一时刻读到同一个最大值，重试时又同时读到同一个新的最大值。

##### 7.1 数据库变更（已执行）

> 2026-10-28 已在本机 `sparchetype` 库执行完成，并已同步写入 `scripts/sql/MES-TEXT.sql`（文件末尾）。

```sql
CREATE TABLE IF NOT EXISTS `sp_sequence` (
  `seq_name` varchar(64) NOT NULL COMMENT '序列名',
  `seq_value` bigint NOT NULL DEFAULT 0 COMMENT '当前值',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`seq_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='业务编号序列表';
```

首次取号时，代码会用现有最大单号自动初始化 `work_order` 序列，**无需手工 INSERT**。

初始化验证（执行那三步 SQL 后）：

| 项 | 值 |
|---|---|
| 序列初始化值 | 88（取自当前最大单号 GD00000088） |
| 本次分配 | 89（即下一张单为 GD00000089） |

##### 7.2 代码变更

文件：`mes/src/main/java/com/wangziyang/mes/plan/service/impl/SpWorkOrderServiceImpl.java`

`generateOrderCode()` 改为三步：

1. `INSERT IGNORE ... SELECT MAX(...) FROM sp_work_order`：首次使用时按存量最大单号初始化序列；
2. `UPDATE sp_sequence SET seq_value = LAST_INSERT_ID(seq_value + 1) WHERE seq_name = 'work_order'`：原子自增；
3. `SELECT LAST_INSERT_ID()`：取回本次分配到的值。

`LAST_INSERT_ID()` 是**连接级**的，同一连接读到的一定是自己那次自增的结果，因此并发下天然不撞号。

原「最大号 + 1」逻辑保留为 `generateOrderCodeByMax()`，只在序列表不可用（未建表 / 数据库异常）时兜底，配合 Controller 的重试仍能工作 —— 这样即使忘了执行 DDL，功能也不会挂。

##### 7.3 验证

重跑 CON-004（20 并发创建工单）：期望**成功 20、失败 0**，单号连续且无重复。

**回归结果（2026-10-28）：** 20 并发创建 → **成功 20、失败 0**，单号连续无重复。
对比修复前后：

| 阶段 | 20 并发成功/失败 | 10 并发成功/失败 |
|---|---|---|
| 修复前（最大号+1，无重试） | 5 / 15 | 2 / 8 |
| 仅加重试（首版） | 明显变多，但仍失败，提示「工单编号生成冲突，请重试」 | — |
| 序列表取号（最终） | **20 / 0** | — |

##### 7.4 备注

- 该方案把并发竞争交给数据库的行锁（`UPDATE ... WHERE seq_name=...` 会对该行加锁），不依赖应用层重试。
- 后续若其他单据（入库/出库/调拨）也需要编号，可直接复用 `sp_sequence`，按 `seq_name` 区分。
- 序列值不回收，删单后编号会有空洞 —— 这是编号类业务的常规取舍，优于撞号。

---

### 接口自动化测试支撑改动（验证码开关 + 空指针修复）

日期：2026-10-28

#### 一、背景

搭接口自动化（pytest）时遇到两个登录相关问题：

1. 登录必须输入图形验证码，脚本无法识图；
2. `login()` 里 `random.equals(captcha)` 在“未请求验证码就提交”时，`random` 为 `null`，直接抛 `NullPointerException`，前端收到 500。

#### 二、改动内容

##### 2.1 新增验证码开关（默认关闭）

文件：`mes/src/main/java/com/wangziyang/mes/system/controller/client/SysLoginController.java`

```java
@org.springframework.beans.factory.annotation.Value("${mes.test.captcha-bypass:false}")
private boolean captchaBypass;

// login() 中：
if (!captchaBypass) {
    // 原有的验证码校验逻辑
}
```

配置文件：`mes/src/main/resources/application-dev.yml`

```yaml
mes:
  test:
    captcha-bypass: true
```

- 默认 `false`，`application-pro.yml` 未配置，**生产环境行为不变**；
- 只在开发环境开启，供接口自动化与本地联调使用；
- 关闭开关后，登录流程与改动前完全一致。

##### 2.2 修复空指针

```java
// 改前：session 中没有验证码时 random 为 null -> NPE -> 500
if (!random.equals(captcha)) { ... }

// 改后：null 安全，返回业务提示
if (random == null || !random.equals(captcha)) {
    return Result.failure("请输入正确的验证码");
}
```

#### 三、影响范围

- 验证码开关只作用于 `/login`，其它接口不受影响；
- NPE 修复后，“未取验证码直接提交”从 500 变为正常业务提示（`code=1`）；
- 未改动数据库。

#### 四、验证

| 场景 | 期望 |
|---|---|
| dev 环境不带 captcha 登录 | `{code:0}`，登录成功 |
| 关闭开关后不带 captcha | `{code:1, msg:"请输入验证码"}` |
| 关闭开关、未取验证码且传了非空 captcha | `{code:1, msg:"请输入正确的验证码"}`（不再是 500） |

#### 五、备注

- 这类“测试开关”在生产项目里常用特性开关（feature flag）实现，关键点是**默认关闭 + 只在测试/开发 profile 打开**；
- 如果团队不接受改产品代码，替代方案是：用 Selenium 登录一次拿 Cookie，再让接口用例复用该会话（会话过期需重新获取）。

---

### 测试方法与验证手段

日期：2026-10-28

本文记录本项目实际采用的测试方法，包括用例怎么设计、数据怎么造、接口怎么调、并发怎么测、结果怎么判定，以及自动化怎么组织。

#### 一、测试环境与工具

| 项 | 内容 |
|---|---|
| 应用 | http://localhost:9090（dev profile，库 sparchetype） |
| 数据库 | MySQL 9.7（库 sparchetype） |
| 缓存 | Redis 7（会话存储已验证可切换） |
| 主要工具 | Chrome DevTools（Network / Console）、curl.exe、MySQL 命令行、pytest + requests + PyMySQL |

#### 二、用例设计方法

**原则：先读代码，再写用例。** 不按页面点，而是先确认实现路径，再决定测什么。

具体做法：

1. **从入口找分支**：如 `createOrder` 分入库/出库两条主路径，出库又分“成品自身有库存→直接锁自身”和“无库存→BOM 递归展开”两条分支，每条分支单独设计用例（WO-004 / WO-005）。
2. **从异常语句反推场景**：把源码里所有 `throw` / `Result.failure` 的文案列出来，逐条对应一个异常用例。例如
   - `物料编码不能为空` / `数量必须为正整数` / `工单类型必须为入库或出库` → WO-002
   - `容量不足：库房[X]已存放N` → WO-003
   - `库存不足，缺料清单如下` → WO-006
   - `工单状态不允许确认` / `物料需求状态异常` → CF-003 / CF-004
3. **按数据类型选方法**：
   - 等价类：数量 0 / 负数 / 正数（WO-002）
   - 边界值：容量正好等于、差 1（WO-003、WH-007）
   - 场景法：工单 草稿→确认→完成，删除/修改的合法与非法时机（CF-003、CF-006、CF-007）
   - 错误推测：并发、脏数据、绕过前端校验
4. **覆盖“看不见的分支”**：如库存扣到 0 且无锁定时记录自动删除（INV-006）、`location_code` 存空串而非 NULL（INV-005），这类点只有读源码才知道要测。

#### 三、测试数据准备

##### 3.1 页面操作口径

| 数据 | 造法 |
|---|---|
| 库房 / 库位 | 仓库管理新增，填名称、容量、库位数（自动生成 KF 编号与库位） |
| 物料 | 基础数据-物料管理新增（编码建议带前缀区分测试数据，如 `AT`） |
| BOM | 工艺-BOM 管理，子项可分“单纯物料 / 物料BOM”两种类型 |
| 库存 | **只能通过入库工单 + 确认产生**（系统没有独立的入库接口） |
| 待确认出库单 | 工单下达选 OUT，保存即产生锁定与需求明细 |

##### 3.2 直接改库造脏数据（脏数据类用例）

```sql
-- 备份（改 BOM 前必做）
CREATE TABLE sp_bom_item_bak AS SELECT * FROM sp_bom_item;

-- CF-004：工单仍是待确认，但需求已发放
UPDATE sp_work_order SET status = '01' WHERE order_code = 'GD000000xx';

-- CF-008：发料量大于锁定量
UPDATE sp_work_order_requirement SET required_qty = required_qty + 5
WHERE order_code = 'GD000000xx' AND materiel_code = 'xxx';

-- WO-012：制造 BOM 循环引用
UPDATE sp_bom_item SET item_type = '1', ref_bom_id = '<BOM-B 的 id>'
WHERE bom_head_id = '<BOM-A 的 id>';

-- 恢复
DELETE FROM sp_bom_item;
INSERT INTO sp_bom_item SELECT * FROM sp_bom_item_bak;
DROP TABLE sp_bom_item_bak;
```

> 原则：**改前先备份、改后立即恢复**，并在用例备注里写明“脏数据来源”，否则后续回归会莫名其妙失败。

#### 四、接口调用方法

##### 4.1 登录与会话

```powershell
# 取验证码建立会话，再用同一会话登录（cookie 复用）
curl.exe -s -c "$env:TEMP\mes.txt" -o NUL http://localhost:9090/verification/code
curl.exe -s -b "$env:TEMP\mes.txt" -X POST http://localhost:9090/login `
  -d "username=admin&password=123&captcha=xxxx"
```

开了 `mes.test.captcha-bypass=true` 后，自动化可直接不带 captcha 登录。

##### 4.2 区分“未登录”和“无权限”

关键在请求头 `X-Requested-With: XMLHttpRequest`：

- **不带**该头 → Shiro 走 `saveRequestAndRedirectToLogin`，返回 **302** 跳 `/login-ui`
- **带上**该头 → `SpLoginFormFilter` 直接 `setStatus(401)`，返回 **401**

```powershell
curl.exe -s -i -X POST http://localhost:9090/plan/work-order/page -H "X-Requested-With: XMLHttpRequest"
```

##### 4.3 绕过前端校验，直测后端分支

前端有必填校验时，UI 上根本发不出空参数请求。要用 Console 的 fetch 或 curl 直接打接口：

```js
fetch('/login', {
  method: 'POST',
  headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
  body: 'username=admin&password=123&captcha='
}).then(r => r.json()).then(console.log)   // {code:1, msg:"请输入验证码"}
```

同理，验证接口层权限时不能只看“菜单是否隐藏”，要直接调写接口：

```js
fetch('/plan/work-order/add-or-update', {
  method: 'POST',
  headers: { 'Content-Type': 'application/x-www-form-urlencoded', 'X-Requested-With': 'XMLHttpRequest' },
  body: 'orderType=IN&materielCode=xxx&qty=1&warehouseCode=KF001'
}).then(r => r.json()).then(console.log)   // {code:1, msg:"您没有此操作的权限"}
```

##### 4.4 一个容易误判的点

本系统业务失败时 **HTTP 仍是 200**，结果在 body 的 `code` 字段：

```json
{"code":1,"msg":"请输入正确的验证码","data":null}
```

所以判定必须看 `code`，不能看到 200 就认为成功。

#### 五、并发测试方法

##### 5.1 前端一键并发（手工阶段）

```js
const body = 'orderType=OUT&materielCode=WL00000002&qty=10';
const run = () => fetch('/plan/work-order/add-or-update', {
  method: 'POST',
  headers: { 'Content-Type': 'application/x-www-form-urlencoded', 'X-Requested-With': 'XMLHttpRequest' },
  body
}).then(r => r.json()).then(j => j.code);

const res = await Promise.all(Array.from({ length: 20 }, run));
console.log('成功', res.filter(c => c === 0).length, '失败', res.filter(c => c !== 0).length);
```

要点：**必须 `Promise.all` 并发**，for 循环里 `await` 会变成串行，测不出竞争。

##### 5.2 自动化并发（pytest）

```python
with ThreadPoolExecutor(max_workers=20) as pool:
    futures = [pool.submit(once, i) for i in range(20)]
    wait(futures)
```

##### 5.3 并发用例的判定标准

| 场景 | 判据 |
|---|---|
| 并发锁定库存 | 可用量只够 1 单时，成功数必须 = 1；`locked_qty ≤ qty`；`version` 只增一次 |
| 并发确认工单 | 成功数 = 1；流水条数 = 需求条数；库存只扣一次 |
| 并发创建工单 | 单号无重复（`GROUP BY order_code HAVING COUNT(*) > 1` 为空）；成功数符合预期 |

#### 六、落库校验（对账）

接口返回成功 ≠ 数据正确，关键数据一律回查数据库。

```sql
-- 库存与锁定
SELECT materiel_code, location_code, qty, locked_qty, version
FROM sp_inventory WHERE materiel_code = 'xxx';

-- 流水与库存对账（同一工单）
SELECT f.flow_code, f.change_type, f.change_qty, f.before_qty, f.after_qty,
       i.qty AS now_qty, i.locked_qty
FROM sp_inventory_flow f
JOIN sp_inventory i
  ON i.materiel_code  = f.materiel_code
 AND i.warehouse_code = f.warehouse_code
 AND i.location_code  = f.location_code
WHERE f.order_code = 'GD000000xx'
ORDER BY f.flow_code;
```

三条判据：
1. 流水 `before_qty` / `after_qty` 首尾连续；
2. 末条 `after_qty` = 当前库存 `qty`；
3. 出库确认后 `locked_qty` 归零。

#### 七、断言的三层结构

自动化用例统一按三层断言，避免“接口 200 就算过”：

| 层 | 内容 | 示例 |
|---|---|---|
| 1 | HTTP 状态码 | 未登录必须 401，而不是 302 |
| 2 | 业务码与文案 | `code=1` 且 msg 含 `容量不足` |
| 3 | 数据库结果 | 库存数量、流水条数、工单状态、需求状态 |

#### 八、缺陷判定与回归

1. **先分清是产品 bug 还是用例 bug**：自动化首轮 29 条里有 2 条失败，实际是断言把 pymysql 返回的元组与 `[]` 比较，属用例缺陷，不是产品缺陷。
2. **缺陷必须可复现**：记录“前置数据 + 操作步骤 + 期望 + 实际”，能对着步骤重现才算成立。
3. **修复后回归同一路径**：如 BUG-001 修复后重跑 WO-003/013/014/015；BUG-002 修复后重跑 20 并发，用**修复前/后数据对比**证明已解决（5/15 → 20/0）。
4. **回归不只看“通过”**：还要确认提示文案、事务回滚、数据无残留。

#### 九、自动化框架组织（pytest-mes）

```
pytest-mes/
├── config.yaml        环境、账号、数据库
├── conftest.py        fixture：登录客户端、DB、物料/库房/造库存
├── common/            client.py（会话保持+断言）、db.py（造数据+落库校验）
├── api/               接口封装层：只发请求，不断言
└── testcases/         用例层：断言在这里，共 29 条
```

设计要点：

- **接口封装与断言分离**：接口变更只改 `api/`；
- **数据自造自清**：物料编码带时间戳，fixture 负责创建与清理，用例互不污染；
- **会话复用**：`requests.Session()` 登录一次贯穿整个测试会话；
- **运行方式**：`pytest` / `pytest -m smoke` / `pytest --html=reports/report.html`。

#### 十、本次测试的产出

| 产出 | 内容 |
|---|---|
| 手工用例 | 46 条，覆盖 7 个模块，P0 19 条，执行通过率 100% |
| 自动化用例 | 29 条，`29 passed`，含 3 条并发用例 |
| 缺陷 | 2 个（容量校验绕过、并发取号冲突），均已修复并回归 |
| 修复记录 | 本文档第 1~3 节（BUG-004、BUG-005）与第 4 节（测试支撑） |

---

### 启动与运行

日期：2026-10-28

本文记录本机跑起整套环境（应用 + 数据库 + 缓存 + 自动化测试）的完整步骤。

#### 一、启动顺序

① MySQL（Windows 服务，通常已随开机启动）
② Redis（便携版，需手动启动；应用已配置 cache.type=redis，没它启动会报错）
③ 应用（IDEA 运行主类，端口 9090）
④ 验证（能打开登录页 / 接口能通）
⑤ 跑自动化（pytest）
```

#### 二、各组件的启动方法

##### 2.1 MySQL

本机以 Windows 服务方式安装，服务名 `MySQL97`，端口 3306，数据库 `sparchetype`，账号 `root/root`。

```powershell
# 查看状态
Get-Service MySQL97

# 如未启动则启动（一般不需要，随开机自启）
Start-Service MySQL97

# 连通性验证
& "C:\Program Files\MySQL\MySQL Server 9.7\bin\mysql.exe" `
  --host=127.0.0.1 --port=3306 --user=root --password=root --database=sparchetype `
  -e "SELECT 1;"
```

> 密码写在命令行会有 `Using a password on the command line interface can be insecure` 警告，属正常提示，不影响执行。

##### 2.2 Redis

用的是免安装版，解压即用（无需注册服务），端口 6379：

```powershell
D:\workspace\.tools\redis\redis-server.exe
```

保持这个窗口不关。另开一个窗口验证：

```powershell
D:\workspace\.tools\redis\redis-cli.exe ping    # 返回 PONG
D:\workspace\.tools\redis\redis-cli.exe keys "shiro_redis_session:*"
```

> 若 `application.yml` 里 `spring.cache.type=redis`，**Redis 没启动会导致登录时报缓存/会话异常**；临时不想开 Redis，可把配置改回 `ehcache`（会话回落 JVM 内存）。

##### 2.3 应用

主类：`com.wangziyang.mes.SparchetypeApplication`，端口 9090，默认激活 `dev` profile（连本机 MySQL 与 Redis）。

**方式一（当前使用）：IDEA 运行**

1. IDEA 打开 `D:\workspace\MES-Springboot-master\mes`
2. 找到 `SparchetypeApplication`，点绿色三角运行
3. 改了 Java 代码后必须 **Rebuild + 重启**，否则跑的还是旧逻辑

**方式二：命令行**

```powershell
cd D:\workspace\MES-Springboot-master\mes
mvn spring-boot:run
```

> 注意：项目自带的 `mvnw` 缺 `maven-wrapper.properties`，无法直接使用；本机也未安装独立 Maven，所以目前以 IDEA 运行为主。

##### 2.4 验证启动成功

```powershell
# 端口是否在监听
(Test-NetConnection -ComputerName 127.0.0.1 -Port 9090 -WarningAction SilentlyContinue).TcpTestSucceeded

# 登录页是否可访问（返回 200）
curl.exe -s -o NUL -w "%{http_code}" http://localhost:9090/login-ui

# 未登录调接口应返回 401（模拟 Ajax）
curl.exe -s -o NUL -w "%{http_code}" -X POST http://localhost:9090/plan/work-order/page `
  -H "X-Requested-With: XMLHttpRequest"
```

期望：`True` / `200` / `401`。

#### 三、运行接口自动化

```powershell
cd D:\workspace\pytest-mes

# 全量（29 条）
.\.venv\Scripts\python.exe -m pytest -v

# 只跑冒烟
.\.venv\Scripts\python.exe -m pytest -m smoke -v

# 只跑并发
.\.venv\Scripts\python.exe -m pytest testcases\test_05_concurrency.py -v

# 生成 HTML 报告
.\.venv\Scripts\python.exe -m pytest --html=reports\report.html
```

前置条件（三者缺一不可）：

1. 应用已启动且是**包含最新代码的版本**；
2. `application-dev.yml` 里 `mes.test.captcha-bypass: true`；
3. `pytest-mes\config.yaml` 里的 `base_url` 与数据库账号与实际一致。

若用自己的 Python 环境：

```powershell
pip install -r requirements.txt
pytest -v
```

#### 四、手工接口验证常用命令

```powershell
# 建立会话并登录（验证码开启时用）
curl.exe -s -c "$env:TEMP\mes.txt" -o NUL http://localhost:9090/verification/code
curl.exe -s -b "$env:TEMP\mes.txt" -X POST http://localhost:9090/login `
  -d "username=admin&password=123&captcha=xxxx"

# 登录后查库存分页
curl.exe -s -b "$env:TEMP\mes.txt" -X POST http://localhost:9090/warehouse/inventory/page `
  -d "materielCode=&current=1&size=5"
```

浏览器侧最常用的两招：

- F12 → **Network**（勾 Preserve log）看请求状态码与响应体；
- F12 → **Console** 用 `fetch(...)` 造并发、绕过前端校验。

#### 五、停止与清理

```powershell
# 停止 Redis
Stop-Process -Name redis-server -Force

# 停止 MySQL（一般不用停）
Stop-Service MySQL97
```

清理测试产生的脏数据（按需执行，注意先 SELECT 预览）：

```sql
-- 自动化测试物料（编码以 AT 开头）
DELETE FROM sp_inventory_flow WHERE materiel_code LIKE 'AT%';
DELETE FROM sp_inventory      WHERE materiel_code LIKE 'AT%';
DELETE r FROM sp_work_order_requirement r
  JOIN sp_work_order w ON w.order_code = r.order_code
 WHERE w.materiel_code LIKE 'AT%';
DELETE FROM sp_work_order WHERE materiel_code LIKE 'AT%';
DELETE FROM sp_materile   WHERE materiel LIKE 'AT%';

-- 自动测试库房（名称以 AUTO 开头）
DELETE FROM sp_warehouse_location WHERE warehouse_code IN
  (SELECT warehouse_code FROM sp_warehouse WHERE warehouse_name LIKE 'AUTO%');
DELETE FROM sp_warehouse WHERE warehouse_name LIKE 'AUTO%';
```

#### 六、常见问题排查

| 现象 | 原因与处理 |
|---|---|
| 应用启动报 Redis 连接失败 | Redis 没起；启动 `redis-server.exe`，或把 `spring.cache.type` 改回 `ehcache` |
| 端口 9090 被占用 | 上一次进程没退干净；`Get-NetTCPConnection -LocalPort 9090` 找到 PID 后结束 |
| 自动化登录失败、提示「请输入验证码」 | `mes.test.captcha-bypass` 未生效：确认改的是 `application-dev.yml`、且应用已重启 |
| 自动化全部 401 | 应用没起来，或 `config.yaml` 的 `base_url` 写错 |
| 改代码后自动化结果没变化 | 忘了 Rebuild + 重启，跑的还是旧 class |
| `Connection pool is full` 警告 | 并发用例超过 requests 默认连接池（10），已通过 `HTTPAdapter(pool_maxsize=30)` 解决 |
| 库房编号不是 KF001 而是更大的号 | 编号采用“最小未使用”规则，之前测试残留的库房占用了编号；清理后再试 |


# 附：原项目 README

> 以下为上游项目原始 README 内容，**非本人开发**。

##  章鱼师兄。真的智造！ 
### 黑科更名为章鱼师兄
### 个人参与开发的MES项目
* **杭州东方通信股份**  (三星SDS麦康平台)
* **浙江大华技术股份**  (三星SDS麦康平台)
* **天能集团**  (自研平台0到1)
### 界面展示
* 演示地址（新）
* http://www.meswozuiniu.icu:8887
用户名admin  密码123
### 章鱼师兄规划
![1.1](https://s3.ax1x.com/2020/12/12/rV9p0s.png)
<table style="text-align:center">
    <tr>
        <th bgcolor=#218868 ><font color=#0F0F0F >系统管理</font></th> 
        <th bgcolor=#218868 ><font color=#0F0F0F >工艺管理</font></th> 
        <th bgcolor=#218868 ><font color=#0F0F0F >计划管理</font></th> 
        <th bgcolor=#218868 ><font color=#0F0F0F >物料管理</font></th> 
   </tr>
    <tr >
        <td bgcolor=#C6E2FF ><font color=#EE0000 >*用户管理*</font></td>
        <td bgcolor=#C6E2FF><font color=#EE0000 >*工艺路线管理*</font></td>
        <td bgcolor=#C6E2FF><font color=#0F0F0F >工单下达</font></td>
        <td bgcolor=#C6E2FF><font color=#0F0F0F >物料出入库</font></td>
   </tr>
 <tr>
        <td bgcolor=#D1D1D1><font color=#EE0000 >*组织管理*</font></td>
        <td bgcolor=#D1D1D1><font color=#0F0F0F >MOM管理</font></td>
        <td bgcolor=#D1D1D1><font color=#0F0F0F >工序工单分解</font></td>
        <td bgcolor=#D1D1D1><font color=#0F0F0F >智能货架</font></td>
   </tr>
   <tr>
        <td bgcolor=#C6E2FF><font color=#EE0000 >*菜单管理*</font></td>
        <td bgcolor=#C6E2FF><font color=#0F0F0F >BOM管理</font></td>
        <td bgcolor=#C6E2FF><font color=#0F0F0F >工单流程变更</font></td>
        <td bgcolor=#C6E2FF><font color=#0F0F0F >物料标签管理</font></td>
   </tr>
    <tr>
        <td bgcolor=#D1D1D1><font color=#EE0000 >*基础数据维护*</font></td>
        <td bgcolor=#D1D1D1><font color=#0F0F0F >SOP管理</font></td>
        <td bgcolor=#D1D1D1><font color=#0F0F0F >工单锁定</font></td>
        <td bgcolor=#D1D1D1><font color=#0F0F0F >AGV+WCS</font></td>
   </tr>
    <tr>
        <td bgcolor=#C6E2FF><font color=#EE0000 >*基础数据配置*</font></td>
        <td bgcolor=#C6E2FF><font color=#0F0F0F >其他工艺文件</font></td>
        <td bgcolor=#C6E2FF><font color=#0F0F0F >工单特殊设置</font></td>
        <td bgcolor=#C6E2FF><font color=#EE0000 >*物料基础数据*</font></td>   
   </tr>
</table>
--------------------------
<table style="text-align:center">
    <tr>
        <th bgcolor=#218868 ><font color=#0F0F0F >设备管理</font></th> 
        <th bgcolor=#218868 ><font color=#0F0F0F >SN码管理</font></th> 
        <th bgcolor=#218868 ><font color=#0F0F0F >在制品管理</font></th> 
        <th bgcolor=#218868 ><font color=#0F0F0F >质量管理</font></th> 
   </tr>
    <tr>
        <td bgcolor=#C6E2FF><font color=#0F0F0F >设备档案</font></td>
        <td bgcolor=#C6E2FF><font color=#0F0F0F >SN码规则管理</font></td>
        <td bgcolor=#C6E2FF><font color=#0F0F0F >工序过站</font></td>
        <td bgcolor=#C6E2FF><font color=#0F0F0F >IOC</font></td>    
   </tr>
 <tr>
        <td bgcolor=#D1D1D1><font color=#0F0F0F >设备维修保养</font></td>
        <td bgcolor=#D1D1D1><font color=#0F0F0F >分配SN管理</font></td>
        <td bgcolor=#D1D1D1><font color=#0F0F0F >在线维修管理</font></td>
        <td bgcolor=#D1D1D1><font color=#0F0F0F >OQC</font></td>
   </tr>
    <tr>
        <td bgcolor=#C6E2FF><font color=#0F0F0F >设备出入库</font></td>
        <td bgcolor=#C6E2FF><font color=#0F0F0F >SN标签+打印</font></td>
        <td bgcolor=#C6E2FF><font color=#0F0F0F >自动化对接</font></td>
        <td bgcolor=#C6E2FF><font color=#0F0F0F >FQC</font></td>   
   </tr>
 <tr>
        <td bgcolor=#D1D1D1><font color=#0F0F0F >设备稼动率</font></td>
        <td bgcolor=#D1D1D1><font color=#0F0F0F ></font></td>
        <td bgcolor=#D1D1D1><font color=#0F0F0F >SN返工管理</font></td>
        <td bgcolor=#D1D1D1><font color=#0F0F0F >质检项维护</font></td>
   </tr>
    <tr>
        <td bgcolor=#C6E2FF style="text-align:left"><font color=#0F0F0F >说明：</font></td>
        <td bgcolor=#C6E2FF><font color=#0F0F0F ></font></td>
        <td bgcolor=#C6E2FF><font color=#EE0000 >*完成</font></td>
        <td bgcolor=#C6E2FF><font color=#0F0F0F >未开发</font></td>   
   </tr>
</table>

### 专属知识星球。智友们上车了
![1.0](https://z3.ax1x.com/2021/04/15/cgKBK1.png)   
 ## MOM平台规划
![1.](https://s1.ax1x.com/2020/04/11/GHGLcV.jpg)
### ISA-95 层级
![1.0](https://s1.ax1x.com/2020/04/03/GN9vid.png)
 四大类: 资源、能力、产品定义和生产计划
 九大模型
 * 人力资源模型
 * 设备资源模型
 * 材料资源模型
 * 过程段模型(过程端模型，过程能力模型)
 * 生产能力模型
 * 产品定义模型
 * 生产计划模型
 * 生产性能模型
![1.0](https://s1.ax1x.com/2020/04/03/GN9aVg.png)
登录界面[MES]
![1.1](https://s2.ax1x.com/2020/03/06/3bQLqI.png)
数字孪生仓库
![1.1.2](https://s1.ax1x.com/2020/07/21/U56OlF.png)
数字化平台 echarts
![1.1.3](https://s1.ax1x.com/2020/03/23/8o7wbq.png)
#### 功能界面
* 主数据展示
![1.1.3](https://s2.ax1x.com/2020/03/11/8AMcA1.png)
* 计划甘特图
![1.1.4](https://s1.ax1x.com/2020/07/02/NH4Su4.png)
* 工艺路线界面
![1.1.4](https://s1.ax1x.com/2020/03/16/8GOl28.png)
* 物料维护界面
![1.1.5](https://s1.ax1x.com/2020/03/23/8HrLin.png)
* BOM维护界面
![1.1.6](https://s1.ax1x.com/2020/04/09/G4yQMt.png)
#### swaggerAPI管理界面
![2](https://s2.ax1x.com/2020/03/06/3qC4Yt.png)
### 技术架构
#### springBoot+mybatis-plus+redis+shiro+hutool+layui+swagger+freemarker+mysql8+echarts
#### jenkins+docker+nginx
### MES个人笔记
[MESA战略计划](http://note.youdao.com/noteshare?id=3d843775354cc7a503ad247a29997848)
[10点技巧，教你成MES实施王者](http://note.youdao.com/noteshare?id=2d4cf9c9827c2f906d36ec4c146e7557)
[MES需求收益评估，如何计算ROI，真香又学知识了](http://note.youdao.com/noteshare?id=5add9a164e26b5e039e7b0016daa19a4)
[做MES重点不是学习别人的成功，而是明白他犯的错误](http://note.youdao.com/noteshare?id=ba5f58ec23376ebee9a9c09d95c3dcfa)
[MES相关术语，字母缩写含义！看一遍就懂。不懂请再看一遍](http://note.youdao.com/noteshare?id=222fcb0a12288b8e5cc76ba94e1bb32d)
### 部署云平台 使用阿里云 （https://www.aliyun.com）
实现功能：
1. 用户管理：用户是系统操作者，该功能主要完成系统用户配置。
2. 主数据管理：动态配置表以及所需要显示的字段，只需要简单维护既可以完成增删改成操作。
3. 赋码管理：动态配置码规则项。例如6位年月日 3位，流水号，随机号。根据用户配置自动创建SN。
4. 菜单管理：配置系统菜单，操作权限，按钮权限标识等。
5. 角色管理：角色菜单权限分配、设置角色按机构进行数据范围权限划分。
6. 字典管理：对系统中经常使用的一些较为固定的数据进行维护，如：是否、男女、类别、级别等。
7. 物料进出管理：包含物料叫料，配料，发料，确认收料，上料
8. 工单管理：工单下达，工单分解，工单状态调整，工单特殊设置
9. 在制品管理：过站工序记录，数据绑定成箱成剁
10. 质量管理： 质检项维护，根据物料或者型号管理质检项目。检验页面，抽检确认
11. 工艺文件管理 ：工艺参数，BOM文件，导入导出
12. 报表：图形化展示
13. 设备管理： 设备信息录入，使用记录，设备台账，设备维保
14. 操作日志：系统正常操作日志记录和查询；系统异常信息日志记录和查询。
15. 连接池监视：监视当期系统数据库连接池状态，可进行分析SQL找出系统性能瓶颈。
16. 工作流引擎：实现业务工单流转、在线流程设计器。
17. 数字化平台：支撑数据展示，定时动态刷新数据。热部署（SQL视图）
##### 使用注意事项
* 前端
    * 日期工具库：static/lib/dayjs.min.js
    * Javascript 工具库：static/lib/lodash.min.js
    * Layui 树形表格插件
        * https://gitee.com/whvse/treetable-lay
    * 图标库使用
        * http://www.fontawesome.com.cn/faicons
    * echart
        * https://www.echartsjs.com/zh/api.html#echarts
---
### 快速部署指南
#### 环境要求
| 组件 | 版本 | 说明 |
|------|------|------|
| JDK | 1.8+ | 运行环境 |
| MySQL | 8.0+ | 数据库 |
| Maven | 3.5+ | 构建工具 |
#### 部署步骤
##### 1. 导入数据库
```bash
# 方式一：命令行导入
mysql -u root -p < scripts/sql/MES-TEXT.sql
# 方式二：使用 Navicat 等工具
# 1. 创建数据库 mes，字符集 utf8mb4
# 2. 运行 scripts/sql/MES-TEXT.sql 中的所有 SQL
```
##### 2. 修改数据库配置
编辑 `mes/src/main/resources/application-dev.yml`：
```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/mes?useUnicode=true&characterEncoding=utf8&useSSL=false&serverTimezone=Asia/Shanghai
    username: root        # 修改为你的数据库用户名
    password: 123456      # 修改为你的数据库密码
```
##### 3. Maven 打包
```bash
cd mes
mvn clean package -DskipTests
```
##### 4. 启动系统
```bash
# 方式一：直接运行 JAR
java -jar target/mes-1.0.0.jar
# 方式二：使用 Maven 插件
mvn spring-boot:run
```
##### 5. 访问系统
打开浏览器访问：`http://localhost:8080`
| 账号 | 密码 | 角色 |
|------|------|------|
| admin | 123 | 系统管理员 |
| (可在用户管理中创建) | | 工艺员 |
| (可在用户管理中创建) | | 操作员 |
#### 常见问题
**Q: 启动报错找不到数据源？**
A: 检查 `application-dev.yml` 中的数据库连接信息是否正确，确认 MySQL 服务已启动。
**Q: 导入 SQL 报错？**
A: 确保 MySQL 版本为 8.0+，字符集为 utf8mb4。运行前先创建数据库：`CREATE DATABASE mes CHARACTER SET utf8mb4;`
**Q: 登录后看不到菜单？**
A: 检查 `sp_sys_user_role` 和 `sp_sys_role_menu` 表中是否有正确的用户角色权限数据。
**Q: 页面报 500 错误？**
A: 查看 `logs/mes.log` 日志文件中的详细错误信息。
#### 参考文档
* **发送 Ajax 示例**：[详情](./docs/ajax.md)
* **FreeMarker 文档**：[详情](./docs/FreeMarker.md)
* **Layui 自定义组件 spLayer**：[详情](./docs/spLayer.md)
* **Layui 自定义组件 spTable**：[详情](./docs/spTable.md)
* **下拉框初始化数据**：[详情](./docs/layuiSelect.md)
* 后端 
    * Hutool 是一个小而全的Java工具类库，通过静态方法封装，降低相关API的学习成本，提高工作效率，使Java拥有函数式语言般的优雅，让Java语言也可以“甜甜的”。
    * 枚举
        * 公共枚举类：CommonEnum
        * 不同模块下的枚举：如 com.songpeng.sparchetype.system.enums
    * 请求参数
        * 每张表的分页查询参数，严格按照一张表对应一个请求参数对象进行开发，如系统用户分页查询参数：SysUserPageReq
## 总结
欢迎想一起开发的小伙伴。。此项目也支持大学生毕业设计。
## MES国际
[![MES](https://s1.ax1x.com/2020/04/10/GIRPEt.png "MESA认证")](http://www.mesa.org/)
[![synfactory](https://s1.ax1x.com/2020/04/11/GHrk01.png "synf官服资料")](https://www.syntropicfactory.com/)
[![ISA](https://s1.ax1x.com/2020/05/14/YBPeVH.png "ISA自动化学会")](https://www.isa.org/)
### QQ Group808898316(此群已满)
[![QQ](https://img.shields.io/badge/QQ-808898316-green.svg?logo=tencent%20qq&logoColor=red)](http://qm.qq.com/cgi-bin/qm/qr?k=vjfiAHPYgOgO5XxeUFxNfxTlQom2wZFZ)
### QQ Group87652870(此群已满)
[![QQ](https://img.shields.io/badge/QQ-87652870-green.svg?logo=tencent%20qq&logoColor=red)](https://jq.qq.com/?_wv=1027&k=55NGCxl)
### QQ Group595803231(请加此群)
[![QQ](https://img.shields.io/badge/QQ-595803231-green.svg?logo=tencent%20qq&logoColor=red)]
### 特别鸣谢
[![MES-智能制造/MES-Springboot](https://gitee.com/wangziyangyang/MES-Springboot/widgets/widget_card.svg?colors=393222,ebdfc1,fffae5,d8ca9f,393222,a28b40)](https://gitee.com/wangziyangyang/MES-Springboot)
