package com.wangziyang.mes.technology.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.wangziyang.mes.common.BaseEntity;
import java.math.BigDecimal;

/**
 * 工序使用物料表
 */
@TableName("sp_process_content_material")
public class SpProcessContentMaterial extends BaseEntity {

    private static final long serialVersionUID = 1L;

    private String contentId;
    private String contentOperId;
    private String materielCode;
    private String materielDesc;
    private String unit;
    private BigDecimal requiredQty;
    private String remark;

    public String getContentId() { return contentId; }
    public void setContentId(String contentId) { this.contentId = contentId; }
    public String getContentOperId() { return contentOperId; }
    public void setContentOperId(String contentOperId) { this.contentOperId = contentOperId; }
    public String getMaterielCode() { return materielCode; }
    public void setMaterielCode(String materielCode) { this.materielCode = materielCode; }
    public String getMaterielDesc() { return materielDesc; }
    public void setMaterielDesc(String materielDesc) { this.materielDesc = materielDesc; }
    public String getUnit() { return unit; }
    public void setUnit(String unit) { this.unit = unit; }
    public BigDecimal getRequiredQty() { return requiredQty; }
    public void setRequiredQty(BigDecimal requiredQty) { this.requiredQty = requiredQty; }
    public String getRemark() { return remark; }
    public void setRemark(String remark) { this.remark = remark; }
}
