package com.wangziyang.mes.technology.entity;

import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableName;
import com.wangziyang.mes.common.BaseEntity;

import java.math.BigDecimal;

/**
 * <p>
 * 工序实体类
 * </p>
 *
 * @author WangZiYang
 * @since 2020-03-14
 */
@TableName(value = "sp_oper")
public class SpOper extends BaseEntity {

    private static final long serialVersionUID = 1L;
    /**
     * 工序编号（系统自动生成）
     */
    private String oper;
    /**
     * 工序名称
     */
    private String operDesc;
    /**
     * 工时
     */
    private BigDecimal workingHours;
    /**
     * 制造周期
     */
    private BigDecimal manufacturingCycle;
    /**
     * 是否生成生产计划：0否 1是
     */
    private String generatePlan;
    /**
     * 逻辑删除
     */
    @TableField("is_deleted")
    private String deleted;
    /**
     * 备注
     */
    private String remark;


    @Override
    public String toString() {
        return "SpOper{" +
                "oper=" + oper +
                ", operDesc=" + operDesc +
                ", workingHours=" + workingHours +
                ", manufacturingCycle=" + manufacturingCycle +
                ", generatePlan=" + generatePlan +
                ", deleted=" + deleted +
                ", remark=" + remark +
                "}";
    }

    /**
     * 获取 工序编号
     *
     * @return oper 工序编号
     */
    public String getOper() {
        return this.oper;
    }

    /**
     * 设置 工序编号
     *
     * @param oper 工序编号
     */
    public void setOper(String oper) {
        this.oper = oper;
    }

    /**
     * 获取 工序名称
     *
     * @return operDesc 工序名称
     */
    public String getOperDesc() {
        return this.operDesc;
    }

    /**
     * 设置 工序名称
     *
     * @param operDesc 工序名称
     */
    public void setOperDesc(String operDesc) {
        this.operDesc = operDesc;
    }

    /**
     * 获取 工时
     *
     * @return workingHours 工时
     */
    public BigDecimal getWorkingHours() {
        return workingHours;
    }

    /**
     * 设置 工时
     *
     * @param workingHours 工时
     */
    public void setWorkingHours(BigDecimal workingHours) {
        this.workingHours = workingHours;
    }

    /**
     * 获取 制造周期
     *
     * @return manufacturingCycle 制造周期
     */
    public BigDecimal getManufacturingCycle() {
        return manufacturingCycle;
    }

    /**
     * 设置 制造周期
     *
     * @param manufacturingCycle 制造周期
     */
    public void setManufacturingCycle(BigDecimal manufacturingCycle) {
        this.manufacturingCycle = manufacturingCycle;
    }

    /**
     * 获取 是否生成生产计划
     *
     * @return generatePlan 是否生成生产计划
     */
    public String getGeneratePlan() {
        return generatePlan;
    }

    /**
     * 设置 是否生成生产计划
     *
     * @param generatePlan 是否生成生产计划
     */
    public void setGeneratePlan(String generatePlan) {
        this.generatePlan = generatePlan;
    }

    /**
     * 获取 逻辑删除
     *
     * @return deleted 逻辑删除
     */
    public String getDeleted() {
        return deleted;
    }

    /**
     * 设置 逻辑删除
     *
     * @param deleted 逻辑删除
     */
    public void setDeleted(String deleted) {
        this.deleted = deleted;
    }

    /**
     * 获取 备注
     *
     * @return remark 备注
     */
    public String getRemark() {
        return remark;
    }

    /**
     * 设置 备注
     *
     * @param remark 备注
     */
    public void setRemark(String remark) {
        this.remark = remark;
    }
}
