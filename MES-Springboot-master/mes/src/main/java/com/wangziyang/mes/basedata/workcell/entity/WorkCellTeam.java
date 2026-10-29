package com.wangziyang.mes.basedata.workcell.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.wangziyang.mes.common.BaseEntity;

/**
 * 加工单元班组关联实体
 *
 * @author WangZiyang
 * @since 2021-03-10
 */
@TableName("sp_work_cell_team")
public class WorkCellTeam extends BaseEntity {

    private static final long serialVersionUID = 1L;

    /**
     * 加工单元ID
     */
    private String workCellId;

    /**
     * 班组ID
     */
    private String teamId;

    public String getWorkCellId() {
        return workCellId;
    }

    public void setWorkCellId(String workCellId) {
        this.workCellId = workCellId;
    }

    public String getTeamId() {
        return teamId;
    }

    public void setTeamId(String teamId) {
        this.teamId = teamId;
    }

    @Override
    public String toString() {
        return "WorkCellTeam{" +
                "workCellId='" + workCellId + '\'' +
                ", teamId='" + teamId + '\'' +
                '}';
    }
}
