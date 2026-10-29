package com.wangziyang.mes.basedata.workcell.entity;

import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableName;
import com.wangziyang.mes.common.BaseEntity;

import java.math.BigDecimal;

/**
 * 加工单元定义实体
 *
 * @author WangZiyang
 * @since 2021-03-10
 */
@TableName("sp_work_cell")
public class WorkCell extends BaseEntity {

    private static final long serialVersionUID = 1L;

    /**
     * 加工单元代码
     */
    private String workCellCode;

    /**
     * 加工单元名称
     */
    private String workCellName;

    /**
     * 标准产能（小时）
     */
    private BigDecimal standardCapacity;

    /**
     * 加工单元类型
     */
    private String workCellType;

    /**
     * 是否有线边库：0否 1是
     */
    private String hasLineSideWarehouse;

    /**
     * 备注
     */
    private String remark;

    /**
     * 逻辑删除：1 表示删除，0 表示未删除，2 表示禁用
     */
    @TableField(value = "is_deleted")
    private String deleted;

    public String getWorkCellCode() {
        return workCellCode;
    }

    public void setWorkCellCode(String workCellCode) {
        this.workCellCode = workCellCode;
    }

    public String getWorkCellName() {
        return workCellName;
    }

    public void setWorkCellName(String workCellName) {
        this.workCellName = workCellName;
    }

    public BigDecimal getStandardCapacity() {
        return standardCapacity;
    }

    public void setStandardCapacity(BigDecimal standardCapacity) {
        this.standardCapacity = standardCapacity;
    }

    public String getWorkCellType() {
        return workCellType;
    }

    public void setWorkCellType(String workCellType) {
        this.workCellType = workCellType;
    }

    public String getHasLineSideWarehouse() {
        return hasLineSideWarehouse;
    }

    public void setHasLineSideWarehouse(String hasLineSideWarehouse) {
        this.hasLineSideWarehouse = hasLineSideWarehouse;
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
        return "WorkCell{" +
                "workCellCode='" + workCellCode + '\'' +
                ", workCellName='" + workCellName + '\'' +
                ", standardCapacity=" + standardCapacity +
                ", workCellType='" + workCellType + '\'' +
                ", hasLineSideWarehouse='" + hasLineSideWarehouse + '\'' +
                ", remark='" + remark + '\'' +
                ", deleted='" + deleted + '\'' +
                '}';
    }
}
