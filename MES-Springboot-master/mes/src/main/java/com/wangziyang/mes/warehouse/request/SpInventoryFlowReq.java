package com.wangziyang.mes.warehouse.request;

import com.wangziyang.mes.warehouse.entity.SpInventoryFlow;

import com.wangziyang.mes.common.BasePageReq;

/**
 * 库存流水分页查询请求
 *
 * @author WangZiYang
 * @since 2026-08-16
 */
public class SpInventoryFlowReq extends BasePageReq<SpInventoryFlow> {

    private static final long serialVersionUID = 1L;

    /**
     * 流水编号
     */
    private String flowCode;

    /**
     * 物料编码
     */
    private String materielCode;

    /**
     * 库房编号
     */
    private String warehouseCode;

    /**
     * 变动类型：IN 入库 / OUT 出库
     */
    private String changeType;

    /**
     * 工单编号
     */
    private String orderCode;

    public String getFlowCode() {
        return flowCode;
    }

    public void setFlowCode(String flowCode) {
        this.flowCode = flowCode;
    }

    public String getMaterielCode() {
        return materielCode;
    }

    public void setMaterielCode(String materielCode) {
        this.materielCode = materielCode;
    }

    public String getWarehouseCode() {
        return warehouseCode;
    }

    public void setWarehouseCode(String warehouseCode) {
        this.warehouseCode = warehouseCode;
    }

    public String getChangeType() {
        return changeType;
    }

    public void setChangeType(String changeType) {
        this.changeType = changeType;
    }

    public String getOrderCode() {
        return orderCode;
    }

    public void setOrderCode(String orderCode) {
        this.orderCode = orderCode;
    }
}
