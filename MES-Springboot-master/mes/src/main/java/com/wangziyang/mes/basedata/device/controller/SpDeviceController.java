package com.wangziyang.mes.basedata.device.controller;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.wangziyang.mes.basedata.device.entity.SpDevice;
import com.wangziyang.mes.basedata.device.request.SpDeviceReq;
import com.wangziyang.mes.basedata.device.service.ISpDeviceService;
import com.wangziyang.mes.common.BaseController;
import com.wangziyang.mes.common.Result;
import io.swagger.annotations.ApiOperation;
import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.apache.shiro.authz.annotation.RequiresPermissions;

import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

/**
 * 设备定义前端控制器
 *
 * @author WangZiYang
 * @since 2021-03-01
 */
@Controller
@RequestMapping("/admin/sys/device")
public class SpDeviceController extends BaseController {

    @Autowired
    private ISpDeviceService iSpDeviceService;

    @ApiOperation("设备定义界面UI")
    @GetMapping("/list-ui")
    public String listUI(Model model) {
        return "admin/system/device/list";
    }

    @ApiOperation("设备新增/修改界面")
    @GetMapping("/add-or-update-ui")
    public String addOrUpdateUI(Model model, SpDevice spDevice) {
        if (StringUtils.isNotEmpty(spDevice.getId())) {
            SpDevice result = iSpDeviceService.getById(spDevice.getId());
            model.addAttribute("result", result);
        }
        return "admin/system/device/addOrUpdate";
    }

    /**
     * 生成设备编号（新增时预先展示）
     * 格式：ShB00001、ShB00002 依次递增，自动回收已删除的编号
     */
    @ApiOperation("生成设备编号")
    @GetMapping("/generate-code")
    @ResponseBody
    public Result generateCode() {
        return Result.success(generateDeviceCode());
    }

    @ApiOperation("设备分页查询")
    @PostMapping("/page")
    @ResponseBody
    public Result page(SpDeviceReq req) {
        QueryWrapper<SpDevice> qw = new QueryWrapper<>();
        if (StringUtils.isNotEmpty(req.getDeviceCodeLike())) {
            qw.like("device_code", req.getDeviceCodeLike());
        }
        if (StringUtils.isNotEmpty(req.getDeviceNameLike())) {
            qw.like("device_name", req.getDeviceNameLike());
        }
        qw.orderByDesc("update_time");
        IPage<SpDevice> result = iSpDeviceService.page(req, qw);
        return Result.success(result);
    }

    @ApiOperation("设备新增/修改")
    @PostMapping("/add-or-update")
    @ResponseBody
    @RequiresPermissions("user:add")
    public Result addOrUpdate(SpDevice spDevice) {
        // 新增时自动生成设备编号（ShB 格式 + 回收）
        if (StringUtils.isEmpty(spDevice.getId()) && StringUtils.isEmpty(spDevice.getDeviceCode())) {
            spDevice.setDeviceCode(generateDeviceCode());
        }
        if (StringUtils.isEmpty(spDevice.getId())) {
            spDevice.setDeleted("0");
        }
        iSpDeviceService.saveOrUpdate(spDevice);
        return Result.success();
    }

    /**
     * 生成设备编号：ShB00001、ShB00002 依次递增
     * 自动回收：查询所有未删除的 ShB 编号，从 1 开始找最小未使用编号，被删除设备的编号可再次分配
     *
     * @return 新的设备编号
     */
    private String generateDeviceCode() {
        QueryWrapper<SpDevice> wrapper = new QueryWrapper<>();
        wrapper.likeRight("device_code", "ShB");
        List<SpDevice> list = iSpDeviceService.list(wrapper);
        Set<Integer> usedNums = new HashSet<>();
        for (SpDevice device : list) {
            String code = device.getDeviceCode();
            if (code != null && code.length() > 3) {
                String numStr = code.substring(3);
                if (numStr.matches("\\d+")) {
                    usedNums.add(Integer.parseInt(numStr));
                }
            }
        }
        int seq = 1;
        while (usedNums.contains(seq)) {
            seq++;
        }
        return "ShB" + String.format("%05d", seq);
    }

    @ApiOperation("删除设备")
    @PostMapping("/delete")
    @ResponseBody
    @RequiresPermissions("user:add")
    public Result delete(SpDevice spDevice) {
        iSpDeviceService.removeById(spDevice.getId());
        return Result.success();
    }

    @ApiOperation("批量删除设备")
    @PostMapping("/delete-batch")
    @ResponseBody
    @RequiresPermissions("user:add")
    public Result deleteBatch(String ids) {
        if (StringUtils.isEmpty(ids)) {
            return Result.failure("请选择需要删除的数据");
        }
        List<String> idList = Arrays.asList(ids.split(","));
        iSpDeviceService.removeByIds(idList);
        return Result.success();
    }
}
