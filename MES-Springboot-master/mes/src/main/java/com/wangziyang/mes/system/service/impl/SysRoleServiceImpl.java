package com.wangziyang.mes.system.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.wangziyang.mes.common.enums.CommonEnum;
import com.wangziyang.mes.system.dto.SysRoleDTO;
import com.wangziyang.mes.system.dto.SysUserDTO;
import com.wangziyang.mes.system.entity.SysRole;
import com.wangziyang.mes.system.entity.SysRoleMenu;
import com.wangziyang.mes.system.entity.SysUserRole;
import com.wangziyang.mes.system.enums.SysRoleEnum;
import com.wangziyang.mes.system.mapper.SysRoleMapper;
import com.wangziyang.mes.system.service.ISysRoleMenuService;
import com.wangziyang.mes.system.service.ISysRoleService;
import com.wangziyang.mes.system.service.ISysUserRoleService;
import org.apache.commons.lang3.ArrayUtils;
import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.wangziyang.mes.system.entity.SysRoleMenu;
import com.wangziyang.mes.system.service.ISysRoleMenuService;

import java.util.ArrayList;
import java.util.List;

/**
 * <p>
 * 服务实现类
 * </p>
 *
 * @author SongPeng
 * @since 2019-10-16
 */
@Service
public class SysRoleServiceImpl extends ServiceImpl<SysRoleMapper, SysRole> implements ISysRoleService {

    @Autowired
    private SysRoleMapper sysRoleMapper;

    @Autowired
    private ISysUserRoleService sysUserRoleService;

    @Autowired
    private ISysRoleMenuService sysRoleMenuService;

    /**
     * 根据用户ID获取角色列表信息
     *
     * @param userId 系统用户ID
     * @return 角色列表
     * @throws Exception 异常
     */
    @Override
    public List<SysRoleDTO> listByUserId(String userId) throws Exception {
        List<SysRoleDTO> result = new ArrayList<>();

        List<SysRole> sysRoles = sysRoleMapper.listByUserId(userId);

        QueryWrapper<SysRole> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq(CommonEnum.FIELD_NAME_IS_DELETED.getCode(), SysRoleEnum.DELETED_NORMAL.getCode());
        List<SysRole> sysRolesAll = sysRoleMapper.selectList(null);

        for (SysRole role : sysRolesAll) {
            SysRoleDTO roleDTO = new SysRoleDTO();
            BeanUtils.copyProperties(role, roleDTO);
            for (SysRole r : sysRoles) {
                if (role.getId().equals(r.getId())) {
                    roleDTO.setChecked(true);
                }
            }
            result.add(roleDTO);
        }
        return result;
    }

    /**
     * 重新建立用户角色关系
     *
     * @param sysUserDTO 系统用户DTO
     * @throws Exception 异常
     */
    @Override
    @Transactional(rollbackFor = Exception.class)
    public void rebuild(SysUserDTO sysUserDTO) throws Exception {
        if (StringUtils.isNotEmpty(sysUserDTO.getId())) {
            QueryWrapper<SysUserRole> deleteWrapper = new QueryWrapper<>();
            deleteWrapper.eq("user_id", sysUserDTO.getId());
            sysUserRoleService.remove(deleteWrapper);
        }
        if (ArrayUtils.isNotEmpty(sysUserDTO.getSysRoleIds())) {
            for (String roleId : sysUserDTO.getSysRoleIds()) {
                if (StringUtils.isEmpty(roleId)) {
                    continue;
                }
                // 校验：被禁用的角色无法分配给用户
                SysRole role = sysRoleMapper.selectById(roleId);
                if (role != null && SysRoleEnum.DELETED_DISABLED.getCode().equals(role.getDeleted())) {
                    throw new Exception("角色【" + role.getName() + "】已被禁用，无法分配给用户");
                }
                SysUserRole sysUserRole = new SysUserRole();
                sysUserRole.setUserId(sysUserDTO.getId());
                sysUserRole.setRoleId(roleId);
                sysUserRoleService.save(sysUserRole);
            }
        }
    }


    /**
     * 根据角色ID查询已分配的菜单ID列表
     *
     * @param roleId 角色ID
     * @return 菜单ID列表
     */
    @Override
    public List<String> listMenuIdsByRoleId(String roleId) {
        return sysRoleMapper.listMenuIdsByRoleId(roleId);
    }

    /**
     * 分配角色菜单权限
     *
     * @param roleId  角色ID
     * @param menuIds 菜单ID数组
     */
    @Override
    @Transactional(rollbackFor = Exception.class)
    public void assignMenus(String roleId, String[] menuIds) {
        // 先删除角色所有菜单关联
        QueryWrapper<SysRoleMenu> deleteWrapper = new QueryWrapper<>();
        deleteWrapper.eq("role_id", roleId);
        sysRoleMenuService.remove(deleteWrapper);

        // 重新建立角色菜单关联
        if (ArrayUtils.isNotEmpty(menuIds)) {
            for (String menuId : menuIds) {
                if (StringUtils.isEmpty(menuId)) {
                    continue;
                }
                SysRoleMenu sysRoleMenu = new SysRoleMenu();
                sysRoleMenu.setRoleId(roleId);
                sysRoleMenu.setMenuId(menuId);
                sysRoleMenuService.save(sysRoleMenu);
            }
        }
    }

}
