package com.wangziyang.mes.warehouse.service;

import com.wangziyang.mes.warehouse.entity.SpInventoryFlow;
import com.baomidou.mybatisplus.extension.service.IService;

/**
 * 库存流水 服务类
 *
 * @author WangZiYang
 * @since 2026-08-16
 */
public interface ISpInventoryFlowService extends IService<SpInventoryFlow> {

    /**
     * 生成流水编号（LS00000001、LS00000002...）
     *
     * @return 流水编号
     */
    String generateFlowCode();

    /**
     * 保存库存流水（流水编号走数据库唯一索引保证幂等，冲突时自动重新生成重试）
     *
     * @param flow 流水信息
     * @return 保存后的流水
     */
    SpInventoryFlow saveFlow(SpInventoryFlow flow);
}
