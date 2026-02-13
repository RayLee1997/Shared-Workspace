---
date: 2026-02-13
tags:
  - world-bank
  - open-data
  - API
  - macro-economics
  - MCP
status: completed
---

# World Bank 公开数据集调研

> **执行摘要**：World Bank 提供全球最大的发展经济学公开数据平台之一，包含 **16,000+ 时间序列指标**、**45+ 数据库**、覆盖 **217 个经济体**，数据可追溯超过 **50 年**。其 API 完全免费、无需认证，是宏观经济研究和股票基本面分析的核心数据源。目前已有第三方 MCP Server 可用于 AI Agent 集成。

---

## 一、数据接口（API）架构

World Bank 提供 **四大公开 API**，覆盖指标数据、数据目录、文档检索和新一代数据平台：

### 1.1 Indicators API V2（核心接口）

| 属性           | 说明                                   |
| ------------ | ------------------------------------ |
| **Base URL** | `https://api.worldbank.org/v2/`      |
| **认证**       | ❌ 无需 API Key，完全开放                    |
| **响应格式**     | JSON、XML（默认 XML，加 `?format=json` 切换） |
| **分页**       | 支持 `page`, `per_page` 参数             |
| **版本**       | V2（V1 已于 2020 年 6 月停用）               |

**核心查询端点**：

```
# 查询某国家某指标数据
GET /v2/country/{country_code}/indicator/{indicator_code}

# 示例：获取美国 GDP（当前美元）
GET /v2/country/US/indicator/NY.GDP.MKTP.CD?format=json

# 查询所有指标列表
GET /v2/indicator?format=json

# 查询所有数据源
GET /v2/sources?format=json

# 按主题查询指标
GET /v2/topic/{topic_id}/indicator?format=json

# 日期范围筛选
GET /v2/country/US/indicator/NY.GDP.MKTP.CD?date=2015:2024&format=json
```

**支持的查询维度**：

- **Country**：ISO 国家代码（如 `US`, `CN`, `JP`）或区域聚合（如 `EAS` 东亚太平洋）
- **Indicator**：标准化指标代码（如 `NY.GDP.MKTP.CD` = GDP）
- **Date**：年份或年份范围（如 `2020` 或 `2015:2024`）
- **Source**：指定某数据库（如 `source=2` = WDI）

### 1.2 Data Catalog API

