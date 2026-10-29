package com.wangziyang.mes.technology.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.wangziyang.mes.common.BaseEntity;

/**
 * 工艺编制工序内容表
 */
@TableName("sp_process_content_oper")
public class SpProcessContentOper extends BaseEntity {

    private static final long serialVersionUID = 1L;

    private String contentId;
    private String processItemId;
    private String operId;
    private String oper;
    private String operDesc;
    private Integer bomLevel;
    private String materielItemCode;
    private String materielItemDesc;
    private String contentText;
    private String images;
    private Integer sortNum;
    private String status;
    private String remark;

    public String getContentId() { return contentId; }
    public void setContentId(String contentId) { this.contentId = contentId; }
    public String getProcessItemId() { return processItemId; }
    public void setProcessItemId(String processItemId) { this.processItemId = processItemId; }
    public String getOperId() { return operId; }
    public void setOperId(String operId) { this.operId = operId; }
    public String getOper() { return oper; }
    public void setOper(String oper) { this.oper = oper; }
    public String getOperDesc() { return operDesc; }
    public void setOperDesc(String operDesc) { this.operDesc = operDesc; }
    public Integer getBomLevel() { return bomLevel; }
    public void setBomLevel(Integer bomLevel) { this.bomLevel = bomLevel; }
    public String getMaterielItemCode() { return materielItemCode; }
    public void setMaterielItemCode(String materielItemCode) { this.materielItemCode = materielItemCode; }
    public String getMaterielItemDesc() { return materielItemDesc; }
    public void setMaterielItemDesc(String materielItemDesc) { this.materielItemDesc = materielItemDesc; }
    public String getContentText() { return contentText; }
    public void setContentText(String contentText) { this.contentText = contentText; }
    public String getImages() { return images; }
    public void setImages(String images) { this.images = images; }
    public Integer getSortNum() { return sortNum; }
    public void setSortNum(Integer sortNum) { this.sortNum = sortNum; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getRemark() { return remark; }
    public void setRemark(String remark) { this.remark = remark; }
}
