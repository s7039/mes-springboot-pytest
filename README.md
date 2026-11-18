# MES-Springboot 项目集

![ci](https://github.com/s7039/mes-springboot-pytest/actions/workflows/ci.yml/badge.svg)

包含两个项目：**MES 制造执行系统**（二次开发）与**接口自动化测试工程**（Python）。


## 目录结构

```
MES-Springboot/
├── MES-Springboot-master/      MES 系统（Java）
│   ├── mes/                    应用源码（Spring Boot 工程）
│   ├── scripts/sql/            建库脚本（MES-TEXT.sql，34 张表）
│   ├── docs/                   截图与文档
│   └── README.md               改造说明、技术栈对照、核心实现、测试记录
└── pytest-mes/                 接口自动化（Python）
    ├── api/                    接口封装层
    ├── testcases/              29 条用例
    ├── conftest.py             登录、数据库、测试数据 fixture
    ├── MES测试用例表.xlsx       46 条手工用例（含缺陷记录与执行统计）
    ├── 测试结论摘要.txt         测试范围、结果、缺陷、关键验证点
    └── README.md               说明
```
