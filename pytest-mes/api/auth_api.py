# -*- coding: utf-8 -*-
"""登录相关接口。"""


class AuthApi:
    def __init__(self, client):
        self.c = client

    def login(self, username, password, captcha=""):
        return self.c.post("/login", {"username": username, "password": password, "captcha": captcha})

    def logout(self):
        return self.c.get("/logout", allow_redirects=False)

    def captcha_image(self):
        return self.c.get("/verification/code")
