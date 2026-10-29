package com.wangziyang.mes.system.controller.admin;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.wangziyang.mes.common.BaseController;
import com.wangziyang.mes.common.Result;
import com.wangziyang.mes.system.entity.SysRole;
import com.wangziyang.mes.system.request.SysRolePageReq;
import com.wangziyang.mes.system.service.ISysMenuService;
import com.wangziyang.mes.system.service.ISysRoleService;
import com.wangziyang.mes.system.vo.TreeVO;
import com.wangziyang.mes.system.entity.SysMenu;
import org.apache.commons.lang3.StringUtils;
import org.apache.shiro.authz.annotation.RequiresPermissions;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import java.util.Arrays;
import java.util.List;

/**
 * <p>
 * 前端控制器
 * </p>
 *
 * @author SongPeng
 * @since 2019-10-16
 */
@Controller("adminSysRoleController")
@RequestMapping("/admin/sys/role")
public class SysRoleController extends BaseController {

    @Autowired
    private ISysRoleService sysRoleService;

    @Autowired
    private ISysMenuService sysMenuService;

    @GetMapping("/list-ui")
    public String listUI(Model model) {
        return "admin/system/role/list";
    }

    @PostMapping("/page")
    @ResponseBody
    public Result page(SysRolePageReq req) {
        QueryWrapper qw = new QueryWrapper();
        if (StringUtils.isNotEmpty(req.getNameLike())) {
            qw.like("name", req.getNameLike());
        }
        if (StringUtils.isNotEmpty(req.getCodeLike())) {
            qw.like("code", req.getCodeLike());
        }
        qw.orderByDesc(req.getOrderBy());
        IPage result = sysRoleService.page(req, qw);
        return Result.success(result);
    }

    @GetMapping("/add-or-update-ui")
    public String addOrUpdateUI(Model model, SysRole record) {
        if (StringUtils.isNotEmpty(record.getId())) {
            SysRole result = sysRoleService.getById(record.getId());
            model.addAttribute("result", result);
        }
        return "admin/system/role/addOrUpdate";
    }

    @PostMapping("/add-or-update")
    @ResponseBody
    @RequiresPermissions("user:add")
    public Result addOrUpdate(SysRole record) {
        sysRoleService.saveOrUpdate(record);
        return Result.success(record.getId());
    }

    @PostMapping("/delete")
    @ResponseBody
    @RequiresPermissions("user:add")
    public Result delete(SysRole record) {
        SysRole role = sysRoleService.getById(record.getId());
        if (role != null && "1".equals(role.getSysRole())) {
            return Result.failure("系统内置角色不可删除");
        }
        sysRoleService.removeById(record.getId());
        return Result.success();
    }

    @PostMapping("/delete-batch")
    @ResponseBody
    @RequiresPermissions("user:add")
    public Result deleteBatch(String ids) {
        if (StringUtils.isNotEmpty(ids)) {
            List<String> idList = Arrays.asList(ids.split(","));
            for (String id : idList) {
                SysRole role = sysRoleService.getById(id);
                if (role != null && "1".equals(role.getSysRole())) {
                    return Result.failure("系统内置角色【" + role.getName() + "】不可删除");
                }
            }
            sysRoleService.removeByIds(idList);
        }
        return Result.success();
    }

    /**
     * 权限分配页面
     */
    @GetMapping("/assign-menu-ui")
    public String assignMenuUI(Model model, String id) {
        model.addAttribute("roleId", id);
        return "admin/system/role/assignMenu";
    }

    /**
     * 获取角色已分配的菜单ID列表
     */
    @PostMapping("/list-menu-ids")
    @ResponseBody
    public Result listMenuIds(String roleId) {
        List<String> menuIds = sysRoleService.listMenuIdsByRoleId(roleId);
        return Result.success(menuIds);
    }

    /**
     * 获取系统菜单树（用于权限分配）
     */
    @PostMapping("/menu-tree")
    @ResponseBody
    public Result menuTree() throws Exception {
        List<TreeVO<SysMenu>> tree = sysMenuService.listMenuTree();
        return Result.success(tree);
    }

    /**
     * 保存角色菜单权限分配
     */
    @PostMapping("/assign-menus")
    @ResponseBody
    @RequiresPermissions("user:add")
    public Result assignMenus(String roleId, @RequestParam(value = "menuIds", required = false) String[] menuIds) {
        if (StringUtils.isEmpty(roleId)) {
            return Result.failure("角色ID不能为空");
        }
        sysRoleService.assignMenus(roleId, menuIds);
        return Result.success();
    }
}
