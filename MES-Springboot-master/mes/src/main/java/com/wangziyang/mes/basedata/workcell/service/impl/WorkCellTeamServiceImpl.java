package com.wangziyang.mes.basedata.workcell.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.wangziyang.mes.basedata.workcell.entity.WorkCellTeam;
import com.wangziyang.mes.basedata.workcell.mapper.WorkCellTeamMapper;
import com.wangziyang.mes.basedata.workcell.service.IWorkCellTeamService;
import org.springframework.stereotype.Service;

/**
 * 加工单元班组关联 服务实现类
 *
 * @author WangZiyang
 * @since 2021-03-10
 */
@Service
public class WorkCellTeamServiceImpl extends ServiceImpl<WorkCellTeamMapper, WorkCellTeam> implements IWorkCellTeamService {
}
