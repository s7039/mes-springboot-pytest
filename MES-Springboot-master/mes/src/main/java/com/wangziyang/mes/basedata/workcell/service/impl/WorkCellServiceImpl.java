package com.wangziyang.mes.basedata.workcell.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.wangziyang.mes.basedata.workcell.entity.WorkCell;
import com.wangziyang.mes.basedata.workcell.mapper.WorkCellMapper;
import com.wangziyang.mes.basedata.workcell.service.IWorkCellService;
import org.springframework.stereotype.Service;

/**
 * 加工单元定义 服务实现类
 *
 * @author WangZiyang
 * @since 2021-03-10
 */
@Service
public class WorkCellServiceImpl extends ServiceImpl<WorkCellMapper, WorkCell> implements IWorkCellService {
}
