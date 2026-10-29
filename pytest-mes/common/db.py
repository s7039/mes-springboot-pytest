# -*- coding: utf-8 -*-
"""数据库工具：造数据 + 落库校验。"""

import pymysql


class Db:
    def __init__(self, cfg: dict):
        self.conn = pymysql.connect(
            host=cfg["host"],
            port=int(cfg["port"]),
            user=cfg["user"],
            password=cfg["password"],
            database=cfg["database"],
            charset="utf8mb4",
            autocommit=True,
            cursorclass=pymysql.cursors.DictCursor,
        )

    # ---------- 查询 ----------
    def one(self, sql: str, args=None):
        with self.conn.cursor() as cur:
            cur.execute(sql, args or ())
            return cur.fetchone()

    def all(self, sql: str, args=None):
        with self.conn.cursor() as cur:
            cur.execute(sql, args or ())
            # pymysql 空结果返回的是 tuple，统一转成 list，避免与 [] 比较时误判
            return list(cur.fetchall())

    def scalar(self, sql: str, args=None):
        row = self.one(sql, args)
        if not row:
            return None
        return list(row.values())[0]

    # ---------- 写 ----------
    def execute(self, sql: str, args=None) -> int:
        with self.conn.cursor() as cur:
            return cur.execute(sql, args or ())

    def close(self):
        try:
            self.conn.close()
        except Exception:
            pass

    # ---------- 业务封装 ----------
    def create_materiel(self, code: str, desc: str = "自动化测试物料", mat_type: str = "01"):
        self.execute(
            "INSERT INTO sp_materile "
            "(id, materiel, materiel_desc, unit, mat_type, create_time, create_username, update_time, update_username, is_deleted) "
            "VALUES (REPLACE(UUID(),'-',''), %s, %s, '个', %s, NOW(), 'autotest', NOW(), 'autotest', '0')",
            (code, desc, mat_type),
        )
        return code

    def delete_materiel(self, code: str):
        self.execute("DELETE FROM sp_inventory_flow WHERE materiel_code = %s", (code,))
        self.execute("DELETE FROM sp_inventory WHERE materiel_code = %s", (code,))
        self.execute(
            "DELETE r FROM sp_work_order_requirement r "
            "JOIN sp_work_order w ON w.order_code = r.order_code WHERE w.materiel_code = %s",
            (code,),
        )
        self.execute("DELETE FROM sp_work_order WHERE materiel_code = %s", (code,))
        self.execute("DELETE FROM sp_materile WHERE materiel = %s", (code,))

    def inventory(self, materiel_code: str, warehouse_code: str = None, location_code: str = None):
        sql = "SELECT * FROM sp_inventory WHERE materiel_code = %s"
        args = [materiel_code]
        if warehouse_code is not None:
            sql += " AND warehouse_code = %s"
            args.append(warehouse_code)
        if location_code is not None:
            sql += " AND location_code = %s"
            args.append(location_code)
        return self.one(sql, tuple(args))

    def inventory_list(self, materiel_code: str):
        return self.all("SELECT * FROM sp_inventory WHERE materiel_code = %s", (materiel_code,))

    def latest_order(self, materiel_code: str):
        return self.one(
            "SELECT * FROM sp_work_order WHERE materiel_code = %s ORDER BY create_time DESC, order_code DESC LIMIT 1",
            (materiel_code,),
        )

    def flows(self, order_code: str):
        return self.all(
            "SELECT * FROM sp_inventory_flow WHERE order_code = %s ORDER BY flow_code", (order_code,)
        )

    def requirement(self, order_code: str):
        return self.all(
            "SELECT * FROM sp_work_order_requirement WHERE order_code = %s", (order_code,)
        )
