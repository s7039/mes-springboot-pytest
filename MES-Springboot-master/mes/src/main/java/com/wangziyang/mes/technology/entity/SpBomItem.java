package com.wangziyang.mes.technology.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.wangziyang.mes.common.BaseEntity;

import java.math.BigDecimal;

/**
 * <p>
 *
 * </p>
 *
 * @author WangZiYang
 * @since 2020-03-28
 */
@TableName(value = "sp_bom_item")
public class SpBomItem extends BaseEntity {

    private static final long serialVersionUID = 1L;

    /**
     * bom编号
     */
    private String bomHeadId;

    /**
     * 物料ID
     */
    private String materielItemCode;

    /**
     * 物料描述
     */
    private String materielItemDesc;

    /**
     * 用量
     */
    private BigDecimal itemNum;

    /**
     * 子项基本单位
     */
    private String itemUnit;

    /**
     * 子项类型（0-单纯物料，1-物料BOM）
     */
    private String itemType;

    /**
     * 引用的BOM头ID（子项类型为物料BOM时有效）
     */
    private String refBomId;

    public String getBomHeadId() {
        return bomHeadId;
    }

    public void setBomHeadId(String bomHeadId) {
        this.bomHeadId = bomHeadId;
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

    public String getItemType() {
        return itemType;
    }

    public void setItemType(String itemType) {
        this.itemType = itemType;
    }

    public String getRefBomId() {
        return refBomId;
    }

    public void setRefBomId(String refBomId) {
        this.refBomId = refBomId;
    }

    @Override
    public String toString() {
        return "SpBomItem{" +
                "bomHeadId=" + bomHeadId +
                ", materielItemCode=" + materielItemCode +
                ", materielItemDesc=" + materielItemDesc +
                ", itemNum=" + itemNum +
                ", itemUnit=" + itemUnit +
                ", itemType=" + itemType +
                ", refBomId=" + refBomId +
                "}";
    }
}
