package com.wangziyang.mes.basedata.device.request;

import com.wangziyang.mes.basedata.device.entity.SpDeviceGroup;

import com.wangziyang.mes.common.BasePageReq;

/**
 * 设备编组分页查询请求
 *
 * @author WangZiYang
 * @since 2021-03-01
 */
public class SpDeviceGroupReq extends BasePageReq<SpDeviceGroup> {

    private static final long serialVersionUID = 1L;

    /**
     * 编组代码模糊查询
     */
    private String groupCodeLike;

    /**
     * 编组名称模糊查询
     */
    private String groupNameLike;

    public String getGroupCodeLike() {
        return groupCodeLike;
    }

    public void setGroupCodeLike(String groupCodeLike) {
        this.groupCodeLike = groupCodeLike;
    }

    public String getGroupNameLike() {
        return groupNameLike;
    }

    public void setGroupNameLike(String groupNameLike) {
        this.groupNameLike = groupNameLike;
    }
}
