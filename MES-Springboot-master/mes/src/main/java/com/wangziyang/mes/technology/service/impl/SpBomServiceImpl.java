package com.wangziyang.mes.technology.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.wangziyang.mes.technology.dto.SpBomTreeNode;
import com.wangziyang.mes.technology.entity.SpBom;
import com.wangziyang.mes.technology.entity.SpBomItem;
import com.wangziyang.mes.technology.mapper.SpBomMapper;
import com.wangziyang.mes.technology.service.ISpBomItemService;
import com.wangziyang.mes.technology.service.ISpBomService;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

/**
 * <p>
 *  BOM服务实现类
 * </p>
 *
 * @author WangZiYang
 * @since 2020-03-28
 */
@Service
public class SpBomServiceImpl extends ServiceImpl<SpBomMapper, SpBom> implements ISpBomService {

    @Autowired
    private ISpBomItemService iSpBomItemService;

    @Override
    public String generateBomCode() {
        // BOM00001、BOM00002 依次递增，自动回收已删除的编号
        QueryWrapper<SpBom> wrapper = new QueryWrapper<>();
        wrapper.likeRight("bom_code", "BOM");
        List<SpBom> list = this.list(wrapper);
        Set<Long> usedNums = new HashSet<>();
        for (SpBom bom : list) {
            String code = bom.getBomCode();
            if (code != null && code.length() > 3) {
                String numStr = code.substring(3);
                if (numStr.matches("\\d+")) {
                    usedNums.add(Long.parseLong(numStr));
                }
            }
        }
        // 从 1 开始查找最小的未使用编号，实现编码回收
        long seq = 1;
        while (usedNums.contains(seq)) {
            seq++;
        }
        return "BOM" + String.format("%05d", seq);
    }

    @Override
    public SpBomTreeNode buildBomTree(String bomId) {
        if (StringUtils.isEmpty(bomId)) {
            return null;
        }
        // 记录已展开的BOM，防止循环引用导致死循环
        Set<String> visited = new HashSet<>();
        visited.add(bomId);
        return buildBomTree(bomId, visited);
    }

    private SpBomTreeNode buildBomTree(String bomId, Set<String> visited) {
        SpBom bom = this.getById(bomId);
        if (bom == null) {
            return null;
        }

        SpBomTreeNode root = new SpBomTreeNode();
        root.setId(bom.getId());
        root.setMaterielCode(bom.getMaterielCode());
        root.setMaterielDesc(bom.getMaterielDesc());
        root.setItemNum(BigDecimal.ONE);
        root.setItemUnit(null);
        root.setIsBomHead(true);

        // 递归构建子节点
        buildChildren(root, visited);

        return root;
    }

    /**
     * 递归构建子节点
     */
    private void buildChildren(SpBomTreeNode parent, Set<String> visited) {
        QueryWrapper<SpBomItem> qw = new QueryWrapper<>();
        qw.eq("bom_head_id", parent.getId());
        qw.orderByAsc("create_time");
        List<SpBomItem> items = iSpBomItemService.list(qw);

        if (items == null || items.isEmpty()) {
            return;
        }

        for (SpBomItem item : items) {
            SpBomTreeNode childNode = new SpBomTreeNode();
            childNode.setId(item.getId());
            childNode.setMaterielCode(item.getMaterielItemCode());
            childNode.setMaterielDesc(item.getMaterielItemDesc());
            childNode.setItemNum(item.getItemNum());
            childNode.setItemUnit(item.getItemUnit());

            // 子项类型为物料BOM时，按引用的BOM展开下级；单纯物料不展开
            String childBomId = resolveChildBomId(item);
            if (StringUtils.isNotEmpty(childBomId) && !visited.contains(childBomId)) {
                SpBom childBom = this.getById(childBomId);
                if (childBom != null) {
                    childNode.setIsBomHead(true);
                    visited.add(childBomId);
                    SpBomTreeNode subTree = buildBomTree(childBomId, visited);
                    if (subTree != null) {
                        childNode.setChildren(subTree.getChildren());
                    }
                    visited.remove(childBomId);
                } else {
                    childNode.setIsBomHead(false);
                }
            } else {
                childNode.setIsBomHead(false);
            }

            parent.getChildren().add(childNode);
        }
    }

    /**
     * 获取子项需要展开的BOM头ID
     */
    private String resolveChildBomId(SpBomItem item) {
        if ("1".equals(item.getItemType())) {
            return item.getRefBomId();
        }
        if (StringUtils.isNotEmpty(item.getItemType())) {
            // 单纯物料，不展开下级
            return null;
        }
        // 兼容历史数据（子项类型为空）：按物料编码自动匹配BOM
        SpBom childBom = this.getOne(new QueryWrapper<SpBom>()
                .eq("materiel_code", item.getMaterielItemCode())
                .last("LIMIT 1"));
        return childBom == null ? null : childBom.getId();
    }

    @Override
    public boolean isBomContains(String bomId, String targetBomId) {
        if (StringUtils.isEmpty(bomId) || StringUtils.isEmpty(targetBomId)) {
            return false;
        }
        if (bomId.equals(targetBomId)) {
            return true;
        }
        Set<String> visited = new HashSet<>();
        visited.add(bomId);
        return containsBom(bomId, targetBomId, visited);
    }

    private boolean containsBom(String bomId, String targetBomId, Set<String> visited) {
        QueryWrapper<SpBomItem> qw = new QueryWrapper<>();
        qw.eq("bom_head_id", bomId).eq("item_type", "1");
        List<SpBomItem> items = iSpBomItemService.list(qw);
        if (items == null || items.isEmpty()) {
            return false;
        }
        for (SpBomItem item : items) {
            String refBomId = item.getRefBomId();
            if (StringUtils.isEmpty(refBomId)) {
                continue;
            }
            if (refBomId.equals(targetBomId)) {
                return true;
            }
            if (visited.add(refBomId) && containsBom(refBomId, targetBomId, visited)) {
                return true;
            }
        }
        return false;
    }

}
