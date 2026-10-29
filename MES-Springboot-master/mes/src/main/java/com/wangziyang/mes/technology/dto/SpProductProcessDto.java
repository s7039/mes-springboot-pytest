package com.wangziyang.mes.technology.dto;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.wangziyang.mes.technology.entity.SpProductProcessItem;

import java.util.List;

/**
 * 产品工艺规划DTO
 *
 * @author WangZiYang
 * @since 2020-03-28
 */
@JsonIgnoreProperties(ignoreUnknown = true)
public class SpProductProcessDto {

    /**
     * 工艺规划头ID
     */
    private String id;

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
     * 备注
     */
    private String remark;

    /**
     * 工序集合
     */
    private List<SpProductProcessItem> itemList;

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

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

    public String getRemark() {
        return remark;
    }

    public void setRemark(String remark) {
        this.remark = remark;
    }

    public List<SpProductProcessItem> getItemList() {
        return itemList;
    }

    public void setItemList(List<SpProductProcessItem> itemList) {
        this.itemList = itemList;
    }
}
