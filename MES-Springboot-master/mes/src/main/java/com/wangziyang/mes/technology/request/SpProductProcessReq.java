package com.wangziyang.mes.technology.request;

import com.wangziyang.mes.technology.entity.SpProductProcess;

import com.wangziyang.mes.common.BasePageReq;

/**
 * 产品工艺规划分页查询请求
 *
 * @author WangZiYang
 * @since 2020-03-28
 */
public class SpProductProcessReq extends BasePageReq<SpProductProcess> {

    /**
     * 物料编码模糊查询
     */
    private String materielCodeLike;

    /**
     * 物料描述模糊查询
     */
    private String materielDescLike;

    /**
     * BOM编号模糊查询
     */
    private String bomCodeLike;

    /**
     * 锁定状态
     */
    private String locked;

    public String getMaterielCodeLike() {
        return materielCodeLike;
    }

    public void setMaterielCodeLike(String materielCodeLike) {
        this.materielCodeLike = materielCodeLike;
    }

    public String getMaterielDescLike() {
        return materielDescLike;
    }

    public void setMaterielDescLike(String materielDescLike) {
        this.materielDescLike = materielDescLike;
    }

    public String getBomCodeLike() {
        return bomCodeLike;
    }

    public void setBomCodeLike(String bomCodeLike) {
        this.bomCodeLike = bomCodeLike;
    }

    public String getLocked() {
        return locked;
    }

    public void setLocked(String locked) {
        this.locked = locked;
    }
}
