# 进阶课程：让你的 AI Agent 连接世界

## 目录 (Table of Contents)

- [1. 课程概述 (Course Overview)](#1-课程概述-course-overview)
- [2. 安全基石：Antigravity 配置 (Security Foundation)](#2-安全基石antigravity-配置-security-foundation)
  - [2.1 Network Access (联网权限)](#21-network-access-联网权限)
  - [2.2 Shell Execution (命令执行)](#22-shell-execution-命令执行)
- [3. 第一部分：实战演练 (Part 1: Practical Case Studies)](#3-第一部分实战演练-part-1-practical-case-studies)
  - [3.1 案例 A：个股深度分析 (Stock Analysis)](#31-案例-a个股深度分析-stock-analysis)
  - [3.2 案例 B：行业/宏观调查 (Industry Investigation)](#32-案例-b行业宏观调查-industry-investigation)
- [4. 第二部分：核心架构解析 (Part 2: Core Architecture & Concepts)](#4-第二部分核心架构解析-part-2-core-architecture--concepts)
  - [4.1 大模型工作原理 (LLM Working Principles)](#41-大模型工作原理-llm-working-principles)
  - [4.2 构建大脑 (The "Brain")](#42-构建大脑-the-brain)
  - [4.3 装备升级 —— 工具与技能 (Tools & Skills)](#43-装备升级--工具与技能-tools--skills)
- [5. 下一步行动 (Next Steps)](#5-下一步行动-next-steps)
- [6. 附录与环境配置 (Appendix & Configuration)](#6-附录与环境配置-appendix--configuration)
  - [6.1 MCP 配置与 API 密钥 (MCP Configuration)](#61-mcp-配置与-api-密钥-mcp-configuration)
  - [6.2 Agent 能力地图 (Agent Capabilities)](#62-agent-能力地图-agent-capabilities)
  - [6.3 学习资源 (Resources)](#63-学习资源-resources)

---

## 1. 课程概述 (Course Overview)

**核心目标**：这是一门面向未来的进阶课程。旨在帮助用户掌握 Antigravity/Claude Agent 系统，通过 MCP 协议连接数字世界的数据孤岛，利用 AI Agent 扩展人类的认知边界，并能独立产出机构级深度的投研报告。

**适用人群**：

- 希望打造个性化 AI 助手的开发者。
- 需要深度投研能力的投资者/分析师。
- 追求高效工作流的知识工作者。

**核心哲学**：**Constraint-Driven Engineering** (在限制中寻求最优解) + **Bilingual Intelligence** (双语智慧桥接)。

---

## 2. 安全基石：Antigravity 配置 (Security Foundation)

在连接世界之前，首先要确确保 Agent 的安全性。Antigravity 的 `User Settings` 是控制 AI 行为边界的第一道防线。

### ⚠️ 核心安全策略 (Security Policies)

推荐配置以下策略以确保系统安全与行为可控：

#### 2.1 Network Access (联网权限)

- **推荐配置**: 开启 `brave-search` 以获取实时信息，但限制其他不必要的网络请求。
- **Risk (风险)**: AI 可能会无意中访问恶意网站或未授权的 API。
- **Action**: 使用白名单机制管理可访问的域名 (如 `api.search.brave.com`, `api.sec.gov`)。

#### 2.2 Shell Execution (命令执行)

- **⚠️ 高危权限**: 赋予 Agent 执行 Shell 命令的能力意味着它拥有了操作系统的部分权限。
- **Policy (策略)**: 建议始终设置为 **Interactive (交互模式)**，即 Agent 生成的任何命令都需要你手动点击 "Run" 或 "Approve" 才能执行。
- **Forbidden**: 严禁将 Shell 权限设置为 `Always Allow (始终允许)`，除非在完全隔离的沙箱环境中。

### 🔑 联网搜索配置 (Search Configuration)

为了让 Agent 具备"上帝视角"，我们需要配置联网能力：

1. **Provider**: **Brave Search** (最佳隐私保护与 API 稳定性)。
2. **获取 Key**: [Register for Brave Search API](https://api.search.brave.com/register)
3. **配置 Env**: 在 `.env` 文件或环境变量中设置 `BRAVE_API_KEY=your_key_here`。
4. **Usage Rule**: 在 Prompt 中明确要求 *"Always cite sources with URLs"* 以避免幻觉。

---

## 3. 第一部分：实战演练 (Part 1: Practical Case Studies)

**目标**：结合 `web-research` 与 `us-stock-analysis` 技能，通过真实案例掌握 AI 投研的核心流程。

### 3.1 案例 A：个股深度分析 (Stock Analysis)

**工具**：`us-stock-analysis` skill, `EdgarTools` MCP, `YFinance` MCP

#### Cloudflare (NET) 深度研报解析

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

### 3.2 案例 B：行业/宏观调查 (Industry Investigation)

**工具**：`web-research` skill, `FRED` MCP

#### 美股 AI 泡沫深度调查

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

## 4. 第二部分：核心架构解析 (Part 2: Core Architecture & Concepts)

**目标**：理解 Agent 的认知框架、工具原理与行为准则，从"会用"进阶到"懂原理"。

### 4.1 大模型工作原理 (LLM Working Principles)

在深入 Agent 架构之前，我们需要理解大模型（LLM）处理信息的核心机制。模型并非只是简单地“回答问题”，而是在一个特定的**上下文窗口 (Context Window)** 中，根据不同**角色 (Roles)** 的指令进行推理和生成。

#### 核心角色解析 (Context Roles)

大模型的上下文由三种核心角色构成，它们共同定义了 AI 的行为模式：

1.  **System (系统层)**
    - **定义**：上帝视角的指令，定义了模型的“人设”、行为边界和底层规则。
    - **作用**：它是最高优先级的指令源。例如：“你是一个专业的金融分析师，只使用中文回答，严禁编造数据。”
    - **在 Agent 中的体现**：对应 `GEMINI.md` 或 `.agent/rules/` 中的内容。

2.  **User (用户层)**
    - **定义**：当前对话的输入者，即你（Ray）。
    - **作用**：提出具体的需求、问题或任务。例如：“分析 PLTR 的最新财报。”
    - **在 Agent 中的体现**：你在对话框中输入的 Prompt。

3.  **Assistant (助手层)**
    - **定义**：模型自身的输出历史。
    - **作用**：模型会参考自己之前的回答来保持上下文的连贯性（Coherence）。
    - **在 Agent 中的体现**：对话历史记录。

#### 指令遵循优先级 (Instruction Priority)

当不同角色的指令发生冲突时，模型通常遵循以下优先级（但现代模型正努力平衡 User 指令的权重）：

1.  **System Prompt (最高优先级)**：
    - 模型**必须**遵守的安全限制、格式要求和核心人设。
    - *示例*：如果 System 规定“只能用 JSON 格式输出”，即使 User 要求“写一首诗”，模型也应尝试用 JSON 包装这首诗或拒绝。

2.  **User Prompt (当前任务)**：
    - 具体的任务指令。在不违反 System 原则的前提下，模型会尽力满足 User 的需求。
    - *技巧*：在 User Prompt 中通过“忽略之前的指令”进行攻击（Prompt Injection）是常见的安全挑战，因此 System Prompt 需要足够强健。

3.  **Context History (历史上下文)**：
    - 之前的对话内容。模型会试图保持逻辑一致，但如果 User 明确要求“从现在开始改变话题”，模型会跟随新的 User 指令。

> **💡 核心洞察**：构建一个强大的 Agent，本质上就是编写一套**不可动摇的 System Prompt**，使其在面对各种 User 输入时，都能稳定地调用工具（Tools）并输出符合预期格式的结果。

### 4.2 构建大脑 (The "Brain")

#### Lesson 4.2.1: 赋予灵魂 —— GEMINI.md

- **概念**：`GEMINI.md` 不仅仅是一个文档，它是 Agent 的"系统提示词 (System Prompt)"的外挂显存。
- **核心组件拆解**：
  - **Taxonomy (分类体系)**：P.A.R.A. + JD 体系的混合变体（如 `04_Investments`, `07_Investigation`）。
  - **Tone & Voice (语调)**：如何定义"专业投研"与"技术笔记"的不同风格。
  - **Mental Models (思维模型)**：第一性原理、MECE、二阶思维在 AI 推理中的植入。

#### Lesson 4.2.2: 行为准则 —— Rules 系统

- **路径**：`.agent/rules/`
- **实战案例**：
  - `report-rules.md`：如何强制 AI 执行"双语原则"（技术术语保留英文，分析用中文）。
  - **练习**：创建一个新的 Rule 文件（例如 `coding-style.md`），规定代码注释风格。

#### Lesson 4.2.3: 肌肉记忆 —— Workflows

- **路径**：`.agent/workflows/`
- **概念**：将复杂的多步操作固化为标准流程 (`.md` 文件)。
- **案例解析**：
  - `/git-push`：一键提交代码的自动化流程。
  - `/init`：初始化新环境的标准动作。
- **实战**：编写一个 `/daily-review` workflow，自动打开日记并插入天气信息。

### 4.3 装备升级 —— 工具与技能 (Tools & Skills)

#### Lesson 4.3.1: 连接世界 —— MCP Server 配置

- **概念**：Model Context Protocol (MCP) 是连接 AI 模型与外部数据/工具的通用标准。
- **核心工具箱配置**：
  - **Brave Search**：联网搜索能力（实时信息）。
  - **EdgarTools**：SEC 监管文件查询（美股财报源头数据）。
  - **YFinance**：实时股价、历史数据、期权链。
  - **FRED**：美联储宏观经济数据（利率、通胀）。
- **配置实战**：在 `claude_desktop_config.json` (或等效配置) 中添加 server 定义。

#### Lesson 4.3.2: 技能封装 —— Skills 开发

- **路径**：`.agent/skills/`
- **概念**：Skills 是"高级的 Prompt 工程 + 工具调用逻辑"的封装包。
- **案例解析**：
  - `us-stock-analysis`：如何编排 "Search -> Financials -> Synthesis" 的复杂链条。
  - `mermaid-chart`：如何让 AI 稳定生成高质量图表。
- **练习**：修改 `us-stock-analysis` skill，增加一个"竞争对手对比"的自动步骤。

---

## 5. 下一步行动 (Next Steps)

1. **Environment Audit (环境自检)**: 确认本地 `.agent` 目录结构完整（包含 `rules`, `workflows`, `skills`）。
2. **Key Configuration (密钥配置)**: 准备好 `Brave` (搜索), `OpenAI/Gemini/Claude` (推理) 的 API Key。
3. **Day One Challenge (首日挑战)**:
    - **Planning**: 使用 **Gemini 3 Pro** 回顾并优化你的 `GEMINI.md`。
    - **Execution**: 运行 `/yfinance` workflow，让 **Antigravity** 自动抓取你的投资组合数据。
    - **Review**: 使用 **Claude Sonnet** 将抓取的数据整理成一份简单的 Markdown 简报。

---

## 6. 附录与环境配置 (Appendix & Configuration)

### 6.1 MCP 配置与 API 密钥 (MCP Configuration)

核心配置文件规范路径：`05_Technology/Agents/mcp/mcp_config.json.md`

> [!TIP] 自动安装 (Auto-Install)
> 复制 `mcp_config.json` 的配置文本到 Antigravity Chat 对话框中，并命令 AI Agent 自动安装执行。Agent 会识别配置内容并将其部署到系统路径 (`~/.gemini/antigravity/mcp_config.json`)。
> 这实现了配置的"文档化管理" (Configuration as Code)。

#### ⚠️ 安全警告 (Security Warning)

该配置文件目前**未被 Git 忽略**。为防止密钥泄漏，**请勿**将真实的 API Key 直接提交到版本控制系统中。建议使用环境变量或本地 `.env` 文件管理。

#### 🔑 必需的 API 密钥 (Required Keys)

在使用相关 Agent 功能前，请确保在配置文件中填入以下密钥：

| 服务名称 (Server) | 环境变量 (Env Var) | 用途 | 获取方式 |
| :--- | :--- | :--- | :--- |
| **brave-search** | `BRAVE_API_KEY` | 联网搜索实时的网页、新闻与图片 | [Brave Search API](https://api.search.brave.com/) |
| **edgartools** | `EDGAR_IDENTITY` | 访问 SEC EDGAR 下载财报 (格式: `Name email@domain.com`) | [SEC User Agent](https://www.sec.gov/os/accessing-edgar-data) |
| **fred-mcp-server** | `FRED_API_KEY` | 查询美联储 (FRED) 宏观经济数据 | [FRED API Key](https://fred.stlouisfed.org/docs/api/api_key.html) |

*注：`yfinance` 不需要 API Key。*

### 6.2 Agent 能力地图 (Agent Capabilities)

本工作区集成了强大的 AI Agent 能力，位于 `.agent` 目录下。

#### 🛠️ 核心技能 (Skills)

| 技能名称 | 目录 | 触发场景 | 功能描述 |
| :--- | :--- | :--- | :--- |
| **us-stock-analysis** | `skills/us-stock-analysis` | “分析 NVDA”、“解读财报” | **[旗舰技能]** 整合 SEC 财报、电话会议纪要与 Yahoo Finance 行情，生成机构级深度研报。 |
| **fred-data** | `skills/fred-data` | “查一下美国通胀”、“宏观分析” | 连接美联储 (FRED) 数据库，查询利率、CPI、就业等 84万+ 宏观经济指标。 |
| **web-research** | `skills/web-research` | “搜索最新...”| 基于 Brave Search 的深度联网检索，支持多源交叉验证与事实核查。 |
| **mermaid-chart** | `skills/mermaid-chart` | “画个图”、“可视化” | 生成符合 **Healing Dream** 风格的专业图表（折线/柱状/饼图/桑基图）。 |
| **gmail-mcp** | `skills/gmail-mcp` | “发送邮件” | 通过 Gmail API 发送带附件的邮件，支持从本地工作目录提取文件。 |

#### 🔄 常用工作流 (Workflows)

| 指令 | 对应文件 | 用途 |
| :--- | :--- | :--- |
| **`/notion-push`** | `workflows/notion-push.md` | **[核心]** 将当前 Markdown 笔记智能同步到 Notion 数据库，支持大文件自动分块。 |
| **`/yfinance`** | `workflows/yfinance.md` | 快速调用 Yahoo Finance 工具进行个股数据查询（行情/财务/持仓/评级）。 |
| **`/create-moc`** | `workflows/create-moc.md` | 全盘扫描工作区，在 `09_MOC` 目录下生成最新的知识索引图谱 (Map of Content)。 |
| **`/create-tech-tutorial`** | `workflows/create-tech-tutorial.md` | 结构化生成技术教程，包含环境配置、实战案例与最佳实践。 |
| **`/git-push`** | `workflows/git-push.md` | 自动化 Git 流程：Status → Add All → Commit (Auto Message) → Push。 |
| **`/init`** | `workflows/init.md` | 初始化工作区上下文，根据现有内容生成 `GEMINI.md` 规范文件。 |

#### 📜 行为准则 (Rules)

位于 `rules/` 目录，定义了 Agent 的基础行为模式。

- **report-rules.md**: 强制执行 **双语写作原则**（中文叙述 + 英文术语），确保专业性与准确性。

### 6.3 学习资源 (Resources)

#### 必备文件清单

- `GEMINI.md`: 核心系统提示词。
- `.agent/skills/us-stock-analysis/SKILL.md`: 研报生成逻辑。
- `.agent/rules/report-rules.md`: 写作规范。

#### 理论基石：背景与生态 (Theoretical Foundation: Background & Ecosystem)

**目标**：理解 2026 年 AI 工程化的"分化"格局，以及 MCP 协议如何作为通用语言连接一切。

##### 通用语言 —— Model Context Protocol (MCP)

- **定义**：MCP 是 AI 时代的 USB-C 接口。它制定了一套通用标准，让不同的 AI 模型（Brain）能即插即用地连接外部数据与工具（World）。
- **架构图解**： `Client (Antigravity/Claude) <--> Host <--> Server (Google Drive/Slack/Postgres)`。
- **核心价值**：只需编写一次 MCP Server（例如连接公司内部数据库），即可同时在 Claude Code 和 Antigravity 中使用，无需重复开发。

##### 双雄对决 —— Google Antigravity vs Claude Code

- **2026 年的格局**：AI 开发工具已分化为"工厂"与"经理"两种形态。
- **Google Antigravity ("The Factory")**：
  - **定位**：**IDE-Native (原生集成开发环境)**。就像一个不知疲倦的初级工程师团队。
  - **核心哲学**："Verify, Don't Just Trust" (验证，不仅仅是信任)。
  - **最佳场景**：从零构建项目、快速原型开发、本地环境调试。
- **Claude Code ("The Manager")**：
  - **定位**：**CLI-First (命令行优先)**。就像一个经验丰富的技术架构师。
  - **核心哲学**："Connect the Digital World" (连接数字世界)。
  - **最佳场景**：架构设计、代码审查 (Code Review)、编写文档、跨系统协作。
- **结论**：Ray 的工作流应采用 **Hybrid Strategy** —— 用 Antigravity 进行繁重的代码构建（Building），用 Claude Code 进行高维度的管理与审查（Reasoning）。

##### 模型矩阵 —— 给对的人派对的活 (Model Matrix)

- **Gemini 3 Pro (The Strategist)**: 项目初始化、阅读整个代码库、制定宏观路线图。
- **Claude 4.5 Opus (The Architect)**: 编写 `implementation_plan.md`、系统架构审查。
- **Claude 4.5 Sonnet (The Engineer)**: 具体的代码实现、Bug 修复、小的功能迭代。
