package com.wangziyang.mes.technology.service.impl;

import cn.hutool.core.collection.CollectionUtil;
import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.wangziyang.mes.common.Result;
import com.wangziyang.mes.technology.dto.SpProductProcessDto;
import com.wangziyang.mes.technology.entity.SpFlow;
import com.wangziyang.mes.technology.entity.SpProductProcess;
import com.wangziyang.mes.technology.entity.SpProductProcessItem;
import com.wangziyang.mes.technology.mapper.SpProductProcessMapper;
import com.wangziyang.mes.technology.service.ISpFlowService;
import com.wangziyang.mes.technology.service.ISpProductProcessItemService;
import com.wangziyang.mes.technology.service.ISpProductProcessService;
import org.apache.commons.lang3.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Objects;

/**
 * <p>
 * 产品工艺规划 服务实现类
 * </p>
 *
 * @author WangZiYang
 * @since 2020-03-28
 */
@Service
public class SpProductProcessServiceImpl extends ServiceImpl<SpProductProcessMapper, SpProductProcess> implements ISpProductProcessService {

    private final Logger log = LoggerFactory.getLogger(SpProductProcessServiceImpl.class);

    @Autowired
    private ISpProductProcessItemService spProductProcessItemService;

    @Autowired
    private ISpFlowService iSpFlowService;

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void saveProcess(SpProductProcessDto dto) throws Exception {
        log.info("开始保存产品工艺规划");
        String processId = dto.getId();

        // 如果已锁定则不允许编辑
        if (StringUtils.isNotEmpty(processId)) {
            SpProductProcess existing = getById(processId);
            if (existing != null && "1".equals(existing.getLocked())) {
                throw new Exception("该产品工艺规划已锁定，无法编辑");
            }
        }

        // 保存头表
        SpProductProcess process = new SpProductProcess();
        process.setId(dto.getId());
        process.setBomId(dto.getBomId());
        process.setBomCode(dto.getBomCode());
        process.setMaterielCode(dto.getMaterielCode());
        process.setMaterielDesc(dto.getMaterielDesc());
        process.setFlowId(dto.getFlowId());
        process.setFlow(dto.getFlow());
        process.setFlowDesc(dto.getFlowDesc());
        process.setRemark(dto.getRemark());
        saveOrUpdate(process);

        if (StringUtils.isEmpty(processId)) {
            processId = process.getId();
        }

        // 处理工序明细
        List<SpProductProcessItem> itemList = dto.getItemList();
        if (CollectionUtil.isNotEmpty(itemList)) {
            // 先删除旧的明细
            QueryWrapper<SpProductProcessItem> qw = new QueryWrapper<>();
            qw.eq("process_id", processId);
            spProductProcessItemService.remove(qw);

            // 批量保存新的明细
            for (SpProductProcessItem item : itemList) {
                item.setProcessId(processId);
                item.setId(null); // 新增
            }
            spProductProcessItemService.saveBatch(itemList);
        }

        log.info("产品工艺规划保存完成，ID：{}", processId);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void lockProcess(String id, String locked) throws Exception {
        SpProductProcess process = getById(id);
        if (process == null) {
            throw new Exception("工艺规划记录不存在");
        }
        process.setLocked(locked);
        updateById(process);
        log.info("产品工艺规划{}操作完成，ID：{}", "1".equals(locked) ? "锁定" : "解锁", id);
    }
}
