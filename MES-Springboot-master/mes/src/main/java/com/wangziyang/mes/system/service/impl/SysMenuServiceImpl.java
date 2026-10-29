package com.wangziyang.mes.system.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.wangziyang.mes.common.util.TreeUtil;
import com.wangziyang.mes.system.dto.SysMenuDTO;
import com.wangziyang.mes.system.dto.SysRoleDTO;
import com.wangziyang.mes.system.dto.SysUserDTO;
import com.wangziyang.mes.system.entity.SysMenu;
import com.wangziyang.mes.system.mapper.SysMenuMapper;
import com.wangziyang.mes.system.service.ISysMenuService;
import com.wangziyang.mes.system.vo.TreeVO;
import org.apache.commons.collections.CollectionUtils;
import org.apache.shiro.SecurityUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.*;

/**
 * <p>
 * 服务实现类
 * </p>
 *
 * @author SongPeng
 * @since 2019-10-16
 */
@Service
public class SysMenuServiceImpl extends ServiceImpl<SysMenuMapper, SysMenu> implements ISysMenuService {

    @Autowired
    private SysMenuMapper sysMenuMapper;

    /**
     * 根据角色id查询菜单列表
     *
     * @param roleId
     * @return
     * @throws Exception
     */
    @Override
    public List<SysMenuDTO> listByRoleId(String roleId) throws Exception {
        return sysMenuMapper.listByRoleId(roleId);
    }

    /**
     * 系统首页初始化菜单树数据
     *
     * @return 系统首页初始化菜单树数据
     * @throws Exception 异常
     */
    @Override
    public Map<String, Object> listIndexMenuTree() throws Exception {
        Map<String, Object> result = new LinkedHashMap<>(4);
        // 只返回当前登录用户拥有权限的菜单
        List<SysMenu> sysMenus = getCurrentUserMenus();

        Map<String, String> clearInfo = new HashMap<>(2);
        clearInfo.put("clearUrl", "json/clear.json");

        Map<String, String> homeInfo = new HashMap<>(4);
        homeInfo.put("name", "首页");
        homeInfo.put("icon", "fa fa-home");
        homeInfo.put("url", "admin/welcome-ui");

        Map<String, String> logoInfo = new HashMap<>(4);
        logoInfo.put("name", "黑科制造MES");
        logoInfo.put("image", "/image/logo.png");
        logoInfo.put("url", "");

        Map<String, Object> menuInfo = new LinkedHashMap<>(8);

        List<TreeVO<SysMenu>> menus = new ArrayList<>();
        for (SysMenu m : sysMenus) {
            TreeVO<SysMenu> tree = new TreeVO<>();
            tree.setId(m.getId());
            tree.setPid(m.getParentId());
            tree.setCode(m.getCode());
            tree.setName(m.getName());
            tree.setUrl(m.getUrl());
            tree.setIcon(m.getIcon());
            tree.setType(m.getType());
            tree.setPermission(m.getPermission());
            // TODO 是否需要更改？
            tree.setTarget("_self");
            menus.add(tree);
        }
        List<TreeVO<SysMenu>> treeVOS = TreeUtil.buildList(menus, "0");
        for (TreeVO<SysMenu> mTree : treeVOS) {
            menuInfo.put(mTree.getCode(), mTree);
        }

        result.put("clearInfo", clearInfo);
        result.put("homeInfo", homeInfo);
        result.put("logoInfo", logoInfo);
        result.put("menuInfo", menuInfo);

        return result;
    }

