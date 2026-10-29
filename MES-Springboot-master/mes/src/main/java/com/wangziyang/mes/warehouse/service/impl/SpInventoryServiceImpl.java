package com.wangziyang.mes.warehouse.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.UpdateWrapper;
import com.wangziyang.mes.warehouse.entity.SpInventory;
import com.wangziyang.mes.warehouse.mapper.SpInventoryMapper;
import com.wangziyang.mes.warehouse.service.ISpInventoryService;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import org.apache.commons.lang3.StringUtils;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;

/**
 * 库存 服务实现类
 *
 * @author WangZiYang
 * @since 2021-06-02
 */
@Service
public class SpInventoryServiceImpl extends ServiceImpl<SpInventoryMapper, SpInventory> implements ISpInventoryService {

    @Override
    public SpInventory selectByIdForUpdate(String id) {
        return this.baseMapper.selectByIdForUpdate(id);
    }

    @Override
    public List<SpInventory> listAvailableByMateriel(String materielCode) {
        QueryWrapper<SpInventory> qw = new QueryWrapper<>();
        qw.eq("materiel_code", materielCode);
        qw.apply("qty - locked_qty > 0");
        qw.orderByAsc("qty - locked_qty");
        return this.list(qw);
    }

    @Override
    public BigDecimal sumAvailableByMateriel(String materielCode) {
        QueryWrapper<SpInventory> qw = new QueryWrapper<>();
        qw.eq("materiel_code", materielCode);
        qw.apply("qty - locked_qty > 0");
        List<SpInventory> list = this.list(qw);
        BigDecimal sum = BigDecimal.ZERO;
        for (SpInventory inv : list) {
            sum = sum.add(inv.getQty().subtract(nvl(inv.getLockedQty())));
        }
        return sum;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean lockInventory(String id, BigDecimal lockQty) {
        // 悲观锁：行级锁读取，防止并发预占超扣（双保险之一）
        SpInventory inventory = selectByIdForUpdate(id);
        if (inventory == null) {
            return false;
        }
        BigDecimal qty = nvl(inventory.getQty());
        BigDecimal lockedQty = nvl(inventory.getLockedQty());
        // 条件更新保证不超扣：可用数量充足才锁定，同时乐观锁版本号校验（双保险之二）
        if (qty.subtract(lockedQty).compareTo(lockQty) < 0) {
            return false;
        }
        UpdateWrapper<SpInventory> uw = new UpdateWrapper<>();
        uw.setSql("locked_qty = locked_qty + " + lockQty.toPlainString() + ", version = version + 1");
        uw.eq("id", id);
        uw.eq("version", inventory.getVersion());
        uw.apply("qty - locked_qty >= {0}", lockQty);
        return this.update(uw);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean deductInventory(String id, BigDecimal deductQty, boolean releaseLock) {
        // 悲观锁：行级锁读取（双保险之一）
        SpInventory inventory = selectByIdForUpdate(id);
        if (inventory == null) {
            return false;
        }
        BigDecimal qty = nvl(inventory.getQty());
        BigDecimal lockedQty = nvl(inventory.getLockedQty());
        // 发料数量不能超过锁定数量，否则说明预占逻辑有漏洞
        if (releaseLock && lockedQty.compareTo(deductQty) < 0) {
            throw new IllegalStateException("发料数量超过锁定数量，预占逻辑有漏洞：物料" + inventory.getMaterielCode()
                    + " 锁定数量" + lockedQty + "，发料数量" + deductQty);
        }
        if (qty.compareTo(deductQty) < 0) {
            throw new IllegalStateException("实际库存不足：物料" + inventory.getMaterielCode()
                    + " 实际库存" + qty + "，需要扣减" + deductQty);
        }
        UpdateWrapper<SpInventory> uw = new UpdateWrapper<>();
        String setSql;
        if (releaseLock) {
            // 先扣减锁定数量，再扣减实际库存数量
            setSql = "locked_qty = locked_qty - " + deductQty.toPlainString()
                    + ", qty = qty - " + deductQty.toPlainString() + ", version = version + 1";
        } else {
            setSql = "qty = qty - " + deductQty.toPlainString() + ", version = version + 1";
        }
        uw.setSql(setSql);
        uw.eq("id", id);
        uw.eq("version", inventory.getVersion());
        boolean updated = this.update(uw);
        if (updated) {
            // 实际库存数量扣减到 0 且无锁定数量时，自动删除该库存记录（库存管理不再保留零库存数据）
            BigDecimal newQty = qty.subtract(deductQty);
            BigDecimal newLocked = releaseLock ? lockedQty.subtract(deductQty) : lockedQty;
            if (newQty.compareTo(BigDecimal.ZERO) == 0 && newLocked.compareTo(BigDecimal.ZERO) == 0) {
                this.removeById(id);
            }
        }
        return updated;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean releaseLock(String id, BigDecimal releaseQty) {
        // 悲观锁：行级锁读取（双保险之一）
        SpInventory inventory = selectByIdForUpdate(id);
        if (inventory == null) {
            return false;
        }
        BigDecimal lockedQty = nvl(inventory.getLockedQty());
        if (lockedQty.compareTo(releaseQty) < 0) {
            throw new IllegalStateException("锁定数量不足，无法释放：物料" + inventory.getMaterielCode()
                    + " 锁定数量" + lockedQty + "，释放数量" + releaseQty);
        }
        UpdateWrapper<SpInventory> uw = new UpdateWrapper<>();
        uw.setSql("locked_qty = locked_qty - " + releaseQty.toPlainString() + ", version = version + 1");
        uw.eq("id", id);
        uw.eq("version", inventory.getVersion());
        return this.update(uw);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public SpInventory increaseInventory(String materielCode, String materielDesc,
                                         String warehouseCode, String locationCode, BigDecimal addQty) {
        if (StringUtils.isEmpty(locationCode)) {
            locationCode = "";
        }
        QueryWrapper<SpInventory> qw = new QueryWrapper<>();
        qw.eq("materiel_code", materielCode);
        qw.eq("warehouse_code", warehouseCode);
        qw.eq("location_code", locationCode);
        SpInventory inventory = this.getOne(qw);
        if (inventory == null) {
            inventory = new SpInventory();
            inventory.setMaterielCode(materielCode);
            inventory.setMaterielDesc(materielDesc);
            inventory.setQty(addQty);
            inventory.setLockedQty(BigDecimal.ZERO);
            inventory.setVersion(0);
            inventory.setUnit(null);
            inventory.setWarehouseCode(warehouseCode);
            inventory.setLocationCode(locationCode);
            inventory.setStatus("01");
            this.save(inventory);
        } else {
            // 悲观锁 + 乐观锁双保险累加
            SpInventory locked = selectByIdForUpdate(inventory.getId());
            if (locked == null) {
                throw new IllegalStateException("库存记录不存在：" + inventory.getId());
            }
            UpdateWrapper<SpInventory> uw = new UpdateWrapper<>();
            uw.setSql("qty = qty + " + addQty.toPlainString() + ", version = version + 1");
            uw.eq("id", locked.getId());
            uw.eq("version", locked.getVersion());
            if (!this.update(uw)) {
                throw new IllegalStateException("库存并发更新冲突，请重试");
            }
            inventory.setQty(nvl(inventory.getQty()).add(addQty));
            inventory.setVersion(nvlVersion(locked.getVersion()) + 1);
        }
        return inventory;
    }

    private BigDecimal nvl(BigDecimal value) {
        return value == null ? BigDecimal.ZERO : value;
    }

    private Integer nvlVersion(Integer value) {
        return value == null ? 0 : value;
    }
}
