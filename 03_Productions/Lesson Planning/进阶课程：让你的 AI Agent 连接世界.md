# 进阶课程：让你的 AI Agent 连接世界

## 1. 课程概述 (Course Overview)

**核心目标**：这是一门面向未来的进阶课程。旨在帮助用户掌握 Antigravity Agent 系统，通过 MCP 协议连接数字世界的数据孤岛，利用 AI Agent 扩展人类的认知边界，并能独立产出机构级深度的投研报告。

**适用人群**：

- 希望打造个性化 AI 助手的开发者。
- 需要深度投研能力的投资者/分析师。
- 追求高效工作流的知识工作者。

**核心哲学**：**Constraint-Driven Engineering** (在限制中寻求最优解) + **Bilingual Intelligence** (双语智慧桥接)。

---

## 2. 课程大纲 (Curriculum Outline)

### 模块一：构建大脑 —— 核心架构解析 (The "Brain")

**目标**：理解 Agent 的认知框架与行为准则，让 AI "懂你"。

#### Lesson 1.1: 赋予灵魂 —— GEMINI.md

- **概念**：`GEMINI.md` 不仅仅是一个文档，它是 Agent 的"系统提示词 (System Prompt)"的外挂显存。
- **核心组件拆解**：
  - **Taxonomy (分类体系)**：P.A.R.A. + JD 体系的混合变体（如 `04_Investments`, `07_Investigation`）。
  - **Tone & Voice (语调)**：如何定义"专业投研"与"技术笔记"的不同风格。
  - **Mental Models (思维模型)**：第一性原理、MECE、二阶思维在 AI 推理中的植入。

#### Lesson 1.2: 行为准则 —— Rules 系统

- **路径**：`.agent/rules/`
- **实战案例**：
  - `report-rules.md`：如何强制 AI 执行"双语原则"（技术术语保留英文，分析用中文）。
  - **练习**：创建一个新的 Rule 文件（例如 `coding-style.md`），规定代码注释风格。

#### Lesson 1.3: 肌肉记忆 —— Workflows

- **路径**：`.agent/workflows/`
- **概念**：将复杂的多步操作固化为标准流程 (`.md` 文件)。
- **案例解析**：
  - `/git-push`：一键提交代码的自动化流程。
  - `/init`：初始化新环境的标准动作。
- **实战**：编写一个 `/daily-review` workflow，自动打开日记并插入天气信息。

---

### 模块二：装备升级 —— 工具与技能 (Tools & Skills)

**目标**：通过 MCP Server 和 Skills 扩展 Agent 的能力边界。

#### Lesson 2.1: 连接世界 —— MCP Server 配置

- **概念**：Model Context Protocol (MCP) 是连接 AI 模型与外部数据/工具的通用标准。
- **核心工具箱配置**：
  - **Brave Search**：联网搜索能力（实时信息）。
  - **EdgarTools**：SEC 监管文件查询（美股财报源头数据）。
  - **YFinance**：实时股价、历史数据、期权链。
  - **FRED**：美联储宏观经济数据（利率、通胀）。
- **配置实战**：在 `claude_desktop_config.json` (或等效配置) 中添加 server 定义。

#### Lesson 2.2: 技能封装 —— Skills 开发

- **路径**：`.agent/skills/`
- **概念**：Skills 是"高级的 Prompt 工程 + 工具调用逻辑"的封装包。
- **案例解析**：
  - `us-stock-analysis`：如何编排 "Search -> Financials -> Synthesis" 的复杂链条。
  - `mermaid-chart`：如何让 AI 稳定生成高质量图表。
- **练习**：修改 `us-stock-analysis` skill，增加一个"竞争对手对比"的自动步骤。

---

### 模块三：实战演练 A —— 个股深度分析 (Stock Analysis)

**目标**：利用 `us-stock-analysis` skill 和 `EdgarTools/YFinance` MCP 产出机构级研报。

#### 案例：Cloudflare (NET) 深度研报解析

- **参考资料**：`04_Investments/Company Watchlist/net/Cloudflare_NET_Q3_2025.md`
- **关键步骤复盘**：
    1. **数据获取**：
        - 使用 `mcp_edgartools` 获取 10-Q 表格，提取 Revenue, Margin, FCF。
        - 使用 `mcp_yfinance` 获取 36 个月股价历史。
    2. **可视化制作**：
        - 使用 `mermaid-chart` skill 生成 `xychart-beta`（估值对比图）。
        - 制作 "Revenue vs Capex" 的多维度对比图。
    3. **深度洞察**：
        - 结合 Earnings Call Transcript（电话会议纪要）提取管理层语调。
        - 运用"二阶思维"分析 AI Capex 对未来 FCF 的影响。
- **作业**：选择一只观察列表中的股票（如 PLTR），生成一份 Q4 财报前瞻分析。

---

### 模块四：实战演练 B —— 行业/宏观调查 (Industry Investigation)

**目标**：结合 `web-research` skill 和 `FRED` MCP 进行宏观叙事构建。

#### 案例：美股 AI 泡沫深度调查

- **参考资料**：`07_Investigation/AI 泡沫/美股 AI 泡沫深度调查报告.md`
- **方法论拆解**：
    1. **框架先行**：引入 Owen Lamont 的"泡沫四骑士"理论作为分析骨架。
    2. **宏观验证**：
        - 使用 `fred-mcp` 拉取 M2, 10Y Yield, High Yield Spread 数据。
        - 对比 Dot-com 时期与当前的宏观环境（数据驱动的叙事）。
    3. **横向扫描**：
        - 对比 Tier 1 (Infra), Tier 2 (Platform), Tier 3 (App) 的估值分化。
        - 制作 "Bubble Scorecard"（泡沫评分卡）。
