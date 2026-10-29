package com.wangziyang.mes.technology.controller;


import cn.hutool.core.util.StrUtil;
import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.wangziyang.mes.common.BaseController;
import com.wangziyang.mes.common.Result;
import com.wangziyang.mes.technology.dto.SpBomTreeNode;
import com.wangziyang.mes.technology.entity.SpBom;
import com.wangziyang.mes.technology.entity.SpBomItem;
import com.wangziyang.mes.technology.request.SpBomReq;
import com.wangziyang.mes.technology.service.ISpBomItemService;
import com.wangziyang.mes.technology.service.ISpBomService;
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

/**
 * <p>
 * BOM前端控制器
 * </p>
 *
 * @author WangZiYang
 * @since 2020-03-28
 */
@Controller
@RequestMapping("/technology/bom")
public class SpBomController extends BaseController {
    /**
     * bom服务
     */
    @Autowired
    private ISpBomService iSpBomService;

    /**
     * BOM子项服务
     */
    @Autowired
    private ISpBomItemService iSpBomItemService;

    /**
     * 工艺BOM管理界面
     *
     * @param model 模型
     * @return 工艺BOM管理界面
     */
    @ApiOperation("工艺BOM管理界面UI")
    @ApiImplicitParams({@ApiImplicitParam(name = "model", value = "模型", defaultValue = "模型")})
    @GetMapping("/list-ui")
    public String listUI(Model model) {

        return "technology/bom/list";
    }


    /**
     * 工艺BOM管理修改界面
     *
     * @param model 模型
     * @param spBom bom实体
     * @return 更改界面
     */
    @ApiOperation("工艺BOM管理修改界面")
    @GetMapping("/add-or-update-ui")
    public String addOrUpdateUI(Model model, SpBom spBom) throws Exception {
        if (StringUtils.isNotEmpty(spBom.getId())) {
            SpBom result = iSpBomService.getById(spBom.getId());
            model.addAttribute("result", result);
        } else {
            // 新增时自动生成BOM编号并传递到前端
            String bomCode = iSpBomService.generateBomCode();
            model.addAttribute("generatedBomCode", bomCode);
        }

        return "technology/bom/addOrUpdate";
    }


    /**
     * 工艺BOM分页查询
     *
     * @param req 请求参数
     * @return Result 执行结果
     */
    @ApiOperation("工艺BOM分页分页查询")
    @ApiImplicitParams({@ApiImplicitParam(name = "req", value = "请求参数", defaultValue = "请求参数")})
    @PostMapping("/page")
    @ResponseBody
    public Result page(SpBomReq req) {
        QueryWrapper qw = new QueryWrapper();
        if (StringUtils.isNotEmpty(req.getBomCodeLike())) {
            qw.like("bom_code", req.getBomCodeLike());
        }
        if (StringUtils.isNotEmpty(req.getMaterielCodeLike())) {
            qw.likeRight("materiel_code",req.getMaterielCodeLike());
        }
        IPage result = iSpBomService.page(req,qw);
        return Result.success(result);
    }

    /**
     * 工艺BOM修改、新增
     *
     * @param spBom 物料实体类
     * @return 执行结果
     */
    @ApiOperation("工艺BOM修改、新增")
    @PostMapping("/add-or-update")
    @ResponseBody
    @RequiresPermissions("user:add")
    public Result addOrUpdate(SpBom spBom) {
        // 新增时自动生成BOM编号
        if (StrUtil.isBlank(spBom.getId()) && StrUtil.isBlank(spBom.getBomCode())) {
            String bomCode = iSpBomService.generateBomCode();
            spBom.setBomCode(bomCode);
        }
        iSpBomService.saveOrUpdate(spBom);
        return Result.success();
    }


    /**
     * 删除工艺BOM
     *
     * @param spBom 请求参数
     * @return Result 执行结果
     */
    @ApiOperation("删除工艺BOM")
    @ApiImplicitParams({@ApiImplicitParam(name = "req", value = "工艺BOM", defaultValue = "工艺BOM")})
    @PostMapping("/delete")
    @ResponseBody
    @RequiresPermissions("user:add")
    public Result deleteByTableNameId(SpBom spBom) throws Exception {
        // 物理删除BOM头表及子项
        iSpBomService.removeById(spBom.getId());
        QueryWrapper itemQw = new QueryWrapper();
        itemQw.eq("bom_head_id", spBom.getId());
        iSpBomItemService.remove(itemQw);
        return Result.success();
    }

    /**
     * 产品分解结构图界面
     *
     * @param model  模型
     * @param bomId  BOM头表ID
     * @return 结构图界面
     */
    @ApiOperation("产品分解结构图界面")
    @GetMapping("/tree-ui")
    public String treeUI(Model model, String bomId) {
        if (StringUtils.isNotEmpty(bomId)) {
            SpBom bom = iSpBomService.getById(bomId);
            model.addAttribute("bom", bom);
            model.addAttribute("bomId", bomId);
        }
        return "technology/bom/tree";
    }

    /**
     * 获取BOM产品分解结构树数据
     *
     * @param bomId BOM头表ID
     * @return 树形结构数据
     */
    @ApiOperation("获取BOM分解结构树")
    @PostMapping("/tree")
    @ResponseBody
    public Result tree(String bomId) {
        if (StringUtils.isEmpty(bomId)) {
            return Result.failure("BOM ID不能为空");
        }
        SpBomTreeNode root = iSpBomService.buildBomTree(bomId);
        return Result.success(root);
    }

}
