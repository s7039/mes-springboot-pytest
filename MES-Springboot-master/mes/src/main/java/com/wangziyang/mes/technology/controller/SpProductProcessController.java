package com.wangziyang.mes.technology.controller;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.wangziyang.mes.common.BaseController;
import com.wangziyang.mes.common.Result;
import com.wangziyang.mes.technology.dto.SpProductProcessDto;
import com.wangziyang.mes.technology.entity.SpBom;
import com.wangziyang.mes.technology.entity.SpFlow;
import com.wangziyang.mes.technology.entity.SpProductProcess;
import com.wangziyang.mes.technology.entity.SpProductProcessItem;
import com.wangziyang.mes.technology.request.SpProductProcessReq;
import com.wangziyang.mes.technology.service.ISpBomService;
import com.wangziyang.mes.technology.service.ISpFlowService;
import com.wangziyang.mes.technology.service.ISpOperService;
import com.wangziyang.mes.technology.service.ISpProductProcessItemService;
import com.wangziyang.mes.technology.service.ISpProductProcessService;
import com.wangziyang.mes.technology.vo.SpOperVo;
import io.swagger.annotations.ApiImplicitParam;
import io.swagger.annotations.ApiImplicitParams;
import io.swagger.annotations.ApiOperation;
import org.apache.commons.lang3.StringUtils;
import org.apache.shiro.authz.annotation.RequiresPermissions;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.ResponseBody;

import java.util.List;

/**
 * <p>
 * 产品工艺规划管理 前端控制器
 * </p>
 *
 * @author WangZiYang
 * @since 2020-03-28
 */
@Controller
@RequestMapping("/technology/process/plan")
public class SpProductProcessController extends BaseController {

    @Autowired
    private ISpProductProcessService spProductProcessService;

    @Autowired
    private ISpProductProcessItemService spProductProcessItemService;

    @Autowired
    private ISpBomService iSpBomService;

    @Autowired
    private ISpFlowService iSpFlowService;

    @Autowired
    private ISpOperService iSpOperService;

    @Autowired
    private com.wangziyang.mes.technology.mapper.SpFlowOperRelationMapper spFlowOperRelationMapper;

    /**
     * 工艺规划管理列表界面
     */
    @ApiOperation("工艺规划管理列表界面UI")
    @GetMapping("/list-ui")
    public String listUI(Model model) {
        return "technology/process/list";
    }

    /**
     * 工艺规划编辑界面
     */
    @ApiOperation("工艺规划编辑界面UI")
    @GetMapping("/add-or-update-ui")
    public String addOrUpdateUI(Model model, SpProductProcess record) throws Exception {
        // 全部流程列表（用于下拉选择）
        List<SpFlow> flowList = iSpFlowService.list();
        model.addAttribute("flowList", flowList);

        // 全部工序列表（用于穿梭框）
        List<SpOperVo> allOpers = new java.util.ArrayList<>();
        List<com.wangziyang.mes.technology.entity.SpOper> operList = iSpOperService.list();
        for (com.wangziyang.mes.technology.entity.SpOper oper : operList) {
            SpOperVo vo = new SpOperVo();
            vo.setValue(oper.getId());
            vo.setTitle(oper.getOperDesc());
            allOpers.add(vo);
        }
        model.addAttribute("allOpers", allOpers);

        if (StringUtils.isNotEmpty(record.getId())) {
            // 编辑：加载已有工艺规划
            SpProductProcess process = spProductProcessService.getById(record.getId());
            model.addAttribute("process", process);

            // 加载已选的工序明细（按BOM层次分组）
            QueryWrapper<SpProductProcessItem> qw = new QueryWrapper<>();
            qw.eq("process_id", record.getId());
            qw.orderByAsc("bom_level", "sort_num");
            List<SpProductProcessItem> items = spProductProcessItemService.list(qw);
            model.addAttribute("items", items);

            // 加载BOM信息
            if (StringUtils.isNotEmpty(process.getBomId())) {
                SpBom bom = iSpBomService.getById(process.getBomId());
                model.addAttribute("bom", bom);
            }
        }

        return "technology/process/addOrUpdate";
    }

