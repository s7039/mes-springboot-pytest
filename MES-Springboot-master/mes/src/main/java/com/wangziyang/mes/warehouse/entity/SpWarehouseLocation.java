package com.wangziyang.mes.warehouse.entity;

import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableName;
import com.wangziyang.mes.common.BaseEntity;

/**
 * 库位
 *
 * @author WangZiYang
 * @since 2021-06-02
 */
@TableName("sp_warehouse_location")
public class SpWarehouseLocation extends BaseEntity {

    private static final long serialVersionUID = 1L;

    /**
     * 库位编码（KF001-1、KF001-2...，随库房创建自动生成）
     */
    private String locationCode;

    /**
     * 库位名称
     */
    private String locationName;

    /**
     * 所属库房ID
     */
    private String warehouseId;

    /**
     * 所属库房编号
     */
    private String warehouseCode;

    /**
     * 所属库房名称
     */
    private String warehouseName;

    /**
     * 存放物料编码
     */
    private String materielCode;

    /**
     * 存放物料描述
     */
    private String materielDesc;

    /**
     * 容量（库房容量/库位数量，向下取整）
     */
    private Integer capacity;

    /**
     * 备注
     */
    private String remark;

    /**
     * 状态(00:删除;01:正常;02:禁用)
     */
    @TableField(value = "is_deleted")
    private String deleted;

    public String getLocationCode() {
        return locationCode;
    }

    public void setLocationCode(String locationCode) {
        this.locationCode = locationCode;
    }

    public String getLocationName() {
        return locationName;
    }

    public void setLocationName(String locationName) {
        this.locationName = locationName;
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

    public Integer getCapacity() {
        return capacity;
    }

    public void setCapacity(Integer capacity) {
        this.capacity = capacity;
    }

    public String getRemark() {
        return remark;
    }

    public void setRemark(String remark) {
        this.remark = remark;
    }

    public String getDeleted() {
        return deleted;
    }

    public void setDeleted(String deleted) {
        this.deleted = deleted;
    }

    @Override
    public String toString() {
        return "SpWarehouseLocation{" +
                "locationCode='" + locationCode + '\'' +
                ", locationName='" + locationName + '\'' +
                ", warehouseId='" + warehouseId + '\'' +
                ", warehouseCode='" + warehouseCode + '\'' +
                ", warehouseName='" + warehouseName + '\'' +
                ", materielCode='" + materielCode + '\'' +
                ", materielDesc='" + materielDesc + '\'' +
                ", capacity=" + capacity +
                ", remark='" + remark + '\'' +
                "}";
    }
}
