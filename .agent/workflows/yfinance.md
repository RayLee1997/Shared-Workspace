---
description: yfinance 股票分析 - 使用 Yahoo Finance MCP 工具进行个股数据查询与财务分析
---

# yfinance 股票分析工作流

使用 Yahoo Finance MCP Server 提供的工具集，对指定股票进行全方位数据查询与分析。

## 1. 需求确认

首先确认以下信息：

- **股票代码**：用户想要分析的股票 ticker（如 `AAPL`、`NVDA`、`TSLA`）
- **分析深度**：快速概览 / 标准分析 / 深度研报
- **关注重点**：行情走势、财务健康、机构持仓、期权策略、分析师评级

> **注意**：使用美股代码（如 `BABA` 而非 `9988.HK`），美股数据最全。

## 2. 基础信息收集

// turbo

依次调用以下工具获取公司概况：

1. 调用 `get_stock_info(ticker)` — 获取公司基本面（市值、PE、行业、简介等）
2. 调用 `get_yahoo_finance_news(ticker)` — 获取最新相关新闻
3. 调用 `get_stock_actions(ticker)` — 获取分红与拆股历史

## 3. 行情与价格分析

// turbo

根据分析需求选择合适的参数：

1. **长期趋势**：`get_historical_stock_prices(ticker, period="1y", interval="1wk")`
2. **中期走势**：`get_historical_stock_prices(ticker, period="3mo", interval="1d")`
3. **短期波动**：`get_historical_stock_prices(ticker, period="5d", interval="1h")`

> 分析要点：识别关键支撑/阻力位、成交量变化趋势、价格形态。

## 4. 财务报表分析

// turbo

调用 `get_financial_statement` 获取三大报表，推荐组合查询：

1. **损益表**：`get_financial_statement(ticker, "income_stmt")` — 收入增长、利润率
2. **资产负债表**：`get_financial_statement(ticker, "balance_sheet")` — 资产结构、负债水平
3. **现金流量表**：`get_financial_statement(ticker, "cashflow")` — 经营性现金流、自由现金流

如需最新季度数据，使用 `quarterly_` 前缀版本（如 `quarterly_income_stmt`）。

> 分析要点：
>
> - 营收与净利润的同比/环比增长率
> - 毛利率、营业利润率、净利润率的变化趋势
> - 自由现金流 = 经营性现金流 - 资本支出
> - 资产负债率、流动比率等偿债能力指标

## 5. 机构持仓与内部交易

// turbo

1. 调用 `get_holder_info(ticker, "major_holders")` — 主要股东概览
2. 调用 `get_holder_info(ticker, "institutional_holders")` — 机构持仓明细
3. 调用 `get_holder_info(ticker, "insider_transactions")` — 内部人交易记录

> 分析要点：机构持仓集中度、近期内部人买卖方向。

## 6. 分析师评级

// turbo

1. 调用 `get_recommendations(ticker, "recommendations")` — 当前共识评级
2. 调用 `get_recommendations(ticker, "upgrades_downgrades")` — 近期评级变动

## 7. 期权数据（可选）

仅在用户关注衍生品策略时执行：

// turbo

1. 调用 `get_option_expiration_dates(ticker)` — 获取可用到期日
2. 选择目标到期日后调用 `get_option_chain(ticker, expiration_date, "calls")` 和 `get_option_chain(ticker, expiration_date, "puts")`

## 8. 综合分析输出

基于上述所有数据，撰写分析报告，包含以下模块：

```markdown
# [公司名称] ([TICKER]) 股票分析报告

## 公司概况
- 行业、市值、核心业务

## 行情分析
- 价格走势、关键价位、成交量分析

## 财务健康度
- 营收与利润趋势（表格呈现）
- 关键财务比率

## 持仓结构
- 机构持仓、内部人交易动态

## 市场评级
- 分析师共识、近期评级变动

## 风险提示
- 识别的主要风险因素

## 总结与观点
- 综合评价与展望
```

## 9. 最佳实践提醒

- **数据粒度**：日内分析用 `interval="1h"` 或 `"15m"`；长期趋势用 `period="5y"` + `interval="1wk"`
- **财务比率**：结合 `get_financial_statement` 和 `get_stock_info` 计算 PEG、ROIC 等自定义指标
- **错误处理**：Yahoo Finance 偶有访问限制，遇到网络错误时稍后重试
- **数据隐私**：所有数据直接从本地请求至 Yahoo Finance，不经第三方中转
