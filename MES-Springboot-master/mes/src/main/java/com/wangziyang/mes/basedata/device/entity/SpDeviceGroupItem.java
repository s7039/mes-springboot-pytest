package com.wangziyang.mes.basedata.device.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.wangziyang.mes.common.BaseEntity;

/**
 * 设备编组明细
 *
 * @author WangZiYang
 * @since 2021-03-01
 */
@TableName("sp_device_group_item")
public class SpDeviceGroupItem extends BaseEntity {

    private static final long serialVersionUID = 1L;

    /**
     * 编组ID
     */
    private String groupId;

    /**
     * 设备ID
     */
    private String deviceId;

    public String getGroupId() {
        return groupId;
    }

    public void setGroupId(String groupId) {
        this.groupId = groupId;
    }

    public String getDeviceId() {
        return deviceId;
    }

    public void setDeviceId(String deviceId) {
        this.deviceId = deviceId;
    }

    @Override
    public String toString() {
        return "SpDeviceGroupItem{" +
                "groupId='" + groupId + '\'' +
                ", deviceId='" + deviceId + '\'' +
                "}";
    }
}
