package com.wangziyang.mes.technology.dto;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

/**
 * BOM树形节点（产品分解结构图节点）
 *
 * @author WangZiYang
 * @since 2021-03-01
 */
public class SpBomTreeNode {

    /**
     * 节点ID（bomId或itemId）
     */
    private String id;

    /**
     * 物料编码
     */
    private String materielCode;

    /**
     * 物料名称
     */
    private String materielDesc;

    /**
     * 用量（根节点为1，子节点为实际用量）
     */
    private BigDecimal itemNum;

    /**
     * 单位
     */
    private String itemUnit;

    /**
     * 是否为BOM头节点（true=产品/半成品节点，false=原材料节点）
     */
    private Boolean isBomHead;

    /**
     * 子节点列表
     */
    private List<SpBomTreeNode> children;

    /**
     * 是否有工艺（true=有工序，false=无工序）
     */
    private Boolean hasProcess;

    /**
     * 工序名称
     */
    private String operDesc;

    /**
     * 工序内容说明
     */
    private String contentText;

    /**
     * 工序图片JSON
     */
    private String images;

    public SpBomTreeNode() {
        this.children = new ArrayList<>();
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
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

    public BigDecimal getItemNum() {
        return itemNum;
    }

    public void setItemNum(BigDecimal itemNum) {
        this.itemNum = itemNum;
    }

    public String getItemUnit() {
        return itemUnit;
    }

    public void setItemUnit(String itemUnit) {
        this.itemUnit = itemUnit;
    }

    public Boolean getIsBomHead() {
        return isBomHead;
    }

    public void setIsBomHead(Boolean isBomHead) {
        this.isBomHead = isBomHead;
    }

    public List<SpBomTreeNode> getChildren() {
        return children;
    }

    public void setChildren(List<SpBomTreeNode> children) {
        this.children = children;
    }

    public Boolean getHasProcess() {
        return hasProcess;
    }

    public void setHasProcess(Boolean hasProcess) {
        this.hasProcess = hasProcess;
    }

    public String getOperDesc() {
        return operDesc;
    }

    public void setOperDesc(String operDesc) {
        this.operDesc = operDesc;
    }

    public String getContentText() {
        return contentText;
    }

    public void setContentText(String contentText) {
        this.contentText = contentText;
    }

    public String getImages() {
        return images;
    }

    public void setImages(String images) {
        this.images = images;
    }
}
