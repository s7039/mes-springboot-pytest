# -*- coding: utf-8 -*-
"""登录与鉴权。"""

from common.client import MesClient


def test_unauthorized_returns_401(cfg):
    """未登录访问受保护接口：Ajax 请求应返回 401（SpLoginFormFilter 对 Ajax 不跳转）。"""
    anonymous = MesClient(cfg["base_url"], cfg.get("timeout", 10))
    resp = anonymous.post("/plan/work-order/page", {"current": 1, "size": 1})
    assert resp.status_code == 401, f"未登录应返回 401，实际 {resp.status_code}"


def test_login_and_access(client, apis):
    """登录后可正常访问受保护接口。"""
    resp = apis.workorder.page()
    body = client.json(resp)
    assert body["code"] == 0
    assert "records" in body["data"]


def test_logout_then_denied(cfg):
    """退出登录后再次访问应被拒绝（用独立会话，避免影响其它用例）。"""
    c = MesClient(cfg["base_url"], cfg.get("timeout", 10))
    c.login(cfg["login"]["username"], cfg["login"]["password"])

    c.get("/logout", allow_redirects=False)

    resp = c.post("/warehouse/inventory/page", {"current": 1, "size": 1})
    assert resp.status_code == 401, f"登出后应 401，实际 {resp.status_code}；若为 200 说明会话未失效"
