package com.wangziyang.mes.basedata.team.entity;

import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableName;
import com.wangziyang.mes.common.BaseEntity;

/**
 * 班组实体
 *
 * @author WangZiyang
 * @since 2021-02-25
 */
@TableName("sp_bz_team")
public class BzTeam extends BaseEntity {

    private static final long serialVersionUID = 1L;

    /**
     * 班组编号
     */
    private String code;

    /**
     * 班组名称
     */
    private String name;

    /**
     * 状态(0:正常;2:异常)
     */
    @TableField(value = "is_deleted")
    private String isDeleted;

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

    public String getIsDeleted() {
        return isDeleted;
    }

    public void setIsDeleted(String isDeleted) {
        this.isDeleted = isDeleted;
    }
}
