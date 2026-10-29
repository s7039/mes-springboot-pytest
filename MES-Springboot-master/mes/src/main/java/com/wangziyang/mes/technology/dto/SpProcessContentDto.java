package com.wangziyang.mes.technology.dto;

import com.wangziyang.mes.technology.entity.SpProcessContentOper;
import com.wangziyang.mes.technology.entity.SpProcessContentDevice;
import com.wangziyang.mes.technology.entity.SpProcessContentMaterial;

import java.util.List;

/**
 * 工艺编制DTO
 */
public class SpProcessContentDto {

    private String id;
    private String processId;
    private String bomId;
    private String bomCode;
    private String materielCode;
    private String materielDesc;
    private String status;
    private String remark;

    /** 当前编辑的工序ID */
    private String currentOperId;

    private List<SpProcessContentOper> operList;
    private List<SpProcessContentDevice> deviceList;
    private List<SpProcessContentMaterial> materialList;

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }
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
    public String getCurrentOperId() { return currentOperId; }
    public void setCurrentOperId(String currentOperId) { this.currentOperId = currentOperId; }
    public List<SpProcessContentOper> getOperList() { return operList; }
    public void setOperList(List<SpProcessContentOper> operList) { this.operList = operList; }
    public List<SpProcessContentDevice> getDeviceList() { return deviceList; }
    public void setDeviceList(List<SpProcessContentDevice> deviceList) { this.deviceList = deviceList; }
    public List<SpProcessContentMaterial> getMaterialList() { return materialList; }
    public void setMaterialList(List<SpProcessContentMaterial> materialList) { this.materialList = materialList; }
}
