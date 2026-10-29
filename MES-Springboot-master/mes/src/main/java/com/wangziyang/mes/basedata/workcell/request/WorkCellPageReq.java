package com.wangziyang.mes.basedata.workcell.request;

import com.wangziyang.mes.basedata.workcell.entity.WorkCell;

import com.wangziyang.mes.common.BasePageReq;

/**
 * 加工单元定义 分页请求
 *
 * @author WangZiyang
 * @since 2021-03-10
 */
public class WorkCellPageReq extends BasePageReq<WorkCell> {

    private String workCellCodeLike;

    private String workCellNameLike;

    private String workCellType;

    public String getWorkCellCodeLike() {
        return workCellCodeLike;
    }

    public void setWorkCellCodeLike(String workCellCodeLike) {
        this.workCellCodeLike = workCellCodeLike;
    }

    public String getWorkCellNameLike() {
        return workCellNameLike;
    }

    public void setWorkCellNameLike(String workCellNameLike) {
        this.workCellNameLike = workCellNameLike;
    }

    public String getWorkCellType() {
        return workCellType;
    }

    public void setWorkCellType(String workCellType) {
        this.workCellType = workCellType;
    }
}
