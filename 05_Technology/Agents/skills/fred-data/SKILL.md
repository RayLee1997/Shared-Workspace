---
name: fred-data
description: >-
  使用 FRED MCP Server 查询美联储经济数据（Federal Reserve Economic Data）。
  提供 840,000+ 条经济时间序列的浏览、搜索与数据获取能力，覆盖利率、通胀、就业、GDP、
  货币供应、金融市场等全维度宏观经济数据。
  适用于：宏观经济分析、投资研报宏观环境评估、经济周期判断、量化因子构建、数据探索。
  当用户提及"宏观经济、利率、通胀、CPI、PCE、GDP、失业率、非农、美联储、FRED、
  联邦基金利率、国债收益率、收益率曲线、货币供应、M2、经济周期、金融条件"时触发。
license: MIT
allowed-tools:
  - fred_browse
  - fred_search
  - fred_get_series
metadata:
  version: "1.0.0"
  author: "Digital Ray"
---

# FRED Data（宏观经济数据查询）

## 功能概述

通过 **FRED MCP Server**（`fred-mcp-server`）接入美联储圣路易斯联邦储备银行维护的 FRED 数据库，提供 **840,000+** 条经济时间序列的完整访问能力：

1. **数据目录浏览**：按分类（Category）、发布（Release）、来源（Source）导航 FRED 数据树
2. **智能搜索**：按关键词、标签、频率、季节调整等维度精确定位数据系列
3. **数据获取**：按 Series ID 拉取时间序列数据，支持日期范围、数据变换（同比/环比/对数等）、频率聚合

**核心价值**：为投资分析与宏观研究提供**权威、免费、实时更新**的一级经济数据。

---

## 使用时机

当用户需要以下内容时使用此技能：

- **宏观经济分析**：「当前美国的通胀趋势如何？」「分析利率周期走势」
- **投资环境评估**：「帮我评估当前的宏观经济对科技股的影响」「当前流动性环境如何？」
- **经济数据查询**：「最新的 CPI 数据是多少？」「拉取过去 3 年的 GDP 增长率」
- **经济指标探索**：「FRED 有没有消费者信心指数？」「帮我找失业率数据」
- **经济周期判断**：「收益率曲线是否倒挂？」「Sahm Rule 指标当前值多少？」
- **量化因子构建**：「构建一个利率-通胀因子」「需要实际利率数据」

**不要使用**：

- 个股行情数据（使用 Yahoo Finance MCP → `us-stock-analysis` 技能）
- 公司财务报表（使用 EdgarTools MCP → `us-stock-analysis` 技能）
- 非经济类数据查询

---

## 可用工具

| 工具 | 功能 | 何时使用 |
|------|------|----------|
| `fred_browse` | 浏览 FRED 数据目录 | 探索数据分类、查看某个分类/发布下的全部系列 |
| `fred_search` | 搜索数据系列 | 按关键词查找指标、不确定 Series ID 时定位数据 |
| `fred_get_series` | 获取时间序列数据 | **核心工具**——知道 Series ID 后拉取实际数据 |

---

## 核心数据集速查表

> 以下为投资分析中最常用的 FRED Series ID，可直接用于 `fred_get_series` 查询。

### 利率体系

| Series ID | 指标名称 | 频率 | 用途 |
|-----------|----------|------|------|
| `FEDFUNDS` | 联邦基金有效利率 | Daily | 美联储政策利率基准 |
| `DFEDTARU` | 联邦基金目标利率上限 | Daily | 政策利率目标区间 |
| `DGS2` | 2 年期国债收益率 | Daily | 短端利率、加息预期 |
| `DGS10` | 10 年期国债收益率 | Daily | **无风险利率基准**（DCF 折现率输入） |
| `DGS30` | 30 年期国债收益率 | Daily | 长端利率 |
| `T10Y2Y` | 10Y-2Y 国债利差 | Daily | **收益率曲线斜率**（<0 = 倒挂 = 衰退预警） |
| `T10YIE` | 10 年期 Breakeven 通胀率 | Daily | 市场隐含通胀预期 |

