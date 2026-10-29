package com.wangziyang.mes.basedata.device.request;

import com.wangziyang.mes.basedata.device.entity.SpDevice;

import com.wangziyang.mes.common.BasePageReq;

/**
 * 设备定义分页查询请求
 *
 * @author WangZiYang
 * @since 2021-03-01
 */
public class SpDeviceReq extends BasePageReq<SpDevice> {

    private static final long serialVersionUID = 1L;

    /**
     * 设备编号模糊查询
     */
    private String deviceCodeLike;

    /**
     * 设备名称模糊查询
     */
    private String deviceNameLike;

    public String getDeviceCodeLike() {
        return deviceCodeLike;
    }

    public void setDeviceCodeLike(String deviceCodeLike) {
        this.deviceCodeLike = deviceCodeLike;
    }

    public String getDeviceNameLike() {
        return deviceNameLike;
    }

    public void setDeviceNameLike(String deviceNameLike) {
        this.deviceNameLike = deviceNameLike;
    }
}
