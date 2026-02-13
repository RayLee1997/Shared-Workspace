# Ray's Workspace (Shared)

欢迎来到 Ray 的核心工作区（Shared Workspace）。

这里是 **第二大脑与投资研究指挥中心**，一个融合了深度投资研究、前沿技术探索与长期知识沉淀的混合型工作环境。本工作区旨在通过结构化的知识管理，将碎片化信息转化为可复用的智慧资产。

---

## 1. 核心目标 (Core Objectives)

1. **深度投资研究 (Investment Research)**
    * 生产达到机构级水准的个股深度分析报告（如 NVDA, TSM, MSFT）。
    * 基于宏观经济数据的全球策略分析。
    * 维护动态的关注列表 (Watchlist) 与投资组合计划。

2. **技术与工程 (Engineering & Technology)**
    * 全栈开发与 AI Agent 系统构建（Heimdall, PersonaPlex, OpenClaw）。
    * 系统化整理技术栈笔记（Python, FastAPI, Cloudflare）。
    * 探索与沉淀前沿 AI 工具（Claude Code, Google Antigravity, MCP）。

3. **知识沉淀 (Knowledge Management)**
    * 通过 P.A.R.A + JD 体系管理长期知识。
    * 记录历史、哲学与地缘政治的深度思考。

---

## 2. 文件夹结构 (Structure)

本工作区采用 **P.A.R.A.** (Projects, Areas, Resources, Archives) 与 **Johnny Decimal** (JD) 混合编号体系：

### 📥 输入与处理

* **00_Inbox**: 收集箱。包含 `00_RSS_News` (订阅新闻)、待处理的灵感碎片。

### 🚀 核心领域

* **01_Research**: 通用课题研究与学术笔记。
* **02_Ideas**: 创新点子、写作灵感与随机想法。
* **03_Productions**: 已产出的作品。包括文章、视频脚本、开源项目文档。
* **04_Investments**: **[核心]** 投资研究。财报分析、宏观策略、个股研报。
* **05_Technology**: **[核心]** 技术笔记。涵盖 Agents, Cloudflare, DevOps 等技术栈。
* **07_Investigation**: 深度调查报告。针对特定事件或主题的尽职调查（如 AI 泡沫研究）。

### ⚙️ 系统与支持

* **06_Accounts**: 账户管理、财务记录与订阅服务。
* **08_Personal**: 个人日记与生活记录。
* **10_Explore**: 探索性项目与前沿趋势追踪。
* **11_MOC (Map of Content)**: 知识索引图谱，用于快速导航。
* **99_Archives**: 归档。已完成项目或历史资料。

---

## 3. 关键原则 (Key Principles)

### 双语原则 (Bilingualism)

* **中文 (Chinese)**: 用于综合叙述、逻辑推演、策略总结与定性分析。
* **英文 (English)**: 严格用于专业术语、代码实现、API 文档与财务指标 (Revenue, YoY, CAGR)。这意味着在同一文档中可能会出现中英文混排，旨在保持技术与概念的精准性。

### 事实驱动 (Fact-Driven)

* 任何定性判断（如“增长强劲”）必须辅以定量数据支撑（如“+35.9% YoY”）。
* 投资分析强调逻辑严密性与数据交叉验证 (SEC Filings)。

---

## 4. 给 AI Agent 的指引 (For AI Agents)

* **上下文核心**: 请始终参考根目录下的 **`GEMINI.md`**，它是本工作区的“宪法”与上下文大脑。
* **风格要求**:
  * 写作风格需专业、理性、客观。
  * 强制使用 **Mermaid.js** 进行数据可视化，并遵循 "Healing Dream" 配色风格。
  * 保持 `YYYY-MM-DD` 的时间敏感度，区分历史背景与当前现状。

---

## 5. MCP 配置与 API 密钥 (MCP Configuration)

本工作区使用 **MCP (Model Context Protocol)** 扩展 AI 能力。核心配置文件位于：
`05_Technology/Agents/mcp/mcp_config.json`