    /**
     * 用户搜索系统首页初始化菜单树数据
     * @param menuName 菜单名字
     * @return 菜单树数据
     * @throws Exception 异常
     */
    @Override
    public Map<String, Object> listIndexMenuSearchTree(String menuName) throws Exception {
        Map<String, Object> result = new LinkedHashMap<>(4);
        Map<String, Object> menuInfo = new LinkedHashMap<>(8);
        // 基于当前用户拥有权限的菜单进行搜索
        List<SysMenu> authorizedMenus = getCurrentUserMenus();
        List<SysMenu> sysMenus = new ArrayList<>();
        for (SysMenu m : authorizedMenus) {
            // 名称匹配的菜单，以及所有父级菜单（保证树完整）
            if ((m.getName() != null && m.getName().contains(menuName)) || !"3".equals(m.getGrade())) {
                sysMenus.add(m);
            }
        }
        List<TreeVO<SysMenu>> menus = new ArrayList<>();
        for (SysMenu m : sysMenus) {
            TreeVO<SysMenu> tree = new TreeVO<>();
            tree.setId(m.getId());
            tree.setPid(m.getParentId());
            tree.setCode(m.getCode());
            tree.setName(m.getName());
            tree.setUrl(m.getUrl());
            tree.setIcon(m.getIcon());
            tree.setType(m.getType());
            tree.setPermission(m.getPermission());
            // TODO 是否需要更改？
            tree.setTarget("_self");
            menus.add(tree);
        }
        List<TreeVO<SysMenu>> treeVOS = TreeUtil.buildList(menus, "0");
        for (TreeVO<SysMenu> mTree : treeVOS) {
            menuInfo.put(mTree.getCode(), mTree);
        }
        result.put("menuInfo", menuInfo);
        return result;
    }

    /**
     * 获取当前登录用户拥有权限的菜单（汇总其所有角色的菜单权限，并补充父级菜单保证树完整）
     *
     * @return 有权限的菜单列表
     * @throws Exception 异常
     */
    private List<SysMenu> getCurrentUserMenus() throws Exception {
        SysUserDTO user = (SysUserDTO) SecurityUtils.getSubject().getPrincipal();
        if (user == null || CollectionUtils.isEmpty(user.getSysRoleDTOs())) {
            return new ArrayList<>();
        }
        // 1. 汇总当前用户所有角色有权限的菜单
        Map<String, SysMenu> menuMap = new LinkedHashMap<>();
        for (SysRoleDTO role : user.getSysRoleDTOs()) {
            List<SysMenuDTO> roleMenus = listByRoleId(role.getId());
            if (CollectionUtils.isEmpty(roleMenus)) {
                continue;
            }
            for (SysMenuDTO menu : roleMenus) {
                menuMap.put(menu.getId(), menu);
            }
        }
        // 2. 补充父级菜单，保证菜单树完整展示
        if (!menuMap.isEmpty()) {
            Map<String, SysMenu> allMenuMap = new HashMap<>();
            for (SysMenu m : sysMenuMapper.selectList(null)) {
                allMenuMap.put(m.getId(), m);
            }
            boolean changed = true;
            while (changed) {
                changed = false;
                Set<String> ids = new HashSet<>(menuMap.keySet());
                for (String id : ids) {
                    SysMenu menu = menuMap.get(id);
                    String pid = menu.getParentId();
                    if (pid != null && !"0".equals(pid) && !menuMap.containsKey(pid) && allMenuMap.containsKey(pid)) {
                        menuMap.put(pid, allMenuMap.get(pid));
                        changed = true;
                    }
                }
            }
        }
        List<SysMenu> menus = new ArrayList<>(menuMap.values());
        menus.sort(Comparator.comparingInt(SysMenu::getSortNum));
        return menus;
    }

    /**
     * 获取系统菜单树
     *
     * @return 系统菜单树
     * @throws Exception 异常
     */
    @Override
    public List<TreeVO<SysMenu>> listMenuTree() throws Exception {
        List<TreeVO<SysMenu>> menus = new ArrayList<>();
        List<SysMenu> sysMenus = sysMenuMapper.selectList(null);
        for (SysMenu m : sysMenus) {
            TreeVO<SysMenu> tree = new TreeVO<>();
            tree.setId(m.getId());
            tree.setPid(m.getParentId());
            tree.setCode(m.getCode());
            tree.setName(m.getName());
            tree.setUrl(m.getUrl());
            tree.setIcon(m.getIcon());
            tree.setType(m.getType());
            tree.setPermission(m.getPermission());
            menus.add(tree);
        }
        return TreeUtil.buildList(menus, "0");
    }
}
