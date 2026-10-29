package com.wangziyang.mes.warehouse.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.wangziyang.mes.common.BaseEntity;

import java.math.BigDecimal;

/**
 * 库存流水
 *
 * @author WangZiYang
 * @since 2026-08-16
 */
@TableName("sp_inventory_flow")
public class SpInventoryFlow extends BaseEntity {

    private static final long serialVersionUID = 1L;

    /**
     * 流水编号（LS00000001、LS00000002...，数据库唯一索引保证幂等）
     */
    private String flowCode;

    /**
     * 物料编码
     */
    private String materielCode;

    /**
     * 物料描述
     */
    private String materielDesc;

    /**
     * 库房编号
     */
    private String warehouseCode;

    /**
     * 库位编号（空表示仓库级库存）
     */
    private String locationCode;

    /**
     * 变动类型：IN 入库 / OUT 出库
     */
    private String changeType;

    /**
     * 变动数量（正负：入库为正、出库为负）
     */
    private BigDecimal changeQty;

    /**
     * 变动前数量
     */
    private BigDecimal beforeQty;

    /**
     * 变动后数量
     */
    private BigDecimal afterQty;

    /**
     * 工单编号
     */
    private String orderCode;

    /**
     * 备注
     */
    private String remark;

    public String getFlowCode() {
        return flowCode;
    }

    public void setFlowCode(String flowCode) {
        this.flowCode = flowCode;
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

    public String getChangeType() {
        return changeType;
    }

    public void setChangeType(String changeType) {
        this.changeType = changeType;
    }

    public BigDecimal getChangeQty() {
        return changeQty;
    }

    public void setChangeQty(BigDecimal changeQty) {
        this.changeQty = changeQty;
    }

    public BigDecimal getBeforeQty() {
        return beforeQty;
    }

    public void setBeforeQty(BigDecimal beforeQty) {
        this.beforeQty = beforeQty;
    }

    public BigDecimal getAfterQty() {
        return afterQty;
    }

    public void setAfterQty(BigDecimal afterQty) {
        this.afterQty = afterQty;
    }

    public String getOrderCode() {
        return orderCode;
    }

    public void setOrderCode(String orderCode) {
        this.orderCode = orderCode;
    }

    public String getRemark() {
        return remark;
    }

    public void setRemark(String remark) {
        this.remark = remark;
    }

    @Override
    public String toString() {
        return "SpInventoryFlow{" +
                "flowCode='" + flowCode + '\'' +
                ", materielCode='" + materielCode + '\'' +
                ", materielDesc='" + materielDesc + '\'' +
                ", warehouseCode='" + warehouseCode + '\'' +
                ", locationCode='" + locationCode + '\'' +
                ", changeType='" + changeType + '\'' +
                ", changeQty=" + changeQty +
                ", beforeQty=" + beforeQty +
                ", afterQty=" + afterQty +
                ", orderCode='" + orderCode + '\'' +
                ", remark='" + remark + '\'' +
                "}";
    }
}
