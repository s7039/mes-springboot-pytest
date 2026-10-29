package com.wangziyang.mes.basedata.workcell.controller;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.wangziyang.mes.basedata.device.entity.SpDevice;
import com.wangziyang.mes.basedata.device.entity.SpDeviceGroup;
import com.wangziyang.mes.basedata.device.entity.SpDeviceGroupItem;
import com.wangziyang.mes.basedata.device.service.ISpDeviceGroupItemService;
import com.wangziyang.mes.basedata.device.service.ISpDeviceGroupService;
import com.wangziyang.mes.basedata.device.service.ISpDeviceService;
import com.wangziyang.mes.basedata.team.entity.BzTeam;
import com.wangziyang.mes.basedata.team.service.IBzTeamService;
import com.wangziyang.mes.basedata.workcell.entity.WorkCell;
import com.wangziyang.mes.basedata.workcell.entity.WorkCellDeviceGroup;
import com.wangziyang.mes.basedata.workcell.entity.WorkCellTeam;
import com.wangziyang.mes.basedata.workcell.request.WorkCellPageReq;
import com.wangziyang.mes.basedata.workcell.service.IWorkCellDeviceGroupService;
import com.wangziyang.mes.basedata.workcell.service.IWorkCellService;
import com.wangziyang.mes.basedata.workcell.service.IWorkCellTeamService;
import com.wangziyang.mes.common.BaseController;
import com.wangziyang.mes.common.Result;
import io.swagger.annotations.ApiOperation;
import org.apache.commons.lang3.StringUtils;
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
 * 加工单元定义 前端控制器
 *
 * @author WangZiyang
 * @since 2021-03-10
 */
@Controller
@RequestMapping("/admin/sys/workCell")
public class WorkCellController extends BaseController {

    @Autowired
    private IWorkCellService workCellService;

    @Autowired
    private IWorkCellTeamService workCellTeamService;

    @Autowired
    private IWorkCellDeviceGroupService workCellDeviceGroupService;

    @Autowired
    private IBzTeamService bzTeamService;

    @Autowired
    private ISpDeviceGroupService iSpDeviceGroupService;

    @Autowired
    private ISpDeviceGroupItemService iSpDeviceGroupItemService;

    @Autowired
    private ISpDeviceService iSpDeviceService;

    @ApiOperation("加工单元列表UI")
    @GetMapping("/list-ui")
    public String listUI(Model model) {
        return "admin/system/workCell/list";
    }

    @ApiOperation("加工单元新增/修改界面")
    @GetMapping("/add-or-update-ui")
    public String addOrUpdateUI(Model model, WorkCell record) {
        if (StringUtils.isNotEmpty(record.getId())) {
            WorkCell result = workCellService.getById(record.getId());
            model.addAttribute("result", result);
        }
        return "admin/system/workCell/addOrUpdate";
    }

    /**
     * 生成加工单元代码（新增时预先展示）
     * 格式：JG0001、JG0002 依次递增，自动回收已删除的编号
     */
    @ApiOperation("生成加工单元代码")
    @GetMapping("/generate-code")
    @ResponseBody
    public Result generateCode() {
        return Result.success(generateWorkCellCode());
    }

    @ApiOperation("加工单元分页查询")
    @PostMapping("/page")
    @ResponseBody
    public Result page(WorkCellPageReq req) {
        QueryWrapper<WorkCell> qw = new QueryWrapper<>();
        if (StringUtils.isNotEmpty(req.getWorkCellCodeLike())) {
            qw.like("work_cell_code", req.getWorkCellCodeLike());
        }
        if (StringUtils.isNotEmpty(req.getWorkCellNameLike())) {
            qw.like("work_cell_name", req.getWorkCellNameLike());
        }
        if (StringUtils.isNotEmpty(req.getWorkCellType())) {
            qw.eq("work_cell_type", req.getWorkCellType());
        }
        qw.orderByDesc("update_time");
        IPage<WorkCell> result = workCellService.page(req, qw);
        // 状态联动：若加工单元关联的班组状态异常或编组设备状态异常，则加工单元状态显示为异常
        for (WorkCell workCell : result.getRecords()) {
            if (!"2".equals(workCell.getDeleted()) && isWorkCellAbnormal(workCell.getId())) {
                workCell.setDeleted("2");
            }
        }
        return Result.success(result);
    }

