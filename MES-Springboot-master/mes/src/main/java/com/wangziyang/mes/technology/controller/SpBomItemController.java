package com.wangziyang.mes.technology.controller;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.wangziyang.mes.common.BaseController;
import com.wangziyang.mes.common.BasePageReq;
import com.wangziyang.mes.common.Result;
import com.wangziyang.mes.technology.entity.SpBom;
import com.wangziyang.mes.technology.entity.SpBomItem;
import com.wangziyang.mes.technology.service.ISpBomItemService;
import com.wangziyang.mes.technology.service.ISpBomService;
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
 * BOM子项前端控制器
 *
 * @author WangZiYang
 * @since 2021-03-01
 */
@Controller
@RequestMapping("/technology/bom/item")
public class SpBomItemController extends BaseController {

    @Autowired
    private ISpBomItemService iSpBomItemService;

    @Autowired
    private ISpBomService iSpBomService;

    @ApiOperation("BOM子项管理界面UI")
    @GetMapping("/list-ui")
    public String listUI(Model model, String bomHeadId) {
        model.addAttribute("bomHeadId", bomHeadId);
        return "technology/bom/item/list";
    }

    @ApiOperation("BOM子项新增/修改界面")
    @GetMapping("/add-or-update-ui")
    public String addOrUpdateUI(Model model, SpBomItem spBomItem) {
        if (StringUtils.isNotEmpty(spBomItem.getId())) {
            SpBomItem result = iSpBomItemService.getById(spBomItem.getId());
            model.addAttribute("result", result);
            // 子项为物料BOM时，回显所引用的BOM编号
            if (result != null && "1".equals(result.getItemType()) && StringUtils.isNotEmpty(result.getRefBomId())) {
                SpBom refBom = iSpBomService.getById(result.getRefBomId());
                if (refBom != null) {
                    model.addAttribute("refBomCode", refBom.getBomCode());
                }
            }
        } else {
            model.addAttribute("bomHeadId", spBomItem.getBomHeadId());
        }
        return "technology/bom/item/addOrUpdate";
    }

    @ApiOperation("BOM子项分页查询")
    @PostMapping("/page")
    @ResponseBody
    public Result page(BasePageReq<SpBomItem> req, String bomHeadId) {
        QueryWrapper<SpBomItem> qw = new QueryWrapper<>();
        if (StringUtils.isNotEmpty(bomHeadId)) {
            qw.eq("bom_head_id", bomHeadId);
        }
        IPage<SpBomItem> result = iSpBomItemService.page(req, qw);
        return Result.success(result);
    }

    @ApiOperation("BOM子项新增/修改")
    @PostMapping("/add-or-update")
    @ResponseBody
    @RequiresPermissions("user:add")
    public Result addOrUpdate(SpBomItem spBomItem) {
        if ("1".equals(spBomItem.getItemType())) {
            // 添加物料的BOM：校验所引用的BOM
            if (StringUtils.isEmpty(spBomItem.getRefBomId())) {
                return Result.failure("请选择要添加的物料BOM");
            }
            SpBom refBom = iSpBomService.getById(spBomItem.getRefBomId());
            if (refBom == null) {
                return Result.failure("所选的物料BOM不存在");
            }
            if (spBomItem.getRefBomId().equals(spBomItem.getBomHeadId())) {
                return Result.failure("不能引用当前BOM自身");
            }
            if (iSpBomService.isBomContains(spBomItem.getRefBomId(), spBomItem.getBomHeadId())) {
                return Result.failure("所选的物料BOM已引用当前BOM，存在循环引用");
            }
            // 子项物料信息以所选BOM的物料为准
            spBomItem.setMaterielItemCode(refBom.getMaterielCode());
            spBomItem.setMaterielItemDesc(refBom.getMaterielDesc());
        } else {
            // 单纯添加物料
            spBomItem.setItemType("0");
            // 置为空串，便于更新时清除原有的引用关系
            spBomItem.setRefBomId("");
        }
        iSpBomItemService.saveOrUpdate(spBomItem);
        return Result.success();
    }

    @ApiOperation("删除BOM子项")
    @PostMapping("/delete")
    @ResponseBody
    @RequiresPermissions("user:add")
    public Result delete(SpBomItem spBomItem) {
        iSpBomItemService.removeById(spBomItem.getId());
        return Result.success();
    }
}
