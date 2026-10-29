package com.wangziyang.mes.technology.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.wangziyang.mes.technology.dto.SpProductProcessDto;
import com.wangziyang.mes.technology.entity.SpProductProcess;

/**
 * <p>
 * 产品工艺规划 服务接口
 * </p>
 *
 * @author WangZiYang
 * @since 2020-03-28
 */
public interface ISpProductProcessService extends IService<SpProductProcess> {

    /**
     * 保存产品工艺规划（含工序明细）
     *
     * @param dto 工艺规划DTO
     * @throws Exception 异常
     */
    void saveProcess(SpProductProcessDto dto) throws Exception;

    /**
     * 锁定/解锁产品工艺规划
     *
     * @param id     工艺规划ID
     * @param locked 锁定状态：0未锁定 1已锁定
     * @throws Exception 异常
     */
    void lockProcess(String id, String locked) throws Exception;
}
