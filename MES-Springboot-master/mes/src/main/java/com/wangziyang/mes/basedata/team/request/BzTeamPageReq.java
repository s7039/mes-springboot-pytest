package com.wangziyang.mes.basedata.team.request;

import com.wangziyang.mes.basedata.team.entity.BzTeam;

import com.wangziyang.mes.common.BasePageReq;

/**
 * 班组分页查询参数
 *
 * @author WangZiyang
 * @since 2021-02-25
 */
public class BzTeamPageReq extends BasePageReq<BzTeam> {

    /**
     * 班组编号
     */
    private String code;

    /**
     * 班组名称
     */
    private String name;

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }
}
