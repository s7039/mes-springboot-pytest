package com.wangziyang.mes.warehouse.request;

import com.wangziyang.mes.warehouse.entity.SpWarehouse;

import com.wangziyang.mes.common.BasePageReq;

/**
 * 库房分页查询请求
 *
 * @author WangZiYang
 * @since 2021-03-01
 */
public class SpWarehouseReq extends BasePageReq<SpWarehouse> {

    private static final long serialVersionUID = 1L;

    /**
     * 库房名称模糊查询
     */
    private String warehouseNameLike;

    /**
     * 库房类型模糊查询
     */
    private String warehouseTypeLike;

    public String getWarehouseNameLike() {
        return warehouseNameLike;
    }

    public void setWarehouseNameLike(String warehouseNameLike) {
        this.warehouseNameLike = warehouseNameLike;
    }

    public String getWarehouseTypeLike() {
        return warehouseTypeLike;
    }

    public void setWarehouseTypeLike(String warehouseTypeLike) {
        this.warehouseTypeLike = warehouseTypeLike;
    }
}
