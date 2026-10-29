package com.wangziyang.mes.technology.request;

import com.wangziyang.mes.technology.entity.SpBom;

import com.wangziyang.mes.common.BasePageReq;

/**
 * bom 分页请求
 *
 * @author wangziyang
 * @since 20200328
 */

public class SpBomReq extends BasePageReq<SpBom> {
    /**
     * BOM编号模糊查询
     */
    private String bomCodeLike;

    /**
     * 物料模糊查询
     */
    private  String materielCodeLike ;

    public String getBomCodeLike() {
        return this.bomCodeLike;
    }

    public void setBomCodeLike(String bomCodeLike) {
        this.bomCodeLike = bomCodeLike;
    }

    /**
     * 获取 物料模糊查询
     *
     * @return materielCodeLike 物料模糊查询
     */
    public String getMaterielCodeLike() {
        return this.materielCodeLike;
    }

    /**
     * 设置 物料模糊查询
     *
     * @param materielCodeLike 物料模糊查询
     */
    public void setMaterielCodeLike(String materielCodeLike) {
        this.materielCodeLike = materielCodeLike;
    }
}
