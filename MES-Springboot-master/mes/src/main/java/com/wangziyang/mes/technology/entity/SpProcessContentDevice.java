package com.wangziyang.mes.technology.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.wangziyang.mes.common.BaseEntity;

/**
 * 工序使用工装设备表
 */
@TableName("sp_process_content_device")
public class SpProcessContentDevice extends BaseEntity {

    private static final long serialVersionUID = 1L;

    private String contentId;
    private String contentOperId;
    private String deviceId;
    private String deviceCode;
    private String deviceName;
    private Integer requiredQty;
    private String remark;

    public String getContentId() { return contentId; }
    public void setContentId(String contentId) { this.contentId = contentId; }
    public String getContentOperId() { return contentOperId; }
    public void setContentOperId(String contentOperId) { this.contentOperId = contentOperId; }
    public String getDeviceId() { return deviceId; }
    public void setDeviceId(String deviceId) { this.deviceId = deviceId; }
    public String getDeviceCode() { return deviceCode; }
    public void setDeviceCode(String deviceCode) { this.deviceCode = deviceCode; }
    public String getDeviceName() { return deviceName; }
    public void setDeviceName(String deviceName) { this.deviceName = deviceName; }
    public Integer getRequiredQty() { return requiredQty; }
    public void setRequiredQty(Integer requiredQty) { this.requiredQty = requiredQty; }
    public String getRemark() { return remark; }
    public void setRemark(String remark) { this.remark = remark; }
}
