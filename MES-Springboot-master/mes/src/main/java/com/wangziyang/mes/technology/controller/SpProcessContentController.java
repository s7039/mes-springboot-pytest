package com.wangziyang.mes.technology.controller;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.wangziyang.mes.common.BaseController;
import com.wangziyang.mes.common.Result;
import com.wangziyang.mes.technology.entity.*;
import com.wangziyang.mes.technology.service.*;
import io.swagger.annotations.ApiOperation;
import org.apache.commons.lang3.StringUtils;
import org.apache.shiro.authz.annotation.RequiresPermissions;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.*;

@Controller
@RequestMapping("/technology/process/content")
public class SpProcessContentController extends BaseController {

    private final Logger log = LoggerFactory.getLogger(SpProcessContentController.class);

    @Value("${web.upload-path:src/main/resources/static/upload/}")
    private String uploadPath;

    @Autowired
    private ISpProcessContentService spProcessContentService;

    @Autowired
    private com.wangziyang.mes.technology.service.ISpProcessContentOperService spProcessContentOperService;

    @Autowired
    private com.wangziyang.mes.technology.service.ISpProcessContentDeviceService spProcessContentDeviceService;

    @Autowired
    private com.wangziyang.mes.technology.service.ISpProcessContentMaterialService spProcessContentMaterialService;

    @Autowired
    private ISpProductProcessService spProductProcessService;

    @Autowired
    private ISpProductProcessItemService spProductProcessItemService;

    @Autowired
    private com.wangziyang.mes.basedata.device.service.ISpDeviceService iSpDeviceService;

    @Autowired
    private com.wangziyang.mes.basedata.service.ISpMaterileService iSpMaterileService;

    // ==================== 列表页 ====================

    @GetMapping("/list-ui")
    public String listUI(Model model) {
        return "technology/process/content/list";
    }

    @PostMapping("/page")
    @ResponseBody
    public Result page(com.wangziyang.mes.technology.request.SpProductProcessReq req) {
        QueryWrapper<SpProcessContent> qw = new QueryWrapper<>();
        if (StringUtils.isNotEmpty(req.getMaterielCodeLike())) {
            qw.like("materiel_code", req.getMaterielCodeLike());
        }
        if (StringUtils.isNotEmpty(req.getMaterielDescLike())) {
            qw.like("materiel_desc", req.getMaterielDescLike());
        }
        Page<SpProcessContent> page = new Page<>(req.getCurrent(), req.getSize());
        IPage<SpProcessContent> result = spProcessContentService.page(page, qw);
        return Result.success(result);
    }

    // ==================== 获取可编制的工艺规划列表 ====================

    @PostMapping("/available-process")
    @ResponseBody
    public Result availableProcess() {
        QueryWrapper<SpProductProcess> qw = new QueryWrapper<>();
        qw.eq("locked", "1");
        List<SpProductProcess> list = spProductProcessService.list(qw);
        return Result.success(list);
    }

    // ==================== 开始编制 ====================

    @GetMapping("/edit-ui")
    public String editUI(Model model, String processId, String id) {
        if (StringUtils.isNotEmpty(id)) {
            SpProcessContent content = spProcessContentService.getById(id);
            model.addAttribute("content", content);
            processId = content.getProcessId();
        }
        if (StringUtils.isNotEmpty(processId)) {
            SpProductProcess process = spProductProcessService.getById(processId);
            model.addAttribute("process", process);

            // 加载工艺规划下的工序明细
            QueryWrapper<SpProductProcessItem> qw = new QueryWrapper<>();
            qw.eq("process_id", processId);
            qw.orderByAsc("bom_level", "sort_num");
            List<SpProductProcessItem> items = spProductProcessItemService.list(qw);
            model.addAttribute("items", items);

            // 加载已编制的工序内容
            java.util.Map<String, String> processItemToContentOperMap = new java.util.HashMap<>();
            if (StringUtils.isNotEmpty(id)) {
                QueryWrapper<SpProcessContentOper> operQw = new QueryWrapper<>();
                operQw.eq("content_id", id);
                operQw.orderByAsc("sort_num");
                List<SpProcessContentOper> opers = spProcessContentOperService.list(operQw);
                model.addAttribute("contentOpers", opers);
                // 构建 SpProductProcessItem.id → SpProcessContentOper.id 映射
                for (SpProcessContentOper oper : opers) {
                    processItemToContentOperMap.put(oper.getProcessItemId(), oper.getId());
                }
            }
            model.addAttribute("processItemToContentOperMap", processItemToContentOperMap);
        }
        return "technology/process/content/edit";
    }

