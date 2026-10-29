package com.wangziyang.mes.warehouse.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.wangziyang.mes.warehouse.entity.SpWarehouse;
import com.wangziyang.mes.warehouse.entity.SpWarehouseLocation;
import com.wangziyang.mes.warehouse.mapper.SpWarehouseMapper;
import com.wangziyang.mes.warehouse.service.ISpWarehouseLocationService;
import com.wangziyang.mes.warehouse.service.ISpWarehouseService;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashSet;
import java.util.List;
import java.util.Set;

/**
 * 库房 服务实现类
 *
 * @author WangZiYang
 * @since 2021-03-01
 */
@Service
public class SpWarehouseServiceImpl extends ServiceImpl<SpWarehouseMapper, SpWarehouse> implements ISpWarehouseService {

    @Autowired
    private ISpWarehouseLocationService iSpWarehouseLocationService;

    @Override
    public String generateWarehouseCode() {
        // 自动回收：查询所有（含已物理删除前占用的）以KF开头的编号，找到最小未使用编号
        QueryWrapper<SpWarehouse> qw = new QueryWrapper<>();
        qw.likeRight("warehouse_code", "KF");
        List<SpWarehouse> list = this.list(qw);
        Set<Integer> usedNums = new HashSet<>();
        for (SpWarehouse wh : list) {
            String code = wh.getWarehouseCode();
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
        return "KF" + String.format("%03d", seq);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void createWarehouseWithLocations(SpWarehouse warehouse) {
        // 校验：库房名称不能为空
        if (StringUtils.isEmpty(warehouse.getWarehouseName())) {
            throw new IllegalArgumentException("库房名称不能为空");
        }
        // 校验：库房容量必须为正整数
        if (warehouse.getCapacity() == null || warehouse.getCapacity() <= 0) {
            throw new IllegalArgumentException("库房容量必须为正整数");
        }
        // 校验：库位数量必须为非负整数，为空默认为0
        if (warehouse.getLocationCount() == null || warehouse.getLocationCount() < 0) {
            warehouse.setLocationCount(0);
        }
        // 新增时自动生成库房编号（自动回收）
        if (StringUtils.isBlank(warehouse.getId())) {
            warehouse.setWarehouseCode(generateWarehouseCode());
        }
        warehouse.setDeleted("0");
        this.save(warehouse);

        // 同步创建库位：每个库位容量 = 库房容量 / 库位数量（向下取整）
        int locationCount = warehouse.getLocationCount();
        if (locationCount > 0) {
            int capacityPerLocation = warehouse.getCapacity() / locationCount;
            for (int i = 1; i <= locationCount; i++) {
                SpWarehouseLocation location = new SpWarehouseLocation();
                location.setLocationCode(warehouse.getWarehouseCode() + "-" + i);
                location.setLocationName(warehouse.getWarehouseCode() + "-" + i);
                location.setWarehouseId(warehouse.getId());
                location.setWarehouseCode(warehouse.getWarehouseCode());
                location.setWarehouseName(warehouse.getWarehouseName());
                location.setCapacity(capacityPerLocation);
                location.setRemark(warehouse.getRemark());
                location.setDeleted("0");
                iSpWarehouseLocationService.save(location);
            }
        }
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void deleteWarehouse(String id) {
        SpWarehouse warehouse = this.getById(id);
        if (warehouse == null) {
            throw new IllegalArgumentException("库房不存在");
        }
        // 同步删除该库房下所有库位（物理删除）
        QueryWrapper<SpWarehouseLocation> locationQw = new QueryWrapper<>();
        locationQw.eq("warehouse_id", id);
        iSpWarehouseLocationService.remove(locationQw);
        // 物理删除库房
        this.removeById(id);
    }
}
