package com.wangziyang.mes.technology.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.wangziyang.mes.common.BaseEntity;

/**
 * <p>
 * 产品工艺规划明细表（工序与BOM层次绑定）
 * </p>
 *
 * @author WangZiYang
 * @since 2020-03-28
 */
@TableName(value = "sp_product_process_item")
public class SpProductProcessItem extends BaseEntity {

    private static final long serialVersionUID = 1L;

    /**
     * 工艺规划头ID
     */
    private String processId;

    /**
     * 上级工艺项ID（对应BOM层次关系）
     */
    private String parentId;

    /**
     * BOM子项ID
     */
    private String bomItemId;

    /**
     * BOM层次
     */
    private Integer bomLevel;

    /**
     * 子项物料编码
     */
    private String materielItemCode;

    /**
     * 子项物料描述
     */
    private String materielItemDesc;

    /**
     * 工序ID
     */
    private String operId;

    /**
     * 工序编号
     */
    private String oper;

    /**
     * 工序名称
     */
    private String operDesc;

    /**
     * 排序号
     */
    private Integer sortNum;

    /**
     * 备注
     */
    private String remark;

    public String getProcessId() {
        return processId;
    }

    public void setProcessId(String processId) {
        this.processId = processId;
    }

    public String getParentId() {
        return parentId;
    }

    public void setParentId(String parentId) {
        this.parentId = parentId;
    }

    public String getBomItemId() {
        return bomItemId;
    }

    public void setBomItemId(String bomItemId) {
        this.bomItemId = bomItemId;
    }

    public Integer getBomLevel() {
        return bomLevel;
    }

    public void setBomLevel(Integer bomLevel) {
        this.bomLevel = bomLevel;
    }

    public String getMaterielItemCode() {
        return materielItemCode;
    }

    public void setMaterielItemCode(String materielItemCode) {
        this.materielItemCode = materielItemCode;
    }

    public String getMaterielItemDesc() {
        return materielItemDesc;
    }

    public void setMaterielItemDesc(String materielItemDesc) {
        this.materielItemDesc = materielItemDesc;
    }

    public String getOperId() {
        return operId;
    }

    public void setOperId(String operId) {
        this.operId = operId;
    }

    public String getOper() {
        return oper;
    }

    public void setOper(String oper) {
        this.oper = oper;
    }

    public String getOperDesc() {
        return operDesc;
    }

    public void setOperDesc(String operDesc) {
        this.operDesc = operDesc;
    }

    public Integer getSortNum() {
        return sortNum;
    }

    public void setSortNum(Integer sortNum) {
        this.sortNum = sortNum;
    }

    public String getRemark() {
        return remark;
    }

    public void setRemark(String remark) {
        this.remark = remark;
    }
}
