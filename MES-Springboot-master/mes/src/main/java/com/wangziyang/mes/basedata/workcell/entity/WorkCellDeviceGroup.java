package com.wangziyang.mes.basedata.workcell.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.wangziyang.mes.common.BaseEntity;

/**
 * 加工单元-编组设备关联实体
 *
 * @author WangZiyang
 * @since 2021-03-10
 */
@TableName("sp_work_cell_device_group")
public class WorkCellDeviceGroup extends BaseEntity {

    private static final long serialVersionUID = 1L;

    /**
     * 加工单元ID
     */
    private String workCellId;

    /**
     * 编组设备ID
     */
    private String deviceGroupId;

    public String getWorkCellId() {
        return workCellId;
    }

    public void setWorkCellId(String workCellId) {
        this.workCellId = workCellId;
    }

    public String getDeviceGroupId() {
        return deviceGroupId;
    }

    public void setDeviceGroupId(String deviceGroupId) {
        this.deviceGroupId = deviceGroupId;
    }

    @Override
    public String toString() {
        return "WorkCellDeviceGroup{" +
                "workCellId='" + workCellId + '\'' +
                ", deviceGroupId='" + deviceGroupId + '\'' +
                '}';
    }
}