    /**
     * 工艺规划分页查询
     */
    @ApiOperation("工艺规划分页查询")
    @PostMapping("/page")
    @ResponseBody
    public Result page(SpProductProcessReq req) {
        QueryWrapper<SpProductProcess> qw = new QueryWrapper<>();
        if (StringUtils.isNotEmpty(req.getMaterielCodeLike())) {
            qw.like("materiel_code", req.getMaterielCodeLike());
        }
        if (StringUtils.isNotEmpty(req.getMaterielDescLike())) {
            qw.like("materiel_desc", req.getMaterielDescLike());
        }
        if (StringUtils.isNotEmpty(req.getBomCodeLike())) {
            qw.like("bom_code", req.getBomCodeLike());
        }
        if (StringUtils.isNotEmpty(req.getLocked())) {
            qw.eq("locked", req.getLocked());
        }
        IPage<SpProductProcess> result = spProductProcessService.page(req, qw);
        return Result.success(result);
    }

    /**
     * 保存工艺规划（含工序明细）
     */
    @ApiOperation("保存工艺规划")
    @PostMapping("/add-or-update")
    @ResponseBody
    @RequiresPermissions("user:add")
    public Result addOrUpdate(@RequestBody SpProductProcessDto dto) {
        try {
            spProductProcessService.saveProcess(dto);
            return Result.success(null, "产品工艺规划保存成功");
        } catch (Exception e) {
            return Result.failure(e.getMessage());
        }
    }

    /**
     * 删除工艺规划
     */
    @ApiOperation("删除工艺规划")
    @PostMapping("/delete")
    @ResponseBody
    @RequiresPermissions("user:add")
    public Result delete(SpProductProcess record) {
        try {
            SpProductProcess process = spProductProcessService.getById(record.getId());
            if (process != null && "1".equals(process.getLocked())) {
                return Result.failure("该工艺规划已锁定，无法删除");
            }
            // 删除头表
            spProductProcessService.removeById(record.getId());
            // 删除明细
            QueryWrapper<SpProductProcessItem> qw = new QueryWrapper<>();
            qw.eq("process_id", record.getId());
            spProductProcessItemService.remove(qw);
            return Result.success();
        } catch (Exception e) {
            return Result.failure(e.getMessage());
        }
    }

    /**
     * 锁定/解锁工艺规划
     */
    @ApiOperation("锁定/解锁工艺规划")
    @PostMapping("/lock")
    @ResponseBody
    @RequiresPermissions("user:add")
    public Result lock(SpProductProcess record) {
        try {
            spProductProcessService.lockProcess(record.getId(), record.getLocked());
            String msg = "1".equals(record.getLocked()) ? "产品工艺规划锁定成功" : "产品工艺规划解锁成功";
            return Result.success(null, msg);
        } catch (Exception e) {
            return Result.failure(e.getMessage());
        }
    }

    /**
     * 获取BOM列表（未关联工艺规划的BOM）
     */
    @ApiOperation("获取可选BOM列表")
    @PostMapping("/bom-list")
    @ResponseBody
    public Result bomList() {
        List<SpBom> bomList = iSpBomService.list();
        return Result.success(bomList);
    }

    /**
     * 查询工艺规划下的工序明细
     */
    @ApiOperation("查询工艺规划下的工序明细")
    @PostMapping("/process-items")
    @ResponseBody
    public Result processItems(String processId) {
        if (StringUtils.isEmpty(processId)) {
            return Result.success(new java.util.ArrayList<>());
        }
        QueryWrapper<SpProductProcessItem> qw = new QueryWrapper<>();
        qw.eq("process_id", processId);
        qw.orderByAsc("bom_level", "sort_num");
        List<SpProductProcessItem> items = spProductProcessItemService.list(qw);
        return Result.success(items);
    }

    /**
     * 根据流程ID获取工序列表
     */
    @ApiOperation("根据流程获取工序列表")
    @PostMapping("/flow-opers")
    @ResponseBody
    public Result flowOpers(String flowId) {
        if (StringUtils.isEmpty(flowId)) {
            return Result.success(new java.util.ArrayList<>());
        }
        SpFlow flow = iSpFlowService.getById(flowId);
        if (flow == null) {
            return Result.success(new java.util.ArrayList<>());
        }
        // 从流程工序关系表中获取工序
        List<SpOperVo> opers = spFlowOperRelationMapper.queryOperRelationByFlowId(flowId);
        return Result.success(opers);
    }
}
