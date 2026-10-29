package com.wangziyang.mes.warehouse.request;

import com.wangziyang.mes.warehouse.entity.SpInventory;

import com.wangziyang.mes.common.BasePageReq;

/**
 * 库存分页查询请求
 *
 * @author WangZiYang
 * @since 2021-06-02
 */
public class SpInventoryReq extends BasePageReq<SpInventory> {

    private static final long serialVersionUID = 1L;

    /**
     * 物料编码
     */
    private String materielCode;

    /**
     * 物料描述
     */
    private String materielDesc;

    /**
     * 库房编号
     */
    private String warehouseCode;

    /**
     * 库位编码
     */
    private String locationCode;

    /**
     * 状态：01 可用 02 冻结
     */
    private String status;

    public String getMaterielCode() {
        return materielCode;
    }

    public void setMaterielCode(String materielCode) {
        this.materielCode = materielCode;
    }

    public String getMaterielDesc() {
        return materielDesc;
    }

    public void setMaterielDesc(String materielDesc) {
        this.materielDesc = materielDesc;
    }

    public String getWarehouseCode() {
        return warehouseCode;
    }

    public void setWarehouseCode(String warehouseCode) {
        this.warehouseCode = warehouseCode;
    }

    public String getLocationCode() {
        return locationCode;
    }

    public void setLocationCode(String locationCode) {
        this.locationCode = locationCode;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }
}
