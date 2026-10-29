# -*- coding: utf-8 -*-
"""仓库管理：编号生成、库位容量、必填校验、级联删除、编号回收。"""

import time

import pytest


def _create(apis, db, name, capacity, location_count):
    resp = apis.warehouse.save(name, capacity=capacity, location_count=location_count)
    body = apis.warehouse.c.json(resp)
    assert body["code"] == 0, f"建库房失败：{body}"
    return db.one(
        "SELECT * FROM sp_warehouse WHERE warehouse_name = %s ORDER BY create_time DESC LIMIT 1", (name,)
    )


@pytest.mark.smoke
def test_create_warehouse_generates_code_and_locations(apis, db):
    """新增库房：自动生成 KF 编号，并按库位数等比生成库位容量。"""
    name = "AUTO建库" + time.strftime("%H%M%S") + str(int(time.time() * 1000) % 100)
    row = _create(apis, db, name, capacity=1000, location_count=3)

    try:
        assert row["warehouse_code"].startswith("KF"), f"编号格式异常：{row['warehouse_code']}"
        assert row["capacity"] == 1000
        assert row["location_count"] == 3

        locations = db.all(
            "SELECT * FROM sp_warehouse_location WHERE warehouse_code = %s ORDER BY location_code",
            (row["warehouse_code"],),
        )
        assert len(locations) == 3, f"库位数量应为 3，实际 {len(locations)}"
        # 1000 / 3 = 333（向下取整）
        assert all(loc["capacity"] == 333 for loc in locations), [loc["capacity"] for loc in locations]
        assert [loc["location_code"] for loc in locations] == [
            f"{row['warehouse_code']}-{i}" for i in (1, 2, 3)
        ]
    finally:
        apis.warehouse.delete(row["id"])


def test_create_warehouse_without_name_fails(apis):
    resp = apis.warehouse.save("", capacity=100, location_count=0)
    body = apis.warehouse.c.json(resp)
    assert body["code"] == 1
    assert "库房名称不能为空" in body["msg"]


@pytest.mark.parametrize("capacity", [0, -5])
def test_create_warehouse_invalid_capacity(apis, capacity):
    resp = apis.warehouse.save("AUTO非法容量", capacity=capacity, location_count=0)
    body = apis.warehouse.c.json(resp)
    assert body["code"] == 1
    assert "库房容量必须为正整数" in body["msg"]


@pytest.mark.smoke
def test_delete_warehouse_cascades_locations(apis, db):
    """删除库房应级联删除其库位。"""
    name = "AUTO级联" + time.strftime("%H%M%S") + str(int(time.time() * 1000) % 100)
    row = _create(apis, db, name, capacity=100, location_count=2)
    code = row["warehouse_code"]

    assert db.scalar(
        "SELECT COUNT(*) FROM sp_warehouse_location WHERE warehouse_code = %s", (code,)
    ) == 2

    body = apis.warehouse.c.json(apis.warehouse.delete(row["id"]))
    assert body["code"] == 0, body

    assert db.scalar("SELECT COUNT(*) FROM sp_warehouse WHERE id = %s", (row["id"],)) == 0
    assert db.scalar(
        "SELECT COUNT(*) FROM sp_warehouse_location WHERE warehouse_code = %s", (code,)
    ) == 0, "库房删除后库位未被级联删除"


def test_warehouse_code_is_reusable(apis, db):
    """删除库房后，新建库房应复用最小未使用编号（编号回收）。"""
    name1 = "AUTO回收A" + time.strftime("%H%M%S") + str(int(time.time() * 1000) % 100)
    row1 = _create(apis, db, name1, capacity=50, location_count=0)
    code1 = row1["warehouse_code"]

    apis.warehouse.delete(row1["id"])

    name2 = "AUTO回收B" + time.strftime("%H%M%S") + str(int(time.time() * 1000) % 100)
    row2 = _create(apis, db, name2, capacity=50, location_count=0)
    try:
        assert row2["warehouse_code"] == code1, f"编号未复用：删除 {code1} 后新建得到 {row2['warehouse_code']}"
    finally:
        apis.warehouse.delete(row2["id"])


def test_warehouse_page_query(apis, db):
    """分页查询能按名称模糊搜索到新建库房。"""
    name = "AUTO查询" + time.strftime("%H%M%S") + str(int(time.time() * 1000) % 100)
    row = _create(apis, db, name, capacity=80, location_count=0)
    try:
        body = apis.warehouse.c.json(apis.warehouse.page(name_like=name))
        assert body["code"] == 0
        names = [r["warehouseName"] for r in body["data"]["records"]]
        assert name in names
    finally:
        apis.warehouse.delete(row["id"])
