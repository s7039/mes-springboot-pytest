# -*- coding: utf-8 -*-
"""仓库 / 库位相关接口。"""


class WarehouseApi:
    def __init__(self, client):
        self.c = client

    def save(self, name, capacity, location_count=0):
        return self.c.post("/warehouse/add-or-update", {
            "warehouseName": name,
            "capacity": capacity,
            "locationCount": location_count,
        })

    def page(self, name_like="", current=1, size=10):
        return self.c.post("/warehouse/page",
                           {"warehouseNameLike": name_like, "current": current, "size": size})

    def all_list(self):
        return self.c.post("/warehouse/all-list")

    def location_list(self, warehouse_code):
        return self.c.post("/warehouse/location-list", {"warehouseCode": warehouse_code})

    def location_page(self, warehouse_code, current=1, size=50):
        return self.c.post("/warehouse/location/page",
                           {"warehouseCode": warehouse_code, "current": current, "size": size})

    def delete(self, warehouse_id):
        return self.c.post("/warehouse/delete", {"id": warehouse_id})
