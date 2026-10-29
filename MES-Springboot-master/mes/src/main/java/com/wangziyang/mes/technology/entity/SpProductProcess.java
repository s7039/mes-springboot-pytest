package com.wangziyang.mes.technology.entity;

import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableName;
import com.wangziyang.mes.common.BaseEntity;

/**
 * <p>
 * 产品工艺规划头表
 * </p>
 *
 * @author WangZiYang
 * @since 2020-03-28
 */
@TableName(value = "sp_product_process")
public class SpProductProcess extends BaseEntity {

    private static final long serialVersionUID = 1L;

    /**
     * BOM头ID
     */
    private String bomId;

    /**
     * BOM编号
     */
    private String bomCode;

    /**
     * 物料编码
     */
    private String materielCode;

    /**
     * 物料描述
     */
    private String materielDesc;

    /**
     * 关联流程ID
     */
    private String flowId;

    /**
     * 关联流程编码
     */
    private String flow;

    /**
     * 关联流程描述
     */
    private String flowDesc;

    /**
     * 锁定状态：0未锁定 1已锁定
     */
    @TableField(value = "locked")
    private String locked;

    /**
     * 备注
     */
    private String remark;

    public String getBomId() {
        return bomId;
    }

    public void setBomId(String bomId) {
        this.bomId = bomId;
    }

    public String getBomCode() {
        return bomCode;
    }

    public void setBomCode(String bomCode) {
        this.bomCode = bomCode;
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

    public String getFlowId() {
        return flowId;
    }

    public void setFlowId(String flowId) {
        this.flowId = flowId;
    }

    public String getFlow() {
        return flow;
    }

    public void setFlow(String flow) {
        this.flow = flow;
    }

    public String getFlowDesc() {
        return flowDesc;
    }

    public void setFlowDesc(String flowDesc) {
        this.flowDesc = flowDesc;
    }

    public String getLocked() {
        return locked;
    }

    public void setLocked(String locked) {
        this.locked = locked;
    }

    public String getRemark() {
        return remark;
    }

    public void setRemark(String remark) {
        this.remark = remark;
    }
}