    /**
     * 开始编制：创建工艺编制头，并初始化工序内容
     */
    @PostMapping("/start")
    @ResponseBody
    @RequiresPermissions("user:add")
    public Result start(String processId) {
        try {
            SpProductProcess process = spProductProcessService.getById(processId);
            if (process == null) {
                return Result.failure("工艺规划不存在");
            }

            // 创建编制头
            SpProcessContent content = new SpProcessContent();
            content.setProcessId(processId);
            content.setBomId(process.getBomId());
            content.setBomCode(process.getBomCode());
            content.setMaterielCode(process.getMaterielCode());
            content.setMaterielDesc(process.getMaterielDesc());
            content.setStatus("0");
            spProcessContentService.save(content);

            // 从工艺规划明细初始化工序内容
            QueryWrapper<SpProductProcessItem> qw = new QueryWrapper<>();
            qw.eq("process_id", processId);
            qw.orderByAsc("bom_level", "sort_num");
            List<SpProductProcessItem> items = spProductProcessItemService.list(qw);

            int sort = 1;
            for (SpProductProcessItem item : items) {
                SpProcessContentOper oper = new SpProcessContentOper();
                oper.setContentId(content.getId());
                oper.setProcessItemId(item.getId());
                oper.setOperId(item.getOperId());
                oper.setOper(item.getOper());
                oper.setOperDesc(item.getOperDesc());
                oper.setBomLevel(item.getBomLevel());
                oper.setMaterielItemCode(item.getMaterielItemCode());
                oper.setMaterielItemDesc(item.getMaterielItemDesc());
                oper.setContentText("");
                oper.setImages("[]");
                oper.setSortNum(sort++);
                oper.setStatus("0");
                spProcessContentOperService.save(oper);
            }

            Map<String, Object> result = new HashMap<>();
            result.put("id", content.getId());
            return Result.success(result);
        } catch (Exception e) {
            log.error("开始编制失败", e);
            return Result.failure("开始编制失败：" + e.getMessage());
        }
    }

    // ==================== 获取单道工序内容 ====================

    @GetMapping("/get-oper")
    @ResponseBody
    public Result getOper(String id) {
        if (StringUtils.isEmpty(id)) {
            return Result.success(new SpProcessContentOper());
        }
        SpProcessContentOper oper = spProcessContentOperService.getById(id);
        return Result.success(oper);
    }

    // ==================== 保存工序内容 ====================

    @PostMapping("/save-oper")
    @ResponseBody
    @RequiresPermissions("user:add")
    public Result saveOper(@RequestBody SpProcessContentOper oper) {
        try {
            if (StringUtils.isNotEmpty(oper.getContentText())) {
                oper.setStatus("1");
            }
            spProcessContentOperService.saveOrUpdate(oper);
            return Result.success();
        } catch (Exception e) {
            return Result.failure("保存工序内容失败：" + e.getMessage());
        }
    }

    // ==================== 上传工序图片 ====================

    @PostMapping("/upload-image")
    @ResponseBody
    @RequiresPermissions("user:add")
    public Result uploadImage(@RequestParam("file") MultipartFile file) {
        if (file.isEmpty()) {
            return Result.failure("请选择要上传的图片");
        }
        try {
            BufferedImage image = ImageIO.read(file.getInputStream());
            if (image == null) {
                return Result.failure("上传的文件不是有效的图片格式");
            }
            String originalFilename = file.getOriginalFilename();
            String ext = originalFilename.substring(originalFilename.lastIndexOf("."));
            String fileName = UUID.randomUUID().toString().replaceAll("-", "") + ext;
            String dateDir = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyy/MM/dd"));
            File destDir = new File(uploadPath + dateDir);
            if (!destDir.exists()) {
                destDir.mkdirs();
            }
            File destFile = new File(destDir, fileName);
            file.transferTo(destFile);
            String fileUrl = "/upload/" + dateDir + "/" + fileName;
            return Result.success(fileUrl);
        } catch (IOException e) {
            log.error("图片上传失败", e);
            return Result.failure("图片上传失败");
        }
    }

    // ==================== 工装设备管理 ====================

    @PostMapping("/device-list")
    @ResponseBody
    public Result deviceList(String contentOperId) {
        QueryWrapper<SpProcessContentDevice> qw = new QueryWrapper<>();
        qw.eq("content_oper_id", contentOperId);
        List<SpProcessContentDevice> list = spProcessContentDeviceService.list(qw);
        return Result.success(list);
    }

