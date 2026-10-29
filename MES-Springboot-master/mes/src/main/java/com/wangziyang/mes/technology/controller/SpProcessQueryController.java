package com.wangziyang.mes.technology.controller;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.wangziyang.mes.common.BaseController;
import com.wangziyang.mes.common.Result;
import com.wangziyang.mes.technology.dto.SpBomTreeNode;
import com.wangziyang.mes.technology.entity.SpProcessContent;
import com.wangziyang.mes.technology.entity.SpProcessContentOper;
import com.wangziyang.mes.technology.entity.SpProductProcess;
import com.wangziyang.mes.technology.entity.SpProductProcessItem;
import com.wangziyang.mes.technology.request.SpProductProcessReq;
import com.wangziyang.mes.technology.service.ISpBomService;
import com.wangziyang.mes.technology.service.ISpProcessContentOperService;
import com.wangziyang.mes.technology.service.ISpProcessContentService;
import com.wangziyang.mes.technology.service.ISpProductProcessItemService;
import io.swagger.annotations.ApiOperation;
import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * <p>
 * 产品工艺查询 前端控制器
 * </p>
 *
 * @author WangZiYang
 * @since 2020-03-28
 */
@Controller
@RequestMapping("/technology/process/query")
public class SpProcessQueryController extends BaseController {

    @Autowired
    private ISpProcessContentService spProcessContentService;

    @Autowired
    private ISpProcessContentOperService spProcessContentOperService;

    @Autowired
    private ISpBomService iSpBomService;

    @Autowired
    private ISpProductProcessItemService spProductProcessItemService;

    /**
     * 产品工艺查询列表界面
     */
    @ApiOperation("产品工艺查询列表界面UI")
    @GetMapping("/list-ui")
    public String listUI(Model model) {
        return "technology/process/query/list";
    }

    /**
     * 产品工艺查询明细界面（BOM树 + 工艺信息）
     */
    @ApiOperation("产品工艺查询明细界面UI")
    @GetMapping("/detail-ui")
    public String detailUI(Model model, String id) {
        if (StringUtils.isNotEmpty(id)) {
            SpProcessContent content = spProcessContentService.getById(id);
            model.addAttribute("content", content);
            if (content != null) {
                model.addAttribute("bomId", content.getBomId());
                model.addAttribute("processId", content.getProcessId());
            }
        }
        return "technology/process/query/detail";
    }

    /**
     * 分页查询已完成的工艺编制记录
     */
    @ApiOperation("已完成工艺编制分页查询")
    @PostMapping("/page")
    @ResponseBody
    public Result page(SpProductProcessReq req) {
        QueryWrapper<SpProcessContent> qw = new QueryWrapper<>();
        qw.eq("status", "1"); // 只查询已完成的
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

    /**
     * 查询产品工艺信息（BOM树 + 工序完成状态）
     */
    @ApiOperation("查询产品工艺信息")
    @PostMapping("/process-tree")
    @ResponseBody
    public Result processTree(String bomId, String contentId) {
        if (StringUtils.isEmpty(bomId)) {
            return Result.failure("BOM ID不能为空");
        }

        // 1. 加载BOM树
        SpBomTreeNode root = iSpBomService.buildBomTree(bomId);
        if (root == null) {
            return Result.failure("BOM结构不存在");
        }

        // 2. 加载工艺编制工序内容
        List<SpProcessContentOper> opers = null;
        if (StringUtils.isNotEmpty(contentId)) {
            QueryWrapper<SpProcessContentOper> qw = new QueryWrapper<>();
            qw.eq("content_id", contentId);
            qw.orderByAsc("sort_num");
            opers = spProcessContentOperService.list(qw);
        }

        // 3. 构建物料编码 → 工序内容 映射
        Map<String, SpProcessContentOper> operMap = new HashMap<>();
        if (opers != null) {
            for (SpProcessContentOper oper : opers) {
                if (StringUtils.isNotEmpty(oper.getMaterielItemCode())) {
                    operMap.put(oper.getMaterielItemCode(), oper);
                }
            }
        }

        // 4. 递归增强BOM树节点
        enrichTreeNode(root, operMap);

        return Result.success(root);
    }

    /**
     * 递归增强BOM树节点，添加工艺信息
     */
    private void enrichTreeNode(SpBomTreeNode node, Map<String, SpProcessContentOper> operMap) {
        if (node == null) return;

        // 查找该节点物料编码对应的工序内容
        SpProcessContentOper oper = operMap.get(node.getMaterielCode());
        if (oper != null) {
            node.setHasProcess(true);
            node.setOperDesc(oper.getOperDesc());
            node.setContentText(oper.getContentText());
            node.setImages(oper.getImages());
        } else {
            node.setHasProcess(false);
        }

        // 递归处理子节点
        if (node.getChildren() != null) {
            for (SpBomTreeNode child : node.getChildren()) {
                enrichTreeNode(child, operMap);
            }
        }
    }
}
