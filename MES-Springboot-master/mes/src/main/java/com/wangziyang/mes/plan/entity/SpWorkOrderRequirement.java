package com.wangziyang.mes.plan.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.wangziyang.mes.common.BaseEntity;

import java.math.BigDecimal;

/**
 * 工单物料需求（出库工单BOM展开并锁定库存后生成）
 *
 * @author WangZiYang
 * @since 2026-08-16
 */
@TableName("sp_work_order_requirement")
public class SpWorkOrderRequirement extends BaseEntity {

    private static final long serialVersionUID = 1L;

    /**
     * 工单编号
     */
    private String orderCode;

    /**
     * 物料编码
     */
    private String materielCode;

    /**
     * 物料描述
     */
    private String materielDesc;

    /**
     * 需求数量（=已锁定数量）
     */
    private BigDecimal requiredQty;

    /**
     * 单位
     */
    private String unit;

    /**
     * 锁定的库存记录ID
     */
    private String inventoryId;

    /**
     * 锁定库房编号
     */
    private String warehouseCode;

    /**
     * 锁定库位编号
     */
    private String locationCode;

    /**
     * 状态：01 已锁定 / 02 已发放
     */
    private String status;

    public String getOrderCode() {
        return orderCode;
    }

    public void setOrderCode(String orderCode) {
        this.orderCode = orderCode;
    }

    public String getMaterielCode() {
        return materielCode;
    }

    public void setMaterielCode(String materielCode) {
        this.materielCode = materielCode;
    }

    public String getMaterielDesc() {
        return materielDesc;
    }

    public void setMaterielDesc(String materielDesc) {
        this.materielDesc = materielDesc;
    }

    public BigDecimal getRequiredQty() {
        return requiredQty;
    }

    public void setRequiredQty(BigDecimal requiredQty) {
        this.requiredQty = requiredQty;
    }

    public String getUnit() {
        return unit;
    }

    public void setUnit(String unit) {
        this.unit = unit;
    }

    public String getInventoryId() {
        return inventoryId;
    }

    public void setInventoryId(String inventoryId) {
        this.inventoryId = inventoryId;
    }

    public String getWarehouseCode() {
        return warehouseCode;
    }

    public void setWarehouseCode(String warehouseCode) {
        this.warehouseCode = warehouseCode;
    }

    public String getLocationCode() {
        return locationCode;
    }

    public void setLocationCode(String locationCode) {
        this.locationCode = locationCode;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    @Override
    public String toString() {
        return "SpWorkOrderRequirement{" +
                "orderCode='" + orderCode + '\'' +
                ", materielCode='" + materielCode + '\'' +
                ", materielDesc='" + materielDesc + '\'' +
                ", requiredQty=" + requiredQty +
                ", unit='" + unit + '\'' +
                ", warehouseCode='" + warehouseCode + '\'' +
                ", locationCode='" + locationCode + '\'' +
                ", status='" + status + '\'' +
                "}";
    }
}
