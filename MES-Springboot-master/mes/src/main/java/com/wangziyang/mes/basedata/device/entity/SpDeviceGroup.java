package com.wangziyang.mes.basedata.device.entity;

import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableName;
import com.wangziyang.mes.common.BaseEntity;

/**
 * 设备编组
 *
 * @author WangZiYang
 * @since 2021-03-01
 */
@TableName("sp_device_group")
public class SpDeviceGroup extends BaseEntity {

    private static final long serialVersionUID = 1L;

    /**
     * 编组代码
     */
    private String groupCode;

    /**
     * 编组名称
     */
    private String groupName;

    /**
     * 备注
     */
    private String remark;

    /**
     * 状态(00:删除;01:正常;02:禁用)
     */
    @TableField(value = "is_deleted")
    private String deleted;

    public String getGroupCode() {
        return groupCode;
    }

    public void setGroupCode(String groupCode) {
        this.groupCode = groupCode;
    }

    public String getGroupName() {
        return groupName;
    }

    public void setGroupName(String groupName) {
        this.groupName = groupName;
    }

    public String getRemark() {
        return remark;
    }

    public void setRemark(String remark) {
        this.remark = remark;
    }

    public String getDeleted() {
        return deleted;
    }

    public void setDeleted(String deleted) {
        this.deleted = deleted;
    }

    @Override
    public String toString() {
        return "SpDeviceGroup{" +
                "groupCode='" + groupCode + '\'' +
                ", groupName='" + groupName + '\'' +
                ", remark='" + remark + '\'' +
                ", deleted='" + deleted + '\'' +
                "}";
    }
}
