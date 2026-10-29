package com.wangziyang.mes.basedata.device.controller;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.wangziyang.mes.basedata.device.entity.SpDevice;
import com.wangziyang.mes.basedata.device.entity.SpDeviceGroup;
import com.wangziyang.mes.basedata.device.entity.SpDeviceGroupItem;
import com.wangziyang.mes.basedata.device.request.SpDeviceGroupReq;
import com.wangziyang.mes.basedata.device.service.ISpDeviceGroupItemService;
import com.wangziyang.mes.basedata.device.service.ISpDeviceGroupService;
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

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

/**
 * 设备编组前端控制器
 *
 * @author WangZiYang
 * @since 2021-03-01
 */
@Controller
@RequestMapping("/admin/sys/deviceGroup")
public class SpDeviceGroupController extends BaseController {

    @Autowired
    private ISpDeviceGroupService iSpDeviceGroupService;

    @Autowired
    private ISpDeviceGroupItemService iSpDeviceGroupItemService;

    @Autowired
    private ISpDeviceService iSpDeviceService;

    @ApiOperation("设备编组设备管理界面UI")
    @GetMapping("/device-manage-ui")
    public String deviceManageUI(Model model, SpDeviceGroup spDeviceGroup) {
        if (StringUtils.isNotEmpty(spDeviceGroup.getId())) {
            SpDeviceGroup result = iSpDeviceGroupService.getById(spDeviceGroup.getId());
            model.addAttribute("result", result);
        }
        return "admin/system/deviceGroup/deviceManage";
    }

    @ApiOperation("查询编组可用设备列表（未加入该编组且未禁用的设备）")
    @PostMapping("/available-device-page")
    @ResponseBody
    public Result availableDevicePage(String groupId) {
        // 查询已在该编组中的设备ID
        QueryWrapper<SpDeviceGroupItem> itemQw = new QueryWrapper<>();
        itemQw.eq("group_id", groupId);
        List<SpDeviceGroupItem> itemList = iSpDeviceGroupItemService.list(itemQw);
        List<String> deviceIds = new ArrayList<>();
        for (SpDeviceGroupItem item : itemList) {
            deviceIds.add(item.getDeviceId());
        }

        // 查询未加入该编组且未禁用的设备
        QueryWrapper<SpDevice> deviceQw = new QueryWrapper<>();
        deviceQw.eq("is_deleted", "0");
        if (!deviceIds.isEmpty()) {
            deviceQw.notIn("id", deviceIds);
        }
        deviceQw.orderByDesc("update_time");
        List<SpDevice> deviceList = iSpDeviceService.list(deviceQw);
        return Result.success(deviceList);
    }

    @ApiOperation("设备编组界面UI")
    @GetMapping("/list-ui")
    public String listUI(Model model) {
        return "admin/system/deviceGroup/list";
    }

    /**
     * 生成编组代码（新增时预先展示）
     * 格式：BZS0001、BZS0002 依次递增，自动回收已删除的编号
     */
    @ApiOperation("生成编组代码")
    @GetMapping("/generate-code")
    @ResponseBody
    public Result generateCode() {
        return Result.success(generateGroupCode());
    }

    @ApiOperation("设备编组新增/修改界面")
    @GetMapping("/add-or-update-ui")
    public String addOrUpdateUI(Model model, SpDeviceGroup spDeviceGroup) {
        if (StringUtils.isNotEmpty(spDeviceGroup.getId())) {
            SpDeviceGroup result = iSpDeviceGroupService.getById(spDeviceGroup.getId());
            model.addAttribute("result", result);
        }
        return "admin/system/deviceGroup/addOrUpdate";
    }

    @ApiOperation("设备编组分页查询")
    @PostMapping("/page")
    @ResponseBody
    public Result page(SpDeviceGroupReq req) {
        QueryWrapper<SpDeviceGroup> qw = new QueryWrapper<>();
        if (StringUtils.isNotEmpty(req.getGroupCodeLike())) {
            qw.like("group_code", req.getGroupCodeLike());
        }
        if (StringUtils.isNotEmpty(req.getGroupNameLike())) {
            qw.like("group_name", req.getGroupNameLike());
        }
        qw.orderByDesc("update_time");
        IPage<SpDeviceGroup> result = iSpDeviceGroupService.page(req, qw);
        // 状态联动：若编组内存在被禁用的设备，则编组状态显示为异常
        for (SpDeviceGroup group : result.getRecords()) {
            if (!"2".equals(group.getDeleted()) && isGroupDeviceAbnormal(group.getId())) {
                group.setDeleted("2");
            }
        }
        return Result.success(result);
    }

    /**
     * 判断编组内是否存在被禁用的设备
     *
     * @param groupId 编组ID
     * @return true 存在禁用设备
     */
    private boolean isGroupDeviceAbnormal(String groupId) {
        QueryWrapper<SpDeviceGroupItem> itemQw = new QueryWrapper<>();
        itemQw.eq("group_id", groupId);
        List<SpDeviceGroupItem> itemList = iSpDeviceGroupItemService.list(itemQw);
        for (SpDeviceGroupItem item : itemList) {
            SpDevice device = iSpDeviceService.getById(item.getDeviceId());
            if (device != null && "1".equals(device.getDeleted())) {
                return true;
            }
        }
        return false;
    }

