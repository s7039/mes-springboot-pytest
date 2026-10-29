# -*- coding: utf-8 -*-
"""HTTP 客户端封装：会话保持、统一请求头、统一断言。"""

import requests


class ApiError(AssertionError):
    """业务码非 0 时抛出，便于在用例里定位问题。"""


class MesClient:
    """MES 接口客户端。

    特点：
    1. 用 requests.Session 保持 Cookie，登录一次复用整个会话；
    2. 默认带 X-Requested-With，未登录时会返回 401 而不是 302 跳转；
    3. 提供 json()/expect_ok() 等断言辅助方法。
    """

    def __init__(self, base_url: str, timeout: int = 10):
        self.base_url = base_url.rstrip("/")
        self.timeout = timeout
        self.session = requests.Session()
        # 并发用例会同时发 20 个请求，默认连接池只有 10，会打印 "Connection pool is full"
        adapter = requests.adapters.HTTPAdapter(pool_connections=30, pool_maxsize=30, max_retries=0)
        self.session.mount("http://", adapter)
        self.session.mount("https://", adapter)

    # ---------- 底层请求 ----------
    def post(self, path: str, data=None, ajax: bool = True, allow_redirects: bool = True):
        headers = {"X-Requested-With": "XMLHttpRequest"} if ajax else {}
        return self.session.post(
            self.base_url + path,
            data=data or {},
            headers=headers,
            timeout=self.timeout,
            allow_redirects=allow_redirects,
        )

    def get(self, path: str, params=None, allow_redirects: bool = True):
        return self.session.get(
            self.base_url + path, params=params or {}, timeout=self.timeout,
            allow_redirects=allow_redirects,
        )

    # ---------- 断言辅助 ----------
    @staticmethod
    def json(resp) -> dict:
        assert resp.status_code == 200, f"HTTP 状态异常：{resp.status_code}，body={resp.text[:200]}"
        try:
            return resp.json()
        except ValueError:
            raise AssertionError(f"响应不是 JSON：{resp.text[:200]}")

    def expect_ok(self, resp, action: str = "") -> dict:
        body = self.json(resp)
        assert body.get("code") == 0, f"{action} 应成功，实际 {body}"
        return body

    def expect_fail(self, resp, msg_part: str = None, action: str = "") -> dict:
        body = self.json(resp)
        assert body.get("code") == 1, f"{action} 应失败，实际 {body}"
        if msg_part:
            assert msg_part in (body.get("msg") or ""), f"{action} 提示信息不符：{body.get('msg')}"
        return body

    # ---------- 登录 ----------
    def login(self, username: str, password: str, captcha: str = None) -> dict:
        data = {"username": username, "password": password}
        if captcha is not None:
            data["captcha"] = captcha
        body = self.json(self.post("/login", data))
        assert body.get("code") == 0, f"登录失败：{body}（确认 mes.test.captcha-bypass=true 已开启）"
        return body
