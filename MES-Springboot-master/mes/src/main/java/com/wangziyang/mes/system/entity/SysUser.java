package com.wangziyang.mes.system.entity;

import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableName;
import com.wangziyang.mes.common.BaseEntity;

/**
 * <p>
 *
 * </p>
 *
 * @author SongPeng
 * @since 2019-10-15
 */
@TableName("sp_sys_user")
public class SysUser extends BaseEntity {

    private static final long serialVersionUID = 1L;

    /**
     * 工号
     */
    @TableField(value = "job_no")
    private String jobNo;

    /**
     * 姓名
     */
    private String name;

    /**
     * 用户名
     */
    private String username;

    /**
     * 密码(加密存储)
     */
    private String password;

    /**
     * 密码(明文)
     */
    @TableField(value = "password_plain")
    private String passwordPlain;

    /**
     * 邮箱
     */
    private String email;

    /**
     * 联系方式
     */
    private String mobile;

    /**
     * 性别(0:女;1:男;2:其他)
     */
    private String sex;

    /**
     * 出生日期
     */
    private String birthday;

    /**
     * 证件号码
     */
    private String idCard;

    /**
     * 籍贯
     */
    private String province;

    /**
     * 联系地址
     */
    private String city;

    /**
     * 备注
     */
    private String descr;

    /**
     * 状态(0:正常;2:异常)
     */
    @TableField(value = "is_deleted")
    private String deleted;

	public String getJobNo() {
		return jobNo;
	}

	public void setJobNo(String jobNo) {
		this.jobNo = jobNo;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getUsername() {
		return username;
	}

	public void setUsername(String username) {
		this.username = username;
	}

	public String getPassword() {
		return password;
	}

	public void setPassword(String password) {
		this.password = password;
	}

	public String getPasswordPlain() {
		return passwordPlain;
	}

	public void setPasswordPlain(String passwordPlain) {
		this.passwordPlain = passwordPlain;
	}

	public String getEmail() {
		return email;
	}

	public void setEmail(String email) {
		this.email = email;
	}

	public String getMobile() {
		return mobile;
	}

	public void setMobile(String mobile) {
		this.mobile = mobile;
	}

	public String getSex() {
		return sex;
	}

	public void setSex(String sex) {
		this.sex = sex;
	}

	public String getBirthday() {
		return birthday;
	}

	public void setBirthday(String birthday) {
		this.birthday = birthday;
	}

	public String getIdCard() {
		return idCard;
	}

	public void setIdCard(String idCard) {
		this.idCard = idCard;
	}

	public String getProvince() {
		return province;
	}

	public void setProvince(String province) {
		this.province = province;
	}

	public String getCity() {
		return city;
	}

	public void setCity(String city) {
		this.city = city;
	}

	public String getDescr() {
		return descr;
	}

	public void setDescr(String descr) {
		this.descr = descr;
	}

	public String getDeleted() {
		return deleted;
	}

	public void setDeleted(String deleted) {
		this.deleted = deleted;
	}
}