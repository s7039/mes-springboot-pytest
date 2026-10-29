package com.wangziyang.mes.plan.service;

import com.wangziyang.mes.plan.entity.SpWorkOrder;
import com.baomidou.mybatisplus.extension.service.IService;

/**
 * 工单 服务类
 *
 * @author WangZiYang
 * @since 2026-08-16
 */
public interface ISpWorkOrderService extends IService<SpWorkOrder> {

    /**
     * 生成工单编号（GD00000001、GD00000002...）
     *
     * @return 工单编号
     */
    String generateOrderCode();

    /**
     * 添加工单：
     * - 出库工单：根据BOM递归展开得到物料需求量，校验库存可用量，不足则抛出缺料清单异常；
     *   库存充足则逐物料锁定库存（锁定数量），并生成工单物料需求
     * - 入库工单：直接保存（含库房/库位）
     *
     * @param order    工单信息
     * @param username 操作人
     */
    void createOrder(SpWorkOrder order, String username);

    /**
     * 工单确认：
     * - 出库工单：逐条物料需求先扣减锁定数量再扣减实际库存数量，写库存流水（类型：出库）
     * - 入库工单：直接增加实际库存数量，写库存流水（类型：入库）
     * 每次库存变动都写流水，流水编号唯一（数据库唯一索引保证幂等）
     *
     * @param id       工单ID
     * @param username 操作人
     */
    void confirmOrder(String id, String username);

    /**
     * 删除工单（物理删除）：
     * - 待确认的出库工单删除时同步释放已锁定库存，并删除物料需求
     * - 已完成的工单不允许删除
     *
     * @param id 工单ID
     */
    void deleteOrder(String id);

    /**
     * 修改工单（仅允许待确认工单）：
     * - 出库工单：先释放原锁定库存并删除物料需求，再重新BOM展开锁定
     * - 入库工单：直接更新
     *
     * @param order    工单信息（含ID）
     * @param username 操作人
     */
    void updateOrder(SpWorkOrder order, String username);
}
