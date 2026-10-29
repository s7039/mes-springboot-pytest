package com.wangziyang.mes.warehouse.service;

import com.wangziyang.mes.warehouse.entity.SpWarehouse;
import com.baomidou.mybatisplus.extension.service.IService;

/**
 * 库房 服务类
 *
 * @author WangZiYang
 * @since 2021-03-01
 */
public interface ISpWarehouseService extends IService<SpWarehouse> {

    /**
     * 生成库房编号（KF001、KF002...），自动回收：已删除库房的编号可被再次分配
     *
     * @return 新库房编号
     */
    String generateWarehouseCode();

    /**
     * 新增库房，并按库位数量同步创建库位
     * 每个库位的容量 = 库房容量 / 库位数量（向下取整）
     *
     * @param warehouse 库房信息
     */
    void createWarehouseWithLocations(SpWarehouse warehouse);

    /**
     * 删除库房（物理删除），同步删除该库房下所有库位
     *
     * @param id 库房ID
     */
    void deleteWarehouse(String id);
}
