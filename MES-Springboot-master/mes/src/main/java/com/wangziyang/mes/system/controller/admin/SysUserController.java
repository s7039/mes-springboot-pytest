package com.wangziyang.mes.system.controller.admin;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.wangziyang.mes.basedata.team.entity.BzTeamUser;
import com.wangziyang.mes.basedata.team.service.IBzTeamUserService;
import com.wangziyang.mes.common.BaseController;
import com.wangziyang.mes.common.Result;
import com.wangziyang.mes.system.dto.SysRoleDTO;
import com.wangziyang.mes.system.dto.SysUserDTO;
import com.wangziyang.mes.system.entity.SysUser;
import com.wangziyang.mes.system.entity.SysUserRole;
import com.wangziyang.mes.system.request.SysUserPageReq;
import com.wangziyang.mes.system.service.ISysRoleService;
import com.wangziyang.mes.system.service.ISysUserRoleService;
import com.wangziyang.mes.system.service.ISysUserService;
import org.apache.commons.lang3.StringUtils;
import org.apache.shiro.authz.annotation.RequiresPermissions;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import java.util.HashSet;
import java.util.List;
import java.util.Set;

/**
 * <p>
 * 前端控制器
 * </p>
 *
 * @author SongPeng
 * @since 2019-10-15
 */
@Controller("adminSysUserController")
@RequestMapping("/admin/sys/user")
public class SysUserController extends BaseController {

    Logger logger = LoggerFactory.getLogger(SysUserController.class);

    @Autowired
    private ISysUserService sysUserService;

    @Autowired
    private ISysRoleService sysRoleService;

    @Autowired
    private ISysUserRoleService sysUserRoleService;

    @Autowired
    private IBzTeamUserService bzTeamUserService;

    @GetMapping("/list-ui")
    public String listUI(Model model) {
        return "admin/system/user/list";
    }

    @PostMapping("/page")
    @ResponseBody
    public Result page(SysUserPageReq req) throws Exception {
        QueryWrapper qw = new QueryWrapper();
        qw.ne("is_deleted", "1");
        if (StringUtils.isNotEmpty(req.getJobNoLike())) {
            qw.likeRight("job_no", req.getJobNoLike());
        }
        if (StringUtils.isNotEmpty(req.getNameLike())) {
            qw.likeRight("name", req.getNameLike());
        }
        if (StringUtils.isNotEmpty(req.getUsernameLike())) {
            qw.likeRight("username", req.getUsernameLike());
        }
        qw.orderByDesc(req.getOrderBy());
        IPage page = sysUserService.page(req, qw);
        return Result.success(page);
    }

    @GetMapping("/add-or-update-ui")
    public String addOrUpdateUI(SysUser record, Model model) throws Exception {
        if (StringUtils.isNotEmpty(record.getId())) {
            SysUser result = sysUserService.getById(record.getId());
            model.addAttribute("result", result);
        }
        List<SysRoleDTO> sysRoles = sysRoleService.listByUserId(record.getId());
        model.addAttribute("sysRoles", sysRoles);
        return "admin/system/user/addOrUpdate";
    }

    /**
     * 生成工号（新增时预先展示）
     * 格式：YG00001、YG00002 依次递增，自动回收已删除的编号
     */
    @GetMapping("/generate-code")
    @ResponseBody
    public Result generateCode() {
        return Result.success(generateJobNo());
    }

    @PostMapping("/add-or-update")
    @ResponseBody
    @RequiresPermissions("user:add")
    public Result addOrUpdate(SysUserDTO record) {
        try {
            // 新增时自动生成工号（YG 格式 + 回收）
            if (StringUtils.isEmpty(record.getId()) && StringUtils.isEmpty(record.getJobNo())) {
                record.setJobNo(generateJobNo());
            }
            if (StringUtils.isEmpty(record.getId())) {
                sysUserService.save(record);
            } else {
                sysUserService.update(record);
            }
        } catch (Exception e) {
            logger.error("保存用户失败", e);
            return Result.failure(e.getMessage());
        }
        return Result.success(record.getId());
    }

    /**
     * 生成工号：YG00001、YG00002 依次递增
     * 自动回收：查询所有未删除的 YG 工号，从 1 开始找最小未使用编号，被删除用户的工号可再次分配
     *
     * @return 新的工号
     */
    private String generateJobNo() {
        QueryWrapper<SysUser> qw = new QueryWrapper<>();
        qw.likeRight("job_no", "YG");
        // 排除已逻辑删除的用户，其工号可被回收重新分配
        qw.ne("is_deleted", "1");
        List<SysUser> list = sysUserService.list(qw);
        Set<Integer> usedNums = new HashSet<>();
        for (SysUser user : list) {
            String jobNo = user.getJobNo();
            if (jobNo != null && jobNo.length() > 2) {
                String numStr = jobNo.substring(2);
                if (numStr.matches("\\d+")) {
                    usedNums.add(Integer.parseInt(numStr));
                }
            }
        }
        int seq = 1;
        while (usedNums.contains(seq)) {
            seq++;
        }
        return "YG" + String.format("%05d", seq);
    }

    /**
     * 删除用户（物理删除：删除后记录消失，工号可回收）
     */
    @PostMapping("/delete")
    @ResponseBody
    @Transactional(rollbackFor = Exception.class)
    @RequiresPermissions("user:add")
    public Result delete(SysUser record) {
        if (StringUtils.isEmpty(record.getId())) {
            return Result.failure("参数不能为空");
        }
        removeUserRelations(record.getId());
        sysUserService.removeById(record.getId());
        return Result.success();
    }

    /**
     * 批量删除用户（物理删除）
     */
    @PostMapping("/delete-batch")
    @ResponseBody
    @Transactional(rollbackFor = Exception.class)
    @RequiresPermissions("user:add")
    public Result deleteBatch(String ids) {
        if (StringUtils.isEmpty(ids)) {
            return Result.failure("请选择需要删除的数据");
        }
        String[] idArr = ids.split(",");
        for (String id : idArr) {
            if (StringUtils.isEmpty(id)) {
                continue;
            }
            removeUserRelations(id);
            sysUserService.removeById(id);
        }
        return Result.success();
    }

    /**
     * 清理用户关联数据（用户-角色、班组-员工）
     *
     * @param userId 用户ID
     */
    private void removeUserRelations(String userId) {
        QueryWrapper<SysUserRole> userRoleWrapper = new QueryWrapper<>();
        userRoleWrapper.eq("user_id", userId);
        sysUserRoleService.remove(userRoleWrapper);
        QueryWrapper<BzTeamUser> teamUserWrapper = new QueryWrapper<>();
        teamUserWrapper.eq("user_id", userId);
        bzTeamUserService.remove(teamUserWrapper);
    }
}
