# -*- coding: utf-8 -*-
"""并发场景：并发锁定不超锁、并发确认只生效一次。"""

from concurrent.futures import ThreadPoolExecutor, wait

import pytest


def _post_many(client, path, data, n, workers=None):
    """用线程池同时发 n 个请求，返回业务码列表。"""
    def once(_):
        return client.post(path, data).json().get("code")

    with ThreadPoolExecutor(max_workers=workers or n) as pool:
        futures = [pool.submit(once, i) for i in range(n)]
        wait(futures)
    return [f.result() for f in futures]


@pytest.mark.concurrency
@pytest.mark.smoke
def test_concurrent_outbound_never_over_locks(apis, db, materiel, warehouse, make_stock):
    """20 个请求同时创建需要 10 个库存的出库单：只能成功 1 单，不得超锁。"""
    make_stock(materiel, warehouse.code, 10)

    codes = _post_many(
        apis.workorder.c,
        "/plan/work-order/add-or-update",
        {"orderType": "OUT", "materielCode": materiel, "qty": 10, "warehouseCode": warehouse.code},
        n=20,
    )

    success = codes.count(0)
    assert success == 1, f"可用量 10、每单需 10，应只有 1 单成功，实际 {success} 单"

    inv = db.inventory(materiel, warehouse.code)
    assert float(inv["locked_qty"]) <= float(inv["qty"]), "锁定数量超过实际库存（超锁）"
    assert float(inv["locked_qty"]) == 10.0
    assert float(inv["qty"]) == 10.0
    assert inv["version"] >= 1, "版本号应因条件更新而递增"


@pytest.mark.concurrency
def test_concurrent_confirm_only_once(apis, db, materiel, warehouse, make_stock):
    """10 个请求同时确认同一张出库单：只生效一次，流水不重复。"""
    make_stock(materiel, warehouse.code, 100)

    resp = apis.workorder.save("OUT", materiel, 10, warehouse.code)
    assert apis.workorder.c.json(resp)["code"] == 0

    order = db.latest_order(materiel)
    codes = _post_many(
        apis.workorder.c, "/plan/work-order/confirm", {"id": order["id"]}, n=10
    )

    assert codes.count(0) == 1, f"同一工单只应确认成功 1 次，实际 {codes.count(0)} 次"

    inv = db.inventory(materiel, warehouse.code)
    assert float(inv["qty"]) == 90.0, "库存只应扣减一次"
    assert float(inv["locked_qty"]) == 0.0

    flows = db.flows(order["order_code"])
    assert len(flows) == 1, f"流水不应重复，实际 {len(flows)} 条"
    assert float(flows[0]["change_qty"]) == -10.0


@pytest.mark.concurrency
def test_concurrent_create_orders_code_unique(apis, db, materiel, warehouse):
    """20 并发创建工单：单号不重复、不应出现数据库异常。"""
    codes = _post_many(
        apis.workorder.c,
        "/plan/work-order/add-or-update",
        {"orderType": "IN", "materielCode": materiel, "qty": 1, "warehouseCode": warehouse.code},
        n=20,
    )

    success = codes.count(0)
    duplicates = db.all(
        "SELECT order_code, COUNT(*) c FROM sp_work_order GROUP BY order_code HAVING c > 1"
    )
    assert duplicates == [], f"出现重复单号：{duplicates}"

    failed = 20 - success
    assert failed == 0, f"并发创建仍有 {failed} 个失败（应为 0，若为 SQLIntegrityConstraint 说明取号未生效）"
