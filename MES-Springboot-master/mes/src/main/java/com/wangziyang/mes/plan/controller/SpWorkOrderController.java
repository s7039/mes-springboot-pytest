package com.wangziyang.mes.plan.controller;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.wangziyang.mes.basedata.entity.SpMaterile;
import com.wangziyang.mes.basedata.service.ISpMaterileService;
import com.wangziyang.mes.common.BaseController;
import com.wangziyang.mes.common.BasePageReq;
import com.wangziyang.mes.common.Result;
import com.wangziyang.mes.plan.entity.SpWorkOrder;
import com.wangziyang.mes.plan.entity.SpWorkOrderRequirement;
import com.wangziyang.mes.plan.request.SpWorkOrderReq;
import com.wangziyang.mes.plan.service.ISpWorkOrderRequirementService;
import com.wangziyang.mes.plan.service.ISpWorkOrderService;
import com.wangziyang.mes.technology.entity.SpBom;
import com.wangziyang.mes.technology.service.ISpBomService;
import io.swagger.annotations.ApiOperation;
import org.apache.commons.lang3.StringUtils;
import org.apache.shiro.authz.annotation.RequiresPermissions;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Collections;

/**
 * 工单管理前端控制器（工单下达/工单确认）
 *
 * @author WangZiYang
 * @since 2026-08-16
 */
@Controller
@RequestMapping("/plan/work-order")
public class SpWorkOrderController extends BaseController {

    private static final DateTimeFormatter DATE_TIME_FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

    @Autowired
    private ISpWorkOrderService iSpWorkOrderService;

    @Autowired
    private ISpWorkOrderRequirementService iSpWorkOrderRequirementService;

    @Autowired
    private ISpMaterileService iSpMaterileService;

    @Autowired
    private ISpBomService iSpBomService;

    @ApiOperation("工单下达界面UI")
    @GetMapping("/release-list-ui")
    public String releaseListUI() {
        return "plan/work-order/release-list";
    }

    @ApiOperation("工单确认界面UI")
    @GetMapping("/confirm-list-ui")
    public String confirmListUI() {
        return "plan/work-order/confirm-list";
    }

    @ApiOperation("工单分页查询")
    @PostMapping("/page")
    @ResponseBody
    public Result page(SpWorkOrderReq req) {
        QueryWrapper<SpWorkOrder> qw = new QueryWrapper<>();
        if (StringUtils.isNotEmpty(req.getOrderCode())) {
            qw.like("order_code", req.getOrderCode());
        }
        if (StringUtils.isNotEmpty(req.getMaterielCode())) {
            qw.like("materiel_code", req.getMaterielCode());
        }
        if (StringUtils.isNotEmpty(req.getMaterielDesc())) {
            qw.like("materiel_desc", req.getMaterielDesc());
        }
        if (StringUtils.isNotEmpty(req.getOrderType())) {
            qw.eq("order_type", req.getOrderType());
        }
        if (StringUtils.isNotEmpty(req.getStatus())) {
            qw.eq("status", req.getStatus());
        }
        qw.orderByDesc("create_time");
        IPage<SpWorkOrder> result = iSpWorkOrderService.page(req, qw);
        return Result.success(result);
    }

    @ApiOperation("工单新增/修改界面")
    @GetMapping("/add-or-update-ui")
    public String addOrUpdateUI(Model model, SpWorkOrder spWorkOrder) {
        model.addAttribute("orderType", spWorkOrder.getOrderType());
        if (StringUtils.isNotEmpty(spWorkOrder.getId())) {
            SpWorkOrder result = iSpWorkOrderService.getById(spWorkOrder.getId());
            model.addAttribute("result", result);
            model.addAttribute("orderType", result.getOrderType());
            // 时间格式化为字符串，避免FreeMarker对java.time类型渲染异常；出库工单仅展示日期
            String timeFmt = "OUT".equals(result.getOrderType()) ? "yyyy-MM-dd" : "yyyy-MM-dd HH:mm:ss";
            DateTimeFormatter fmt = DateTimeFormatter.ofPattern(timeFmt);
            model.addAttribute("startTimeStr", result.getStartTime() == null ? "" : result.getStartTime().format(fmt));
            model.addAttribute("endTimeStr", result.getEndTime() == null ? "" : result.getEndTime().format(fmt));
        }
        return "plan/work-order/addOrUpdate";
    }

    @ApiOperation("工单新增/修改（出库工单自动BOM展开并锁定库存）")
    @PostMapping("/add-or-update")
    @ResponseBody
    @RequiresPermissions("user:add")
    public Result addOrUpdate(SpWorkOrder spWorkOrder, String startTimeStr, String endTimeStr) {
        try {
            spWorkOrder.setStartTime(parseTime(startTimeStr));
            spWorkOrder.setEndTime(parseTime(endTimeStr));
            String username = getSysUser().getUsername();
            if (StringUtils.isEmpty(spWorkOrder.getId())) {
                // 并发创建时“取最大号+1”会算出相同编号，撞 uk_order_code 后整单回滚；
                // 这里对唯一键冲突做有限次重试（每次重新取号），避免用户看到数据库异常
                final int maxRetry = 5;
                for (int attempt = 0; ; attempt++) {
                    try {
                        iSpWorkOrderService.createOrder(spWorkOrder, username);
                        break;
                    } catch (Exception e) {
                        if (!isDuplicateKey(e) || attempt >= maxRetry - 1) {
                            throw e;
                        }
                        // 清空主键与编号，让 createOrder 重新生成编号并重新展开/锁定
                        spWorkOrder.setId(null);
                        spWorkOrder.setOrderCode(null);
                        try {
                            Thread.sleep(15L * (attempt + 1));
                        } catch (InterruptedException ie) {
                            Thread.currentThread().interrupt();
                        }
                    }
                }
            } else {
                // 编辑：先释放原锁定库存，再重新BOM展开锁定
                iSpWorkOrderService.updateOrder(spWorkOrder, username);
            }
            return Result.success();
        } catch (Exception e) {
            if (isDuplicateKey(e)) {
                return Result.failure("工单编号生成冲突，请重试");
            }
            return Result.failure(e.getMessage());
        }
    }

