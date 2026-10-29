package com.wangziyang.mes.warehouse.controller;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.wangziyang.mes.common.BaseController;
import com.wangziyang.mes.common.Result;
import com.wangziyang.mes.warehouse.entity.SpInventory;
import com.wangziyang.mes.warehouse.request.SpInventoryReq;
import com.wangziyang.mes.warehouse.service.ISpInventoryService;
import io.swagger.annotations.ApiOperation;
import org.apache.commons.lang3.StringUtils;
import org.apache.shiro.authz.annotation.RequiresPermissions;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import java.math.BigDecimal;

/**
 * 库存管理前端控制器
 *
 * @author WangZiYang
 * @since 2021-06-02
 */
@Controller
@RequestMapping("/warehouse/inventory")
public class SpInventoryController extends BaseController {

    @Autowired
    private ISpInventoryService iSpInventoryService;

    @ApiOperation("库存管理界面UI")
    @GetMapping("/list-ui")
    public String listUI() {
        return "warehouse/inventoryList";
    }

    @ApiOperation("库存分页查询")
    @PostMapping("/page")
    @ResponseBody
    public Result page(SpInventoryReq req) {
        QueryWrapper<SpInventory> qw = new QueryWrapper<>();
        if (StringUtils.isNotEmpty(req.getMaterielCode())) {
            qw.like("materiel_code", req.getMaterielCode());
        }
        if (StringUtils.isNotEmpty(req.getMaterielDesc())) {
            qw.like("materiel_desc", req.getMaterielDesc());
        }
        if (StringUtils.isNotEmpty(req.getWarehouseCode())) {
            qw.eq("warehouse_code", req.getWarehouseCode());
        }
        if (StringUtils.isNotEmpty(req.getLocationCode())) {
            qw.like("location_code", req.getLocationCode());
        }
        if (StringUtils.isNotEmpty(req.getStatus())) {
            qw.eq("status", req.getStatus());
        }
        qw.orderByDesc("update_time");
        IPage<SpInventory> result = iSpInventoryService.page(req, qw);
        // 计算可用数量 = 实际库存数量 - 锁定数量
        result.getRecords().forEach(inv -> {
            BigDecimal qty = inv.getQty() == null ? BigDecimal.ZERO : inv.getQty();
            BigDecimal locked = inv.getLockedQty() == null ? BigDecimal.ZERO : inv.getLockedQty();
            inv.setAvailableQty(qty.subtract(locked));
        });
        return Result.success(result);
    }

    @ApiOperation("删除库存（物理删除，仅当实际与锁定数量均为0时允许）")
    @PostMapping("/delete")
    @ResponseBody
    @RequiresPermissions("user:add")
    public Result delete(SpInventory spInventory) {
        try {
            SpInventory inventory = iSpInventoryService.getById(spInventory.getId());
            if (inventory == null) {
                return Result.failure("库存记录不存在");
            }
            BigDecimal qty = inventory.getQty() == null ? BigDecimal.ZERO : inventory.getQty();
            BigDecimal locked = inventory.getLockedQty() == null ? BigDecimal.ZERO : inventory.getLockedQty();
            if (qty.compareTo(BigDecimal.ZERO) > 0 || locked.compareTo(BigDecimal.ZERO) > 0) {
                return Result.failure("库存数量不为0（实际" + qty + "，锁定" + locked + "），不允许删除");
            }
            iSpInventoryService.removeById(inventory.getId());
            return Result.success();
        } catch (Exception e) {
            return Result.failure(e.getMessage());
        }
    }
}
