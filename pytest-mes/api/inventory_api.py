# -*- coding: utf-8 -*-
"""库存 / 流水相关接口。"""


class InventoryApi:
    def __init__(self, client):
        self.c = client

    def page(self, materiel_code="", current=1, size=20):
        return self.c.post("/warehouse/inventory/page",
                           {"materielCode": materiel_code, "current": current, "size": size})

    def delete(self, inventory_id):
        return self.c.post("/warehouse/inventory/delete", {"id": inventory_id})

    def flow_page(self, order_code="", current=1, size=50):
        return self.c.post("/warehouse/flow/page",
                           {"orderCode": order_code, "current": current, "size": size})
