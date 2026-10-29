package com.wangziyang.mes.warehouse.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.wangziyang.mes.warehouse.entity.SpInventoryFlow;
import com.wangziyang.mes.warehouse.mapper.SpInventoryFlowMapper;
import com.wangziyang.mes.warehouse.service.ISpInventoryFlowService;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import org.apache.commons.lang3.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * 库存流水 服务实现类
 *
 * @author WangZiYang
 * @since 2026-08-16
 */
@Service
public class SpInventoryFlowServiceImpl extends ServiceImpl<SpInventoryFlowMapper, SpInventoryFlow> implements ISpInventoryFlowService {

    private static final Logger logger = LoggerFactory.getLogger(SpInventoryFlowServiceImpl.class);

    @Override
    public String generateFlowCode() {
        QueryWrapper<SpInventoryFlow> qw = new QueryWrapper<>();
        qw.likeRight("flow_code", "LS");
        qw.orderByDesc("flow_code");
        qw.last("LIMIT 1");
        SpInventoryFlow max = this.getOne(qw, false);
        int seq = 1;
        if (max != null && StringUtils.isNotBlank(max.getFlowCode())) {
            String numStr = max.getFlowCode().substring(2);
            if (numStr.matches("\\d+")) {
                seq = Integer.parseInt(numStr) + 1;
            }
        }
        return "LS" + String.format("%08d", seq);
    }

    @Override
    public SpInventoryFlow saveFlow(SpInventoryFlow flow) {
        // 流水编号需要唯一：数据库唯一索引保证幂等，冲突时自动重新生成重试
        for (int i = 0; i < 5; i++) {
            if (StringUtils.isBlank(flow.getFlowCode())) {
                flow.setFlowCode(generateFlowCode());
            }
            try {
                this.save(flow);
                return flow;
            } catch (DuplicateKeyException e) {
                logger.warn("流水编号{}冲突，重新生成重试", flow.getFlowCode());
                flow.setFlowCode(null);
            }
        }
        throw new IllegalStateException("流水编号生成失败，请重试");
    }
}
