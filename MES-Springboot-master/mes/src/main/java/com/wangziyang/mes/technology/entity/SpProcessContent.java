package com.wangziyang.mes.technology.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.wangziyang.mes.common.BaseEntity;

/**
 * 工艺编制头表
 */
@TableName("sp_process_content")
public class SpProcessContent extends BaseEntity {

    private static final long serialVersionUID = 1L;

    private String processId;
    private String bomId;
    private String bomCode;
    private String materielCode;
    private String materielDesc;
    private String status;
    private String remark;

    public String getProcessId() { return processId; }
    public void setProcessId(String processId) { this.processId = processId; }
    public String getBomId() { return bomId; }
    public void setBomId(String bomId) { this.bomId = bomId; }
    public String getBomCode() { return bomCode; }
    public void setBomCode(String bomCode) { this.bomCode = bomCode; }
    public String getMaterielCode() { return materielCode; }
    public void setMaterielCode(String materielCode) { this.materielCode = materielCode; }
    public String getMaterielDesc() { return materielDesc; }
    public void setMaterielDesc(String materielDesc) { this.materielDesc = materielDesc; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getRemark() { return remark; }
    public void setRemark(String remark) { this.remark = remark; }
}
