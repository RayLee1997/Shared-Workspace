---
date: 2026-02-13
tags: [Innovation, AI, Bubble, Research, Plan]
status: Complete
---

# Research Plan: AI Bubble Investigation (US Equities)

> ✅ **研究已完成** → 完整报告: [[美股 AI 泡沫深度调查报告]]

## 1. Research Objective (研究目标)

本研究旨在通过多维度定量与定性分析，评估当前美股 AI 板块是否存在系统性泡沫风险。核心目标是回答以下关键问题：

1. **Valuation Justification**: 当前的高估值是否被预期的 **Earnings Growth** 和 **Free Cash Flow** 所支撑？
2. **Market Structure**: 市场上涨是由少数巨头 (`Magnificent 7`) 驱动，还是已扩散至广泛的 AI 产业链？
3. **Macro Sensitivity**: 在 **High Interest Rate** 环境下，AI 板块的流动性与风险溢价是否合理？

## 2. Research Scope & Tiers (研究范围与分层)

将研究对象分为三个层级，以区分不同环节的泡沫程度：

* **Tier 1: Infrastructure & Enablers (卖铲人)**
  * **Key Stocks**: NVDA, AMD, TSM, AVGO, MU, SMCI, VRT
  * **Focus**: **Hardware Sales**, **Backlog**, **Pricing Power**
* **Tier 2: Cloud & Foundation Models (基建与模型)**
  * **Key Stocks**: MSFT, GOOGL, AMZN, META
  * **Focus**: **Capex Efficiency**, **AI Revenue Attribution**, **Cloud Growth**
* **Tier 3: Applications & Software (应用层)**
  * **Key Stocks**: PLTR, ADBE, CRM, NOW, DUOL, UPST, AI (C3.ai)
  * **Focus**: **Monetization**, **User Adoption**, **Churn Rate**

## 3. Core Research Tasks (核心调研任务)

### 3.1. Valuation Analysis (估值偏离度分析)

* **Metric 1: Historical Comparison**: 对比当前 **P/E (TTM & Fwd)**, **P/S**, **EV/EBITDA** 与过去 5 年/10 年历史分位值。
  * *Action*: 计算 Key Stocks 的 **Z-Score**。
* **Metric 2: Growth-Adjusted Valuation**: 计算 **PEG Ratio (P/E to Growth)**。
  * *Threshold*: PEG > 2.0 视为高估警示。
* **Metric 3: Relative Valuation**: 对比 AI Sector vs. S&P 500 (SPX) vs. Nasdaq 100 (NDX) 的溢价率。
* **Data Source**: Yahoo Finance, Seeking Alpha, Bloomberg.

### 3.2. Earnings Quality & Sustainability (盈利质量评估)

* **Metric 1: AI Revenue Reality Check**: 剥离非 AI 业务，估算纯 AI 带来的 **Incremental Revenue**。
* **Metric 2: CAPEX vs. Revenue Growth**: 分析 **Capital Expenditure** 的增长速度是否远超 **Revenue** 增长（暗示过度投资）。
  * *Key Ratio*: **Capex/Revenue**, **Return on Invested Capital (ROIC)**.
* **Metric 3: Free Cash Flow (FCF) Yield**: 评估在巨额资本开支下的现金流健康度。

### 3.3. Macro Liquidity & Sentiment (宏观流动性与情绪)

* **Liquidity Indicators**:
  * **10-Year Treasury Yield**: 利率变化对高估值科技股的敏感度分析。
  * **High Yield Spread**: 信贷市场风险偏好。
  * *Data Source*: FRED (Federal Reserve Economic Data).
* **Sentiment Indicators**:
  * **Put/Call Ratio**: 期权市场的投机情绪。
  * **Retail vs. Institutional Flows**: 散户入场程度（通常是泡沫末期信号）。
  * **Insider Activity**: 内部高管的 **Net Selling** 规模。

### 3.4. Historical Bubble Comparison (历史泡沫对比)

* **Benchmark 1: Dot-com Bubble (2000)**: 对比 CSCO, INTC 当年的 **P/E** 峰值与当前的 NVDA, MSFT。
* **Benchmark 2: COVID Tech Bubble (2021)**: 对比 ARKK 成分股的崩盘路径。
* **Key Discriminator**: 当前 AI 巨头的 **Profitability** 与当年“概念股”的区别。

### 3.5. Technical & Market Breadth (技术面与市场广度)

* **Breadth Indicator**: 标普 500 创新高股票占比 vs. AI 板块走势（背离预警）。
* **Concentration Risk**: Top 10 市值占比。

## 4. Execution Roadmap (执行路线图)

1. **Data Collection (Phase 1)**:
    * [ ] Fetch **Fundamental Data** (P/E, Revenue Growth, PEG) for Tier 1/2/3 stocks via `yfinance`.
    * [ ] Retrieve **Macro Data** (10Y Yield, Liquidity) via `FRED`.
    * [ ] Gather **Insider Trading** summary.
2. **Analysis & Synthesis (Phase 2)**:
    * [ ] Create **Comparative Valuation Table**.
    * [ ] Visualize **Capex Trends** using Mermaid charts.
    * [ ] Draft **Bubble Scorecard** (scoring each Tier from 1-10 on bubble risk).
3. **Reporting (Phase 3)**:
    * [ ] Compile findings into "AI Bubble Investigation Report".
    * [ ] Formulate **Investment Strategy** (Buy/Hold/Hedging).

## 5. Deliverables (交付物)

* **Investigation Report**: 包含数据图表、核心论点与结论的完整 Markdown 报告。
* **Bubble Scorecard**: 量化评估表。
* **Actionable Advice**: 针对当前投资组合的调整建议。