    @PostMapping("/device-all")
    @ResponseBody
    public Result deviceAll() {
        QueryWrapper<com.wangziyang.mes.basedata.device.entity.SpDevice> qw = new QueryWrapper<>();
        qw.ne("is_deleted", "1");
        List<com.wangziyang.mes.basedata.device.entity.SpDevice> list = iSpDeviceService.list(qw);
        return Result.success(list);
    }

    @PostMapping("/device-add")
    @ResponseBody
    @RequiresPermissions("user:add")
    public Result deviceAdd(@RequestBody SpProcessContentDevice device) {
        try {
            spProcessContentDeviceService.saveOrUpdate(device);
            return Result.success();
        } catch (Exception e) {
            return Result.failure("添加工装设备失败：" + e.getMessage());
        }
    }

    @PostMapping("/device-delete")
    @ResponseBody
    @RequiresPermissions("user:add")
    public Result deviceDelete(String id) {
        spProcessContentDeviceService.removeById(id);
        return Result.success();
    }

    // ==================== 工序物料管理 ====================

    @PostMapping("/material-list")
    @ResponseBody
    public Result materialList(String contentOperId) {
        QueryWrapper<SpProcessContentMaterial> qw = new QueryWrapper<>();
        qw.eq("content_oper_id", contentOperId);
        List<SpProcessContentMaterial> list = spProcessContentMaterialService.list(qw);
        if (list.isEmpty()) {
            // 自动从BOM物料信息填充
            SpProcessContentOper oper = spProcessContentOperService.getById(contentOperId);
            if (oper != null && org.apache.commons.lang3.StringUtils.isNotEmpty(oper.getMaterielItemCode())) {
                SpProcessContentMaterial mat = new SpProcessContentMaterial();
                mat.setContentId(oper.getContentId());
                mat.setContentOperId(contentOperId);
                mat.setMaterielCode(oper.getMaterielItemCode());
                mat.setMaterielDesc(oper.getMaterielItemDesc());
                // 从物料表查单位
                com.wangziyang.mes.basedata.entity.SpMaterile materile = iSpMaterileService.getOne(
                        new QueryWrapper<com.wangziyang.mes.basedata.entity.SpMaterile>()
                                .eq("materiel", oper.getMaterielItemCode())
                                .last("LIMIT 1")
                );
                if (materile != null) {
                    mat.setUnit(materile.getUnit());
                }
                mat.setRequiredQty(java.math.BigDecimal.ONE);
                list.add(mat);
            }
        }
        return Result.success(list);
    }

    @PostMapping("/material-save")
    @ResponseBody
    @RequiresPermissions("user:add")
    public Result materialSave(@RequestBody SpProcessContentMaterial material) {
        try {
            spProcessContentMaterialService.saveOrUpdate(material);
            return Result.success();
        } catch (Exception e) {
            return Result.failure("保存物料失败：" + e.getMessage());
        }
    }

    // ==================== 完成编制 ====================

    @PostMapping("/complete")
    @ResponseBody
    @RequiresPermissions("user:add")
    public Result complete(String id) {
        try {
            SpProcessContent content = spProcessContentService.getById(id);
            if (content == null) {
                return Result.failure("编制记录不存在");
            }
            content.setStatus("1");
            spProcessContentService.updateById(content);
            return Result.success(null, "工艺编制完成");
        } catch (Exception e) {
            return Result.failure("完成编制失败：" + e.getMessage());
        }
    }

    // ==================== 删除 ====================

    @PostMapping("/delete")
    @ResponseBody
    @RequiresPermissions("user:add")
    public Result delete(String id) {
        try {
            // 删除工序物料
            QueryWrapper<SpProcessContentMaterial> matQw = new QueryWrapper<>();
            matQw.eq("content_id", id);
            spProcessContentMaterialService.remove(matQw);
            // 删除工序设备
            QueryWrapper<SpProcessContentDevice> devQw = new QueryWrapper<>();
            devQw.eq("content_id", id);
            spProcessContentDeviceService.remove(devQw);
            // 删除工序内容
            QueryWrapper<SpProcessContentOper> operQw = new QueryWrapper<>();
            operQw.eq("content_id", id);
            spProcessContentOperService.remove(operQw);
            // 删除头表
            spProcessContentService.removeById(id);
            return Result.success();
        } catch (Exception e) {
            return Result.failure("删除失败：" + e.getMessage());
        }
    }
}
