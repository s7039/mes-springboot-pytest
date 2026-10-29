package com.wangziyang.mes.basedata.team.controller;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.wangziyang.mes.basedata.team.entity.BzTeam;
import com.wangziyang.mes.basedata.team.entity.BzTeamUser;
import com.wangziyang.mes.basedata.team.request.BzTeamPageReq;
import com.wangziyang.mes.basedata.team.service.IBzTeamService;
import com.wangziyang.mes.basedata.team.service.IBzTeamUserService;
import com.wangziyang.mes.common.BaseController;
import com.wangziyang.mes.common.Result;
import com.wangziyang.mes.system.entity.SysUser;
import com.wangziyang.mes.system.service.ISysUserService;
import io.swagger.annotations.ApiImplicitParam;
import io.swagger.annotations.ApiImplicitParams;
import io.swagger.annotations.ApiOperation;
import org.apache.commons.lang3.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.apache.shiro.authz.annotation.RequiresPermissions;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * 班组管理前端控制器
 *
 * @author WangZiyang
 * @since 2021-02-25
 */
@Controller
@RequestMapping("/admin/basedata/team")
public class BzTeamController extends BaseController {

    Logger logger = LoggerFactory.getLogger(BzTeamController.class);

    @Autowired
    private IBzTeamService bzTeamService;

    @Autowired
    private IBzTeamUserService bzTeamUserService;

    @Autowired
    private ISysUserService sysUserService;

    @ApiOperation("班组列表UI")
    @ApiImplicitParams({@ApiImplicitParam(name = "model", value = "模型", defaultValue = "模型")})
    @GetMapping("/list-ui")
    public String listUI(Model model) {
        return "admin/basedata/team/list";
    }

    @ApiOperation("班组分页列表")
    @ApiImplicitParams({@ApiImplicitParam(name = "page", value = "模型", defaultValue = "模型")})
    @PostMapping("/page")
    @ResponseBody
    public Result page(BzTeamPageReq req) {
        QueryWrapper<BzTeam> qw = new QueryWrapper<>();
        if (StringUtils.isNotEmpty(req.getCode())) {
            qw.likeRight("code", req.getCode());
        }
        if (StringUtils.isNotEmpty(req.getName())) {
            qw.like("name", req.getName());
        }
        qw.orderByDesc("update_time");
        IPage<BzTeam> result = bzTeamService.page(req, qw);
        // 状态联动：若班组内存在状态异常的用户，则班组状态显示为异常
        for (BzTeam team : result.getRecords()) {
            if (!"2".equals(team.getIsDeleted()) && isTeamUserAbnormal(team.getId())) {
                team.setIsDeleted("2");
            }
        }
        return Result.success(result);
    }

    /**
     * 判断班组内是否存在状态异常的用户
     *
     * @param teamId 班组ID
     * @return true 存在异常用户
     */
    private boolean isTeamUserAbnormal(String teamId) {
        QueryWrapper<BzTeamUser> qw = new QueryWrapper<>();
        qw.eq("team_id", teamId);
        List<BzTeamUser> list = bzTeamUserService.list(qw);
        for (BzTeamUser tu : list) {
            SysUser user = sysUserService.getById(tu.getUserId());
            if (user != null && "2".equals(user.getDeleted())) {
                return true;
            }
        }
        return false;
    }

    @GetMapping("/add-or-update-ui")
    public String addOrUpdateUI(Model model, BzTeam record) {
        if (StringUtils.isNotEmpty(record.getId())) {
            BzTeam team = bzTeamService.getById(record.getId());
            model.addAttribute("team", team);
        }
        return "admin/basedata/team/addOrUpdate";
    }

    /**
     * 生成班组编号（新增时预先展示）
     * 格式：BZ0001、BZ0002 依次递增，自动回收已删除的编号
     */
    @ApiOperation("生成班组编号")
    @GetMapping("/generate-code")
    @ResponseBody
    public Result generateCode() {
        return Result.success(generateTeamCode());
    }