### 通胀指标

| Series ID | 指标名称 | 频率 | 用途 |
|-----------|----------|------|------|
| `CPIAUCSL` | CPI（城市消费者-所有项目） | Monthly | 标题通胀 |
| `CPILFESL` | 核心 CPI（排除食品与能源） | Monthly | 核心通胀趋势 |
| `PCEPILFE` | 核心 PCE | Monthly | **美联储首选通胀指标** |
| `PPIFIS` | PPI（最终需求） | Monthly | 生产者端价格压力 |
| `DCOILWTICO` | WTI 原油价格 | Daily | 能源成本 / 能源股分析 |
| `GOLDAMGBD228NLBM` | 伦敦黄金定盘价 | Daily | 避险资产 |

### 就业市场

| Series ID | 指标名称 | 频率 | 用途 |
|-----------|----------|------|------|
| `UNRATE` | U-3 失业率 | Monthly | 官方失业率 |
| `U6RATE` | U-6 广义失业率 | Monthly | 真实就业松紧 |
| `PAYEMS` | 非农就业人数 | Monthly | 劳动力市场景气指标 |
| `ICSA` | 首次申请失业金人数 | Weekly | **高频就业前瞻**（每周四更新） |
| `CCSA` | 持续申请失业金人数 | Weekly | 就业市场压力持续性 |
| `JTSJOL` | JOLTS 职位空缺 | Monthly | 劳动力供需 |
| `CIVPART` | 劳动参与率 | Monthly | 劳动力供给 |
| `CES0500000003` | 平均时薪 | Monthly | 工资通胀 |

### 经济增长

| Series ID | 指标名称 | 频率 | 用途 |
|-----------|----------|------|------|
| `GDP` | 名义 GDP | Quarterly | 经济总量 |
| `GDPC1` | 实际 GDP | Quarterly | 剔除通胀的真实增长 |
| `A191RL1Q225SBEA` | 实际 GDP 年化 QoQ % | Quarterly | **GDP 增长率**（季度增长率年化） |
| `INDPRO` | 工业生产指数 | Monthly | 制造业产出 |
| `TCU` | 产能利用率 | Monthly | 产出缺口 |
| `RSAFS` | 零售及食品服务销售额 | Monthly | 消费支出 |
| `UMCSENT` | 密歇根消费者信心指数 | Monthly | 消费者前瞻 |

### 金融条件 & 风险偏好

| Series ID | 指标名称 | 频率 | 用途 |
|-----------|----------|------|------|
| `VIXCLS` | VIX 恐慌指数 | Daily | 市场波动率 / 恐慌程度 |
| `SP500` | 标普 500 指数 | Daily | 大盘走势 |
| `BAMLH0A0HYM2` | ICE BofA 高收益债 OAS | Daily | **信用利差**（金融条件松紧） |
| `WILL5000IND` | Wilshire 5000 全市场指数 | Daily | 全市场估值参考 |

### 货币与流动性

| Series ID | 指标名称 | 频率 | 用途 |
|-----------|----------|------|------|
| `M2SL` | M2 货币供应量 | Monthly | 广义流动性 |
| `BOGMBASE` | 基础货币 | Biweekly | 央行释放的基础货币 |
| `WALCL` | 美联储资产负债表总规模 | Weekly | **QE/QT 追踪**（流动性核心指标） |

### 房地产

| Series ID | 指标名称 | 频率 | 用途 |
|-----------|----------|------|------|
| `HOUST` | 新屋开工数 | Monthly | 地产周期领先指标 |
| `PERMIT` | 建筑许可证 | Monthly | 地产上游景气 |
| `CSUSHPISA` | S&P/Case-Shiller 房价指数 | Monthly | 房价趋势 |
| `MORTGAGE30US` | 30 年期固定抵押贷款利率 | Weekly | 房贷成本 / 地产压力 |

### 经济周期 & 衰退指标

