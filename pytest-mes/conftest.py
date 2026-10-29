# -*- coding: utf-8 -*-
"""全局 fixture：配置、登录客户端、数据库、测试数据。"""

import pathlib
import random
import time
from types import SimpleNamespace

import pytest
import yaml

from api.auth_api import AuthApi
from api.inventory_api import InventoryApi
from api.warehouse_api import WarehouseApi
from api.workorder_api import WorkOrderApi
from common.client import MesClient
from common.db import Db

ROOT = pathlib.Path(__file__).resolve().parent


# ---------------------------------------------------------------- 基础
@pytest.fixture(scope="session")
def cfg():
    with open(ROOT / "config.yaml", encoding="utf-8") as f:
        return yaml.safe_load(f)


@pytest.fixture(scope="session")
def client(cfg):
    """已登录的客户端（依赖 mes.test.captcha-bypass=true）。"""
    c = MesClient(cfg["base_url"], cfg.get("timeout", 10))
    c.login(cfg["login"]["username"], cfg["login"]["password"])
    return c


@pytest.fixture(scope="session")
def db(cfg):
    d = Db(cfg["db"])
    yield d
    d.close()


@pytest.fixture(scope="session")
def apis(client):
    return SimpleNamespace(
        auth=AuthApi(client),
        warehouse=WarehouseApi(client),
        inventory=InventoryApi(client),
        workorder=WorkOrderApi(client),
    )


# ---------------------------------------------------------------- 测试数据
def _unique_suffix() -> str:
    return time.strftime("%H%M%S") + str(random.randint(10, 99))


@pytest.fixture
def materiel(db):
    """每个用例独立物料，用后即删，避免用例间互相污染。"""
    code = "AT" + _unique_suffix()
    db.create_materiel(code, "自动化测试物料")
    yield code
    db.delete_materiel(code)


@pytest.fixture
def warehouse(apis, db):
    """新建一个库房（容量 1000、2 个库位，每库位 500）。"""
    name = "AUTO库" + _unique_suffix()
    resp = apis.warehouse.save(name, capacity=1000, location_count=2)
    body = apis.warehouse.c.json(resp)
    assert body["code"] == 0, f"建库房失败：{body}"

    row = db.one("SELECT * FROM sp_warehouse WHERE warehouse_name = %s ORDER BY create_time DESC LIMIT 1", (name,))
    assert row, "库房未落库"
    locations = db.all(
        "SELECT * FROM sp_warehouse_location WHERE warehouse_code = %s ORDER BY location_code",
        (row["warehouse_code"],),
    )

    data = SimpleNamespace(
        id=row["id"],
        code=row["warehouse_code"],
        capacity=row["capacity"],
        locations=locations,
    )
    yield data

    # 清理：先删库存与工单，再删库房
    db.execute(
        "DELETE FROM sp_inventory_flow WHERE warehouse_code = %s", (data.code,)
    )
    db.execute(
        "DELETE r FROM sp_work_order_requirement r JOIN sp_work_order w ON w.order_code = r.order_code "
        "WHERE w.warehouse_code = %s", (data.code,)
    )
    db.execute("DELETE FROM sp_work_order WHERE warehouse_code = %s", (data.code,))
    db.execute("DELETE FROM sp_inventory WHERE warehouse_code = %s", (data.code,))
    apis.warehouse.delete(data.id)


@pytest.fixture
def make_stock(apis, db):
    """造库存：建入库工单 -> 确认 -> 库存落库。返回实际入库数量。"""

    def _make(materiel_code: str, warehouse_code: str, qty: int) -> int:
        resp = apis.workorder.save("IN", materiel_code, qty, warehouse_code)
        body = apis.workorder.c.json(resp)
        assert body["code"] == 0, f"建入库工单失败：{body}"

        order = db.latest_order(materiel_code)
        assert order, "入库工单未落库"

        resp = apis.workorder.confirm(order["id"])
        body = apis.workorder.c.json(resp)
        assert body["code"] == 0, f"确认入库失败：{body}"
        return qty

    return _make
