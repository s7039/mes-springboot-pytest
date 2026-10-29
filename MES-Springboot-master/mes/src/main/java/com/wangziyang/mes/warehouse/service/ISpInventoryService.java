package com.wangziyang.mes.warehouse.service;

import com.wangziyang.mes.warehouse.entity.SpInventory;
import com.baomidou.mybatisplus.extension.service.IService;

import java.math.BigDecimal;
import java.util.List;

/**
 * 库存 服务类
 *
 * @author WangZiYang
 * @since 2021-06-02
 */
public interface ISpInventoryService extends IService<SpInventory> {

    /**
     * 悲观锁查询（SELECT ... FOR UPDATE，数据库行锁）
     *
     * @param id 库存ID
     * @return 库存记录
     */
    SpInventory selectByIdForUpdate(String id);

    /**
     * 查询物料所有可用库存记录（可用数量>0），按可用数量升序
     *
     * @param materielCode 物料编码
     * @return 库存记录列表
     */
    List<SpInventory> listAvailableByMateriel(String materielCode);

    /**
     * 查询物料总可用数量（Σ(实际数量-锁定数量)）
     *
     * @param materielCode 物料编码
     * @return 可用数量
     */
    BigDecimal sumAvailableByMateriel(String materielCode);

    /**
     * 锁定库存（条件更新保证不超扣）：锁定数量增加，乐观锁版本号+1
     * 前置悲观锁行级查询，双重保险
     *
     * @param id      库存ID
     * @param lockQty 锁定数量
     * @return 是否锁定成功
     */
    boolean lockInventory(String id, BigDecimal lockQty);

    /**
     * 库存扣减：先扣减锁定数量，再扣减实际库存数量（乐观锁+条件更新双保险）
     *
     * @param id         库存ID
     * @param deductQty  扣减数量（发料数量）
     * @param releaseLock 是否同时释放锁定数量（出库发放时传true）
     * @return 是否扣减成功
     */
    boolean deductInventory(String id, BigDecimal deductQty, boolean releaseLock);

    /**
     * 释放锁定数量（工单删除时回滚预占）
     *
     * @param id         库存ID
     * @param releaseQty 释放数量
     * @return 是否释放成功
     */
    boolean releaseLock(String id, BigDecimal releaseQty);

    /**
     * 库存增加（入库），若不存在则创建仓库级/库位级库存记录
     *
     * @param materielCode  物料编码
     * @param materielDesc  物料描述
     * @param warehouseCode 库房编号
     * @param locationCode  库位编号（空表示仓库级库存）
     * @param addQty        增加数量
     * @return 库存记录
     */
    SpInventory increaseInventory(String materielCode, String materielDesc,
                                  String warehouseCode, String locationCode, BigDecimal addQty);
}