- **作业**：针对"固态电池"或"人形机器人"行业，撰写一份行业现状与泡沫分析报告。

---

## 3. 学习资源与附录 (Resources)

### 3.1 必备文件清单

- `GEMINI.md`: 核心系统提示词。
- `.agent/skills/us-stock-analysis/SKILL.md`: 研报生成逻辑。
- `.agent/rules/report-rules.md`: 写作规范。

### 3.2 推荐 MCP Servers

| Server | 用途 | 关键工具 |
| :--- | :--- | :--- |
| **edgartools** | 美股基本面 | `edgar_company_research`, `edgar_analyze_financials` |
| **yfinance** | 市场数据 | `get_historical_stock_prices`, `get_stock_info` |
| **brave-search** | 联网信息 | `brave_web_search`, `brave_news_search` |
| **fred-mcp-server** | 宏观数据 | `fred_get_series`, `fred_search` |

### 3.3 理论基石：背景与生态 (Theoretical Foundation: Background & Ecosystem)

**目标**：理解 2026 年 AI 工程化的"分化"格局，以及 MCP 协议如何作为通用语言连接一切。

#### 3.3.1 通用语言 —— Model Context Protocol (MCP)

- **定义**：MCP 是 AI 时代的 USB-C 接口。它制定了一套通用标准，让不同的 AI 模型（Brain）能即插即用地连接外部数据与工具（World）。
- **架构图解**： `Client (Antigravity/Claude) <--> Host <--> Server (Google Drive/Slack/Postgres)`。
- **核心价值**：只需编写一次 MCP Server（例如连接公司内部数据库），即可同时在 Claude Code 和 Antigravity 中使用，无需重复开发。

#### 3.3.2 双雄对决 —— Google Antigravity vs Claude Code

- **2026 年的格局**：AI 开发工具已分化为"工厂"与"经理"两种形态。
- **Google Antigravity ("The Factory")**：
  - **定位**：**IDE-Native (原生集成开发环境)**。就像一个不知疲倦的初级工程师团队。
  - **核心哲学**："Verify, Don't Just Trust" (验证，不仅仅是信任)。
  - **杀手级功能**：
    - **Mission Control**：多 Agent 协同（前端、后端、测试 Agent 并行工作）。
    - **Bifurcation Loop**：自动化的 `生成 -> 运行 -> 报错 -> 修正` 闭环。
    - **Vibe Coding**：视觉驱动开发（画图 -> 生成代码 -> 视觉验收）。
  - **最佳场景**：从零构建项目、快速原型开发、本地环境调试。
- **Claude Code ("The Manager")**：
  - **定位**：**CLI-First (命令行优先)**。就像一个经验丰富的技术架构师。
  - **核心哲学**："Connect the Digital World" (连接数字世界)。
  - **杀手级功能**：
    - **Deep Reasoning**：擅长复杂的架构决策与逻辑推理。
    - **SaaS Integration**：深度集成 Jira, Slack, GitHub，擅长代码审查与沟通。
    - **MCP Apps**：在对话框中直接渲染交互式 UI（如即时修改 Jira 票据）。
  - **最佳场景**：架构设计、代码审查 (Code Review)、编写文档、跨系统协作。
- **结论**：Ray 的工作流应采用 **Hybrid Strategy** —— 用 Antigravity 进行繁重的代码构建（Building），用 Claude Code 进行高维度的管理与审查（Reasoning）。

#### 3.3.3 模型矩阵 —— 给对的人派对的活 (Model Matrix)

- **核心理念**：没有一个模型能通吃所有场景。要根据任务的"上下文窗口需求"与"推理深度需求"灵活切换。
- **Gemini 3 Pro (The Strategist)**:
  - **特长**：**Task Planning (任务规划)**，拥有超长上下文窗口 (2M Tokens)。
  - **最佳场景**：项目初始化、阅读整个代码库、制定宏观路线图、理解复杂的多文件依赖关系。
- **Claude 3.5 Opus (The Architect)**:
  - **特长**：**Deep Reasoning (深度推理)**，擅长复杂逻辑与详细计划制定。
  - **最佳场景**：编写 `implementation_plan.md`、设计复杂算法、进行系统架构审查、撰写深度研报的提纲。
- **Claude 3.5 Sonnet (The Engineer)**:
  - **特长**：**Coding Speed & Execution (编码与执行)**，速度快且代码质量高。
  - **最佳场景**：具体的代码实现、Bug 修复、小的功能迭代、日常重构 (Refactoring)、执行 Opus 制定的计划。

## 4. 下一步行动 (Next Steps)

1. **Environment Audit (环境自检)**: 确认本地 `.agent` 目录结构完整（包含 `rules`, `workflows`, `skills`）。
2. **Key Configuration (密钥配置)**: 准备好 `Brave` (搜索), `OpenAI/Gemini/Claude` (推理) 的 API Key。
3. **Day One Challenge (首日挑战)**:
    - **Planning**: 使用 **Gemini 3 Pro** 回顾并优化你的 `GEMINI.md`。
    - **Execution**: 运行 `/yfinance` workflow，让 **Antigravity** 自动抓取你的投资组合数据。
    - **Review**: 使用 **Claude Sonnet** 将抓取的数据整理成一份简单的 Markdown 简报。
