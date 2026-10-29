# -*- coding: utf-8 -*-
"""库存管理：可用量计算、删除约束。"""

import pytest


@pytest.mark.smoke
def test_available_qty_equals_qty_minus_locked(apis, db, materiel, warehouse, make_stock):
    """库存列表返回的 availableQty 应等于 qty - lockedQty。"""
    make_stock(materiel, warehouse.code, 100)

    body = apis.inventory.c.json(apis.inventory.page(materiel_code=materiel))
    assert body["code"] == 0
    records = [r for r in body["data"]["records"] if r["materielCode"] == materiel]
    assert records, "库存列表未查到该物料"

    row = records[0]
    assert float(row["qty"]) == 100.0
    assert float(row["lockedQty"]) == 0.0
    assert float(row["availableQty"]) == float(row["qty"]) - float(row["lockedQty"])


@pytest.mark.smoke
def test_delete_inventory_forbidden_when_qty_positive(apis, db, materiel, warehouse, make_stock):
    """库存数量不为 0 时不允许删除。"""
    make_stock(materiel, warehouse.code, 30)
    inv = db.inventory(materiel, warehouse.code)

    body = apis.inventory.c.json(apis.inventory.delete(inv["id"]))
    assert body["code"] == 1
    assert "库存数量不为0" in body["msg"]
    assert db.inventory(materiel, warehouse.code) is not None, "记录不应被删除"


def test_delete_inventory_allowed_when_zero(apis, db, materiel, warehouse, make_stock):
    """实际与锁定都为 0 的库存记录允许删除。"""
    make_stock(materiel, warehouse.code, 10)
    inv = db.inventory(materiel, warehouse.code)

    # 造一条零库存记录：出库扣到 0（扣到 0 且无锁定时系统会自动删除，这里改用直接置零验证接口）
    db.execute("UPDATE sp_inventory SET qty = 0, locked_qty = 0 WHERE id = %s", (inv["id"],))

    body = apis.inventory.c.json(apis.inventory.delete(inv["id"]))
    assert body["code"] == 0, body
    assert db.inventory(materiel, warehouse.code) is None


def test_flow_record_written_on_inbound(apis, db, materiel, warehouse, make_stock):
    """入库确认后应写入一条 IN 流水，且 before/after 连续。"""
    make_stock(materiel, warehouse.code, 50)

    order = db.latest_order(materiel)
    flows = db.flows(order["order_code"])
    assert len(flows) == 1, f"入库应只有 1 条流水，实际 {len(flows)}"

    flow = flows[0]
    assert flow["change_type"] == "IN"
    assert float(flow["change_qty"]) == 50.0
    assert float(flow["after_qty"]) == float(flow["before_qty"]) + 50.0
    assert flow["flow_code"].startswith("LS")
