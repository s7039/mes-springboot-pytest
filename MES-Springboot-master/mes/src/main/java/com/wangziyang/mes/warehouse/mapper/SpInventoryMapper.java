package com.wangziyang.mes.warehouse.mapper;

import com.wangziyang.mes.warehouse.entity.SpInventory;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

/**
 * 库存 Mapper 接口
 *
 * @author WangZiYang
 * @since 2021-06-02
 */
public interface SpInventoryMapper extends BaseMapper<SpInventory> {

    /**
     * 悲观锁：行级锁查询库存记录（SELECT ... FOR UPDATE）
     * 与乐观锁（version条件更新）组成双保险，防止超扣
     *
     * @param id 库存记录ID
     * @return 库存记录
     */
    @Select("SELECT * FROM sp_inventory WHERE id = #{id} FOR UPDATE")
    SpInventory selectByIdForUpdate(@Param("id") String id);
}