| Series ID | 指标名称 | 频率 | 用途 |
|-----------|----------|------|------|
| `USREC` | 经济衰退区间 | Monthly | 0/1 指标（1 = 衰退中） |
| `SAHMREALTIME` | Sahm Rule 实时指标 | Monthly | **>0.5 = 衰退信号** |
| `GFDEBTN` | 联邦政府债务总额 | Quarterly | 财政可持续性 |
| `GFDEGDQ188S` | 联邦债务/GDP 比率 | Quarterly | 债务负担 |

### 汇率

| Series ID | 指标名称 | 频率 | 用途 |
|-----------|----------|------|------|
| `DEXUSEU` | USD/EUR 汇率 | Daily | 欧元兑美元 |
| `DEXJPUS` | JPY/USD 汇率 | Daily | 日元兑美元 |
| `DTWEXBGS` | 美元广义贸易加权指数 | Daily | 美元综合强弱 |

---

## 执行流程（必须遵循）

### 第 1 步：分析查询意图

根据用户需求确定：

| 维度 | 说明 |
|------|------|
| **数据类型** | 利率 / 通胀 / 就业 / GDP / 金融市场 / 货币 / 房地产 / 其他 |
| **时间范围** | 需要多久的数据（近 1 年 / 3 年 / 5 年 / 全历史） |
| **数据形式** | 原始值（`lin`）/ 同比变化率（`pc1`）/ 环比%（`pch`）/ 其他变换 |
| **频率需求** | 维持原频率 / 聚合到月度/季度/年度 |

### 第 2 步：定位 Series ID

**已知指标**：直接从上方速查表获取 Series ID，跳至第 3 步。

**未知指标**：使用搜索流程定位：

```
# Step 2a: 关键词搜索
fred_search:
  search_text: "consumer confidence"
  order_by: "popularity"
  sort_order: "desc"
  limit: 10

# Step 2b: 按标签精确搜索
fred_search:
  tag_names: "inflation,monthly"
  filter_variable: "seasonal_adjustment"
  filter_value: "Seasonally Adjusted"

# Step 2c: 浏览分类探索
fred_browse:
  browse_type: "categories"           # 先看顶级分类
  
fred_browse:
  browse_type: "category_series"      # 再看某分类下的系列
  category_id: 32455                  # 如 Prices 分类
  limit: 20
```

### 第 3 步：获取数据

```
# 基础查询：获取某指标的原始数据
fred_get_series:
  series_id: "FEDFUNDS"
  observation_start: "2023-01-01"

# 同比变化率查询：通胀率 YoY%
fred_get_series:
  series_id: "CPIAUCSL"
  units: "pc1"                        # Percent Change from Year Ago
  observation_start: "2020-01-01"

# 频率聚合查询：日线 → 月度平均
fred_get_series:
  series_id: "DGS10"
  frequency: "m"                      # 聚合到月度
  aggregation_method: "avg"           # 取月平均值
  observation_start: "2020-01-01"

# 获取最新N条数据（降序）
fred_get_series:
  series_id: "UNRATE"
  limit: 12                           # 最新12个月
  sort_order: "desc"
```

### 第 4 步：分析与输出

根据任务类型组织输出：

| 任务类型 | 输出要求 |
|----------|----------|
| **单指标查询** | 当前值 + 趋势描述 + 历史背景 |
| **多指标综合分析** | 数据表格 + 指标间关联分析 + 结论 |
| **投研报告章节** | 结构化章节（标题 + 数据表 + 核心洞察） |
| **经济周期判断** | 多维度信号综合 + 历史对比 + 结论 |

---

## 常用查询模板

### 模板 1：美联储货币政策环境评估

并行调用以下查询，综合评估当前货币政策立场：

```
# 政策利率
fred_get_series(series_id="FEDFUNDS", limit=24, sort_order="desc")

# 收益率曲线
fred_get_series(series_id="T10Y2Y", limit=24, sort_order="desc")

# 通胀（核心 PCE YoY%）
fred_get_series(series_id="PCEPILFE", units="pc1", limit=24, sort_order="desc")

# 美联储资产负债表
fred_get_series(series_id="WALCL", limit=52, sort_order="desc")

# M2 货币供应 YoY%
fred_get_series(series_id="M2SL", units="pc1", limit=24, sort_order="desc")
```

