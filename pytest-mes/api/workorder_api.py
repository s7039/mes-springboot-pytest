# -*- coding: utf-8 -*-
"""工单相关接口。"""


class WorkOrderApi:
    def __init__(self, client):
        self.c = client

    def save(self, order_type, materiel_code, qty, warehouse_code=None,
             location_code=None, bom_id=None, order_id=None):
        data = {"orderType": order_type, "materielCode": materiel_code, "qty": qty}
        if warehouse_code:
            data["warehouseCode"] = warehouse_code
        if location_code:
            data["locationCode"] = location_code
        if bom_id:
            data["bomId"] = bom_id
        if order_id:
            data["id"] = order_id
        return self.c.post("/plan/work-order/add-or-update", data)

    def page(self, status=None, order_type=None, current=1, size=20):
        data = {"current": current, "size": size}
        if status:
            data["status"] = status
        if order_type:
            data["orderType"] = order_type
        return self.c.post("/plan/work-order/page", data)

    def confirm(self, order_id):
        return self.c.post("/plan/work-order/confirm", {"id": order_id})

    def delete(self, order_id):
        return self.c.post("/plan/work-order/delete", {"id": order_id})

    def requirement_page(self, order_code):
        return self.c.post("/plan/work-order/requirement-page",
                           {"orderCode": order_code, "current": 1, "size": 50})

    def material_search(self, code_like="", desc_like=""):
        return self.c.post("/plan/work-order/material-search",
                           {"materielCode": code_like, "materielDesc": desc_like,
                            "current": 1, "size": 10})