| 属性 | 说明 |
|---|---|
| **平台** | [World Bank Data Catalog](https://datacatalog.worldbank.org) |
| **功能** | 检索数千个可下载数据集的元数据信息 |
| **文档** | 2021 年 9 月重构，[临时文档](https://gist.github.com/tgherzog/e6090f9b2ba74f49f75b228f5c7169b9) |
| **用途** | 发现和定位各类数据集资源 |

### 1.3 Documents & Reports API

| 属性 | 说明 |
|---|---|
| **Base URL** | `https://search.worldbank.org/api/v3/wds` |
| **功能** | 检索 World Bank 公开出版物、政策报告、研究论文 |
| **格式** | JSON / XML |
| **用途** | 研究报告检索、政策文件引用 |

### 1.4 Data360 API（Beta）

| 属性 | 说明 |
|---|---|
| **平台** | [Data360](https://data360.worldbank.org) |
| **状态** | Beta 阶段 |
| **定位** | 新一代数据策展平台，整合分析和可视化工具 |

---

## 二、核心数据集分类

World Bank 的 45+ 数据库可按投资与宏观研究需求分为**五大类别**：

### 2.1 宏观经济基础指标

| 数据集/数据库 | 核心指标 | 指标代码示例 |
|---|---|---|
| **World Development Indicators (WDI)** | GDP、人均 GNI、通胀率、人口 | `NY.GDP.MKTP.CD`, `NY.GNP.PCAP.CD`, `FP.CPI.TOTL.ZG` |
| **Global Economic Prospects (GEP)** | GDP 增长预测、全球贸易展望 | 预测型数据 |
| **Worldwide Governance Indicators** | 政治稳定性、监管质量、法治 | `RQ.EST`, `RL.EST` |

> **WDI 是最重要的数据库**，包含 **1,400+ 时间序列指标**，覆盖 217 个经济体和 40+ 国家组合，是所有研究的起点。

### 2.2 金融与投资环境

| 数据集 | 核心指标 | 投资相关度 |
|---|---|---|
| **Doing Business** | 营商便利度排名、开办企业成本 | ⭐⭐⭐⭐ |
| **International Debt Statistics (IDS)** | 外债总额、债务比率、偿债率 | ⭐⭐⭐⭐⭐ |
| **Global Financial Development** | 金融深度、银行信贷/GDP | ⭐⭐⭐⭐ |
| **上市公司相关** | 上市公司数量、市值/GDP 比率 | ⭐⭐⭐⭐ |

关键金融指标代码：

- `CM.MKT.LCAP.CD` — 上市公司市值（当前美元）
- `CM.MKT.LCAP.GD.ZS` — 市值占 GDP 比例
- `CM.MKT.LDOM.NO` — 上市公司数量
- `FR.INR.LEND` — 贷款利率
- `FR.INR.DPST` — 存款利率
- `BX.KLT.DINV.CD.WD` — FDI 净流入

### 2.3 贸易与国际经济

| 数据集 | 核心指标 |
|---|---|
| **Trade Statistics** | 进出口额、贸易差额、贸易伙伴 |
| **WITS (World Integrated Trade Solution)** | 关税数据、非关税壁垒 |
| **Balance of Payments** | 经常账户、资本账户 |

### 2.4 社会发展与 ESG

| 数据集 | 核心指标 |
|---|---|
| **Human Capital Index** | 人力资本指数、教育年限、健康预期 |
| **Subnational Poverty** | 地方贫困率、收入分配 |
| **Gender Statistics** | 性别平等指标、女性劳动参与率 |
| **Health Nutrition & Population** | 预期寿命、卫生支出 |

### 2.5 基础设施与能源

| 数据集 | 核心指标 |
|---|---|
| **Sustainable Energy** | 可再生能源占比、电力接入率 |
| **Infrastructure** | 互联网渗透率、交通基建 |
| **Climate Change** | 碳排放、气候脆弱性指数 |

---

## 三、在宏观经济与股票分析中的价值评估

### 3.1 宏观经济分析价值（⭐⭐⭐⭐⭐）

World Bank 数据在宏观研究中属于**第一梯队数据源**，与 IMF、OECD 并列：

| 应用场景 | 关键数据 | 分析价值 |
|---|---|---|
| **经济增长趋势** | GDP (Nominal/PPP)、GNI、人均收入 | 判断国家经济阶段与增长动能 |
| **通胀与货币政策** | CPI、PPI、利率 | 理解货币政策收紧/宽松周期 |
| **财政健康** | 政府债务/GDP、财政赤字 | 评估主权信用风险 |
| **外部均衡** | 经常账户/GDP、外汇储备 | 判断货币危机风险 |
| **人口结构** | 年龄结构、抚养比、城市化率 | 长期消费趋势与劳动力供给 |
| **区域比较** | 跨国/跨区域对比 | 识别结构性投资机会 |

**核心优势**：

- 数据标准化程度极高，跨国可比性在所有数据源中**最佳**
- 回溯时间长达 50+ 年，支持超长周期分析
- 覆盖发展中经济体的深度远超 OECD、IMF

### 3.2 股票基本面分析价值（⭐⭐⭐⭐）

World Bank 数据对股票分析的价值主要体现在**自上而下（Top-down）分析框架**中：

| 分析层级 | World Bank 数据角色 | 典型用例 |
|---|---|---|
| **宏观环境评估** | GDP 增速、通胀率 → 判断经济周期位置 | 2024 年某国 GDP 增速放缓 → 周期性行业 Revenue 承压 |
| **行业背景研判** | 互联网渗透率、能源消费 → 行业 TAM 估算 | 新兴市场互联网渗透率 40% → 判断电商 TAM 增长空间 |
| **地缘与政策风险** | 治理指标、营商环境 → 国家风险溢价 | 某国法治指数下降 → 提高 WACC 中的 Country Risk Premium |
| **ESG 筛选** | 碳排放、社会指标 → ESG 评分辅助 | 跨国公司在高碳排国家的 Supply Chain Risk |
| **EM 股票选择** | 经济结构数据 → 识别高增长经济体 | FDI 净流入持续增长 → 利好当地基建/工业股 |

**局限性**：

- 数据频率多为**年度**（部分季度），不适合短期交易信号
- 发布滞后通常 **6-12 个月**，无法反映最新变化
- 不直接提供公司级（Company-level）财务数据

### 3.3 与其他数据源的定位对比

| 数据源 | 强项 | 频率 | 免费 | World Bank 互补性 |
|---|---|---|---|---|
| **IMF (WEO/IFS)** | 宏观预测、国际金融 | 季度/年度 | ✅ | 高度互补，IMF 侧重预测 |
| **OECD** | 发达国家政策指标 | 季度 | 部分 | WB 补充发展中国家数据 |
| **FRED (St. Louis Fed)** | 美国经济数据 | 日/周/月 | ✅ | WB 提供全球维度，FRED 提供美国深度 |
| **Yahoo Finance** | 股价、公司财务 | 实时 | ✅ | 完全互补，WB 做宏观层，YF 做微观层 |
| **Bloomberg/Refinitiv** | 全维度金融终端 | 实时 | ❌ | WB 是免费替代的宏观数据源 |

---

## 四、编程接口与数据获取工具

### 4.1 直接 API 调用

```python
import requests

# 获取中国 2015-2024 GDP 数据
url = "https://api.worldbank.org/v2/country/CN/indicator/NY.GDP.MKTP.CD"
params = {"format": "json", "date": "2015:2024", "per_page": 100}
response = requests.get(url, params=params)
data = response.json()

# data[1] 包含实际数据列表
for item in data[1]:
    print(f"{item['date']}: ${item['value']:,.0f}")
```

### 4.2 Python 第三方库

| 库名 | 功能 | 安装 |
|---|---|---|
| **[wbdata](https://wbdata.readthedocs.io/)** | World Bank API 的 Python 封装，支持 Pandas DataFrame | `pip install wbdata` |
| **[wbpy](https://wbpy.readthedocs.io/)** | 另一个 Python 封装，支持 Climate 和 Indicators 两个 API | `pip install wbpy` |
| **[pandas-datareader](https://pandas-datareader.readthedocs.io/)** | 支持从 World Bank 等多源获取数据 | `pip install pandas-datareader` |

```python
import wbdata
import pandas as pd

# 获取美国和中国的 GDP 数据
indicators = {"NY.GDP.MKTP.CD": "GDP (current US$)"}
df = wbdata.get_dataframe(indicators, country=["US", "CN"])
print(df.head(10))
```

### 4.3 R 语言

| 库名 | 安装 |
|---|---|
| **[wbstats](https://cran.r-project.org/web/packages/wbstats/)** | `install.packages("wbstats")` |
| **WDI** | `install.packages("WDI")` |

---

## 五、MCP Server 可用性分析

### 5.1 官方 MCP Server

> **结论**：World Bank **没有官方提供的 MCP Server**。其数据服务仍以传统 RESTful API 为主。

### 5.2 第三方 MCP Server

目前发现 **唯一一个活跃的第三方 MCP Server**：

#### `anshumax/world_bank_mcp_server`

| 属性 | 说明 |
|---|---|
| **GitHub** | [anshumax/world_bank_mcp_server](https://github.com/anshumax/world_bank_mcp_server) |
| **开发者** | Anshuman Saxena |
| **协议** | Model Context Protocol (MCP) |
| **语言** | Python |
| **运行时** | 需要 `uv` 包管理器 |
| **上架平台** | Smithery、Glama、LobeHub、FlowHunt、Playbooks 等 MCP 市场均有收录 |

**提供的 Tools**：

| Tool 名称 | 功能 |
|---|---|
| `list_countries` | 获取 World Bank API 中所有可用国家列表 |
| `list_indicators` | 获取所有可用指标列表 |
| `analyse_indicators` | 对指定国家的指标进行数据分析（如人口分段、贫困数据等） |

**安装方式**：

```bash
# 方式一：通过 Smithery CLI（推荐）
npx -y @smithery/cli install @anshumax/world_bank_mcp_server --client claude

# 方式二：手动配置
git clone https://github.com/anshumax/world_bank_mcp_server.git
```

手动配置 `claude_desktop_config.json`：

```json
{
  "mcpServers": {
    "world_bank": {
      "command": "uv",
      "args": [
        "--directory",
        "/path/to/world_bank_mcp_server",
        "run",
        "world_bank_mcp_server"
      ]
    }
  }
}
```

**技术栈**：

| 依赖 | 用途 |
|---|---|
| `fastmcp` / `mcp` | MCP 协议实现与通信 |
| `requests` | 调用 World Bank REST API |
| `pandas` | 数据处理与分析 |

### 5.3 AI Agent 集成评估

| 评估维度      | 评分   | 说明                                         |
| --------- | ---- | ------------------------------------------ |
| **功能完备性** | ⭐⭐⭐  | 仅提供 3 个基础 Tool，缺少日期范围筛选、多国比较、特定数据库查询等高级功能  |
| **数据覆盖**  | ⭐⭐⭐⭐ | 底层接入 World Bank 全量 API，理论上可查询所有 16,000+ 指标 |
| **稳定性**   | ⭐⭐⭐  | 第三方个人项目，4 位贡献者，更新频率中等                      |
| **易用性**   | ⭐⭐⭐⭐ | 支持 Smithery 一键安装，配置简单                      |
| **生产可用性** | ⭐⭐   | 适合原型验证和个人研究，不建议用于生产环境                      |

**替代方案建议**：

对于严肃的宏观经济研究 Agent，建议：

1. **直接调用 World Bank REST API**：通过自定义 MCP Server 封装，可实现更精细的查询控制
2. **结合 IMF Data MCP**：与已有的 IMF Data MCP Server 组合使用，形成完整的宏观数据层
3. **自建 MCP Server**：基于 `fastmcp` + `wbdata` Python 库，封装符合自身需求的 Tool 集

---

## 六、结论与行动建议

### 核心结论

1. **World Bank Open Data 是宏观经济研究的必备数据源**，其跨国可比性、时间跨度和免费开放特性在同类数据中无可替代
2. **对股票分析的价值主要在 Top-down 层面**，需与 Yahoo Finance、SEC EDGAR 等公司级数据源配合使用
3. **第三方 MCP Server 已可用但功能有限**，适合快速实验，深度使用建议自建

### 下一步行动

- [ ] **评估是否自建 World Bank MCP Server**：基于 `fastmcp` + `wbdata` 封装更完整的 Tool 集
- [ ] **与 IMF Data MCP 整合设计**：构建统一的宏观数据层 MCP 架构
- [ ] **建立核心指标代码表**：梳理投资分析常用的 50-100 个指标代码，形成速查表

---

> **免责声明**：本报告基于 World Bank 公开信息整理，数据接口和功能可能随 World Bank 更新而变化。调研时间：2026 年 2 月。
