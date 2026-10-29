package com.wangziyang.mes.technology.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.wangziyang.mes.common.BaseEntity;

/**
 * <p>
 * bom头表实体
 * </p>
 *
 * @author WangZiYang
 * @since 2020-03-28
 */
@TableName(value = "sp_bom")
public class SpBom extends BaseEntity {

    private static final long serialVersionUID = 1L;

    /**
     * bom编号
     */
    private String bomCode;

    /**
     * 物料ID
     */
    private String materielCode;

    /**
     * 物料描述
     */
    private String materielDesc;

    /**
     * 备注
     */
    private String remark;

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

    public String getRemark() {
        return remark;
    }

    public void setRemark(String remark) {
        this.remark = remark;
    }

    @Override
    public String toString() {
        return "SpBom{" +
                "bomCode=" + bomCode +
                ", materielCode=" + materielCode +
                ", materielDesc=" + materielDesc +
                ", remark=" + remark +
                "}";
    }
}
