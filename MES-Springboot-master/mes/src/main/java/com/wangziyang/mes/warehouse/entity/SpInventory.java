package com.wangziyang.mes.warehouse.entity;

import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableName;
import com.wangziyang.mes.common.BaseEntity;

import java.math.BigDecimal;

/**
 * 库存
 *
 * @author WangZiYang
 * @since 2021-06-02
 */
@TableName("sp_inventory")
public class SpInventory extends BaseEntity {

    private static final long serialVersionUID = 1L;

    /**
     * 物料编码
     */
    private String materielCode;

    /**
     * 物料描述
     */
    private String materielDesc;

    /**
     * 实际库存数量
     */
    private BigDecimal qty;

    /**
     * 锁定数量（订单预占）
     */
    private BigDecimal lockedQty;

    /**
     * 可用数量（实际库存数量-锁定数量），查询时计算，不落库
     */
    @TableField(exist = false)
    private BigDecimal availableQty;

    /**
     * 版本号（库存扣减时用乐观锁）
     */
    private Integer version;

    /**
     * 单位
     */
    private String unit;

    /**
     * 库房ID
     */
    private String warehouseId;

    /**
     * 库房编号
     */
    private String warehouseCode;

    /**
     * 库房名称
     */
    private String warehouseName;

    /**
     * 库位ID
     */
    private String locationId;

    /**
     * 库位编号（空表示仓库级库存）
     */
    private String locationCode;

    /**
     * 状态：01 可用 02 冻结
     */
    private String status;

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

    public BigDecimal getQty() {
        return qty;
    }

    public void setQty(BigDecimal qty) {
        this.qty = qty;
    }

    public BigDecimal getLockedQty() {
        return lockedQty;
    }

    public void setLockedQty(BigDecimal lockedQty) {
        this.lockedQty = lockedQty;
    }

    public BigDecimal getAvailableQty() {
        return availableQty;
    }

    public void setAvailableQty(BigDecimal availableQty) {
        this.availableQty = availableQty;
    }

    public Integer getVersion() {
        return version;
    }

    public void setVersion(Integer version) {
        this.version = version;
    }

    public String getUnit() {
        return unit;
    }

    public void setUnit(String unit) {
        this.unit = unit;
    }

    public String getWarehouseId() {
        return warehouseId;
    }

    public void setWarehouseId(String warehouseId) {
        this.warehouseId = warehouseId;
    }

    public String getWarehouseCode() {
        return warehouseCode;
    }

    public void setWarehouseCode(String warehouseCode) {
        this.warehouseCode = warehouseCode;
    }

    public String getWarehouseName() {
        return warehouseName;
    }

    public void setWarehouseName(String warehouseName) {
        this.warehouseName = warehouseName;
    }

    public String getLocationId() {
        return locationId;
    }

    public void setLocationId(String locationId) {
        this.locationId = locationId;
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
        return "SpInventory{" +
                "materielCode='" + materielCode + '\'' +
                ", materielDesc='" + materielDesc + '\'' +
                ", qty=" + qty +
                ", lockedQty=" + lockedQty +
                ", version=" + version +
                ", unit='" + unit + '\'' +
                ", warehouseCode='" + warehouseCode + '\'' +
                ", warehouseName='" + warehouseName + '\'' +
                ", locationCode='" + locationCode + '\'' +
                ", status='" + status + '\'' +
                "}";
    }
}
