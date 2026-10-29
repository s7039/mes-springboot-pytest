package com.wangziyang.mes.technology.request;

import com.wangziyang.mes.technology.entity.SpOper;

import com.wangziyang.mes.common.BasePageReq;

/**
 * 工序信息定义分页请求对象
 * @author wangziyang
 * @since 2020/03/15
 */
public class SpOperReq extends BasePageReq<SpOper> {

    /**
     * 模糊查询工序编号
     */
    private String operLike;
    /**
     * 模糊查询工序名称
     */
    private String operDescLike;

    /**
     * 获取 模糊查询工序编号
     *
     * @return operLike 模糊查询工序编号
     */
    public String getOperLike() {
        return operLike;
    }

    /**
     * 设置 模糊查询工序编号
     *
     * @param operLike 模糊查询工序编号
     */
    public void setOperLike(String operLike) {
        this.operLike = operLike;
    }

    /**
     * 获取 模糊查询工序名称
     *
     * @return operDescLike 模糊查询工序名称
     */
    public String getOperDescLike() {
        return operDescLike;
    }

    /**
     * 设置 模糊查询工序名称
     *
     * @param operDescLike 模糊查询工序名称
     */
    public void setOperDescLike(String operDescLike) {
        this.operDescLike = operDescLike;
    }
}
