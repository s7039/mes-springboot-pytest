package com.wangziyang.mes.warehouse.controller;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.wangziyang.mes.common.BaseController;
import com.wangziyang.mes.common.Result;
import com.wangziyang.mes.warehouse.entity.SpInventoryFlow;
import com.wangziyang.mes.warehouse.request.SpInventoryFlowReq;
import com.wangziyang.mes.warehouse.service.ISpInventoryFlowService;
import io.swagger.annotations.ApiOperation;
import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

/**
 * 库存流水管理前端控制器
 *
 * @author WangZiYang
 * @since 2026-08-16
 */
@Controller
@RequestMapping("/warehouse/flow")
public class SpInventoryFlowController extends BaseController {

    @Autowired
    private ISpInventoryFlowService iSpInventoryFlowService;

    @ApiOperation("流水管理界面UI")
    @GetMapping("/list-ui")
    public String listUI() {
        return "warehouse/flowList";
    }

    @ApiOperation("流水分页查询")
    @PostMapping("/page")
    @ResponseBody
    public Result page(SpInventoryFlowReq req) {
        QueryWrapper<SpInventoryFlow> qw = new QueryWrapper<>();
        if (StringUtils.isNotEmpty(req.getFlowCode())) {
            qw.like("flow_code", req.getFlowCode());
        }
        if (StringUtils.isNotEmpty(req.getMaterielCode())) {
            qw.like("materiel_code", req.getMaterielCode());
        }
        if (StringUtils.isNotEmpty(req.getWarehouseCode())) {
            qw.eq("warehouse_code", req.getWarehouseCode());
        }
        if (StringUtils.isNotEmpty(req.getChangeType())) {
            qw.eq("change_type", req.getChangeType());
        }
        if (StringUtils.isNotEmpty(req.getOrderCode())) {
            qw.like("order_code", req.getOrderCode());
        }
        qw.orderByDesc("create_time");
        IPage<SpInventoryFlow> result = iSpInventoryFlowService.page(req, qw);
        return Result.success(result);
    }
}
