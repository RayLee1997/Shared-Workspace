# Yahoo Finance MCP

## 概述

yahoo-finance-mcp 是一个基于 Model Context Protocol (MCP) 的金融数据服务器，封装了 `yfinance` 库，允许 AI Agent 直接获取高质量的 Yahoo Finance 数据。

**核心优势**：

- **全面性**：支持股票历史价格、实时信息、财务报表、期权链、分析师评级、新闻等全方位数据。
- **易用性**：通过 `uv` 包管理器一键运行，配置简单。
- **标准化**：完全遵循 MCP 协议，无缝接入 Claude Desktop、Antigravity 等客户端。

---

## 1. 核心工具与使用场景

该 Server 提供了丰富的工具集，满足从基础行情到深度投研的多种需求。

### 1.1 市场行情与基础信息

| 工具名称 | 功能描述 | 典型场景 |
| :--- | :--- | :--- |
| `get_stock_info` | 获取股票详细信息（市值、PE、行业、公司简介等） | "介绍一下 NVDA 这家公司"; "AAPL 的当前市值是多少？" |
| `get_historical_stock_prices` | 获取历史价格数据（支持多种周期和间隔） | "拉取 TSLA 最近一年的日线数据"; "给我 MSFT 上周的分钟级走势" |
| `get_yahoo_finance_news` | 获取股票相关新闻 | "最近有什么关于 Apple 的重磅新闻？" |
| `get_stock_actions` | 获取公司行为（分红、拆股） | "KO 历年的分红记录" |

### 1.2 深度财务分析

| 工具名称 | 功能描述 | 典型场景 |
| :--- | :--- | :--- |
| `get_financial_statement` | 获取三大财务报表（损益、资产负债、现金流） | "分析 AMZN 过去 3 年的自由现金流变化"; "展示 GOOGL 的最新资产负债表" |
| `get_holder_info` | 获取主要股东与机构持股信息 | "谁是 PLTR 的最大机构持有者？" |

### 1.3 衍生品与评级

| 工具名称 | 功能描述 | 典型场景 |
| :--- | :--- | :--- |
| `get_option_expiration_dates` | 获取期权到期日列表 | "TSLA 期权有哪些行权日期？" |
| `get_option_chain` | 获取特定到期日的期权链数据 | "查看 AAPL 下个月到期的 Call 期权数据" |
| `get_recommendations` | 获取分析师评级建议 | "华尔街分析师对 BABA 的最新评级是什么？" |

---

## 3. 最佳实践总结

1. **数据粒度选择**：
   - 进行日内交易分析时，使用 `interval="1h"` 或 `"15m"`。
   - 进行长期趋势分析时，使用 `period="5y"` 和 `interval="1wk"`。

2. **财务数据分析**：
   - 结合 `get_financial_statement` 和 `get_stock_info`，可以计算自定义财务比率（如 PEG、ROIC）。

3. **错误处理**：
   - 如果遇到网络错误，考虑到 Yahoo Finance 有时会有访问限制，建议稍后重试。
   - 确保股票代码准确（使用美股代码，如 `BABA` 而非 `9988.HK`，虽然部分支持但美股数据最全）。

4. **隐私安全**：
   - 所有数据直接从本地请求至 Yahoo Finance，不经过任何第三方中转，保证了查询隐私。

---
