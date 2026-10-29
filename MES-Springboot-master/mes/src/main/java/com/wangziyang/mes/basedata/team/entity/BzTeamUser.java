package com.wangziyang.mes.basedata.team.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.wangziyang.mes.common.BaseEntity;

/**
 * 班组-员工关联实体
 *
 * @author WangZiyang
 * @since 2021-02-25
 */
@TableName("sp_bz_team_user")
public class BzTeamUser extends BaseEntity {

    private static final long serialVersionUID = 1L;

    /**
     * 班组ID
     */
    private String teamId;

    /**
     * 用户ID
     */
    private String userId;

    public String getTeamId() {
        return teamId;
    }

    public void setTeamId(String teamId) {
        this.teamId = teamId;
    }

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }
}
