package com.wangziyang.mes.warehouse.entity;

import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableName;
import com.wangziyang.mes.common.BaseEntity;

/**
 * 库房
 *
 * @author WangZiYang
 * @since 2021-03-01
 */
@TableName("sp_warehouse")
public class SpWarehouse extends BaseEntity {

    private static final long serialVersionUID = 1L;

    /**
     * 库房编号（KF001、KF002...，删除后自动回收）
     */
    private String warehouseCode;

    /**
     * 库房名称（必填）
     */
    private String warehouseName;

    /**
     * 库房容量（正整数，必填）
     */
    private Integer capacity;

    /**
     * 库位数量（默认0，非负整数）
     */
    private Integer locationCount;

    /**
     * 库房类型（如：零件库、半成品库、成品库等，3D仿真展示用）
     */
    private String warehouseType;

    /**
     * 库房规格（3D仿真展示用）
     */
    private String spec;

    /**
     * 备注
     */
    private String remark;

    /**
     * 状态(00:删除;01:正常;02:禁用)
     */
    @TableField(value = "is_deleted")
    private String deleted;

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

    public Integer getCapacity() {
        return capacity;
    }

    public void setCapacity(Integer capacity) {
        this.capacity = capacity;
    }

    public Integer getLocationCount() {
        return locationCount;
    }

    public void setLocationCount(Integer locationCount) {
        this.locationCount = locationCount;
    }

    public String getWarehouseType() {
        return warehouseType;
    }

    public void setWarehouseType(String warehouseType) {
        this.warehouseType = warehouseType;
    }

    public String getSpec() {
        return spec;
    }

    public void setSpec(String spec) {
        this.spec = spec;
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
        return "SpWarehouse{" +
                "warehouseCode='" + warehouseCode + '\'' +
                ", warehouseName='" + warehouseName + '\'' +
                ", capacity=" + capacity +
                ", locationCount=" + locationCount +
                ", remark='" + remark + '\'' +
                ", deleted='" + deleted + '\'' +
                "}";
    }
}
