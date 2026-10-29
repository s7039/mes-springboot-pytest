# MES 接口自动化测试（pytest）

针对 MES-Springboot（二次开发版）的接口自动化测试框架，覆盖登录鉴权、仓库、库存、工单与并发场景。

## 目录结构

```
pytest-mes/
├── config.yaml            # 环境、账号、数据库配置
├── conftest.py            # 全局 fixture：登录客户端、数据库、测试数据
├── common/
│   ├── client.py          # HTTP 客户端（会话保持、统一断言）
│   └── db.py              # 数据库直连（用于造数据与落库校验）
├── api/                   # 接口封装层：只发请求，不断言
│   ├── auth_api.py
│   ├── warehouse_api.py
│   ├── inventory_api.py
│   └── workorder_api.py
└── testcases/             # 用例层：断言写在这里
    ├── test_01_auth.py
    ├── test_02_warehouse.py
    ├── test_03_inventory.py
    ├── test_04_workorder.py
    └── test_05_concurrency.py
```

分层原则：**接口封装与断言分离**——接口变更只改 `api/`，用例只关心业务。

## 前置条件

1. MES 应用已启动（默认 `http://localhost:9090`）
2. MySQL 可访问，库名 `sparchetype`
3. **验证码开关**：接口自动化无法识别图形验证码，已在 `application-dev.yml` 开启
   ```yaml
   mes:
     test:
       captcha-bypass: true
   ```
   该开关默认 `false`，只在开发环境开启，生产 profile 不受影响。

## 安装与运行

项目里已经带了可直接使用的虚拟环境（`.venv`，已装好依赖）：

```powershell
cd D:\workspace\pytest-mes
.\.venv\Scripts\python.exe -m pytest              # 跑全部
.\.venv\Scripts\python.exe -m pytest -m smoke     # 只跑冒烟
.\.venv\Scripts\python.exe -m pytest testcases\test_05_concurrency.py -v   # 只跑并发
.\.venv\Scripts\python.exe -m pytest --html=reports\report.html            # 生成 HTML 报告
```

如果用你自己的 Python：

```bash
pip install -r requirements.txt
pytest
```

## 断言的三层结构

每条用例都按三层校验，避免“接口返回 200 就算通过”：

| 层 | 校验内容 |
|---|---|
| 1 | HTTP 状态码（200 / 401） |
| 2 | 业务码 `code`（0 成功，1 失败）与 `msg` 文案 |
| 3 | 数据库落库结果（库存数量、流水记录、工单状态） |

## 覆盖的用例

共 **29 个测试函数**，最近一次执行：**29 passed in 2.08s**（报告见 `reports/report.html`）。

对应手工用例表 `MES测试用例表.xlsx` 中的 **24 条**（一个测试函数可能覆盖多条用例编号）；
表内其余 22 条为手工执行，清单见 `测试结论摘要.txt` 第二节。

| 文件 | 覆盖点 | 对应手工用例 |
|---|---|---|
| test_01_auth | 未登录 401、登出后会话失效、登录可用 | AUTH-001、AUTH-005 |
| test_02_warehouse | 新增/编号/库位容量（含取整）/必填/非法容量/级联删除/编号回收/分页查询 | WH-001、WH-003~007 |
| test_03_inventory | 可用量计算、有库存不允许删除、零库存可删、入库流水 | INV-001~003、CF-001 |
| test_04_workorder | 入库确认链路、4 类参数校验、容量校验、缺料、出库锁定→扣减、重复确认、删除释放锁、已完成禁止删除 | WO-001/002/003/004/006/010、CF-001/002/003/006 |
| test_05_concurrency | 20 并发不超锁、10 并发确认只生效一次、20 并发取号唯一 | CON-002、CON-003、CON-004 |

合计覆盖 24 条手工用例：AUTH-001/005、WH-001/003/004/005/006/007、INV-001/002/003、
CF-001/002/003/006、WO-001/002/003/004/006/010、CON-002/003/004。

## 设计说明
1. **会话保持**：`requests.Session()` 自动携带 Cookie，登录一次复用整个测试会话。
2. **数据自造自清**：每个用例用独立物料编码（`AT` + 时间戳），fixture 负责创建与清理，用例之间互不污染。
3. **并发用例用线程池**：`ThreadPoolExecutor` 一次提交 N 个请求后统一 `wait()`，让请求尽可能同时发出，而不是被串行化。
4. **落库校验优先于接口返回**：接口说成功不代表数据对，库存、流水、锁定量都要回查数据库。
