package com.wangziyang.mes.plan.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.wangziyang.mes.plan.entity.SpWorkOrder;
import com.wangziyang.mes.plan.entity.SpWorkOrderRequirement;
import com.wangziyang.mes.plan.mapper.SpWorkOrderMapper;
import com.wangziyang.mes.plan.service.ISpWorkOrderRequirementService;
import com.wangziyang.mes.plan.service.ISpWorkOrderService;
import com.wangziyang.mes.technology.entity.SpBom;
import com.wangziyang.mes.technology.entity.SpBomItem;
import com.wangziyang.mes.technology.service.ISpBomItemService;
import com.wangziyang.mes.technology.service.ISpBomService;
import com.wangziyang.mes.warehouse.entity.SpInventory;
import com.wangziyang.mes.warehouse.entity.SpInventoryFlow;
import com.wangziyang.mes.warehouse.entity.SpWarehouse;
import com.wangziyang.mes.warehouse.entity.SpWarehouseLocation;
import com.wangziyang.mes.warehouse.service.ISpInventoryFlowService;
import com.wangziyang.mes.warehouse.service.ISpInventoryService;
import com.wangziyang.mes.warehouse.service.ISpWarehouseLocationService;
import com.wangziyang.mes.warehouse.service.ISpWarehouseService;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import org.apache.commons.lang3.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * 工单 服务实现类
 *
 * @author WangZiYang
 * @since 2026-08-16
 */
@Service
public class SpWorkOrderServiceImpl extends ServiceImpl<SpWorkOrderMapper, SpWorkOrder> implements ISpWorkOrderService {

    private static final Logger logger = LoggerFactory.getLogger(SpWorkOrderServiceImpl.class);

    @Autowired
    private ISpWorkOrderRequirementService iSpWorkOrderRequirementService;

    @Autowired
    private ISpBomService iSpBomService;

    @Autowired
    private ISpBomItemService iSpBomItemService;

    @Autowired
    private ISpInventoryService iSpInventoryService;

    @Autowired
    private ISpInventoryFlowService iSpInventoryFlowService;

    @Autowired
    private ISpWarehouseService iSpWarehouseService;

    @Autowired
    private ISpWarehouseLocationService iSpWarehouseLocationService;

    @Autowired
    private javax.sql.DataSource dataSource;

    /**
     * 生成工单编号：优先走数据库序列表原子自增（并发安全），序列表不可用时退回“最大号+1”
     *
     * @return 形如 GD00000001 的工单编号
     */
    @Override
    public String generateOrderCode() {
        try (java.sql.Connection conn = dataSource.getConnection()) {
            // 首次使用：用现有最大单号初始化序列，避免与存量单号冲突
            try (java.sql.Statement st = conn.createStatement()) {
                st.executeUpdate("INSERT IGNORE INTO sp_sequence(seq_name, seq_value) "
                        + "SELECT 'work_order', IFNULL(MAX(CAST(SUBSTRING(order_code, 3) AS UNSIGNED)), 0) "
                        + "FROM sp_work_order");
            }
            // 原子自增，并用 LAST_INSERT_ID 取回本次分配到的值（连接级，天然并发安全）
            try (java.sql.PreparedStatement ps = conn.prepareStatement(
                    "UPDATE sp_sequence SET seq_value = LAST_INSERT_ID(seq_value + 1) WHERE seq_name = 'work_order'")) {
                ps.executeUpdate();
            }
            try (java.sql.Statement st = conn.createStatement();
                 java.sql.ResultSet rs = st.executeQuery("SELECT LAST_INSERT_ID()")) {
                if (rs.next()) {
                    long seq = rs.getLong(1);
                    if (seq > 0) {
                        return "GD" + String.format("%08d", seq);
                    }
                }
            }
        } catch (Exception e) {
            logger.warn("序列表取号失败，回退到最大号+1：{}", e.getMessage());
        }
        return generateOrderCodeByMax();
    }

