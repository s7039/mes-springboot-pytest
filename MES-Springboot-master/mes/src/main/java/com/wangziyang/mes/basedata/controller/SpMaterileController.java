package com.wangziyang.mes.basedata.controller;


import cn.hutool.core.util.StrUtil;
import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.wangziyang.mes.basedata.entity.SpMaterile;
import com.wangziyang.mes.basedata.entity.SpTableManager;
import com.wangziyang.mes.basedata.request.spMaterileReq;
import com.wangziyang.mes.basedata.service.ISpMaterileService;
import com.wangziyang.mes.common.BaseController;
import com.wangziyang.mes.common.Result;
import com.wangziyang.mes.technology.entity.SpFlow;
import com.wangziyang.mes.technology.service.ISpFlowService;
import io.swagger.annotations.ApiImplicitParam;
import io.swagger.annotations.ApiImplicitParams;
import io.swagger.annotations.ApiOperation;
import org.apache.commons.lang3.StringUtils;
import org.apache.shiro.authz.annotation.RequiresPermissions;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;

import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Objects;
import java.util.Set;
import java.util.UUID;

/**
 * <p>
 * 物料控制器
 * </p>
 *
 * @author WangZiYang
 * @since 2020-03-19
 */
@Controller
@RequestMapping("/basedata/materile")
public class SpMaterileController extends BaseController {

    Logger logger = LoggerFactory.getLogger(SpMaterileController.class);

    /**
     * 物料服务
     *
     * @date 2020-07-07
     */
    @Autowired
    private ISpMaterileService iSpMaterileService;
    /**
     * 流程服务
     */
    @Autowired
    private ISpFlowService iSpFlowService;

    @Value("${web.upload-path:src/main/resources/static/upload/}")
    private String uploadPath;

    /**
     * 物料管理界面
     *
     * @param model 模型
     * @return 物料管理界面
     */
    @ApiOperation("物料管理界面UI")
    @ApiImplicitParams({@ApiImplicitParam(name = "model", value = "模型", defaultValue = "模型")})
    @GetMapping("/list-ui")
    public String listUI(Model model) {
        return "basedata/materile/list";
    }


    /**
     * 物料管理修改界面
     *
     * @param model  模型
     * @param record 平台表对象
     * @return 更改界面
     */
    @ApiOperation("物料管理修改界面")
    @GetMapping("/add-or-update-ui")
    public String addOrUpdateUI(Model model, SpTableManager record) {
        if (StringUtils.isNotEmpty(record.getId())) {
            SpMaterile SpMaterile = iSpMaterileService.getById(record.getId());
            model.addAttribute("result", SpMaterile);
        }
        return "basedata/materile/addOrUpdate";
    }


    /**
     * 物料管理界面分页查询
     *
     * @param req 请求参数
     * @return Result 执行结果
     */
    @ApiOperation("物料管理界面分页查询")
    @ApiImplicitParams({@ApiImplicitParam(name = "req", value = "请求参数", defaultValue = "请求参数")})
    @PostMapping("/page")
    @ResponseBody
    public Result page(spMaterileReq req) {
        QueryWrapper queryWrapper =new QueryWrapper();
        if (StringUtils.isNotEmpty(req.getMaterielLike()))
        {
            queryWrapper.like("materiel",req.getMaterielLike());
        }
        if (StringUtils.isNotEmpty(req.getMaterielDescLike()))
        {
            queryWrapper.like("materiel_desc",req.getMaterielDescLike());
        }
        IPage result = iSpMaterileService.page(req,queryWrapper);
        return Result.success(result);
    }

    /**
     * 物料管理修改、新增
     *
     * @param record 物料实体类
     * @return 执行结果
     */
    @ApiOperation("物料管理修改、新增")
    @PostMapping("/add-or-update")
    @ResponseBody
    @RequiresPermissions("user:add")
    public Result addOrUpdate(SpMaterile record) {
        // 新增时自动生成物料编码：WL00000001、WL00000002 依次递增
        // 自动回收：已删除物料的编码可以被再次分配（查询包含已删除的所有记录）
        if (StrUtil.isBlank(record.getId()) && StrUtil.isBlank(record.getMateriel())) {
            QueryWrapper<SpMaterile> wrapper = new QueryWrapper<>();
            wrapper.likeRight("materiel", "WL");
            List<SpMaterile> list = iSpMaterileService.list(wrapper);
            Set<Integer> usedNums = new HashSet<>();
            for (SpMaterile m : list) {
                String code = m.getMateriel();
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
            record.setMateriel("WL" + String.format("%08d", seq));
        }
        if (StrUtil.isNotBlank(record.getFlowId())) {
            SpFlow spflow = iSpFlowService.getById(record.getFlowId());
            if (Objects.nonNull(spflow)) {
                record.setFlowDesc(spflow.getFlowDesc());
            }
        }
        iSpMaterileService.saveOrUpdate(record);
        return Result.success();
    }

    /**
     * 上传物料图片
     *
     * @param file 上传的图片文件
     * @return 图片访问URL
     */
    @ApiOperation("上传物料图片")
    @PostMapping("/upload-picture")
    @ResponseBody
    @RequiresPermissions("user:add")
    public Result uploadPicture(@RequestParam("file") MultipartFile file) {
        if (file.isEmpty()) {
            return Result.failure("请选择要上传的图片");
        }
        try {
            // 验证文件是否为图片
            BufferedImage image = ImageIO.read(file.getInputStream());
            if (image == null) {
                return Result.failure("上传的文件不是有效的图片格式");
            }
            // 生成文件名
            String originalFilename = file.getOriginalFilename();
            String ext = originalFilename.substring(originalFilename.lastIndexOf("."));
            String fileName = UUID.randomUUID().toString().replaceAll("-", "") + ext;
            // 按日期分目录存储
            String dateDir = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyy/MM/dd"));
            File destDir = new File(uploadPath + dateDir);
            if (!destDir.exists()) {
                destDir.mkdirs();
            }
            File destFile = new File(destDir, fileName);
            file.transferTo(destFile);
            String fileUrl = "/upload/" + dateDir + "/" + fileName;
            logger.info("图片上传成功: {}", fileUrl);
            return Result.success(fileUrl);
        } catch (IOException e) {
            logger.error("图片上传失败", e);
            return Result.failure("图片上传失败: " + e.getMessage());
        }
    }


    /**
     * 删除物料信息
     *
     * @param req 请求参数
     * @return Result 执行结果
     */
    @ApiOperation("删除物料信息")
    @ApiImplicitParams({@ApiImplicitParam(name = "req", value = "物料实体", defaultValue = "物料实体")})
    @PostMapping("/delete")
    @ResponseBody
    @RequiresPermissions("user:add")
    public Result deleteByTableNameId(SpMaterile req) throws Exception {
        iSpMaterileService.removeById(req.getId());
        return Result.success();
    }

    /**
     * 批量删除物料信息
     *
     * @param ids 物料ID，逗号分隔
     * @return Result 执行结果
     */
    @ApiOperation("批量删除物料信息")
    @PostMapping("/delete-batch")
    @ResponseBody
    @RequiresPermissions("user:add")
    public Result deleteBatch(String ids) {
        if (StringUtils.isEmpty(ids)) {
            return Result.failure("请选择需要删除的数据");
        }
        iSpMaterileService.removeByIds(Arrays.asList(ids.split(",")));
        return Result.success();
    }
}
