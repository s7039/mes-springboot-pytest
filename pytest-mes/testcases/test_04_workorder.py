# -*- coding: utf-8 -*-
"""工单：入库确认链路、参数校验、容量校验、缺料、重复确认、删除释放锁。"""

import pytest


def _code(resp):
    return resp.json().get("code")


@pytest.mark.smoke
def test_inbound_confirm_updates_stock_and_flow(apis, db, materiel, warehouse):
    """入库确认：库存增加、写 IN 流水、工单状态变 02。"""
    before = db.inventory(materiel, warehouse.code)
    assert before is None, "前置条件：物料不应已有库存"

    resp = apis.workorder.save("IN", materiel, 100, warehouse.code)
    assert _code(resp) == 0, resp.text

    order = db.latest_order(materiel)
    assert order["status"] == "01"
    assert order["order_code"].startswith("GD")

    resp = apis.workorder.confirm(order["id"])
    assert _code(resp) == 0, resp.text

    inv = db.inventory(materiel, warehouse.code)
    assert float(inv["qty"]) == 100.0
    assert float(inv["locked_qty"]) == 0.0

    flows = db.flows(order["order_code"])
    assert len(flows) == 1
    assert flows[0]["change_type"] == "IN"
    assert float(flows[0]["change_qty"]) == 100.0

    assert db.latest_order(materiel)["status"] == "02"


@pytest.mark.parametrize("payload,expected", [
    ({"orderType": "IN", "qty": 10, "warehouseCode": "NOPE"}, "物料编码不能为空"),
    ({"orderType": "IN", "materielCode": "X", "qty": 0, "warehouseCode": "NOPE"}, "数量必须为正整数"),
    ({"orderType": "IN", "materielCode": "X", "qty": -3, "warehouseCode": "NOPE"}, "数量必须为正整数"),
    ({"orderType": "ABC", "materielCode": "X", "qty": 1, "warehouseCode": "NOPE"}, "工单类型必须为入库或出库"),
])
def test_workorder_param_validation(client, payload, expected):
    """参数校验：四类非法入参都应被拦截。"""
    resp = client.post("/plan/work-order/add-or-update", payload)
    body = client.json(resp)
    assert body["code"] == 1
    assert expected in body["msg"], f"期望提示包含【{expected}】，实际【{body['msg']}】"


def test_inbound_requires_warehouse(apis, materiel):
    """入库工单必须选择库房。"""
    resp = apis.workorder.save("IN", materiel, 1)
    body = apis.workorder.c.json(resp)
    assert body["code"] == 1
    assert "入库工单必须选择库房" in body["msg"]


@pytest.mark.smoke
def test_inbound_capacity_exceeded(apis, db, materiel):
    """入库数量超过库房容量应被拒绝。"""
    name = "AUTO小库"
    resp = apis.warehouse.save(name, capacity=5, location_count=0)
    assert apis.warehouse.c.json(resp)["code"] == 0

    row = db.one("SELECT * FROM sp_warehouse WHERE warehouse_name = %s ORDER BY create_time DESC LIMIT 1",
                 (name,))
    try:
        resp = apis.workorder.save("IN", materiel, 10, row["warehouse_code"])
        body = apis.workorder.c.json(resp)
        assert body["code"] == 1
        assert "容量不足" in body["msg"], body["msg"]
        assert "超过容量上限5" in body["msg"]
    finally:
        apis.warehouse.delete(row["id"])


@pytest.mark.smoke
def test_outbound_without_stock_reports_shortage(apis, db, materiel, warehouse):
    """库存不足时返回缺料清单，且不创建工单。"""
    resp = apis.workorder.save("OUT", materiel, 50, warehouse.code)
    body = apis.workorder.c.json(resp)
    assert body["code"] == 1
    assert "库存不足" in body["msg"] or "缺料" in body["msg"], body["msg"]
    assert db.latest_order(materiel) is None, "缺料时不应落库工单"


def test_outbound_locks_then_confirm_deducts(apis, db, materiel, warehouse, make_stock):
    """出库：创建即锁定，确认后扣减并释放锁。"""
    make_stock(materiel, warehouse.code, 100)

    resp = apis.workorder.save("OUT", materiel, 20, warehouse.code)
    assert _code(resp) == 0, resp.text

    order = db.latest_order(materiel)
    inv = db.inventory(materiel, warehouse.code)
    assert float(inv["locked_qty"]) == 20.0, "创建出库单应锁定 20"

    resp = apis.workorder.confirm(order["id"])
    assert _code(resp) == 0, resp.text

    inv = db.inventory(materiel, warehouse.code)
    assert float(inv["qty"]) == 80.0
    assert float(inv["locked_qty"]) == 0.0

    flows = db.flows(order["order_code"])
    assert len(flows) == 1
    assert flows[0]["change_type"] == "OUT"
    assert float(flows[0]["change_qty"]) == -20.0


@pytest.mark.smoke
def test_confirm_twice_rejected(apis, db, materiel, warehouse, make_stock):
    """重复确认同一工单应被拒绝（幂等）。"""
    make_stock(materiel, warehouse.code, 50)

    apis.workorder.save("OUT", materiel, 10, warehouse.code)
    order = db.latest_order(materiel)

    assert _code(apis.workorder.confirm(order["id"])) == 0
    resp = apis.workorder.confirm(order["id"])
    body = apis.workorder.c.json(resp)
    assert body["code"] == 1
    assert "不允许确认" in body["msg"] or "无法重复确认" in body["msg"], body["msg"]

    # 库存只扣一次，流水只有一条
    inv = db.inventory(materiel, warehouse.code)
    assert float(inv["qty"]) == 40.0
    assert len(db.flows(order["order_code"])) == 1


def test_delete_pending_outbound_releases_lock(apis, db, materiel, warehouse, make_stock):
    """删除待确认出库单应释放锁定库存与需求明细。"""
    make_stock(materiel, warehouse.code, 50)

    apis.workorder.save("OUT", materiel, 20, warehouse.code)
    order = db.latest_order(materiel)
    assert float(db.inventory(materiel, warehouse.code)["locked_qty"]) == 20.0

    resp = apis.workorder.delete(order["id"])
    assert _code(resp) == 0, resp.text

    assert float(db.inventory(materiel, warehouse.code)["locked_qty"]) == 0.0
    assert db.requirement(order["order_code"]) == []


def test_delete_confirmed_order_rejected(apis, db, materiel, warehouse, make_stock):
    """已完成的工单不允许删除。"""
    make_stock(materiel, warehouse.code, 20)
    apis.workorder.save("OUT", materiel, 5, warehouse.code)
    order = db.latest_order(materiel)
    assert _code(apis.workorder.confirm(order["id"])) == 0

    body = apis.workorder.c.json(apis.workorder.delete(order["id"]))
    assert body["code"] == 1
    assert "工单已完成" in body["msg"]
