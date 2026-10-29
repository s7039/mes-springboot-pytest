package com.wangziyang.mes.warehouse.controller;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.wangziyang.mes.common.BaseController;
import com.wangziyang.mes.common.Result;
import com.wangziyang.mes.warehouse.entity.SpWarehouse;
import com.wangziyang.mes.warehouse.entity.SpWarehouseLocation;
import com.wangziyang.mes.warehouse.request.SpWarehouseLocationReq;
import com.wangziyang.mes.warehouse.request.SpWarehouseReq;
import com.wangziyang.mes.warehouse.service.ISpWarehouseLocationService;
import com.wangziyang.mes.warehouse.service.ISpWarehouseService;
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

import java.util.List;

/**
 * 仓库管理前端控制器
 *
 * @author WangZiYang
 * @since 2021-03-01
 */
@Controller
@RequestMapping("/warehouse")
public class SpWarehouseController extends BaseController {

    @Autowired
    private ISpWarehouseService iSpWarehouseService;

    @Autowired
    private ISpWarehouseLocationService iSpWarehouseLocationService;

    @ApiOperation("仓库管理界面UI")
    @GetMapping("/list-ui")
    public String listUI(Model model) {
        return "warehouse/list";
    }

    @ApiOperation("仓库新增/修改界面")
    @GetMapping("/add-or-update-ui")
    public String addOrUpdateUI(Model model, SpWarehouse spWarehouse) {
        if (StringUtils.isNotEmpty(spWarehouse.getId())) {
            SpWarehouse result = iSpWarehouseService.getById(spWarehouse.getId());
            model.addAttribute("result", result);
        }
        return "warehouse/addOrUpdate";
    }

    @ApiOperation("仓库分页查询")
    @PostMapping("/page")
    @ResponseBody
    public Result page(SpWarehouseReq req) {
        QueryWrapper<SpWarehouse> qw = new QueryWrapper<>();
        if (StringUtils.isNotEmpty(req.getWarehouseNameLike())) {
            qw.like("warehouse_name", req.getWarehouseNameLike());
        }
        qw.orderByAsc("warehouse_code");
        IPage<SpWarehouse> result = iSpWarehouseService.page(req, qw);
        return Result.success(result);
    }

    @ApiOperation("仓库新增/修改（新增时同步创建库位）")
    @PostMapping("/add-or-update")
    @ResponseBody
    @RequiresPermissions("user:add")
    public Result addOrUpdate(SpWarehouse spWarehouse) {
        try {
            iSpWarehouseService.createWarehouseWithLocations(spWarehouse);
            return Result.success();
        } catch (Exception e) {
            return Result.failure(e.getMessage());
        }
    }

    @ApiOperation("删除仓库（物理删除，同步删除其下所有库位）")
    @PostMapping("/delete")
    @ResponseBody
    @RequiresPermissions("user:add")
    public Result delete(SpWarehouse spWarehouse) {
        try {
            iSpWarehouseService.deleteWarehouse(spWarehouse.getId());
            return Result.success();
        } catch (Exception e) {
            return Result.failure(e.getMessage());
        }
    }

    @ApiOperation("获取全部可用仓库")
    @PostMapping("/all-list")
    @ResponseBody
    public Result allList() {
        QueryWrapper<SpWarehouse> qw = new QueryWrapper<>();
        qw.eq("is_deleted", "0");
        qw.orderByAsc("warehouse_code");
        List<SpWarehouse> list = iSpWarehouseService.list(qw);
        return Result.success(list);
    }

    @ApiOperation("根据库房编号获取库位")
    @PostMapping("/location-list")
    @ResponseBody
    public Result locationList(String warehouseCode) {
        QueryWrapper<SpWarehouseLocation> qw = new QueryWrapper<>();
        if (StringUtils.isNotEmpty(warehouseCode)) {
            qw.eq("warehouse_code", warehouseCode);
        }
        qw.eq("is_deleted", "0");
        qw.orderByAsc("location_code");
        List<SpWarehouseLocation> list = iSpWarehouseLocationService.list(qw);
        return Result.success(list);
    }

    @ApiOperation("库位查看界面UI（查看库房下所有库位及容量）")
    @GetMapping("/location/list-ui")
    public String locationListUI(Model model, String warehouseCode) {
        model.addAttribute("warehouseCode", warehouseCode);
        return "warehouse/locationList";
    }

    @ApiOperation("库位分页查询")
    @PostMapping("/location/page")
    @ResponseBody
    public Result locationPage(SpWarehouseLocationReq req, String warehouseCode) {
        QueryWrapper<SpWarehouseLocation> qw = new QueryWrapper<>();
        if (StringUtils.isNotEmpty(req.getLocationCodeLike())) {
            qw.like("location_code", req.getLocationCodeLike());
        }
        if (StringUtils.isNotEmpty(req.getWarehouseId())) {
            qw.eq("warehouse_id", req.getWarehouseId());
        }
        if (StringUtils.isNotEmpty(warehouseCode)) {
            qw.eq("warehouse_code", warehouseCode);
        }
        qw.orderByAsc("location_code");
        IPage<SpWarehouseLocation> result = iSpWarehouseLocationService.page(req, qw);
        return Result.success(result);
    }
}