    /**
     * 判断异常链中是否包含唯一键冲突（并发取号时撞 uk_order_code）
     *
     * @param e 异常
     * @return true-是唯一键冲突
     */
    private boolean isDuplicateKey(Throwable e) {
        Throwable t = e;
        int depth = 0;
        while (t != null && depth++ < 10) {
            if (t instanceof org.springframework.dao.DuplicateKeyException) {
                return true;
            }
            if (t instanceof java.sql.SQLIntegrityConstraintViolationException) {
                return true;
            }
            String msg = t.getMessage();
            if (msg != null && msg.contains("Duplicate entry")) {
                return true;
            }
            t = t.getCause();
        }
        return false;
    }

    @ApiOperation("删除工单（物理删除，出库待确认工单同步释放锁定库存）")
    @PostMapping("/delete")
    @ResponseBody
    @RequiresPermissions("user:add")
    public Result delete(SpWorkOrder spWorkOrder) {
        try {
            iSpWorkOrderService.deleteOrder(spWorkOrder.getId());
            return Result.success();
        } catch (Exception e) {
            return Result.failure(e.getMessage());
        }
    }

    @ApiOperation("确认工单（出库扣减库存写流水，入库增加库存写流水）")
    @PostMapping("/confirm")
    @ResponseBody
    @RequiresPermissions("user:add")
    public Result confirm(SpWorkOrder spWorkOrder) {
        try {
            iSpWorkOrderService.confirmOrder(spWorkOrder.getId(), getSysUser().getUsername());
            return Result.success();
        } catch (Exception e) {
            return Result.failure(e.getMessage());
        }
    }

    @ApiOperation("物料需求界面UI")
    @GetMapping("/requirement-ui")
    public String requirementUI(Model model, String orderCode) {
        model.addAttribute("orderCode", orderCode);
        return "plan/work-order/requirement";
    }

    @ApiOperation("物料需求分页查询")
    @PostMapping("/requirement-page")
    @ResponseBody
    public Result requirementPage(BasePageReq<SpWorkOrderRequirement> req, String orderCode) {
        QueryWrapper<SpWorkOrderRequirement> qw = new QueryWrapper<>();
        if (StringUtils.isNotEmpty(orderCode)) {
            qw.eq("order_code", orderCode);
        }
        qw.orderByAsc("materiel_code");
        return Result.success(iSpWorkOrderRequirementService.page(req, qw));
    }

    @ApiOperation("物料搜索界面UI（独立页面，供工单表单选择物料）")
    @GetMapping("/material-select-ui")
    public String materialSelectUI() {
        return "plan/work-order/material-select";
    }

    @ApiOperation("物料搜索（按物料编码/物料名称，分页返回）")
    @PostMapping("/material-search")
    @ResponseBody
    public Result materialSearch(BasePageReq<SpMaterile> req, String materielCode, String materielDesc) {
        QueryWrapper<SpMaterile> qw = new QueryWrapper<>();
        if (StringUtils.isNotEmpty(materielCode)) {
            qw.like("materiel", materielCode);
        }
        if (StringUtils.isNotEmpty(materielDesc)) {
            qw.like("materiel_desc", materielDesc);
        }
        qw.eq("is_deleted", "0");
        qw.orderByDesc("update_time");
        return Result.success(iSpMaterileService.page(req, qw));
    }

    @ApiOperation("根据物料编码查询物料（自动带出物料名称）")
    @PostMapping("/material-detail")
    @ResponseBody
    public Result materialDetail(String materielCode) {
        if (StringUtils.isEmpty(materielCode)) {
            return Result.failure("请输入物料编码");
        }
        QueryWrapper<SpMaterile> qw = new QueryWrapper<>();
        qw.eq("materiel", materielCode);
        qw.last("LIMIT 1");
        SpMaterile materile = iSpMaterileService.getOne(qw, false);
        return Result.success(materile);
    }

    @ApiOperation("根据物料编码查询工艺BOM列表（出库选择使用）")
    @PostMapping("/bom-list")
    @ResponseBody
    public Result bomList(String materielCode) {
        if (StringUtils.isEmpty(materielCode)) {
            return Result.success(Collections.emptyList());
        }
        QueryWrapper<SpBom> qw = new QueryWrapper<>();
        qw.eq("materiel_code", materielCode);
        qw.orderByAsc("bom_code");
        return Result.success(iSpBomService.list(qw));
    }

    private static final DateTimeFormatter DATE_FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd");

    private LocalDateTime parseTime(String time) {
        if (StringUtils.isBlank(time)) {
            return null;
        }
        String value = time.trim();
        // 支持 yyyy-MM-dd HH:mm:ss（精确时间）与 yyyy-MM-dd（仅日期）
        try {
            return LocalDateTime.parse(value, DATE_TIME_FORMATTER);
        } catch (Exception ignored) {
        }
        try {
            return LocalDate.parse(value, DATE_FORMATTER).atStartOfDay();
        } catch (Exception e) {
            throw new IllegalArgumentException("时间格式不正确：" + time);
        }
    }
}
