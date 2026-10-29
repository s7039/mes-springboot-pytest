package com.wangziyang.mes.plan.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.wangziyang.mes.common.BaseEntity;

import java.time.LocalDateTime;

/**
 * 工单
 *
 * @author WangZiYang
 * @since 2026-08-16
 */
@TableName("sp_work_order")
public class SpWorkOrder extends BaseEntity {

    private static final long serialVersionUID = 1L;

    /**
     * 工单编号（GD00000001、GD00000002...自动生成）
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
     * 数量（正整数）
     */
    private Integer qty;

    /**
     * 开始时间
     */
    private LocalDateTime startTime;

    /**
     * 结束时间
     */
    private LocalDateTime endTime;

    /**
     * 状态：01 待确认 / 02 已完成
     */
    private String status;

    /**
     * 库房编号（入库工单必填）
     */
    private String warehouseCode;

    /**
     * 库位编号（入库工单可空，表示仓库级库存）
     */
    private String locationCode;

    /**
     * 出库使用的工艺BOM头ID（出库工单可空）
     */
    private String bomId;

    /**
     * 备注
     */
    private String remark;

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

    public Integer getQty() {
        return qty;
    }

    public void setQty(Integer qty) {
        this.qty = qty;
    }

    public LocalDateTime getStartTime() {
        return startTime;
    }

    public void setStartTime(LocalDateTime startTime) {
        this.startTime = startTime;
    }

    public LocalDateTime getEndTime() {
        return endTime;
    }

    public void setEndTime(LocalDateTime endTime) {
        this.endTime = endTime;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
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

    public String getBomId() {
        return bomId;
    }

    public void setBomId(String bomId) {
        this.bomId = bomId;
    }

    public String getRemark() {
        return remark;
    }

    public void setRemark(String remark) {
        this.remark = remark;
    }

    @Override
    public String toString() {
        return "SpWorkOrder{" +
                "orderCode='" + orderCode + '\'' +
                ", materielCode='" + materielCode + '\'' +
                ", materielDesc='" + materielDesc + '\'' +
                ", orderType='" + orderType + '\'' +
                ", qty=" + qty +
                ", startTime=" + startTime +
                ", endTime=" + endTime +
                ", status='" + status + '\'' +
                ", warehouseCode='" + warehouseCode + '\'' +
                ", locationCode='" + locationCode + '\'' +
                ", bomId='" + bomId + '\'' +
                ", remark='" + remark + '\'' +
                "}";
    }
}