    /**
     * 兼容取号：序列表不可用时的兜底实现（并发下可能撞号，由上层重试兜底）
     */
    private String generateOrderCodeByMax() {
        QueryWrapper<SpWorkOrder> qw = new QueryWrapper<>();
        qw.likeRight("order_code", "GD");
        qw.orderByDesc("order_code");
        qw.last("LIMIT 1");
        SpWorkOrder max = this.getOne(qw, false);
        int seq = 1;
        if (max != null && StringUtils.isNotBlank(max.getOrderCode())) {
            String numStr = max.getOrderCode().substring(2);
            if (numStr.matches("\\d+")) {
                seq = Integer.parseInt(numStr) + 1;
            }
        }
        return "GD" + String.format("%08d", seq);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void createOrder(SpWorkOrder order, String username) {
        // ===== 参数校验 =====
        if (StringUtils.isEmpty(order.getMaterielCode())) {
            throw new IllegalArgumentException("物料编码不能为空");
        }
        if (order.getQty() == null || order.getQty() <= 0) {
            throw new IllegalArgumentException("数量必须为正整数");
        }
        if (!"IN".equals(order.getOrderType()) && !"OUT".equals(order.getOrderType())) {
            throw new IllegalArgumentException("工单类型必须为入库或出库");
        }
        // 自动生成工单编号
        if (StringUtils.isBlank(order.getId())) {
            order.setOrderCode(generateOrderCode());
            order.setStatus("01"); // 待确认
        }

        if ("OUT".equals(order.getOrderType())) {
            // ===== 出库工单：BOM递归展开 + 校验库存 + 锁定库存 =====
            // 1. 计算物料需求量：
            //    指定了工艺BOM时按所选BOM展开；
            //    未指定时不使用BOM，默认直接出库该物料本身
            Map<String, BigDecimal> requirementMap = new HashMap<>();
            if (StringUtils.isNotEmpty(order.getBomId())) {
                // 出库时选择了工艺BOM，按所选BOM展开
                SpBom selectedBom = iSpBomService.getById(order.getBomId());
                if (selectedBom == null) {
                    throw new IllegalArgumentException("所选工艺BOM不存在");
                }
                if (!order.getMaterielCode().equals(selectedBom.getMaterielCode())) {
                    throw new IllegalArgumentException("所选工艺BOM与工单物料不匹配");
                }
                expandBom(selectedBom, BigDecimal.valueOf(order.getQty()), requirementMap, new HashSet<>());
            } else {
                // 未选择工艺BOM，默认使用物料本身
                requirementMap.put(order.getMaterielCode(), BigDecimal.valueOf(order.getQty()));
            }

            // 2. 遍历需求物料，查询库存可用量，库存不足抛出业务异常（列出缺料清单）
            List<String> shortageList = new ArrayList<>();
            for (Map.Entry<String, BigDecimal> entry : requirementMap.entrySet()) {
                BigDecimal available = iSpInventoryService.sumAvailableByMateriel(entry.getKey());
                if (available.compareTo(entry.getValue()) < 0) {
                    shortageList.add("物料[" + entry.getKey() + "] 需求" + entry.getValue()
                            + "，可用" + available);
                }
            }
            if (!shortageList.isEmpty()) {
                throw new IllegalStateException("库存不足，缺料清单如下：\n" + String.join("\n", shortageList));
            }

            // 3. 库存充足，对每个物料执行锁定库存（锁定数量），用条件更新保证不超扣，体现数据库行锁
            for (Map.Entry<String, BigDecimal> entry : requirementMap.entrySet()) {
                BigDecimal remain = entry.getValue();
                // 按可用数量升序逐个库位/库房锁定，形成发料明细
                List<SpInventory> inventoryList = iSpInventoryService.listAvailableByMateriel(entry.getKey());
                for (SpInventory inv : inventoryList) {
                    if (remain.compareTo(BigDecimal.ZERO) <= 0) {
                        break;
                    }
                    BigDecimal available = inv.getQty().subtract(inv.getLockedQty() == null ? BigDecimal.ZERO : inv.getLockedQty());
                    BigDecimal lockQty = remain.min(available);
                    if (lockQty.compareTo(BigDecimal.ZERO) <= 0) {
                        continue;
                    }
                    boolean ok = iSpInventoryService.lockInventory(inv.getId(), lockQty);
                    if (!ok) {
                        throw new IllegalStateException("库存锁定失败（可能已被并发预占）：物料" + entry.getKey());
                    }
                    // 记录工单物料需求（即锁定明细）
                    SpWorkOrderRequirement req = new SpWorkOrderRequirement();
                    req.setOrderCode(order.getOrderCode());
                    req.setMaterielCode(entry.getKey());
                    req.setMaterielDesc(inv.getMaterielDesc());
                    req.setRequiredQty(lockQty);
                    req.setUnit(inv.getUnit());
                    req.setInventoryId(inv.getId());
                    req.setWarehouseCode(inv.getWarehouseCode());
                    req.setLocationCode(inv.getLocationCode());
                    req.setStatus("01"); // 已锁定
                    iSpWorkOrderRequirementService.save(req);
                    remain = remain.subtract(lockQty);
                }
            }
            this.saveOrUpdate(order);
        } else {
            // ===== 入库工单：校验库房/库位容量是否足够，再保存（库房编号必填，库位编号可空）=====
            if (StringUtils.isEmpty(order.getWarehouseCode())) {
                throw new IllegalArgumentException("入库工单必须选择库房");
            }
            validateInboundCapacity(order);
            this.saveOrUpdate(order);
        }
    }

    /**
     * 校验入库工单的库房/库位容量是否足够存放
     * 指定库位时校验库位容量，否则校验库房容量；已存放数量+本次入库数量不得超过容量上限
     *
     * @param order 入库工单
     */
    private void validateInboundCapacity(SpWorkOrder order) {
        QueryWrapper<SpWarehouse> whQw = new QueryWrapper<>();
        whQw.eq("warehouse_code", order.getWarehouseCode());
        whQw.last("LIMIT 1");
        SpWarehouse warehouse = iSpWarehouseService.getOne(whQw, false);
        if (warehouse == null) {
            throw new IllegalArgumentException("库房不存在：" + order.getWarehouseCode());
        }

        Integer capacity;
        String targetDesc;
        if (StringUtils.isNotBlank(order.getLocationCode())) {
            QueryWrapper<SpWarehouseLocation> locQw = new QueryWrapper<>();
            locQw.eq("location_code", order.getLocationCode());
            locQw.eq("warehouse_code", order.getWarehouseCode());
            locQw.last("LIMIT 1");
            SpWarehouseLocation location = iSpWarehouseLocationService.getOne(locQw, false);
            if (location == null) {
                throw new IllegalArgumentException("库位不存在：" + order.getLocationCode());
            }
            capacity = location.getCapacity();
            targetDesc = "库位[" + location.getLocationCode() + "]";
        } else {
            capacity = warehouse.getCapacity();
            targetDesc = "库房[" + warehouse.getWarehouseCode() + "]";
        }

        if (capacity == null) {
            // 未配置容量则不做限制
            return;
        }
        // 容量口径（已修正）：库位级统计该库位下「全部物料」的存放量；
        // 库房级统计该库房下「所有库位 + 库房级」的存放量，避免换物料或换库位绕过容量上限
        QueryWrapper<SpInventory> invQw = new QueryWrapper<>();
        invQw.eq("warehouse_code", order.getWarehouseCode());
        if (StringUtils.isNotBlank(order.getLocationCode())) {
            invQw.eq("location_code", order.getLocationCode());
        }
        BigDecimal occupied = BigDecimal.ZERO;
        for (SpInventory inv : iSpInventoryService.list(invQw)) {
            occupied = occupied.add(inv.getQty() == null ? BigDecimal.ZERO : inv.getQty());
        }
        BigDecimal after = occupied.add(BigDecimal.valueOf(order.getQty()));
        if (after.compareTo(BigDecimal.valueOf(capacity)) > 0) {
            throw new IllegalStateException("容量不足：" + targetDesc + "已存放" + occupied
                    + "，本次入库物料[" + order.getMaterielCode() + "]" + order.getQty() + "，合计" + after
                    + "，超过容量上限" + capacity);
        }
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void confirmOrder(String id, String username) {
        SpWorkOrder order = this.getById(id);
        if (order == null) {
            throw new IllegalArgumentException("工单不存在");
        }
        if (!"01".equals(order.getStatus())) {
            throw new IllegalArgumentException("工单状态不允许确认，当前状态：" + ("02".equals(order.getStatus()) ? "已完成" : order.getStatus()));
        }

        if ("IN".equals(order.getOrderType())) {
            // ===== 入库：直接增加实际库存数量，写库存流水（类型：入库）=====
            BigDecimal addQty = BigDecimal.valueOf(order.getQty());
            BigDecimal beforeQty = BigDecimal.ZERO;
            QueryWrapper<SpInventory> invQw = new QueryWrapper<>();
            invQw.eq("materiel_code", order.getMaterielCode());
            invQw.eq("warehouse_code", order.getWarehouseCode());
            invQw.eq("location_code", order.getLocationCode() == null ? "" : order.getLocationCode());
            SpInventory exists = iSpInventoryService.getOne(invQw);
            if (exists != null) {
                beforeQty = exists.getQty() == null ? BigDecimal.ZERO : exists.getQty();
            }
            SpInventory after = iSpInventoryService.increaseInventory(order.getMaterielCode(),
                    order.getMaterielDesc(), order.getWarehouseCode(), order.getLocationCode(), addQty);

            SpInventoryFlow flow = new SpInventoryFlow();
            flow.setMaterielCode(order.getMaterielCode());
            flow.setMaterielDesc(order.getMaterielDesc());
            flow.setWarehouseCode(order.getWarehouseCode());
            flow.setLocationCode(order.getLocationCode() == null ? "" : order.getLocationCode());
            flow.setChangeType("IN");
            flow.setChangeQty(addQty);
            flow.setBeforeQty(beforeQty);
            flow.setAfterQty(beforeQty.add(addQty));
            flow.setOrderCode(order.getOrderCode());
            flow.setRemark("工单入库");
            iSpInventoryFlowService.saveFlow(flow);
        } else {
            // ===== 出库：查询工单物料需求，校验需求状态 =====
            QueryWrapper<SpWorkOrderRequirement> reqQw = new QueryWrapper<>();
            reqQw.eq("order_code", order.getOrderCode());
            List<SpWorkOrderRequirement> requirements = iSpWorkOrderRequirementService.list(reqQw);
            if (requirements == null || requirements.isEmpty()) {
                throw new IllegalStateException("工单没有物料需求，无法确认出库");
            }
            for (SpWorkOrderRequirement req : requirements) {
                if (!"01".equals(req.getStatus())) {
                    throw new IllegalStateException("物料需求状态异常（可能已发放），无法重复确认出库");
                }
            }
            // 对每个物料执行：先扣减锁定数量，再扣减实际库存数量；写库存流水（类型：出库）
            for (SpWorkOrderRequirement req : requirements) {
                SpInventory inventory = iSpInventoryService.selectByIdForUpdate(req.getInventoryId());
                if (inventory == null) {
                    throw new IllegalStateException("库存记录不存在：物料" + req.getMaterielCode());
                }
                BigDecimal beforeQty = inventory.getQty() == null ? BigDecimal.ZERO : inventory.getQty();
                boolean ok = iSpInventoryService.deductInventory(req.getInventoryId(), req.getRequiredQty(), true);
                if (!ok) {
                    throw new IllegalStateException("库存扣减失败（并发冲突）：物料" + req.getMaterielCode());
                }
                // 写库存流水（类型：出库）
                SpInventoryFlow flow = new SpInventoryFlow();
                flow.setMaterielCode(req.getMaterielCode());
                flow.setMaterielDesc(req.getMaterielDesc());
                flow.setWarehouseCode(req.getWarehouseCode());
                flow.setLocationCode(req.getLocationCode());
                flow.setChangeType("OUT");
                flow.setChangeQty(req.getRequiredQty().negate());
                flow.setBeforeQty(beforeQty);
                flow.setAfterQty(beforeQty.subtract(req.getRequiredQty()));
                flow.setOrderCode(order.getOrderCode());
                flow.setRemark("工单出库发放");
                iSpInventoryFlowService.saveFlow(flow);
                // 需求状态更新为已发放
                req.setStatus("02");
                iSpWorkOrderRequirementService.updateById(req);
            }
        }
        // 工单状态更新为已完成
        order.setStatus("02");
        this.updateById(order);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void deleteOrder(String id) {
        SpWorkOrder order = this.getById(id);
        if (order == null) {
            throw new IllegalArgumentException("工单不存在");
        }
        if ("02".equals(order.getStatus())) {
            throw new IllegalArgumentException("工单已完成，不允许删除");
        }
        // 出库工单：释放已锁定库存，并删除物料需求
        if ("OUT".equals(order.getOrderType())) {
            releaseRequirements(order.getOrderCode());
        }
        this.removeById(id);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void updateOrder(SpWorkOrder order, String username) {
        SpWorkOrder old = this.getById(order.getId());
        if (old == null) {
            throw new IllegalArgumentException("工单不存在");
        }
        if ("02".equals(old.getStatus())) {
            throw new IllegalArgumentException("工单已完成，不允许修改");
        }
        // 出库工单修改：先释放原锁定库存并删除物料需求，再重新BOM展开锁定
        if ("OUT".equals(old.getOrderType())) {
            releaseRequirements(old.getOrderCode());
        }
        order.setOrderCode(old.getOrderCode());
        createOrder(order, username);
    }

    /**
     * 释放出库工单的库存锁定并删除物料需求
     *
     * @param orderCode 工单编号
     */
    private void releaseRequirements(String orderCode) {
        QueryWrapper<SpWorkOrderRequirement> reqQw = new QueryWrapper<>();
        reqQw.eq("order_code", orderCode);
        List<SpWorkOrderRequirement> requirements = iSpWorkOrderRequirementService.list(reqQw);
        for (SpWorkOrderRequirement req : requirements) {
            if (req.getStatus() != null && "01".equals(req.getStatus())
                    && StringUtils.isNotBlank(req.getInventoryId())) {
                boolean ok = iSpInventoryService.releaseLock(req.getInventoryId(), req.getRequiredQty());
                if (!ok) {
                    throw new IllegalStateException("释放库存锁定失败：物料" + req.getMaterielCode());
                }
            }
        }
        iSpWorkOrderRequirementService.remove(reqQw);
    }

    /**
     * 按指定BOM递归展开下级需求量
     *
     * @param bom     BOM头
     * @param qty     数量
     * @param result  结果集合
     * @param visited 已展开的BOM头ID集合（防环）
     */
    private void expandBom(SpBom bom, BigDecimal qty, Map<String, BigDecimal> result, Set<String> visited) {
        if (!visited.add(bom.getId())) {
            throw new IllegalStateException("BOM存在循环引用，无法展开：" + bom.getBomCode());
        }
        try {
            QueryWrapper<SpBomItem> itemQw = new QueryWrapper<>();
            itemQw.eq("bom_head_id", bom.getId());
            List<SpBomItem> items = iSpBomItemService.list(itemQw);
            if (items == null || items.isEmpty()) {
                result.merge(bom.getMaterielCode(), qty, BigDecimal::add);
                return;
            }
            for (SpBomItem item : items) {
                BigDecimal itemNeed = item.getItemNum() == null ? BigDecimal.ZERO : item.getItemNum().multiply(qty);
                SpBom childBom = resolveChildBom(item);
                if (childBom != null) {
                    expandBom(childBom, itemNeed, result, visited);
                } else {
                    result.merge(item.getMaterielItemCode(), itemNeed, BigDecimal::add);
                }
            }
        } finally {
            visited.remove(bom.getId());
        }
    }

    /**
     * 解析子项需要展开的BOM：物料BOM按引用ID展开，单纯物料不展开，历史数据按物料编码兜底匹配
     */
    private SpBom resolveChildBom(SpBomItem item) {
        String childBomId = null;
        if ("1".equals(item.getItemType())) {
            childBomId = item.getRefBomId();
        } else if (StringUtils.isEmpty(item.getItemType())) {
            QueryWrapper<SpBom> bomQw = new QueryWrapper<>();
            bomQw.eq("materiel_code", item.getMaterielItemCode());
            bomQw.orderByAsc("bom_code");
            bomQw.last("LIMIT 1");
            SpBom childBom = iSpBomService.getOne(bomQw, false);
            childBomId = childBom == null ? null : childBom.getId();
        }
        if (StringUtils.isEmpty(childBomId)) {
            return null;
        }
        return iSpBomService.getById(childBomId);
    }
}