    /**
     * 判断加工单元是否异常：关联班组状态异常 或 关联编组设备状态异常
     *
     * @param workCellId 加工单元ID
     * @return true 异常
     */
    private boolean isWorkCellAbnormal(String workCellId) {
        // 检查关联班组
        QueryWrapper<WorkCellTeam> teamQw = new QueryWrapper<>();
        teamQw.eq("work_cell_id", workCellId);
        List<WorkCellTeam> teamList = workCellTeamService.list(teamQw);
        for (WorkCellTeam wct : teamList) {
            BzTeam team = bzTeamService.getById(wct.getTeamId());
            if (team != null && "2".equals(team.getIsDeleted())) {
                return true;
            }
        }
        // 检查关联编组设备
        QueryWrapper<WorkCellDeviceGroup> groupQw = new QueryWrapper<>();
        groupQw.eq("work_cell_id", workCellId);
        List<WorkCellDeviceGroup> groupList = workCellDeviceGroupService.list(groupQw);
        for (WorkCellDeviceGroup wcdg : groupList) {
            if (isDeviceGroupAbnormal(wcdg.getDeviceGroupId())) {
                return true;
            }
        }
        return false;
    }

    /**
     * 判断编组设备是否异常：编组状态异常 或 编组内存在被禁用的设备
     *
     * @param deviceGroupId 编组设备ID
     * @return true 异常
     */
    private boolean isDeviceGroupAbnormal(String deviceGroupId) {
        SpDeviceGroup group = iSpDeviceGroupService.getById(deviceGroupId);
        if (group == null) {
            return false;
        }
        if ("2".equals(group.getDeleted())) {
            return true;
        }
        // 编组内设备有禁用
        QueryWrapper<SpDeviceGroupItem> itemQw = new QueryWrapper<>();
        itemQw.eq("group_id", deviceGroupId);
        List<SpDeviceGroupItem> itemList = iSpDeviceGroupItemService.list(itemQw);
        for (SpDeviceGroupItem item : itemList) {
            SpDevice device = iSpDeviceService.getById(item.getDeviceId());
            if (device != null && "1".equals(device.getDeleted())) {
                return true;
            }
        }
        return false;
    }

    @ApiOperation("加工单元新增/修改")
    @PostMapping("/add-or-update")
    @ResponseBody
    @RequiresPermissions("user:add")
    public Result addOrUpdate(WorkCell record) {
        // 新增时自动生成加工单元代码（JG 格式 + 回收）
        if (StringUtils.isEmpty(record.getId()) && StringUtils.isEmpty(record.getWorkCellCode())) {
            record.setWorkCellCode(generateWorkCellCode());
        }
        if (StringUtils.isEmpty(record.getId())) {
            record.setDeleted("0");
        }
        workCellService.saveOrUpdate(record);
        return Result.success(record.getId());
    }

