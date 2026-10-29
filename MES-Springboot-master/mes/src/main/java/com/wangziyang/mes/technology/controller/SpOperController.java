package com.wangziyang.mes.technology.controller;


import cn.hutool.core.util.StrUtil;
import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.wangziyang.mes.common.BaseController;
import com.wangziyang.mes.common.Result;
import com.wangziyang.mes.technology.entity.SpOper;
import com.wangziyang.mes.technology.request.SpOperReq;
import com.wangziyang.mes.technology.service.ISpOperService;
import io.swagger.annotations.ApiImplicitParam;
import io.swagger.annotations.ApiImplicitParams;
import io.swagger.annotations.ApiOperation;
import org.apache.commons.lang3.StringUtils;
import org.apache.shiro.authz.annotation.RequiresPermissions;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import java.util.HashSet;
import java.util.List;
import java.util.Set;

/**
 * <p>
 * 工序信息定义 前端控制器
 * </p>
 *
 * @author WangZiYang
 * @since 2020-03-14
 */
@Controller
@RequestMapping("/basedata/sp-oper")
public class SpOperController extends BaseController {

    @Autowired
    private ISpOperService iSpOperService;

    /**
     * 工序信息定义管理界面
     */
    @ApiOperation("工序信息定义管理界面UI")
    @ApiImplicitParams({@ApiImplicitParam(name = "model", value = "模型", defaultValue = "模型")})
    @GetMapping("/list-ui")
    public String listUI(Model model) {
        return "technology/oper/list";
    }

    /**
     * 工序信息定义新增/修改界面
     */
    @ApiOperation("工序信息定义新增/修改界面")
    @GetMapping("/add-or-update-ui")
    public String addOrUpdateUI(Model model, SpOper record) {
        if (StringUtils.isNotEmpty(record.getId())) {
            SpOper result = iSpOperService.getById(record.getId());
            model.addAttribute("result", result);
        }
        return "technology/oper/addOrUpdate";
    }

    /**
     * 生成工序编号（新增时预先展示）
     * 格式：GX00000001、GX00000002 依次递增，自动回收已删除的编号
     */
    @ApiOperation("生成工序编号")
    @GetMapping("/generate-code")
    @ResponseBody
    public Result generateCode() {
        return Result.success(generateOperCode());
    }

    /**
     * 获取单条工序信息
     */
    @ApiOperation("获取单条工序信息")
    @GetMapping("/get")
    @ResponseBody
    public Result get(String id) {
        if (StringUtils.isEmpty(id)) {
            return Result.failure("参数不能为空");
        }
        SpOper result = iSpOperService.getById(id);
        return Result.success(result);
    }

    /**
     * 工序信息定义分页查询
     */
    @ApiOperation("工序信息定义分页查询")
    @PostMapping("/page")
    @ResponseBody
    public Result page(SpOperReq req) {
        QueryWrapper<SpOper> qw = new QueryWrapper<>();
        qw.ne("is_deleted", "1");
        if (StringUtils.isNotEmpty(req.getOperLike())) {
            qw.like("oper", req.getOperLike());
        }
        if (StringUtils.isNotEmpty(req.getOperDescLike())) {
            qw.like("oper_desc", req.getOperDescLike());
        }
        IPage<SpOper> result = iSpOperService.page(req, qw);
        return Result.success(result);
    }

    /**
     * 工序信息定义新增、修改
     */
    @ApiOperation("工序信息定义新增、修改")
    @PostMapping("/add-or-update")
    @ResponseBody
    @RequiresPermissions("user:add")
    public Result addOrUpdate(SpOper record) {
        // 新增时自动生成工序编号（GX 格式 + 回收）
        if (StrUtil.isBlank(record.getId()) && StrUtil.isBlank(record.getOper())) {
            record.setOper(generateOperCode());
        }
        // 制造周期一般要大于工时，如果不填制造周期则默认等于工时
        if (record.getManufacturingCycle() == null && record.getWorkingHours() != null) {
            record.setManufacturingCycle(record.getWorkingHours());
        }
        iSpOperService.saveOrUpdate(record);
        return Result.success();
    }

    /**
     * 删除工序（物理删除：删除后记录消失，编号可回收）
     */
    @ApiOperation("删除工序")
    @PostMapping("/delete")
    @ResponseBody
    @RequiresPermissions("user:add")
    public Result delete(SpOper record) {
        iSpOperService.removeById(record.getId());
        return Result.success();
    }

    /**
     * 批量删除工序（物理删除）
     */
    @ApiOperation("批量删除工序")
    @PostMapping("/delete-batch")
    @ResponseBody
    @RequiresPermissions("user:add")
    public Result deleteBatch(String ids) {
        if (StringUtils.isEmpty(ids)) {
            return Result.failure("请选择需要删除的数据");
        }
        String[] idArr = ids.split(",");
        for (String id : idArr) {
            if (StringUtils.isEmpty(id)) {
                continue;
            }
            iSpOperService.removeById(id);
        }
        return Result.success();
    }

    /**
     * 生成工序编号：GX00000001、GX00000002 依次递增
     * 自动回收：查询所有未删除的 GX 编码，从 1 开始找最小未使用编号，被删除工序的编号可再次分配
     *
     * @return 新的工序编号
     */
    private String generateOperCode() {
        QueryWrapper<SpOper> wrapper = new QueryWrapper<>();
        wrapper.likeRight("oper", "GX");
        // 排除已逻辑删除的工序，其编号可被回收重新分配
        wrapper.ne("is_deleted", "1");
        List<SpOper> list = iSpOperService.list(wrapper);
        Set<Integer> usedNums = new HashSet<>();
        for (SpOper oper : list) {
            String code = oper.getOper();
            if (code != null && code.length() > 2) {
                String numStr = code.substring(2);
                if (numStr.matches("\\d+")) {
                    usedNums.add(Integer.parseInt(numStr));
                }
            }
        }
        int seq = 1;
        while (usedNums.contains(seq)) {
            seq++;
        }
        return "GX" + String.format("%08d", seq);
    }
}
