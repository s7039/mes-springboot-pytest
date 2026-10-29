package com.wangziyang.mes.warehouse.request;

import com.wangziyang.mes.warehouse.entity.SpWarehouseLocation;

import com.wangziyang.mes.common.BasePageReq;

/**
 * 库位分页查询请求
 *
 * @author WangZiYang
 * @since 2021-06-02
 */
public class SpWarehouseLocationReq extends BasePageReq<SpWarehouseLocation> {

    private static final long serialVersionUID = 1L;

    /**
     * 库位编码模糊查询
     */
    private String locationCodeLike;

    /**
     * 所属库房ID
     */
    private String warehouseId;

    /**
     * 物料编码
     */
    private String materielCode;

    public String getLocationCodeLike() {
        return locationCodeLike;
    }

    public void setLocationCodeLike(String locationCodeLike) {
        this.locationCodeLike = locationCodeLike;
    }

    public String getWarehouseId() {
        return warehouseId;
    }

    public void setWarehouseId(String warehouseId) {
        this.warehouseId = warehouseId;
    }

    public String getMaterielCode() {
        return materielCode;
    }

    public void setMaterielCode(String materielCode) {
        this.materielCode = materielCode;
    }
}
