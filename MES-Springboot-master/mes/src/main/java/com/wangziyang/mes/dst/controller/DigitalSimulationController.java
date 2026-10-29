package com.wangziyang.mes.dst.controller;


import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.wangziyang.mes.common.BaseController;
import com.wangziyang.mes.common.Result;
import com.wangziyang.mes.warehouse.entity.SpInventory;
import com.wangziyang.mes.warehouse.entity.SpWarehouse;
import com.wangziyang.mes.warehouse.entity.SpWarehouseLocation;
import com.wangziyang.mes.warehouse.service.ISpInventoryService;
import com.wangziyang.mes.warehouse.service.ISpWarehouseLocationService;
import com.wangziyang.mes.warehouse.service.ISpWarehouseService;
import io.swagger.annotations.ApiOperation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import java.util.*;

/**
 * <p>
 * 数字仿真控制器 基于three.js
 * 连接库房库位数据与3D仓库展示
 * </p>
 *
 * @author WangZiYang
 * @since 2020-08-18
 */
@Controller
@RequestMapping("/digital/simulation")
public class DigitalSimulationController extends BaseController{

    @Autowired
    private ISpWarehouseService warehouseService;

    @Autowired
    private ISpWarehouseLocationService locationService;

    @Autowired
    private ISpInventoryService inventoryService;

    /**
     * 数字仿真界面
     *
     * @return 数字仿真界面
     */
    @ApiOperation("数字仿真3D教学UI")
    @GetMapping("/list-ui")
    public String addOrUpdateUI() {
        return "digitization/3DProject";
    }

    /**
     * 获取所有库房列表（用于3D场景展示）
     * 返回状态正常的库房信息
     */
    @ApiOperation("获取3D库房数据")
    @GetMapping("/warehouse-list")
    @ResponseBody
    public Result getWarehouseList() {
        QueryWrapper<SpWarehouse> wrapper = new QueryWrapper<>();
        wrapper.eq("is_deleted", "0");
        wrapper.orderByAsc("warehouse_code");
        List<SpWarehouse> list = warehouseService.list(wrapper);
        return Result.success(list);
    }

    /**
     * 获取所有库位及其库存数据（用于3D场景货架和货物展示）
     * 包含该库位上的物料信息和库存数量
     */
    @ApiOperation("获取3D库位数据")
    @GetMapping("/location-data")
    @ResponseBody
    public Result getLocationData() {
        // 查询所有正常状态的库位
        QueryWrapper<SpWarehouseLocation> locationWrapper = new QueryWrapper<>();
        locationWrapper.eq("is_deleted", "0");
        locationWrapper.orderByAsc("warehouse_code", "location_code");
        List<SpWarehouseLocation> locations = locationService.list(locationWrapper);

        // 查询所有正常状态的库房，用于映射
        QueryWrapper<SpWarehouse> warehouseWrapper = new QueryWrapper<>();
        warehouseWrapper.eq("is_deleted", "0");
        List<SpWarehouse> warehouses = warehouseService.list(warehouseWrapper);
        Map<String, SpWarehouse> warehouseMap = new HashMap<>();
        for (SpWarehouse w : warehouses) {
            warehouseMap.put(w.getId(), w);
        }

        // 查询所有库存数据
        QueryWrapper<SpInventory> inventoryWrapper = new QueryWrapper<>();
        inventoryWrapper.eq("status", "01"); // 可用库存
        List<SpInventory> inventories = inventoryService.list(inventoryWrapper);
        Map<String, List<SpInventory>> locationInventoryMap = new HashMap<>();
        for (SpInventory inv : inventories) {
            locationInventoryMap.computeIfAbsent(inv.getLocationId(), k -> new ArrayList<>()).add(inv);
        }

        // 构建3D场景数据
        List<Map<String, Object>> shelfDataList = new ArrayList<>();
        Set<String> addedWarehouseIds = new LinkedHashSet<>();

        for (SpWarehouseLocation loc : locations) {
            Map<String, Object> shelfData = new HashMap<>();
            shelfData.put("locationId", loc.getId());
            shelfData.put("locationCode", loc.getLocationCode());
            shelfData.put("locationName", loc.getLocationName());
            shelfData.put("warehouseId", loc.getWarehouseId());
            shelfData.put("warehouseCode", loc.getWarehouseCode());
            shelfData.put("warehouseName", loc.getWarehouseName());
            shelfData.put("capacity", loc.getCapacity());

            // 从warehouseMap获取库房类型
            SpWarehouse wh = warehouseMap.get(loc.getWarehouseId());
            shelfData.put("warehouseType", wh != null ? wh.getWarehouseType() : "");

            // 该库位上的库存信息
            List<SpInventory> locInv = locationInventoryMap.getOrDefault(loc.getId(), Collections.emptyList());
            List<Map<String, Object>> cargoList = new ArrayList<>();
            for (SpInventory inv : locInv) {
                Map<String, Object> cargo = new HashMap<>();
                cargo.put("materielCode", inv.getMaterielCode());
                cargo.put("materielDesc", inv.getMaterielDesc());
                cargo.put("qty", inv.getQty());
                cargo.put("unit", inv.getUnit());
                cargoList.add(cargo);
            }
            shelfData.put("cargos", cargoList);

            shelfDataList.add(shelfData);
            if (loc.getWarehouseId() != null) {
                addedWarehouseIds.add(loc.getWarehouseId());
            }
        }

        // 添加没有库位的库房（作为独立库区展示）
        List<Map<String, Object>> zoneList = new ArrayList<>();
        for (SpWarehouse wh : warehouses) {
            if (!addedWarehouseIds.contains(wh.getId()) && wh.getWarehouseType() != null) {
                Map<String, Object> zone = new HashMap<>();
                zone.put("warehouseId", wh.getId());
                zone.put("warehouseCode", wh.getWarehouseCode());
                zone.put("warehouseName", wh.getWarehouseName());
                zone.put("warehouseType", wh.getWarehouseType());
                zone.put("spec", wh.getSpec());
                zone.put("remark", wh.getRemark());
                zoneList.add(zone);
            }
        }

        Map<String, Object> result = new HashMap<>();
        result.put("shelves", shelfDataList);
        result.put("zones", zoneList);
        result.put("warehouses", warehouses);

        return Result.success(result);
    }
}