    @ApiOperation("设备编组新增/修改")
    @PostMapping("/add-or-update")
    @ResponseBody
    @RequiresPermissions("user:add")
    public Result addOrUpdate(SpDeviceGroup spDeviceGroup) {
        // 新增时自动生成编组代码（BZS 格式 + 回收）
        if (StringUtils.isEmpty(spDeviceGroup.getId()) && StringUtils.isEmpty(spDeviceGroup.getGroupCode())) {
            spDeviceGroup.setGroupCode(generateGroupCode());
        }
        if (StringUtils.isEmpty(spDeviceGroup.getId())) {
            spDeviceGroup.setDeleted("0");
        }
        iSpDeviceGroupService.saveOrUpdate(spDeviceGroup);
        return Result.success();
    }

    /**
     * 生成编组代码：BZS0001、BZS0002 依次递增
     * 自动回收：查询所有未删除的 BZS 编号，从 1 开始找最小未使用编号，被删除编组的编号可再次分配
     *
     * @return 新的编组代码
     */
    private String generateGroupCode() {
        QueryWrapper<SpDeviceGroup> wrapper = new QueryWrapper<>();
        wrapper.likeRight("group_code", "BZS");
        List<SpDeviceGroup> list = iSpDeviceGroupService.list(wrapper);
        Set<Integer> usedNums = new HashSet<>();
        for (SpDeviceGroup group : list) {
            String code = group.getGroupCode();
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
        return "BZS" + String.format("%04d", seq);
    }

    @ApiOperation("删除设备编组")
    @PostMapping("/delete")
    @ResponseBody
    @RequiresPermissions("user:add")
    public Result delete(SpDeviceGroup spDeviceGroup) {
        // 删除编组同时删除关联的设备关系
        QueryWrapper<SpDeviceGroupItem> qw = new QueryWrapper<>();
        qw.eq("group_id", spDeviceGroup.getId());
        iSpDeviceGroupItemService.remove(qw);
        iSpDeviceGroupService.removeById(spDeviceGroup.getId());
        return Result.success();
    }

    @ApiOperation("批量删除设备编组")
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
            // 删除编组同时删除关联的设备关系
            QueryWrapper<SpDeviceGroupItem> qw = new QueryWrapper<>();
            qw.eq("group_id", id);
            iSpDeviceGroupItemService.remove(qw);
            iSpDeviceGroupService.removeById(id);
        }
        return Result.success();
    }

    @ApiOperation("查询编组下的设备列表")
    @PostMapping("/group-device-page")
    @ResponseBody
    public Result groupDevicePage(String groupId) {
        // 查询编组下的设备关联
        QueryWrapper<SpDeviceGroupItem> qw = new QueryWrapper<>();
        qw.eq("group_id", groupId);
        List<SpDeviceGroupItem> itemList = iSpDeviceGroupItemService.list(qw);

        // 获取设备详情
        List<SpDevice> deviceList = new ArrayList<>();
        for (SpDeviceGroupItem item : itemList) {
            SpDevice device = iSpDeviceService.getById(item.getDeviceId());
            if (device != null) {
                deviceList.add(device);
            }
        }
        return Result.success(deviceList);
    }

    @ApiOperation("编组添加设备")
    @PostMapping("/add-device")
    @ResponseBody
    @RequiresPermissions("user:add")
    public Result addDevice(String groupId, String deviceId) {
        // 校验设备状态：被禁用的设备无法加入编组
        SpDevice device = iSpDeviceService.getById(deviceId);
        if (device == null) {
            return Result.failure("设备不存在");
        }
        if ("1".equals(device.getDeleted())) {
            return Result.failure("设备【" + device.getDeviceCode() + "】已被禁用，无法加入编组");
        }
        // 检查是否已存在
        QueryWrapper<SpDeviceGroupItem> qw = new QueryWrapper<>();
        qw.eq("group_id", groupId);
        qw.eq("device_id", deviceId);
        SpDeviceGroupItem exist = iSpDeviceGroupItemService.getOne(qw);
        if (exist != null) {
            return Result.failure("该设备已在编组中");
        }

        SpDeviceGroupItem item = new SpDeviceGroupItem();
        item.setGroupId(groupId);
        item.setDeviceId(deviceId);
        iSpDeviceGroupItemService.save(item);
        return Result.success();
    }

    @ApiOperation("编组移除设备")
    @PostMapping("/remove-device")
    @ResponseBody
    @RequiresPermissions("user:add")
    public Result removeDevice(String groupId, String deviceId) {
        QueryWrapper<SpDeviceGroupItem> qw = new QueryWrapper<>();
        qw.eq("group_id", groupId);
        qw.eq("device_id", deviceId);
        iSpDeviceGroupItemService.remove(qw);
        return Result.success();
    }
}