**分析框架**：

- `FEDFUNDS` 处于历史什么分位？→ 利率限制性程度
- `T10Y2Y` 是否倒挂？→ 衰退预警信号
- `PCEPILFE` YoY% 是否趋近 2% 目标？→ 降息空间
- `WALCL` 趋势：缩表（QT）还是扩表（QE）？→ 流动性方向
- `M2SL` YoY% ≷ 0%？→ 广义流动性收缩/扩张

---

### 模板 2：就业市场健康度评估

```
# 失业率
fred_get_series(series_id="UNRATE", observation_start="2020-01-01")

# 非农就业
fred_get_series(series_id="PAYEMS", units="chg", observation_start="2020-01-01")

# 初次申领
fred_get_series(series_id="ICSA", limit=52, sort_order="desc")

# JOLTS 职位空缺
fred_get_series(series_id="JTSJOL", observation_start="2020-01-01")

# Sahm Rule
fred_get_series(series_id="SAHMREALTIME", observation_start="2020-01-01")
```

**分析框架**：

- `UNRATE` 趋势：是否从低位回升？→ 劳动力市场转弱信号
- `PAYEMS` 月度新增：>200K 强劲 / 100-200K 稳健 / <100K 放缓
- `ICSA`：<250K 健康 / >300K 注意 / >400K 衰退风险
- `JTSJOL` vs `UNRATE`：职位空缺/失业人数比 → 劳动力松紧
- `SAHMREALTIME` >0.5 → 衰退高概率

---

### 模板 3：通胀全景监测

```
# 标题 CPI YoY%
fred_get_series(series_id="CPIAUCSL", units="pc1", observation_start="2020-01-01")

# 核心 CPI YoY%
fred_get_series(series_id="CPILFESL", units="pc1", observation_start="2020-01-01")

# 核心 PCE YoY%（美联储首选）
fred_get_series(series_id="PCEPILFE", units="pc1", observation_start="2020-01-01")

# PPI YoY%
fred_get_series(series_id="PPIFIS", units="pc1", observation_start="2020-01-01")

# Breakeven 通胀预期
fred_get_series(series_id="T10YIE", observation_start="2020-01-01")

# WTI 原油
fred_get_series(series_id="DCOILWTICO", observation_start="2020-01-01")
```

**分析框架**：

- CPI vs 核心 CPI → 食品/能源波动影响
- 核心 PCE → 美联储 2% 目标距离
- PPI → 上游成本传导压力
- `T10YIE` → 市场隐含通胀预期
- 原油 → 能源价格对通胀的前瞻指引

---

### 模板 4：个股分析宏观环境章节

为 `us-stock-analysis` 技能输出的深度报告补充宏观上下文：

```
# 根据行业定制查询：

# [通用] 无风险利率环境
fred_get_series(series_id="DGS10", observation_start="2023-01-01")

# [通用] VIX 市场情绪
fred_get_series(series_id="VIXCLS", observation_start="2024-01-01")

# [科技/成长股] 利率对久期敏感性
fred_get_series(series_id="DGS2", observation_start="2023-01-01")

# [银行/金融] 利差环境
fred_get_series(series_id="T10Y2Y", observation_start="2023-01-01")

# [消费/零售] 零售销售趋势
fred_get_series(series_id="RSAFS", units="pc1", observation_start="2023-01-01")

# [房地产] 新屋开工 + 房贷利率
fred_get_series(series_id="HOUST", observation_start="2023-01-01")
fred_get_series(series_id="MORTGAGE30US", observation_start="2023-01-01")

# [能源] 油价趋势
fred_get_series(series_id="DCOILWTICO", observation_start="2023-01-01")
```

---

### 模板 5：经济衰退风险评估

