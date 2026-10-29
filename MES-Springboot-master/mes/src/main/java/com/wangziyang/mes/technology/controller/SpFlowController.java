package com.wangziyang.mes.technology.controller;


import cn.hutool.core.util.StrUtil;
import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.wangziyang.mes.common.BaseController;
import com.wangziyang.mes.common.Result;
import com.wangziyang.mes.technology.entity.SpFlow;
import com.wangziyang.mes.technology.request.SpFlowReq;
import com.wangziyang.mes.technology.service.ISpFlowOperRelationService;
import com.wangziyang.mes.technology.service.ISpFlowService;
import io.swagger.annotations.ApiImplicitParam;
import io.swagger.annotations.ApiImplicitParams;
import io.swagger.annotations.ApiOperation;
import org.apache.commons.lang3.StringUtils;
import org.apache.shiro.authz.annotation.RequiresPermissions;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import java.util.HashSet;
import java.util.List;
import java.util.Set;

/**
 * <p>
 * 流程控制器
 * </p>
 *
 * @author WangZiYang
 * @since 2020-03-14
 */
@Controller
@RequestMapping("/basedata/flow")
public class SpFlowController extends BaseController {

    @Autowired
    public ISpFlowService iSpFlowService;

    @Autowired
    public ISpFlowOperRelationService iSpFlowOperRelationService;

    /**
     * 流程信息分页查询
     *
     * @param req 请求参数
     * @return Result 执行结果
     */
    @ApiOperation("流程信息分页查询")
    @ApiImplicitParams({@ApiImplicitParam(name = "req", value = "请求参数", defaultValue = "请求参数")})
    @PostMapping("/page")
    @ResponseBody
    public Result page(SpFlowReq req) {
        QueryWrapper<SpFlow> qw = new QueryWrapper<>();
        if (StringUtils.isNotEmpty(req.getFlowLike())) {
            qw.like("flow", req.getFlowLike());
        }
        IPage<SpFlow> result = iSpFlowService.page(req, qw);
        return Result.success(result);
    }


    /**
     * 流程全部信息查询
     *
     * @return Result 执行结果
     */
    @ApiOperation("流程全部信息查询")
    @GetMapping("/list")
    @ResponseBody
    public Result list() {
        QueryWrapper queryWrapper = new QueryWrapper();
        //queryWrapper.eq("is_deleted", "0");
        List<SpFlow> list = iSpFlowService.list(queryWrapper);
        return Result.success(list);
    }

    /**
     * 生成路线编码：LX0001、LX0002 依次递增，自动回收已删除的编号
     *
     * @return 新路线编码
     */
    @ApiOperation("生成路线编码")
    @GetMapping("/generate-code")
    @ResponseBody
    public Result generateCode() {
        return Result.success(generateFlowCode());
    }

    /**
     * 批量删除路线（物理删除，级联删除流程工序关系）
     *
     * @param ids 逗号分隔的路线ID
     * @return 执行结果
     */
    @ApiOperation("批量删除路线")
    @PostMapping("/delete-batch")
    @ResponseBody
    @RequiresPermissions("user:add")
    public Result deleteBatch(String ids) {
        if (StrUtil.isBlank(ids)) {
            return Result.failure("请选择要删除的数据");
        }
        String[] idArr = ids.split(",");
        for (String id : idArr) {
            if (StrUtil.isBlank(id)) {
                continue;
            }
            // 物理删除路线头表
            iSpFlowService.removeById(id);
            // 删除流程工序关系
            QueryWrapper qw = new QueryWrapper();
            qw.eq("flow_id", id);
            iSpFlowOperRelationService.remove(qw);
        }
        return Result.success();
    }

    /**
     * 生成路线编码（LX0001格式，自动回收已删除编号）
     *
     * @return 新路线编码
     */
    private String generateFlowCode() {
        QueryWrapper<SpFlow> wrapper = new QueryWrapper<>();
        wrapper.likeRight("flow", "LX");
        List<SpFlow> list = iSpFlowService.list(wrapper);
        Set<Integer> usedNums = new HashSet<>();
        for (SpFlow f : list) {
            String code = f.getFlow();
            if (code != null && code.length() > 2) {
                String numStr = code.substring(2);
                if (numStr.matches("\\d+")) {
                    usedNums.add(Integer.parseInt(numStr));
                }
            }
        }
        // 从 1 开始查找最小的未使用编号，实现编码回收
        int seq = 1;
        while (usedNums.contains(seq)) {
            seq++;
        }
        return "LX" + String.format("%04d", seq);
    }

}