### ⚠️ 安全警告 (Security Warning)

该配置文件目前**未被 Git 忽略**。为防止密钥泄漏，**请勿**将真实的 API Key 直接提交到版本控制系统中。建议使用环境变量或本地 `.env` 文件管理。

### 🔑 必需的 API 密钥 (Required Keys)

在使用相关 Agent 功能前，请确保在配置文件中填入以下密钥：

| 服务名称 (Server) | 环境变量 (Env Var) | 用途 | 获取方式 |
| :--- | :--- | :--- | :--- |
| **brave-search** | `BRAVE_API_KEY` | 联网搜索实时的网页、新闻与图片 | [Brave Search API](https://api.search.brave.com/) |
| **edgartools** | `EDGAR_IDENTITY` | 访问 SEC EDGAR 下载财报 (格式: `Name email@domain.com`) | [SEC User Agent](https://www.sec.gov/os/accessing-edgar-data) |
| **fred-mcp-server** | `FRED_API_KEY` | 查询美联储 (FRED) 宏观经济数据 | [FRED API Key](https://fred.stlouisfed.org/docs/api/api_key.html) |

*注：`yfinance` 不需要 API Key。*

---

> *Updated: 2026-02*

---

## 6. Agent 能力地图 (Agent Capabilities)

本工作区集成了强大的 AI Agent 能力，位于 `.agent` 目录下。

### 🛠️ 核心技能 (Skills)

技能是 Agent 的“超能力”，通常由自然语言触发（如“帮我分析一下...”）。

| 技能名称 | 目录 | 触发场景 | 功能描述 |
| :--- | :--- | :--- | :--- |
| **us-stock-analysis** | `skills/us-stock-analysis` | “分析 NVDA”、“解读财报” | **[旗舰技能]** 整合 SEC 财报、电话会议纪要与 Yahoo Finance 行情，生成机构级深度研报。 |
| **fred-data** | `skills/fred-data` | “查一下美国通胀”、“宏观分析” | 连接美联储 (FRED) 数据库，查询利率、CPI、就业等 84万+ 宏观经济指标。 |
| **web-research** | `skills/web-research` | “搜索最新...”| 基于 Brave Search 的深度联网检索，支持多源交叉验证与事实核查。 |
| **mermaid-chart** | `skills/mermaid-chart` | “画个图”、“可视化” | 生成符合 **Healing Dream** 风格的专业图表（折线/柱状/饼图/桑基图）。 |
| **gmail-mcp** | `skills/gmail-mcp` | “发送邮件” | 通过 Gmail API 发送带附件的邮件，支持从本地工作目录提取文件。 |

### 🔄 常用工作流 (Workflows)

工作流是标准化的操作程序，通常由 **Slash Command** (`/`) 触发。

| 指令 | 对应文件 | 用途 |
| :--- | :--- | :--- |
| **`/notion-push`** | `workflows/notion-push.md` | **[核心]** 将当前 Markdown 笔记智能同步到 Notion 数据库，支持大文件自动分块。 |
| **`/yfinance`** | `workflows/yfinance.md` | 快速调用 Yahoo Finance 工具进行个股数据查询（行情/财务/持仓/评级）。 |
| **`/create-moc`** | `workflows/create-moc.md` | 全盘扫描工作区，在 `09_MOC` 目录下生成最新的知识索引图谱 (Map of Content)。 |
| **`/create-tech-tutorial`** | `workflows/create-tech-tutorial.md` | 结构化生成技术教程，包含环境配置、实战案例与最佳实践。 |
| **`/git-push`** | `workflows/git-push.md` | 自动化 Git 流程：Status → Add All → Commit (Auto Message) → Push。 |
| **`/init`** | `workflows/init.md` | 初始化工作区上下文，根据现有内容生成 `GEMINI.md` 规范文件。 |

### 📜 行为准则 (Rules)

位于 `rules/` 目录，定义了 Agent 的基础行为模式。

* **report-rules.md**: 强制执行 **双语写作原则**（中文叙述 + 英文术语），确保专业性与准确性。
