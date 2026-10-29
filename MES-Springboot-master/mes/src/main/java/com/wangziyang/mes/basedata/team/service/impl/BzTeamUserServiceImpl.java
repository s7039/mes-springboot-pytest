package com.wangziyang.mes.basedata.team.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.wangziyang.mes.basedata.team.entity.BzTeamUser;
import com.wangziyang.mes.basedata.team.mapper.BzTeamUserMapper;
import com.wangziyang.mes.basedata.team.service.IBzTeamUserService;
import org.springframework.stereotype.Service;

/**
 * 班组-员工关联 Service 实现
 *
 * @author WangZiyang
 * @since 2021-02-25
 */
@Service
public class BzTeamUserServiceImpl extends ServiceImpl<BzTeamUserMapper, BzTeamUser> implements IBzTeamUserService {

}