    /**
     * 生成加工单元代码：JG0001、JG0002 依次递增
     * 自动回收：查询所有未删除的 JG 编号，从 1 开始找最小未使用编号，被删除加工单元的编号可再次分配
     *
     * @return 新的加工单元代码
     */
    private String generateWorkCellCode() {
        QueryWrapper<WorkCell> wrapper = new QueryWrapper<>();
        wrapper.likeRight("work_cell_code", "JG");
        List<WorkCell> list = workCellService.list(wrapper);
        Set<Integer> usedNums = new HashSet<>();
        for (WorkCell workCell : list) {
            String code = workCell.getWorkCellCode();
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
        return "JG" + String.format("%04d", seq);
    }

    @ApiOperation("删除加工单元")
    @PostMapping("/delete")
    @ResponseBody
    @RequiresPermissions("user:add")
    public Result delete(WorkCell record) {
        // 删除加工单元同时删除关联的班组关系和编组设备关系
        QueryWrapper<WorkCellTeam> qw = new QueryWrapper<>();
        qw.eq("work_cell_id", record.getId());
        workCellTeamService.remove(qw);
        QueryWrapper<WorkCellDeviceGroup> dgQw = new QueryWrapper<>();
        dgQw.eq("work_cell_id", record.getId());
        workCellDeviceGroupService.remove(dgQw);
        workCellService.removeById(record.getId());
        return Result.success();
    }

    @ApiOperation("批量删除加工单元")
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
            // 删除加工单元同时删除关联的班组关系和编组设备关系
            QueryWrapper<WorkCellTeam> qw = new QueryWrapper<>();
            qw.eq("work_cell_id", id);
            workCellTeamService.remove(qw);
            QueryWrapper<WorkCellDeviceGroup> dgQw = new QueryWrapper<>();
            dgQw.eq("work_cell_id", id);
            workCellDeviceGroupService.remove(dgQw);
            workCellService.removeById(id);
        }
        return Result.success();
    }

    @ApiOperation("加工单元班组管理界面UI")
    @GetMapping("/team-manage-ui")
    public String teamManageUI(Model model, WorkCell record) {
        if (StringUtils.isNotEmpty(record.getId())) {
            WorkCell result = workCellService.getById(record.getId());
            model.addAttribute("result", result);
        }
        return "admin/system/workCell/teamManage";
    }

    @ApiOperation("查询加工单元已关联班组列表")
    @PostMapping("/team-list")
    @ResponseBody
    public Result teamList(String workCellId) {
        QueryWrapper<WorkCellTeam> qw = new QueryWrapper<>();
        qw.eq("work_cell_id", workCellId);
        List<WorkCellTeam> list = workCellTeamService.list(qw);

        List<Map<String, Object>> resultList = new ArrayList<>();
        for (WorkCellTeam wct : list) {
            Map<String, Object> map = new HashMap<>();
            map.put("id", wct.getId());
            map.put("workCellId", wct.getWorkCellId());
            map.put("teamId", wct.getTeamId());
            map.put("createTime", wct.getCreateTime());
            // 查询班组信息
            BzTeam team = bzTeamService.getById(wct.getTeamId());
            if (team != null) {
                map.put("teamCode", team.getCode());
                map.put("teamName", team.getName());
            } else {
                map.put("teamCode", "未知");
                map.put("teamName", "未知");
            }
            resultList.add(map);
        }
        return Result.success(resultList);
    }

    @ApiOperation("查询可用的班组列表（未加入该加工单元的班组）")
    @PostMapping("/available-team-page")
    @ResponseBody
    public Result availableTeamPage(String workCellId) {
        // 查询已在该加工单元中的班组ID
        QueryWrapper<WorkCellTeam> itemQw = new QueryWrapper<>();
        itemQw.eq("work_cell_id", workCellId);
        List<WorkCellTeam> itemList = workCellTeamService.list(itemQw);
        List<String> teamIds = new ArrayList<>();
        for (WorkCellTeam item : itemList) {
            teamIds.add(item.getTeamId());
        }

        // 查询未加入该加工单元的班组
        QueryWrapper<BzTeam> teamQw = new QueryWrapper<>();
        teamQw.eq("is_deleted", "0");
        if (!teamIds.isEmpty()) {
            teamQw.notIn("id", teamIds);
        }
        teamQw.orderByDesc("update_time");
        List<BzTeam> teamList = bzTeamService.list(teamQw);
        return Result.success(teamList);
    }

    @ApiOperation("加工单元添加班组")
    @PostMapping("/add-team")
    @ResponseBody
    @RequiresPermissions("user:add")
    public Result addTeam(String workCellId, String teamId) {
        // 检查是否已存在
        QueryWrapper<WorkCellTeam> qw = new QueryWrapper<>();
        qw.eq("work_cell_id", workCellId);
        qw.eq("team_id", teamId);
        WorkCellTeam exist = workCellTeamService.getOne(qw);
        if (exist != null) {
            return Result.failure("该班组已添加到该加工单元");
        }

        WorkCellTeam item = new WorkCellTeam();
        item.setWorkCellId(workCellId);
        item.setTeamId(teamId);
        workCellTeamService.save(item);
        return Result.success();
    }

    @ApiOperation("加工单元移除班组")
    @PostMapping("/remove-team")
    @ResponseBody
    @RequiresPermissions("user:add")
    public Result removeTeam(String workCellId, String teamId) {
        QueryWrapper<WorkCellTeam> qw = new QueryWrapper<>();
        qw.eq("work_cell_id", workCellId);
        qw.eq("team_id", teamId);
        workCellTeamService.remove(qw);
        return Result.success();
    }

    @ApiOperation("查询加工单元已关联编组设备列表")
    @PostMapping("/device-group-list")
    @ResponseBody
    public Result deviceGroupList(String workCellId) {
        QueryWrapper<WorkCellDeviceGroup> qw = new QueryWrapper<>();
        qw.eq("work_cell_id", workCellId);
        List<WorkCellDeviceGroup> list = workCellDeviceGroupService.list(qw);

        List<Map<String, Object>> resultList = new ArrayList<>();
        for (WorkCellDeviceGroup wcdg : list) {
            Map<String, Object> map = new HashMap<>();
            map.put("id", wcdg.getId());
            map.put("workCellId", wcdg.getWorkCellId());
            map.put("deviceGroupId", wcdg.getDeviceGroupId());
            map.put("createTime", wcdg.getCreateTime());
            // 查询编组设备信息
            SpDeviceGroup group = iSpDeviceGroupService.getById(wcdg.getDeviceGroupId());
            if (group != null) {
                map.put("groupCode", group.getGroupCode());
                map.put("groupName", group.getGroupName());
                map.put("groupDeleted", group.getDeleted());
            } else {
                map.put("groupCode", "未知");
                map.put("groupName", "未知");
                map.put("groupDeleted", "");
            }
            resultList.add(map);
        }
        return Result.success(resultList);
    }

    @ApiOperation("查询可用的编组设备列表（未加入该加工单元的编组设备）")
    @PostMapping("/available-device-group-page")
    @ResponseBody
    public Result availableDeviceGroupPage(String workCellId) {
        // 查询已在该加工单元中的编组设备ID
        QueryWrapper<WorkCellDeviceGroup> itemQw = new QueryWrapper<>();
        itemQw.eq("work_cell_id", workCellId);
        List<WorkCellDeviceGroup> itemList = workCellDeviceGroupService.list(itemQw);
        List<String> groupIds = new ArrayList<>();
        for (WorkCellDeviceGroup item : itemList) {
            groupIds.add(item.getDeviceGroupId());
        }

        // 查询未加入该加工单元的编组设备
        QueryWrapper<SpDeviceGroup> groupQw = new QueryWrapper<>();
        groupQw.eq("is_deleted", "0");
        if (!groupIds.isEmpty()) {
            groupQw.notIn("id", groupIds);
        }
        groupQw.orderByDesc("update_time");
        List<SpDeviceGroup> groupList = iSpDeviceGroupService.list(groupQw);
        return Result.success(groupList);
    }

    @ApiOperation("加工单元添加编组设备")
    @PostMapping("/add-device-group")
    @ResponseBody
    @RequiresPermissions("user:add")
    public Result addDeviceGroup(String workCellId, String deviceGroupId) {
        // 校验编组设备状态：异常的编组设备无法加入加工单元
        SpDeviceGroup group = iSpDeviceGroupService.getById(deviceGroupId);
        if (group == null) {
            return Result.failure("编组设备不存在");
        }
        if ("2".equals(group.getDeleted())) {
            return Result.failure("编组设备【" + group.getGroupCode() + "】状态异常，无法加入加工单元");
        }
        // 检查是否已存在
        QueryWrapper<WorkCellDeviceGroup> qw = new QueryWrapper<>();
        qw.eq("work_cell_id", workCellId);
        qw.eq("device_group_id", deviceGroupId);
        WorkCellDeviceGroup exist = workCellDeviceGroupService.getOne(qw);
        if (exist != null) {
            return Result.failure("该编组设备已添加到该加工单元");
        }

        WorkCellDeviceGroup item = new WorkCellDeviceGroup();
        item.setWorkCellId(workCellId);
        item.setDeviceGroupId(deviceGroupId);
        workCellDeviceGroupService.save(item);
        return Result.success();
    }

    @ApiOperation("加工单元移除编组设备")
    @PostMapping("/remove-device-group")
    @ResponseBody
    @RequiresPermissions("user:add")
    public Result removeDeviceGroup(String workCellId, String deviceGroupId) {
        QueryWrapper<WorkCellDeviceGroup> qw = new QueryWrapper<>();
        qw.eq("work_cell_id", workCellId);
        qw.eq("device_group_id", deviceGroupId);
        workCellDeviceGroupService.remove(qw);
        return Result.success();
    }
}
