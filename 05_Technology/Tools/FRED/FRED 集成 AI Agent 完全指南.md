---
date: 2026-02-13
tags:
  - research
  - data-source
  - macroeconomics
  - FRED
  - MCP
status: completed
---

# Federal Reserve Economic Data 集成 AI Agent 完全指南

> **FRED** 是美联储圣路易斯联邦储备银行（Federal Reserve Bank of St. Louis）经济研究部门维护的在线经济数据库，自 1991 年运行至今，是全球最权威的宏观经济数据平台之一。官网：[fred.stlouisfed.org](https://fred.stlouisfed.org)

---

## 1. 平台概况

| 维度 | 详情 |
|------|------|
| **运营方** | Federal Reserve Bank of St. Louis, Research Department |
| **上线时间** | 1991 年（至今 35 年） |
| **数据规模** | **840,000+** 条经济时间序列（Time Series） |
| **数据来源** | **118 个** 权威机构，包括美联储（Federal Reserve Board）、劳工统计局（BLS）、经济分析局（BEA）、人口普查局（Census Bureau）、世界银行（World Bank）、国际货币基金组织（IMF）、经合组织（OECD）、欧盟统计局（Eurostat）等 |
| **数据频率** | Daily / Weekly / Monthly / Quarterly / Annual（5 种粒度） |
| **数据格式** | 标准化时间序列（Date + Value），支持 JSON / XML Output |
| **访问方式** | ① 网站交互式浏览与图表 ② RESTful API（HTTPS） ③ 第三方客户端库（Python / R / JS 等） ④ MCP Server（AI Agent 集成） |
| **费用** | **完全免费**，API Key 免费即时申请 |
| **API Key 申请** | [fred.stlouisfed.org/docs/api/api_key.html](https://fred.stlouisfed.org/docs/api/api_key.html) |
| **姊妹平台** | **ALFRED**（ArchivaL FRED）—— 提供历史数据修订版本（Vintage Data），可追溯每个时间点的数据快照，回答"当时官方公布的数据是什么" |

> [!TIP]
> FRED 的核心价值在于其**一级数据源聚合**能力：它将分散在数十个政府机构的原始数据统一标准化、持续更新，并提供强大的 API 接口。华尔街投行、对冲基金、学术机构广泛将 FRED 作为宏观经济数据的**黄金标准**。

---

## 2. 核心数据集分类

FRED 按 **8 大类** 组织全部 840,000+ 条数据系列。以下为每个分类的详细说明、规模及最核心的指标（附 Series ID，可直接用于 API 查询）。

### 2.1 Money, Banking, & Finance（货币、银行与金融）— 21,000+ 系列

涵盖**利率体系**、**汇率**、**货币供应**、**金融市场**和**银行系统**的全维度数据，是理解**美联储货币政策传导机制**的核心数据集。

| 子分类 | 系列数 | 核心指标 (Series ID) | 说明 |
|--------|--------|---------------------|------|
| **Interest Rates** | 940+ | `FEDFUNDS`（联邦基金利率）<br>`DGS10`（10 年期国债收益率）<br>`DGS2`（2 年期国债收益率）<br>`T10Y2Y`（10Y-2Y 利差）<br>`T10YIE`（10 年期 Breakeven 通胀率） | 覆盖从隔夜到 30 年的完整收益率曲线，是定价所有金融资产的基石 |
| **Exchange Rates** | 10+ | `DEXUSEU`（USD/EUR）<br>`DEXJPUS`（JPY/USD）<br>`DTWEXBGS`（美元指数-广义） | 主要货币对 & 贸易加权美元指数 |
| **Monetary Data** | 1,000+ | `M2SL`（M2 货币供应量）<br>`BOGMBASE`（基础货币）<br>`WALCL`（美联储资产负债表总规模） | 流动性分析核心数据，QE/QT 追踪 |
| **Financial Indicators** | 11,000+ | `VIXCLS`（VIX 恐慌指数）<br>`SP500`（标普 500 指数）<br>`BAMLH0A0HYM2`（ICE BofA 高收益债 OAS）<br>`WILL5000IND`（Wilshire 5000 全市场指数） | 金融市场风险偏好与信贷条件 |
| **Banking** | 4,800+ | 银行信贷、商业银行总资产、存贷比、准备金 | 银行体系健康度评估 |
| **Business Lending** | 2,100+ | 商业与工业贷款额、信贷条件调查 | 企业融资环境 |

### 2.2 Population, Employment, & Labor Markets（人口与就业）— 48,000+ 系列

美国劳动力市场的**全景数据集**，覆盖来自**两大就业调查**（Household Survey + Establishment Survey）以及 JOLTS、Weekly Claims 等。

| 子分类 | 系列数 | 核心指标 (Series ID) | 说明 |
|--------|--------|---------------------|------|
| **Current Population Survey (CPS)** | 6,700+ | `UNRATE`（U-3 失业率）<br>`U6RATE`（U-6 广义失业率）<br>`CIVPART`（劳动参与率）<br>`LNS12300060`（25-54 岁劳参率） | 来自 BLS 家庭调查 |
| **Current Employment Statistics (CES)** | 400+ | `PAYEMS`（非农就业总人数）<br>`CES0500000003`（平均时薪） | 来自 BLS 企业调查，Non-Farm Payrolls |
| **ADP Employment** | 60+ | ADP 非农就业变化 | 私营部门就业前瞻 |
| **JOLTS** | 210+ | `JTSJOL`（职位空缺数）<br>`JTSQUR`（离职率） | 劳动力市场供需动态 |
| **Weekly Claims** | 6+ | `ICSA`（首次申请失业金人数）<br>`CCSA`（持续申请人数） | 高频就业市场指标（每周更新） |
| **Productivity & Costs** | 18,000+ | 劳动生产率、单位劳动成本 (ULC) | 通胀成本推动因素 |

### 2.3 National Accounts（国民账户）— 56,000+ 系列

以 **GDP** 为核心的国民经济核算体系，包括收入法、支出法分解以及政府债务、资金流量等。

| 子分类 | 系列数 | 核心指标 (Series ID) | 说明 |
|--------|--------|---------------------|------|
| **NIPA (GDP)** | 13,000+ | `GDP`（名义 GDP）<br>`GDPC1`（实际 GDP）<br>`A191RL1Q225SBEA`（实际 GDP QoQ 年化变化率）<br>`PCEC96`（实际个人消费支出） | 经济增长的终极衡量标准 |
| **Federal Government Debt** | 10+ | `GFDEBTN`（联邦债务总额）<br>`GFDEGDQ188S`（债务/GDP 比率） | 财政可持续性评估 |
| **Flow of Funds** | 41,000+ | 家庭/企业/政府部门资金流量表 | 部门间资产负债联动 |
| **Trade & International** | 460+ | `BOPGSTB`（商品贸易差额）<br>`IEABC`（经常账户差额） | 国际贸易与资本流动 |

### 2.4 Production & Business Activity（生产与商业活动）— 86,000+ 系列

覆盖工业生产、房地产、零售、制造业、经济周期等**实体经济**运行数据。

| 子分类 | 系列数 | 核心指标 (Series ID) | 说明 |
|--------|--------|---------------------|------|
| **Industrial Production** | 2,200+ | `INDPRO`（工业生产指数）<br>`TCU`（产能利用率） | 制造业景气度与产出缺口 |
| **Housing** | 50,000+ | `HOUST`（新屋开工数）<br>`PERMIT`（建筑许可证）<br>`CSUSHPISA`（S&P/Case-Shiller 房价指数）<br>`EXHOSLUSM495S`（成屋库存） | 房地产周期全链条数据 |
| **Retail Trade** | 290+ | `RSAFS`（零售及食品服务销售额） | 消费支出直接指标 |
| **Manufacturing** | 1,100+ | ISM PMI 相关指标 | 制造业景气调查 |
| **Business Cycle** | 130+ | `USREC`（经济衰退区间，0/1 指标）<br>`SAHMREALTIME`（Sahm Rule 实时指标） | NBER 经济周期判定 & 衰退预测 |
| **Consumer Sentiment** | — | `UMCSENT`（密歇根大学消费者信心指数） | 消费者信心前瞻 |

### 2.5 Prices（价格）— 15,000+ 系列

全维度**通胀监测**数据集，覆盖消费者价格、生产者价格、大宗商品与房价。

| 子分类 | 系列数 | 核心指标 (Series ID) | 说明 |
|--------|--------|---------------------|------|
| **CPI & PCE** | 330+ | `CPIAUCSL`（CPI 城市消费者-所有项目）<br>`CPILFESL`（核心 CPI，排除食品与能源）<br>`PCEPILFE`（核心 PCE，**美联储首选通胀指标**） | 通胀测量的两大体系 |
| **PPI** | 11,000+ | 各行业生产者价格指数 | 上游成本传导 |
| **Commodities** | 1,600+ | `DCOILWTICO`（WTI 原油日价格）<br>`GOLDAMGBD228NLBM`（伦敦金价） | 大宗商品价格 |
| **House Price Indexes** | 340+ | S&P/Case-Shiller、FHFA 房价指数 | 房价通胀 |
| **Employment Cost Index** | 200+ | 就业成本指数 | 工资通胀压力 |

### 2.6 International Data（国际数据）— 130,000+ 系列

覆盖全球主要经济体的宏观指标，数据源包括 **IMF**、**World Bank**、**OECD**、各国央行等。

| 子分类 | 系列数 | 说明 |
|--------|--------|------|
| **Countries** | 120,000+ | 按国家分组，覆盖 GDP、CPI、失业率、利率等核心指标 |
| **Indicators** | 82,000+ | 同一指标跨国对比（如"各国 GDP 增速"） |
| **Institutions** | 7,100+ | 按数据发布机构分组（IMF、World Bank、OECD、ECB 等） |

### 2.7 U.S. Regional Data（美国区域数据）— 460,000+ 系列

美国区域经济数据的**最大公开数据集**，按多种地理划分覆盖经济指标：

- **States**（50 州 + DC）：450,000+ 系列
- **Census Regions** / **BEA Regions** / **BLS Regions** / **Federal Reserve Districts**
- 指标包括：各州 GDP、失业率、个人收入、房价、人口等

### 2.8 Academic Data（学术数据）— 15,000+ 系列

为学术研究提供的专门数据集，包括：

| 数据集 | 系列数 | 说明 |
|--------|--------|------|
| **NBER Macrohistory Database** | 2,400+ | 可追溯至 1800 年代的美国宏观历史数据 |
| **Penn World Table** (7.1 & 11.0) | 8,400+ | 跨国实际 GDP、生产率、资本存量比较 |
| **Economic Policy Uncertainty** | 420+ | Baker-Bloom-Davis 经济政策不确定性指数 |
| **Kim-Wright Model** | 3+ | 名义利率期限结构模型 |
| **Banking & Monetary Statistics, 1914-1941** | 1,400+ | 大萧条前后的货币与银行数据 |

---

## 3. API 能力概览

### 3.1 API 架构

| 维度 | 说明 |
|------|------|
| **协议** | RESTful（HTTPS），基于 URL 参数构造请求 |
| **数据格式** | JSON（推荐） / XML |
| **认证** | API Key（免费申请，无硬性调用限制，建议合理限速） |
| **版本** | **V1**：按 Series 级别增量查询 / **V2**：按 Release 级别批量导出 |

### 3.2 核心 Endpoints（共 31 个）

| Endpoint Group | 典型接口 | 用途 |
|---------------|----------|------|
| **Categories** | `fred/category`, `fred/category/children`, `fred/category/series` | 分类浏览、层级导航 |
| **Releases** | `fred/releases`, `fred/release/dates`, `fred/release/series` | 数据发布日历与内容 |
| **Series** | `fred/series`, `fred/series/observations`, `fred/series/search` | **核心接口**——数据查询与搜索 |
| **Sources** | `fred/sources`, `fred/source/releases` | 数据来源机构查询 |
| **Tags** | `fred/tags`, `fred/related_tags`, `fred/tags/series` | 标签系统与关联发现 |
| **Maps** | GeoJSON 格式的区域数据 | 地理可视化 |

### 3.3 数据变换能力（Units Transformation）

API 内置 **8 种** 数据变换，服务端即时计算，无需客户端处理：

| `units` 参数值 | 变换类型 | 典型应用 |
|----------------|----------|----------|
| `lin` | 原始水平值（Levels） | 绝对值分析 |
| `chg` | 环比变化（Change） | 短期波动 |
| `ch1` | 同比变化（Change from Year Ago） | 年度对比 |
| `pch` | 环比变化率 %（Percent Change） | 增长率 |
| `pc1` | **同比变化率 %** (Percent Change from Year Ago) | **最常用**—— YoY Growth |
| `pca` | 复合年化变化率（Compounded Annual Rate） | 年化分析 |
| `cch` | 连续复利变化率 | 学术建模 |
| `log` | 自然对数（Natural Log） | 趋势平滑、弹性分析 |

### 3.4 频率聚合能力

当请求的频率低于原始数据频率时，API 支持自动聚合：

| `frequency` 参数 | 聚合到 | `aggregation_method` 选项 |
|------------------|--------|---------------------------|
| `d` / `w` / `m` / `q` / `a` | 日 / 周 / 月 / 季 / 年 | `avg`（平均值）/ `sum`（求和） / `eop`（期末值） |

> **示例**：月度 CPI 数据请求年度平均值 → `frequency=a&aggregation_method=avg`

---

## 4. MCP 工具：fred-mcp-server

### 4.1 简介

[**fred-mcp-server**](https://github.com/stefanoamorelli/fred-mcp-server) 是由社区开发者 Stefano Amorelli 创建的开源 MCP Server，已**收录于 MCP 官方社区服务器列表**（[modelcontextprotocol/servers](https://github.com/modelcontextprotocol/servers)），是目前最成熟的 FRED MCP 集成方案。

| 维度 | 详情 |
|------|------|
| **GitHub** | [stefanoamorelli/fred-mcp-server](https://github.com/stefanoamorelli/fred-mcp-server) |
| **npm** | [`fred-mcp-server`](https://www.npmjs.com/package/fred-mcp-server) v1.0.2 |
| **语言** | TypeScript (Node.js) |
| **数据覆盖** | 全部 800,000+ FRED 经济数据系列 |
| **工具数量** | 3 个（`fred_browse` / `fred_search` / `fred_get_series`） |
| **特性** | npm 一键安装、Smithery 集成、Docker 支持、Streamable HTTP Transport |

### 4.2 安装配置

在 MCP 配置文件（`claude_desktop_config.json` / `mcp.json` / `.gemini/settings.json`）中添加：

```json
{
  "mcpServers": {
    "fred-mcp-server": {
      "command": "npx",
      "args": ["-y", "fred-mcp-server"],
      "env": {
        "FRED_API_KEY": "<your-fred-api-key>"
      }
    }
  }
}
```

> [!IMPORTANT]
> 需先在 [FRED 官网](https://fred.stlouisfed.org/docs/api/api_key.html) 免费申请 **API Key**。

### 4.3 工具详解

#### 工具 1：`fred_browse` — 浏览数据目录

**功能**：浏览 FRED 完整数据目录，支持按 Category（分类）、Release（发布）、Source（来源）三个维度导航，也可直接获取某个分类或发布下的全部系列。

**参数**：

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `browse_type` | string | ✅ | 浏览类型：`categories`（分类树）、`releases`（数据发布）、`sources`（数据来源）、`category_series`（某分类下全部系列）、`release_series`（某发布下全部系列） |
| `category_id` | number | — | 分类 ID，用于 `categories`（浏览子分类）和 `category_series`（获取系列） |
| `release_id` | number | — | 发布 ID，用于 `release_series` |
| `limit` | number | — | 返回结果数上限（默认 50） |
| `offset` | number | — | 分页偏移量 |
| `order_by` | string | — | 排序字段 |
| `sort_order` | string | — | 排序方向：`asc` / `desc` |

**使用场景**：

```
# 浏览顶级分类
fred_browse(browse_type="categories")

# 浏览"Interest Rates"子分类（category_id=22）
fred_browse(browse_type="categories", category_id=22)

# 获取"Employment Situation"发布下的全部系列
fred_browse(browse_type="release_series", release_id=50)

# 获取"Prices"分类（category_id=32455）下的前20个系列
fred_browse(browse_type="category_series", category_id=32455, limit=20)
```

---

#### 工具 2：`fred_search` — 搜索数据系列

**功能**：按关键词、标签或过滤条件搜索 FRED 数据系列。返回匹配的系列 ID、标题、频率、单位等元数据。当你知道要找什么指标但不确定 Series ID 时使用。

**参数**：

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `search_text` | string | — | 搜索关键词（在标题和描述中全文搜索） |
| `search_type` | string | — | `full_text`（全文搜索，默认）/ `series_id`（按 ID 搜索） |
| `tag_names` | string | — | 按标签过滤（逗号分隔），如 `"gdp,quarterly"` |
| `exclude_tag_names` | string | — | 排除标签（逗号分隔） |
| `limit` | number | — | 返回结果数上限（默认 25） |
| `offset` | number | — | 分页偏移量 |
| `order_by` | string | — | 排序字段：`search_rank`、`popularity`、`last_updated` 等 |
| `sort_order` | string | — | 排序方向：`asc` / `desc` |
| `filter_variable` | string | — | 过滤维度：`frequency` / `units` / `seasonal_adjustment` |
| `filter_value` | string | — | 过滤值（如 `"Quarterly"`、`"Seasonally Adjusted"` 等） |

**使用场景**：

```
# 搜索失业率相关数据，按热度排序
fred_search(search_text="unemployment rate", order_by="popularity", sort_order="desc")

# 搜索季度频率的 GDP 数据
fred_search(search_text="GDP", filter_variable="frequency", filter_value="Quarterly")

# 按标签搜索通胀相关指标
fred_search(tag_names="inflation,monthly", limit=10)

# 搜索特定 Series ID
fred_search(search_text="CPIAUCSL", search_type="series_id")
```

---

#### 工具 3：`fred_get_series` — 获取时间序列数据

**功能**：按 Series ID 获取具体的时间序列数据（Observations）。支持日期范围筛选、数据变换（如同比变化率）、频率聚合等，是**获取实际数据的核心工具**。

**参数**：

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `series_id` | string | ✅ | FRED Series ID（如 `"GDP"`, `"UNRATE"`, `"CPIAUCSL"`） |
| `observation_start` | string | — | 起始日期（`YYYY-MM-DD` 格式） |
| `observation_end` | string | — | 结束日期（`YYYY-MM-DD` 格式） |
| `limit` | number | — | 返回观测值数量上限 |
| `offset` | number | — | 分页偏移量 |
| `sort_order` | string | — | `asc`（升序，默认）/ `desc`（降序） |
| `units` | string | — | 数据变换：`lin`（原值）、`chg`（环比变化）、`pch`（环比%）、`pc1`（同比%）、`pca`（年化%）、`log`（对数） |
| `frequency` | string | — | 频率聚合：`d`（日）、`w`（周）、`m`（月）、`q`（季）、`a`（年） |
| `aggregation_method` | string | — | 聚合方式：`avg`（均值）、`sum`（求和）、`eop`（期末值） |

**使用场景**：

```
# 获取最近3年的联邦基金利率
fred_get_series(series_id="FEDFUNDS", observation_start="2023-01-01")

# 获取 CPI 的同比变化率（通胀率），最近2年
fred_get_series(series_id="CPIAUCSL", units="pc1", observation_start="2024-01-01")

# 获取 GDP 年度数据（季度→年度聚合，取均值）
fred_get_series(series_id="GDPC1", frequency="a", aggregation_method="avg")

# 获取10年期国债收益率，最新10条，降序
fred_get_series(series_id="DGS10", limit=10, sort_order="desc")

# 获取失业率的环比变化
fred_get_series(series_id="UNRATE", units="chg", observation_start="2020-01-01")
```

---

## 5. 使用场景与应用用例

### 5.1 宏观经济研报：利率周期与通胀分析

**场景**：撰写月度/季度宏观经济研报，需要综合利率、通胀、就业数据判断经济所处周期。

**操作流程**：

| 步骤 | 工具调用 | 获取内容 |
|------|----------|----------|
| 1. 利率环境 | `fred_get_series(series_id="FEDFUNDS")` | 当前联邦基金利率水平与趋势 |
| 2. 收益率曲线 | `fred_get_series(series_id="T10Y2Y")` | 10Y-2Y 利差（倒挂=衰退预警） |
| 3. 通胀走势 | `fred_get_series(series_id="CPIAUCSL", units="pc1")` | CPI YoY% 趋势 |
| 4. 核心PCE | `fred_get_series(series_id="PCEPILFE", units="pc1")` | 美联储首选通胀指标 YoY% |
| 5. 就业市场 | `fred_get_series(series_id="UNRATE")` | 失业率 |
| 6. 衰退概率 | `fred_get_series(series_id="SAHMREALTIME")` | Sahm Rule（>0.5 = 衰退信号） |

**分析逻辑**：当 `T10Y2Y` < 0（倒挂）+ `FEDFUNDS` 处于高位 + `SAHMREALTIME` 接近 0.5 → 经济放缓/衰退风险上升 → 建议降低风险敞口。

---

### 5.2 个股深度分析：宏观环境评估章节

**场景**：在美股个股深度报告中增加"宏观环境评估"章节，为估值和业务前景提供宏观背景。

**按行业定制查询**：

| 目标行业 | 查询指标 | 工具调用 |
|----------|----------|----------|
| **科技/成长股** | 10 年期收益率（折现率敏感性） | `fred_get_series(series_id="DGS10")` |
| **银行/金融** | 利差环境（净息差驱动） | `fred_get_series(series_id="T10Y2Y")` |
| **消费/零售** | 零售销售 + 消费者信心 | `fred_get_series(series_id="RSAFS")` |
| **房地产** | 新屋开工 + 房价指数 | `fred_get_series(series_id="HOUST")` |
| **能源** | WTI 原油价格 | `fred_get_series(series_id="DCOILWTICO")` |
| **通用** | VIX 恐慌指数（市场情绪） | `fred_get_series(series_id="VIXCLS")` |

---

### 5.3 AI 泡沫研究：流动性与估值环境

**场景**：研究美股 AI 板块是否存在泡沫，需要评估**宏观流动性环境**对高估值科技股的支撑程度。

**操作流程**：

| 分析维度 | 工具调用 | 分析目的 |
|----------|----------|----------|
| 无风险利率 | `fred_get_series(series_id="DGS10", observation_start="2020-01-01")` | 高利率环境下成长股的 DCF 折现压力 |
| 流动性环境 | `fred_get_series(series_id="WALCL")` | 美联储资产负债表规模（QE/QT 对流动性的影响） |
| 信贷条件 | `fred_get_series(series_id="BAMLH0A0HYM2")` | 高收益债利差（信贷紧缩=风险资产承压） |
| 风险偏好 | `fred_get_series(series_id="VIXCLS", observation_start="2024-01-01")` | VIX 处于低位=市场过度乐观警示 |
| 货币供应 | `fred_get_series(series_id="M2SL", units="pc1")` | M2 增速（流动性收紧→高估值压缩） |
| 经济衰退风险 | `fred_get_series(series_id="USREC")` | 美国是否处于衰退区间 |

**核心洞察**：当 `DGS10` > 4.5% + `M2SL` YoY% < 0 + `BAMLH0A0HYM2` > 400bp → **流动性环境不支撑高估值科技股**，泡沫风险上升。

---

### 5.4 量化策略回测：宏观因子构建

**场景**：构建基于宏观经济因子的量化投资模型，将 FRED 数据作为因子输入。

**常用因子构建**：

| 因子名称 | 数据源 | 构造方法 |
|----------|--------|----------|
| **Yield Curve Slope** | `fred_get_series(series_id="T10Y2Y")` | 直接使用，\<0 为空头信号 |
| **Inflation Momentum** | `fred_get_series(series_id="CPIAUCSL", units="pch")` | CPI 环比变化趋势 |
| **Labor Market Stress** | `fred_get_series(series_id="ICSA")` | 初次申领人数突破阈值=压力信号 |
| **Monetary Tightness** | `fred_get_series(series_id="FEDFUNDS")` - `fred_get_series(series_id="CPIAUCSL", units="pc1")` | 实际利率 = FFR - CPI YoY% |
| **Financial Conditions** | `fred_get_series(series_id="BAMLH0A0HYM2")` | 信用利差扩大=金融条件收紧 |

---

### 5.5 快速数据探索：发现新指标

**场景**：不确定 FRED 是否有某类数据，或需要探索数据目录。

**操作流程**：

```
# Step 1: 搜索关键词，看看有什么
fred_search(search_text="consumer confidence", order_by="popularity")

# Step 2: 找到感兴趣的 Series ID 后，浏览它所在的分类
fred_browse(browse_type="categories", category_id=<返回的category_id>)

# Step 3: 获取数据验证
fred_get_series(series_id="UMCSENT", observation_start="2020-01-01")
```

---

## 6. 与现有投研工具链的协同

> FRED 的核心优势在于**宏观经济面**，与 Yahoo Finance（个股行情/财务数据）、EDGAR（SEC 公司文件）形成**三角互补**：

| 工具 | 数据维度 | 核心能力 | MCP Server |
|------|----------|----------|------------|
| **FRED** | 宏观经济 | 利率、通胀、就业、GDP、流动性 | `fred-mcp-server` ✅ |
| **Yahoo Finance** | 个股市场 | 股价、财务报表、分析师评级、期权 | `yfinance` ✅ |
| **EDGAR** | 公司文件 | 10-K/10-Q、Insider Trading、SEC Filings | `edgartools` ✅ |

三者组合构成完整的**"宏观→行业→个股"** 研究链条，均已通过 MCP Server 实现 AI Agent 自动化调用。

---

## 参考来源

| # | 来源 | 类型 | 可信度 |
|---|------|------|--------|
| 1 | [FRED 官网](https://fred.stlouisfed.org) | 官方 | 高 |
| 2 | [FRED API 文档](https://fred.stlouisfed.org/docs/api/fred/) | 官方 | 高 |
| 3 | [FRED Categories 页面](https://fred.stlouisfed.org/categories) | 官方 | 高 |
| 4 | [What is FRED?](https://fredhelp.stlouisfed.org/fred/about/about-fred/what-is-fred/) | 官方 | 高 |
| 5 | [Fed DDP-FRED Partnership](https://www.federalreserve.gov/data/data-download-fred-information.htm) | 官方 | 高 |
| 6 | [stefanoamorelli/fred-mcp-server (GitHub)](https://github.com/stefanoamorelli/fred-mcp-server) | 社区 | 高 |
| 7 | [fred-mcp-server (npm)](https://www.npmjs.com/package/fred-mcp-server) | 社区 | 高 |
| 8 | [MCP 官方社区服务器列表](https://github.com/modelcontextprotocol/servers) | 官方 | 高 |
