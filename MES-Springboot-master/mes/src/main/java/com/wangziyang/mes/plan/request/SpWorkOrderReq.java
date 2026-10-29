package com.wangziyang.mes.plan.request;

import com.wangziyang.mes.plan.entity.SpWorkOrder;

import com.wangziyang.mes.common.BasePageReq;

/**
 * 工单分页查询请求
 *
 * @author WangZiYang
 * @since 2026-08-16
 */
public class SpWorkOrderReq extends BasePageReq<SpWorkOrder> {

    private static final long serialVersionUID = 1L;

    /**
     * 工单编号
     */
    private String orderCode;

    /**
     * 物料编码
     */
    private String materielCode;

    /**
     * 物料名称
     */
    private String materielDesc;

    /**
     * 工单类型：IN 入库 / OUT 出库
     */
    private String orderType;

    /**
     * 状态：01 待确认 / 02 已完成
     */
    private String status;

    public String getOrderCode() {
        return orderCode;
    }

    public void setOrderCode(String orderCode) {
        this.orderCode = orderCode;
    }

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

    public String getOrderType() {
        return orderType;
    }

    public void setOrderType(String orderType) {
        this.orderType = orderType;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }
}
