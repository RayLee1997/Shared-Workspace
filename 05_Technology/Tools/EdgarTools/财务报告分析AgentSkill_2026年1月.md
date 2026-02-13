# 财务报告分析 Agent Skill 开发报告

> 调研时间：2026-01-26
> 适用平台：Claude Code / OpenCode

---

## 一、调研目标

开发一个适用于 Claude Code 和 OpenCode 的公司财务报告分析 Agent Skill，能够：
1. 自动从公司季度财务报告中提取关键数据
2. **验证数据准确性**（重点）
3. 生成简明的财务分析报告

---

## 二、MCP 财务分析工具调查（Top 10 GitHub 高星项目）

### 1. SEC-MCP (LuisRincon23/SEC-MCP)
**用途**：提供 8 个专业化 MCP 服务器，实现机构级财务研究平台
**特点**：
- SEC EDGAR 数据访问与 XBRL 解析
- 新闻情绪分析、分析师评级
- DCF 建模、Altman Z-Score 计算
- 机构持仓追踪、另类数据分析

**来源**：[GitHub](https://github.com/LuisRincon23/SEC-MCP)

---

### 2. MaverickMCP (wshobson/maverick-mcp)
**用途**：个人股票分析 MCP 服务器
**特点**：
- 39+ 财务分析工具
- 预置 520 支标普 500 股票
- 支持 HTTP/SSE/STDIO 传输
- AI 驱动的研究代理

**来源**：[GitHub](https://github.com/wshobson/maverick-mcp)

---

### 3. Octagon MCP Server (OctagonAI/octagon-mcp-server)
**用途**：AI 驱动的财务研究和分析
**特点**：
- 覆盖 8000+ 上市公司 SEC 文件（10-K, 10-Q, 8-K, 20-F, S-1）
- 财报电话会议记录分析
- 私募市场交易数据
- 深度网络研究

**来源**：[GitHub](https://github.com/OctagonAI/octagon-mcp-server)

---

### 4. Financial Datasets MCP (financial-datasets/mcp-server)
**用途**：股票市场数据访问
**特点**：
- 利润表、资产负债表、现金流量表
- 历史股价数据
- 市场新闻
- 官方远程 MCP 服务器支持

**来源**：[GitHub](https://github.com/financial-datasets/mcp-server) | [文档](https://docs.financialdatasets.ai/mcp-server)

---

### 5. EdgarTools (dgunning/edgartools)
**用途**：SEC EDGAR 文件访问与分析 Python 库
**特点**：
- 内置 MCP 服务器支持
- 10-30 倍快于替代方案
- XBRL 财务数据解析
- 3,450+ 行 API 文档

**来源**：[GitHub](https://github.com/dgunning/edgartools)

---

### 6. SEC EDGAR MCP (stefanoamorelli/sec-edgar-mcp)
**用途**：SEC EDGAR 文件访问
**特点**：
- 精确数值数据提取
- 内幕交易数据
- 支持 Streamable HTTP 传输

**来源**：[GitHub](https://github.com/stefanoamorelli/sec-edgar-mcp)

---

### 7. Financial Modeling Prep MCP (imbenrabi/Financial-Modeling-Prep-MCP-Server)
**用途**：综合财务数据分析
**特点**：
- 25+ 工具集：搜索、公司、报表、图表、新闻、分析师评级
- 技术指标、ESG、参议员交易
- 动态工具发现模式
- 会话隔离

**来源**：[GitHub](https://github.com/imbenrabi/Financial-Modeling-Prep-MCP-Server)

---

### 8. Alpha Vantage MCP
**用途**：实时和历史股票市场数据
**特点**：
- 官方 Alpha Vantage API MCP 服务器
- 支持 Claude、Cursor、VS Code 等
- 综合财务数据访问

**来源**：[官网](https://mcp.alphavantage.co/)

---

### 9. Yahoo Finance MCP (Alex2Yang97/yahoo-finance-mcp)
**用途**：Yahoo Finance 综合财务数据
**特点**：
- 历史价格、公司信息、财务报表
- 期权数据、市场新闻
- 机构持仓分析

**来源**：[GitHub](https://github.com/Alex2Yang97/yahoo-finance-mcp)

---

### 10. Finance-Tools-MCP (VoxLink-org/finance-tools-mcp)
**用途**：投资者代理工具集
**特点**：
- 多数据源集成
- 详细财务研究分析
- LLM 优化设计

**来源**：[GitHub](https://github.com/VoxLink-org/finance-tools-mcp)

---

## 三、OpenCode Agent Skill 开发指南

### 3.1 Skill 基本结构

根据 [OpenCode 官方文档](https://opencode.ai/docs/skills/)，Agent Skill 需要遵循以下结构：

```
.opencode/skills/<skill-name>/
├── SKILL.md          # 必需：技能定义文件
├── scripts/          # 可选：可执行脚本
├── references/       # 可选：参考文档
└── templates/        # 可选：模板文件
```

### 3.2 SKILL.md 文件格式

```yaml
---
name: skill-name                    # 必需：1-64字符，小写字母数字+连字符
description: 技能描述               # 必需：1-1024字符
license: MIT                        # 可选
compatibility: opencode             # 可选
metadata:                           # 可选
  audience: investors
  workflow: financial-analysis
---

# 技能标题

## 功能说明
[技能的具体功能]

## 使用时机
[何时触发此技能]

## 工作流程
[详细步骤]
```

### 3.3 Skill 存放位置

OpenCode 搜索以下位置：
- 项目配置：`.opencode/skills/<name>/SKILL.md`
- 全局配置：`~/.config/opencode/skills/<name>/SKILL.md`
- Claude 兼容：`.claude/skills/<name>/SKILL.md`
- Claude 全局：`~/.claude/skills/<name>/SKILL.md`

### 3.4 命名规则

- 1-64 个字符
- 小写字母数字，单连字符分隔
- 不能以 `-` 开头或结尾
- 不能包含连续 `--`
- 正则：`^[a-z0-9]+(-[a-z0-9]+)*$`

---

## 四、财务报告分析 Skill 最佳实践方案

### 4.1 推荐架构

```
financial-report-analysis/
├── SKILL.md                    # 主技能定义
├── scripts/
│   ├── validate_data.py        # 数据验证脚本
│   ├── extract_metrics.py      # 指标提取脚本
│   └── generate_report.py      # 报告生成脚本
├── references/
│   ├── metrics_definitions.md  # 财务指标定义
│   ├── validation_rules.md     # 验证规则
│   └── report_templates.md     # 报告模板
└── templates/
    ├── quarterly_report.md     # 季度报告模板
    └── earnings_call.md        # 电话会议摘要模板
```

### 4.2 推荐 MCP 服务器组合

| 用途 | 推荐工具 | 优先级 |
|------|----------|--------|
| SEC 文件访问 | SEC-MCP / EdgarTools | 高 |
| 财务数据 API | Financial Datasets MCP | 高 |
| 数据验证 | Octagon MCP（交叉验证） | 高 |
| 实时股价 | Alpha Vantage MCP | 中 |
| 新闻情绪 | SEC-MCP News Sentiment | 中 |

### 4.3 数据验证工作流程（重点）

#### 第一步：多源数据获取
```
1. 从 SEC EDGAR 获取官方 10-K/10-Q 文件
2. 从 Financial Datasets API 获取结构化数据
3. 从公司投资者关系页面获取新闻稿
```

#### 第二步：交叉验证
```
1. 比对 SEC 文件中的 XBRL 标签数据与 API 数据
2. 验证关键指标：
   - 营收 (Revenue)
   - 净利润 (Net Income)
   - 每股收益 (EPS)
   - 现金流 (Cash Flow)
3. 差异超过 0.1% 需人工审核
```

#### 第三步：数据质量检查
```
1. 检查数据完整性（所有必需字段是否存在）
2. 检查数据时效性（报告期是否正确）
3. 检查数据一致性（同比/环比计算是否正确）
4. 标记可疑数据点
```

#### 第四步：审计追踪
```
1. 记录每个数据点的来源
2. 保存原始数据快照
3. 记录验证时间戳
4. 生成验证报告
```

### 4.4 关键财务指标提取清单

| 指标类别 | 具体指标 | 数据来源 |
|----------|----------|----------|
| **盈利能力** | 营收、毛利、营业利润、净利润、EPS | 10-Q/10-K |
| **估值指标** | P/E、P/S、P/B、EV/EBITDA | API + 计算 |
| **现金流** | 经营现金流、自由现金流、资本支出 | 10-Q/10-K |
| **资产负债** | 总资产、总负债、股东权益、负债率 | 10-Q/10-K |
| **增长指标** | YoY 增长率、QoQ 增长率 | 计算得出 |
| **管理层指引** | 下季度/年度预期 | 财报电话会议 |

### 4.5 报告输出格式

#### 季度财报分析报告模板

```markdown
# [公司名称] FY[年份] Q[季度] 财务分析报告

> 生成时间：[时间戳]
> 数据来源：SEC EDGAR, Financial Datasets API
> 验证状态：✅ 已验证

## 一、关键财务指标

| 指标 | 本季度 | 上季度 | 同比变化 | 来源 |
|------|--------|--------|----------|------|
| 营收 | $XXB | $XXB | +X.X% | [10-Q](链接) |
| ... | ... | ... | ... | ... |

## 二、业绩亮点
[提取的关键亮点]

## 三、管理层展望
[电话会议关键信息]

## 四、风险因素
[10-Q Risk Factors 摘要]

## 五、数据验证记录
| 指标 | SEC 数据 | API 数据 | 差异 | 状态 |
|------|----------|----------|------|------|
| ... | ... | ... | ... | ✅ |

---
## 参考来源
1. [SEC 10-Q Filing](https://www.sec.gov/cgi-bin/browse-edgar?action=...)
2. [Earnings Call Transcript](链接)
3. [Financial Datasets API](https://financialdatasets.ai)
```

---

## 五、实施步骤

### 步骤 1：环境准备
```bash
# 1. 创建 skill 目录
mkdir -p ~/.config/opencode/skills/financial-report-analysis

# 2. 安装必要的 MCP 服务器
# 方法 A: 使用 uv（推荐）
uv pip install edgartools mcp[cli] httpx

# 方法 B: 配置远程 MCP 服务器
# 在 opencode.json 中配置 Financial Datasets MCP
```

### 步骤 2：配置 MCP 服务器

在 `~/.config/opencode/config.json` 中添加：

```json
{
  "mcp": {
    "servers": {
      "financial-datasets": {
        "command": "npx",
        "args": ["-y", "@anthropic/mcp-remote", "https://mcp.financialdatasets.ai/mcp"],
        "env": {
          "FINANCIAL_DATASETS_API_KEY": "${FINANCIAL_DATASETS_API_KEY}"
        }
      },
      "sec-edgar": {
        "command": "uvx",
        "args": ["sec-edgar-mcp"]
      }
    }
  }
}
```

### 步骤 3：创建 SKILL.md

创建 `~/.config/opencode/skills/financial-report-analysis/SKILL.md`：

```yaml
---
name: financial-report-analysis
description: 自动化分析公司季度财务报告，提取并验证关键财务数据，生成结构化分析报告。支持 SEC 10-K/10-Q 文件解析、多源数据交叉验证、财报电话会议摘要。
license: MIT
compatibility: opencode
metadata:
  audience: investors
  workflow: quarterly-analysis
---

# 财务报告分析技能

## 功能概述
从公司季度财务报告中自动提取和验证关键数据，生成简明的财务分析报告。

## 使用时机
- 用户请求分析某公司的季度/年度财务报告
- 用户需要提取 10-K/10-Q 中的关键财务指标
- 用户需要财报电话会议摘要
- 用户需要验证财务数据的准确性

## 工作流程

### 第 1 步：数据收集
1. 使用 SEC MCP 获取官方 10-Q/10-K 文件
2. 使用 Financial Datasets MCP 获取结构化财务数据
3. 搜索财报电话会议记录

### 第 2 步：数据验证（必须执行）
1. 交叉比对 SEC 官方数据与 API 数据
2. 验证关键指标：营收、净利润、EPS、现金流
3. 差异超过 0.1% 需标记并说明
4. 记录所有数据来源

### 第 3 步：提取关键指标
- 盈利能力：营收、毛利、净利润、EPS
- 现金流：经营现金流、自由现金流、资本支出
- 资产负债：总资产、负债率、股东权益
- 增长指标：YoY、QoQ 变化

### 第 4 步：生成报告
将验证后的数据保存到 `~/Obsidian/04_Investments/store/[公司]_[年份]Q[季度].md`

### 第 5 步：生成分析报告
将最终分析报告保存到 `~/Obsidian/04_Investments/reports/[公司]_[年份]Q[季度]_分析报告.md`

## 验证规则

### 必须验证的指标
| 指标 | 验证方法 | 容差 |
|------|----------|------|
| 营收 | SEC vs API | 0.1% |
| 净利润 | SEC vs API | 0.1% |
| EPS | SEC vs API | $0.01 |
| 现金流 | SEC vs API | 0.5% |

### 验证失败处理
- 标记数据为"待核实"
- 提供两个来源的原始数值
- 建议用户手动验证

## 输出要求

### store 目录（原始数据）
```markdown
# [公司] FY[年份] Q[季度] 财务数据

## 数据来源
- SEC 10-Q: [链接]
- 获取时间: [时间戳]

## 原始财务数据
[XBRL 提取的数据]

## 验证状态
[验证结果]
```

### reports 目录（分析报告）
```markdown
# [公司] FY[年份] Q[季度] 财务分析

## 投资要点
[3-5 个关键要点]

## 财务表现
[数据表格 + 分析]

## 管理层展望
[电话会议摘要]

## 风险因素
[关键风险]

## 参考来源
[所有数据出处]
```

## 注意事项
1. 所有财务数据必须标注来源
2. 验证步骤不可跳过
3. 发现数据不一致时必须告知用户
4. 保存的文件使用 UTF-8 编码
```

### 步骤 4：验证技能安装

```bash
# 启动 opencode
opencode

# 检查技能是否被发现
# 在对话中输入：
> 你有哪些可用的技能？
```

---

## 六、依赖工具清单

| 工具/服务 | 用途 | 是否必需 | 获取方式 |
|-----------|------|----------|----------|
| OpenCode | 主运行环境 | 是 | `npm i -g opencode-ai` |
| SEC EDGAR MCP | SEC 文件访问 | 是 | `uvx sec-edgar-mcp` |
| Financial Datasets API | 结构化数据 | 推荐 | 需 API Key |
| EdgarTools | Python 解析库 | 推荐 | `pip install edgartools` |
| Brave Search MCP | 新闻搜索 | 可选 | 已内置 |

### API Key 获取

| 服务 | 获取链接 | 免费额度 |
|------|----------|----------|
| Financial Datasets | https://financialdatasets.ai | 有限免费 |
| Alpha Vantage | https://www.alphavantage.co/support/ | 免费 Tier |
| Octagon AI | https://octagonai.com | 需申请 |

---

## 七、方案优势

1. **多源验证**：同时使用 SEC 官方数据和第三方 API，确保数据准确性
2. **标准化流程**：遵循 Agent Skills 开源标准，兼容 Claude Code 和 OpenCode
3. **审计追踪**：完整记录数据来源和验证过程
4. **模块化设计**：skill 可独立更新和扩展
5. **自动化程度高**：减少手动数据录入和核对工作

---

## 八、已知限制

1. **API 限制**：部分 API 有速率限制和免费额度限制
2. **数据延迟**：SEC 文件发布后 API 数据可能有几小时延迟
3. **非美股支持**：当前方案主要针对美股，其他市场需要额外配置
4. **XBRL 解析复杂性**：部分公司的 XBRL 标签不规范可能影响解析

---

## 参考来源汇总

| # | 来源 | 类型 | 可信度 |
|---|------|------|--------|
| 1 | [OpenCode 官方文档 - Skills](https://opencode.ai/docs/skills/) | 官方 | 高 |
| 2 | [Claude Code Skills 文档](https://code.claude.com/docs/en/skills) | 官方 | 高 |
| 3 | [SEC-MCP GitHub](https://github.com/LuisRincon23/SEC-MCP) | 开源项目 | 高 |
| 4 | [MaverickMCP GitHub](https://github.com/wshobson/maverick-mcp) | 开源项目 | 高 |
| 5 | [Octagon MCP GitHub](https://github.com/OctagonAI/octagon-mcp-server) | 开源项目 | 高 |
| 6 | [Financial Datasets MCP](https://github.com/financial-datasets/mcp-server) | 开源项目 | 高 |
| 7 | [EdgarTools GitHub](https://github.com/dgunning/edgartools) | 开源项目 | 高 |
| 8 | [SEC EDGAR 官方指南](https://www.sec.gov/files/edgar/filer-information/specifications/xbrl-guide.pdf) | 官方 | 高 |
| 9 | [Agent Skills 规范](https://github.com/anthropics/skills) | 官方 | 高 |
| 10 | [Writing OpenCode Agent Skills](https://jpcaparas.medium.com/writing-opencode-agent-skills-a-practical-guide-with-examples-870ff24eec66) | 技术博客 | 中 |

---

#财务分析 #AgentSkill #OpenCode #ClaudeCode #MCP #SEC #调研 #2026
