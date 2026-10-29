package com.wangziyang.mes.system.enums;

/**
 * 系统用户枚举
 *
 * @author SongPeng
 * @date 2019/10/17 9:45
 */
public enum SysUserEnum {

    DELETED_NORMAL("0", "正常"),

    DELETED_ABNORMAL("2", "异常");

    /**
     * The Code
     */
    String code;
    /**
     * The Desc
     */
    String desc;

    public String getCode() {
        return code;
    }

    public String getDesc() {
        return desc;
    }

    SysUserEnum(String code, String desc) {
        this.code = code;
        this.desc = desc;
    }
}
