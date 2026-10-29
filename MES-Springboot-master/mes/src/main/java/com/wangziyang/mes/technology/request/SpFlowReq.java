package com.wangziyang.mes.technology.request;

import com.wangziyang.mes.technology.entity.SpFlow;

import com.wangziyang.mes.common.BasePageReq;
/**
 * 流程分页对象
 * @author wangziyang
 * @since 2020/03/15
 */
public class SpFlowReq extends BasePageReq<SpFlow> {

    /**
     * 路线编码模糊查询
     */
    private String flowLike;

    public String getFlowLike() {
        return flowLike;
    }

    public void setFlowLike(String flowLike) {
        this.flowLike = flowLike;
    }
}