```
# 收益率曲线（最可靠的衰退领先指标之一）
fred_get_series(series_id="T10Y2Y", observation_start="2019-01-01")

# Sahm Rule（实时衰退指标）
fred_get_series(series_id="SAHMREALTIME", observation_start="2019-01-01")

# 衰退区间（历史参照）
fred_get_series(series_id="USREC", observation_start="2000-01-01")

# 初次申领（高频衰退前兆）
fred_get_series(series_id="ICSA", observation_start="2019-01-01")

# 信用利差（金融压力）
fred_get_series(series_id="BAMLH0A0HYM2", observation_start="2019-01-01")

# 工业生产（实体经济）
fred_get_series(series_id="INDPRO", units="pc1", observation_start="2019-01-01")
```

**分析框架**：

- `T10Y2Y` 倒挂后 12-18 个月通常出现衰退
- `SAHMREALTIME` >0.5 → 衰退已开始
- `ICSA` 突破 300K → 就业恶化
- `BAMLH0A0HYM2` >500bp → 信贷市场冻结
- `INDPRO` YoY% <0 → 工业衰退

---

## 数据变换参数速查

| `units` 参数值 | 含义 | 典型用途 | 示例 |
|----------------|------|----------|------|
| `lin` | 原始水平值 | 绝对值分析 | GDP = $27.36T |
| `chg` | 环比变化 | 短期波动 | PAYEMS 月增量 |
| `ch1` | 同比变化 | 年度绝对变化 | — |
| `pch` | 环比变化率 % | 月度增长率 | MoM 增长 |
| `pc1` | **同比变化率 %** | **最常用** | CPI YoY% = 3.2% |
| `pca` | 复合年化变化率 % | 年化分析 | GDP QoQ SAAR |
| `cch` | 连续复利变化率 | 学术建模 | — |
| `log` | 自然对数 | 趋势平滑 | 长期趋势分析 |

---

## 频率聚合参数速查

| `frequency` 值 | 聚合到 | 搭配 `aggregation_method` |
|-----------------|--------|---------------------------|
| `d` | Daily | — |
| `w` | Weekly | `avg` / `eop` |
| `bw` | Bi-weekly | `avg` / `eop` |
| `m` | Monthly | `avg`（利率等）/ `eop`（存量指标）/ `sum`（流量指标） |
| `q` | Quarterly | `avg` / `eop` / `sum` |
| `a` | Annual | `avg` / `eop` / `sum` |

> **选择原则**：价格/利率类用 `avg`（平均值）；GDP/就业等流量指标用 `sum`（求和）；货币存量/资产负债表用 `eop`（期末值）。

---

## 与其他技能的协同

| 协同场景 | FRED 技能提供 | 搭配技能 |
|----------|--------------|----------|
| **个股深度分析** | 宏观环境章节（利率/通胀/就业） | `us-stock-analysis` |
| **AI 泡沫研究** | 流动性环境、信用利差、VIX | `us-stock-analysis` + `web-research` |
| **数据可视化** | 原始数据 | `mermaid-chart`（折线图/柱状图） |
| **经济研报** | 全部宏观指标 | `web-research`（补充新闻/评论） |

---

## 注意事项

1. **先查速查表**：常用指标已收录在上方速查表中，优先使用已知 Series ID，避免不必要的搜索
2. **善用数据变换**：需要增长率时设置 `units="pc1"`（同比%）或 `units="pch"`（环比%），避免手动计算
3. **频率匹配**：对比不同指标时注意频率对齐，使用 `frequency` 参数统一频率
4. **聚合方式**：利率/价格用 `avg`，流量指标用 `sum`，存量指标用 `eop`
5. **日期格式**：`YYYY-MM-DD` 格式（如 `"2024-01-01"`）
6. **并行查询**：多个 `fred_get_series` 调用之间无依赖关系，**必须并行执行**以提高效率
7. **数据延迟**：部分指标有发布延迟（如 GDP 滞后 ~1 个月，CPI 滞后 ~2 周），属正常现象
