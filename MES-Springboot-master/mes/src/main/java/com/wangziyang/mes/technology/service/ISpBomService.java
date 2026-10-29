package com.wangziyang.mes.technology.service;

import com.wangziyang.mes.technology.dto.SpBomTreeNode;
import com.wangziyang.mes.technology.entity.SpBom;
import com.baomidou.mybatisplus.extension.service.IService;

/**
 * <p>
 *  bom服务类
 * </p>
 *
 * @author WangZiYang
 * @since 2020-03-28
 */
public interface ISpBomService extends IService<SpBom> {

    /**
     * 自动生成BOM编号
     * 格式：BOM + yyyyMMdd + 4位流水号
     *
     * @return BOM编号
     */
    String generateBomCode();

    /**
     * 递归构建BOM产品分解结构树
     *
     * @param bomId BOM头表ID
     * @return 树形根节点
     */
    SpBomTreeNode buildBomTree(String bomId);

    /**
     * 判断BOM的下级引用中是否包含目标BOM（用于循环引用校验）
     *
     * @param bomId       起始BOM头表ID
     * @param targetBomId 目标BOM头表ID
     * @return true-包含（存在循环引用）
     */
    boolean isBomContains(String bomId, String targetBomId);

}