    @PostMapping("/add-or-update")
    @ResponseBody
    @RequiresPermissions("user:add")
    public Result addOrUpdate(BzTeam record) {
        // 新增时自动生成班组编号（BZ 格式 + 回收）
        if (StringUtils.isEmpty(record.getId()) && StringUtils.isEmpty(record.getCode())) {
            record.setCode(generateTeamCode());
        }
        if (StringUtils.isEmpty(record.getId()) && StringUtils.isEmpty(record.getIsDeleted())) {
            record.setIsDeleted("0");
        }
        bzTeamService.saveOrUpdate(record);
        return Result.success(record.getId());
    }

    /**
     * 生成班组编号：BZ0001、BZ0002 依次递增
     * 自动回收：查询所有 BZ 开头的编号，从 1 开始找最小未使用编号
     *
     * @return 新的班组编号
     */
    private String generateTeamCode() {
        QueryWrapper<BzTeam> qw = new QueryWrapper<>();
        qw.likeRight("code", "BZ");
        List<BzTeam> list = bzTeamService.list(qw);
        Set<Integer> usedNums = new HashSet<>();
        for (BzTeam team : list) {
            String code = team.getCode();
            if (code != null && code.length() > 2) {
                String numStr = code.substring(2);
                if (numStr.matches("\\d+")) {
                    usedNums.add(Integer.parseInt(numStr));
                }
            }
        }
        int seq = 1;
        while (usedNums.contains(seq)) {
            seq++;
        }
        return "BZ" + String.format("%04d", seq);
    }

    @PostMapping("/delete")
    @ResponseBody
    @RequiresPermissions("user:add")
    public Result delete(BzTeam record) {
        bzTeamService.removeById(record.getId());
        return Result.success();
    }

    @PostMapping("/delete-batch")
    @ResponseBody
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
            bzTeamService.removeById(id);
        }
        return Result.success();
    }

    @GetMapping("/team-user-ui")
    public String teamUserUI(Model model, BzTeam record) {
        if (StringUtils.isNotEmpty(record.getId())) {
            BzTeam team = bzTeamService.getById(record.getId());
            model.addAttribute("team", team);
        }
        return "admin/basedata/team/teamUsers";
    }

    @PostMapping("/team-user/list")
    @ResponseBody
    public Result teamUserList(BzTeamUser record) {
        QueryWrapper<BzTeamUser> qw = new QueryWrapper<>();
        qw.eq("team_id", record.getTeamId());
        List<BzTeamUser> list = bzTeamUserService.list(qw);
        // 填充用户姓名和用户名
        List<Map<String, Object>> resultList = new ArrayList<>();
        for (BzTeamUser tu : list) {
            Map<String, Object> map = new HashMap<>();
            map.put("id", tu.getId());
            map.put("teamId", tu.getTeamId());
            map.put("userId", tu.getUserId());
            map.put("createTime", tu.getCreateTime());
            // 查询用户信息
            SysUser user = sysUserService.getById(tu.getUserId());
            if (user != null) {
                map.put("userName", user.getName());
                map.put("userUsername", user.getUsername());
                map.put("userJobNo", user.getJobNo());
            } else {
                map.put("userName", "未知用户");
                map.put("userUsername", "");
                map.put("userJobNo", "");
            }
            resultList.add(map);
        }
        return Result.success(resultList);
    }

    @PostMapping("/team-user/add")
    @ResponseBody
    @RequiresPermissions("user:add")
    public Result addTeamUser(BzTeamUser record) {
        // 检查是否已存在
        QueryWrapper<BzTeamUser> qw = new QueryWrapper<>();
        qw.eq("team_id", record.getTeamId());
        qw.eq("user_id", record.getUserId());
        BzTeamUser exist = bzTeamUserService.getOne(qw);
        if (exist != null) {
            return Result.failure("该员工已添加到此班组");
        }
        bzTeamUserService.save(record);
        return Result.success();
    }

    @PostMapping("/team-user/delete")
    @ResponseBody
    @RequiresPermissions("user:add")
    public Result deleteTeamUser(BzTeamUser record) {
        bzTeamUserService.removeById(record.getId());
        return Result.success();
    }
}
