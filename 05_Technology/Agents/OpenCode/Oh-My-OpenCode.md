# Oh-My-OpenCode 完全指南

> 将 OpenCode 变成最强 AI Agent 调度平台的"电池全包"插件

---

## 目录

1. [项目概述](#1-项目概述)
2. [核心解决方案：MCP 与 Agent 协作](#2-核心解决方案mcp-与-agent-协作)
3. [核心理念：Ultrawork 哲学](#3-核心理念ultrawork-哲学)
4. [与原版 OpenCode 对比](#4-与原版-opencode-对比)
5. [多 Agent 团队协作](#5-多-agent-团队协作)
6. [核心功能详解](#6-核心功能详解)
7. [安装配置指南](#7-安装配置指南)
8. [使用方法](#8-使用方法)
9. [配置选项](#9-配置选项)
10. [常见问题](#10-常见问题)
11. [社区资源](#11-社区资源)

---

## 1. 项目概述

### 1.1 基本信息

| 项目        | 信息                                             |
| --------- | ---------------------------------------------- |
| **仓库地址**  | https://github.com/code-yeongyu/oh-my-opencode |
| **作者**    | @code-yeongyu (Yeongyu Kim)                    |
| **Stars** | 22.7k+                                         |
| **语言**    | TypeScript (99.8%)                             |
| **许可证**   | SUL-1.0                                        |
| **当前版本**  | v3.0.0-beta.16                                 |

### 1.2 一句话定义

> **Oh-My-OpenCode** 是为 [OpenCode](https://github.com/sst/opencode) 打造的"电池全包"插件，通过引入名为 **Sisyphus** 的主 Agent 及其团队，将 OpenCode 转变为最强大的 AI Agent 调度平台。

### 1.3 项目命名寓意

项目名借鉴了希腊神话中的**西西弗斯**（Sisyphus）—— 被惩罚永远推巨石上山的人。

LLM Agent 就像西西弗斯一样，每天不断"推动"他们的"石头"（思考）。**如果给予他们优秀的工具和可靠的队友，AI Agent 可以写出与人类一样出色的代码。**

### 1.4 用户评价

> "它让我取消了 Cursor 订阅。开源社区正在发生令人难以置信的事情。" — Arthur Guiot

> "如果 Claude Code 能在 7 天内完成人类 3 个月的工作，那么 Sisyphus 能在 1 小时内完成。它会一直工作直到任务完成。" — B, 量化研究员

> "用 Oh My OpenCode，你再也回不去了。" — d0t3ch

> "用 Oh My OpenCode 和 ralph loop，我一夜之间将一个 45k 行的 Tauri 应用转换成了 SaaS 网站。" — James Hargis

---

## 2. 核心解决方案：MCP 与 Agent 协作

> **核心解决了什么问题？**  
> 原始 OpenCode 在联网获取信息时，依赖 LLM 凭空推断 URL（"幻觉"风险高，易 404）。  
> **Oh-My-OpenCode (OMO)** 通过引入 **MCP (Model Context Protocol)** 和 **专业分工 Agent**，实现了"先搜索、后抓取"的工业级工作流。

### 2.1 核心架构：MCP 三剑客

OMO 不修改 OpenCode 原生 `webfetch` 工具，而是通过 MCP 协议挂载了三个外部"大脑"，分别覆盖通用搜索、技术文档和代码实例。

#### 1. 通用搜索：Exa AI (Web Search)
- **解决痛点**：解决 LLM 知识滞后和 URL 瞎猜问题。
- **技术实现**：
  - 集成 `https://mcp.exa.ai/mcp`
  - **Exa** 是专为 AI 设计的神经搜索引擎（原 Metaphor），能理解语义而非仅匹配关键词。
- **工作流**：
  - Agent 不再直接 `WebFetch(url)`。
  - 而是先调用 `web_search_exa(query)` 获取高质量、已验证的 URL 列表。
  - 再有的放矢地进行抓取。

#### 2. 技术文档：Context7
- **解决痛点**：解决库版本更新快，LLM 经常引用过时 API 或死链文档的问题。
- **技术实现**：
  - 集成 `https://mcp.context7.com/mcp`
  - 这是一个专门索引技术文档（Documentation）的搜索引擎。
- **优势**：能直接返回精准的文档片段（Snippets），甚至不需要二次抓取。

#### 3. 代码实例：Grep.app
- **解决痛点**：解决 LLM 编造不存在的 API 用法（幻觉代码）。
- **技术实现**：
  - 集成 `grep_app` (GitHub Code Search)。
- **能力**：允许 Agent 直接在 GitHub 海量代码库中搜索真实的"最佳实践"和代码用例。

### 2.2 智能协作：Agent 专家分工

OMO 不仅仅是堆砌工具，它通过 **Agent Orchestration (智能体编排)** 让工具发挥最大效能。

#### Sisyphus (西西弗斯) - 主控大脑
- **角色**：项目经理 / 技术主管。
- **职责**：负责理解用户意图，拆解任务，不直接干脏活累活。
- **策略**：遇到知识盲区，立即委托给专家 Agent。

#### Librarian (图书管理员) - 搜索专家
- **角色**：专职研究员（THE LIBRARIAN）。
- **装备**：独占 Exa、Context7、Grep.app、GitHub CLI 等搜索工具权限。
- **核心职责**：通过查找 **证据** 和 **GitHub 永久链接** 来回答开源库相关问题。
- **行为模式**：
  1. 接收 Sisyphus 的调研任务（如 "研究一下最新的 React Router v7 写法"）。
  2. **请求分类**：将请求分为概念类(A)、实现类(B)、上下文类(C)、综合类(D)。
  3. **文档发现**：使用 websearch 找官方文档 → 检查版本 → 获取 sitemap 了解文档结构。
  4. **多工具并行**：
     - `context7_resolve-library-id` → `context7_query-docs` 查官方文档
     - `grep_app_searchGitHub` 找代码实例
     - `gh repo clone` 深度分析源码
  5. **汇总清洗信息**，只把验证过的、带永久链接的结论返回给 Sisyphus。

### 2.3 工作流对比

```text

┌─────────────────────────────────────────────────────────────────┐
│                    原始 OpenCode 工作流                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   用户提问 → LLM 猜测 URL → WebFetch 抓取 → 可能 404 或过时信息     │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                  Oh-My-OpenCode 工作流                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   用户提问                                                       │
│       ↓                                                         │
│   Sisyphus (主脑) 分析意图                                        │
│       ↓                                                         │
│   发现需要外部知识 → 召唤 Librarian (专家)                         │
│       ↓                                                         │
│   Librarian 并行调用:                                            │
│   ├─ Exa 搜索最新信息                                            │
│   ├─ Context7 查官方文档                                         │
│   └─ Grep.app 找代码实例                                         │
│       ↓                                                         │
│   获取真实 URL + 验证信息                                         │
│       ↓                                                         │
│   返回准确答案（带 GitHub 永久链接）                               │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 2.4 源码验证

以下是从 oh-my-opencode 源码中提取的关键配置，验证了上述架构：

**MCP 配置 (src/mcp/websearch.ts)**:
```typescript
export const websearch = {
  type: "remote" as const,
  url: "https://mcp.exa.ai/mcp?tools=web_search_exa",
  enabled: true,
  // Exa 使用 API Key，不使用 OAuth
  oauth: false as const,
}
```

**MCP 配置 (src/mcp/context7.ts)**:
```typescript
export const context7 = {
  type: "remote" as const,
  url: "https://mcp.context7.com/mcp",
  enabled: true,
  oauth: false as const,
}
```

**Librarian Agent 触发条件 (src/agents/librarian.ts)**:
```typescript
export const LIBRARIAN_PROMPT_METADATA = {
  category: "exploration",
  cost: "CHEAP",
  keyTrigger: "External library/source mentioned → fire `librarian` background",
  useWhen: [
    "How do I use [library]?",
    "What's the best practice for [framework feature]?",
    "Why does [external dependency] behave this way?",
    "Find examples of [library] usage",
    "Working with unfamiliar npm/pip/cargo packages",
  ],
}
```

---

## 3. 核心理念：Ultrawork 哲学

Oh-My-OpenCode 基于以下核心原则设计：

### 3.1 四大原则

| 原则                  | 说明                                |
| ------------------- | --------------------------------- |
| **人工干预是失败信号**       | 就像自动驾驶需要人接管是系统失败，AI 编程需要人修补也是系统失败 |
| **代码应不可区分**         | Agent 写的代码应该与资深工程师写的代码无法区分        |
| **Token 成本 vs 生产力** | 更高的 token 消耗是可接受的，如果它显著提升生产力      |
| **最小化人类认知负担**       | 人类只需说"想要什么"，其他都是 Agent 的工作        |

### 3.2 工作流程理念

```
传统方式：
用户 → 写详细指令 → Agent 执行一步 → 用户检查 → 再写指令 → ...

Ultrawork 方式：
用户 → "ulw 实现认证功能" → Agent 自动规划 → 并行探索 → 持续执行 → 完成
```

---

## 4. 与原版 OpenCode 对比

### 4.1 功能对比表

| 特性                 | OpenCode | Oh-My-OpenCode                                |
| ------------------ | -------- | --------------------------------------------- |
| **获取 URL**         | 纯推理(易幻觉) | MCP 实时检索(100%有效)                              |
| **Agent 系统**       | 单一 Agent | 8+ 专业化 Agent 团队协作                             |
| **模型选择**           | 手动指定     | 按任务类型自动选择最优模型                                 |
| **后台任务**           | 不支持      | 多 Agent 并行运行                                  |
| **LSP 工具**         | 分析功能     | 分析 + 重构（重命名、代码操作等）                            |
| **AST-Grep**       | 不支持      | 支持 25 种语言的 AST 感知搜索                           |
| **内置 MCP**         | 不支持      | Exa (网络搜索)、Context7 (文档)、grep.app (GitHub 搜索) |
| **Hook 系统**        | 基础       | 25+ 预配置钩子                                     |
| **Claude Code 兼容** | 不支持      | 完全兼容                                          |
| **上下文注入**          | 不支持      | 自动注入 AGENTS.md、README.md、条件规则                 |
| **自动恢复**           | 不支持      | 会话恢复、上下文窗口限制恢复                                |
| **任务完成**           | 完成一步等指令  | 强制继续直到任务完成                                    |
| **开箱即用**           | 需配置      | 零配置可用                                         |

### 4.2 核心差异

1. **从单打独斗到团队协作**
   - OpenCode：一个 Agent 处理所有任务
   - Oh-My-OpenCode：Sisyphus 编排 + Oracle 调试 + Librarian 研究 + Explore 搜索...

2. **从被动响应到主动完成**
   - OpenCode：完成一步等待下一步指令
   - Oh-My-OpenCode：Todo Continuation Enforcer 强制 Agent 继续直到任务真正完成

3. **从手动配置到智能编排**
   - OpenCode：需要手动指定模型
   - Oh-My-OpenCode：根据任务类型自动选择（前端用 Gemini，调试用 GPT，编排用 Claude）

---

## 5. 多 Agent 团队协作

### 5.1 核心 Agent

| Agent                 | 默认模型            | 用途                                          |
| --------------------- | --------------- | ------------------------------------------- |
| **Sisyphus**          | Claude Opus 4.5 | **主编排器**：规划、委派、执行复杂任务，使用专业子 Agent 进行激进的并行执行 |
| **Oracle**            | GPT 5.2         | **架构顾问**：架构决策、代码审查、调试（只读，不修改代码）             |
| **Librarian**         | GLM-4.7         | **知识管理员**：多仓库分析、文档查询、开源实现示例                 |
| **Explore**           | Grok Code       | **代码探索者**：快速代码库探索和上下文搜索                     |
| **Multimodal-Looker** | Gemini 3 Flash  | **视觉分析师**：分析 PDF、图片、图表，提取信息                 |

### 5.2 规划 Agent

| Agent          | 默认模型              | 用途                               |
| -------------- | ----------------- | -------------------------------- |
| **Prometheus** | Claude Opus 4.5   | **战略规划师**：通过访谈式问答创建详细工作计划        |
| **Metis**      | Claude Sonnet 4.5 | **计划顾问**：预规划分析，识别隐藏意图和 AI 可能失败的点 |
| **Momus**      | Claude Sonnet 4.5 | **计划审查员**：验证计划的清晰度、可验证性和完整性      |

### 5.3 Agent 调用方式

主 Agent 会自动调用这些子 Agent，你也可以显式调用：

```
Ask @oracle to review this design and propose an architecture
Ask @librarian how this is implemented - why does the behavior keep changing?
Ask @explore for the policy on this feature
```

### 5.4 后台 Agent（并行执行）

像真正的开发团队一样并行工作：

- GPT 调试的同时 Claude 尝试不同方案
- Gemini 写前端的同时 Claude 处理后端
- 大规模并行搜索，继续实现，需要时获取结果

```
# 在后台启动
delegate_task(agent="explore", background=true, prompt="Find auth implementations")

# 继续其他工作...
# 系统会在完成时通知

# 需要时获取结果
background_output(task_id="bg_abc123")
```

---

## 6. 核心功能详解

### 6.1 内置技能（Skills）

| 技能 | 触发条件 | 描述 |
|------|----------|------|
| **playwright** | 浏览器任务、测试、截图 | 通过 Playwright MCP 进行浏览器自动化 |
| **frontend-ui-ux** | UI/UX 任务、样式 | 设计师级别的前端开发，强调大胆的美学方向 |
| **git-master** | commit、rebase、squash、blame | 原子提交、变基、历史搜索，自动检测提交风格 |

### 6.2 内置命令

| 命令 | 描述 |
|------|------|
| `/init-deep` | 初始化分层 AGENTS.md 知识库 |
| `/ralph-loop` | 开始自引用开发循环直到完成 |
| `/ulw-loop` | 以 ultrawork 模式开始循环 |
| `/refactor` | 智能重构（LSP、AST-grep、架构分析、TDD 验证） |
| `/start-work` | 从 Prometheus 计划开始工作 |
| `/cancel-ralph` | 取消活动的 Ralph Loop |

### 6.3 LSP & AST 工具

**LSP 工具**：

| 工具 | 描述 |
|------|------|
| `lsp_diagnostics` | 获取错误/警告 |
| `lsp_prepare_rename` | 验证重命名操作 |
| `lsp_rename` | 跨工作区重命名符号 |
| `lsp_goto_definition` | 跳转到符号定义 |
| `lsp_find_references` | 查找所有使用位置 |
| `lsp_symbols` | 获取文件大纲或工作区符号搜索 |

**AST-Grep 工具**：

| 工具 | 描述 |
|------|------|
| `ast_grep_search` | AST 感知的代码模式搜索（支持 25 种语言） |
| `ast_grep_replace` | AST 感知的代码替换 |

### 6.4 内置 MCP 服务器

| MCP | 功能 |
|-----|------|
| **websearch** (Exa AI) | 实时网络搜索 |
| **context7** | 官方文档查询 |
| **grep_app** | GitHub 代码搜索 |

### 6.5 Hook 系统（25+ 内置钩子）

**上下文注入类**：
- `directory-agents-injector` - 自动注入 AGENTS.md
- `directory-readme-injector` - 自动注入 README.md
- `rules-injector` - 条件规则注入

**生产力控制类**：
- `keyword-detector` - 关键词检测，激活模式
- `think-mode` - 自动检测扩展思考需求
- `ralph-loop` - 自引用循环管理

**质量安全类**：
- `comment-checker` - 防止 AI 添加过多注释
- `thinking-block-validator` - 验证思考块
- `edit-error-recovery` - 编辑错误恢复

**恢复稳定类**：
- `session-recovery` - 会话错误恢复
- `anthropic-context-window-limit-recovery` - 上下文窗口限制恢复
- `background-compaction` - 后台压缩

---

## 7. 安装配置指南

### 7.1 前提条件

确保已安装 OpenCode：

```bash
opencode --version  # 应该 >= 1.0.150
```

如未安装，请先参考：https://opencode.ai/docs

### 7.2 方法一：让 AI 安装（最推荐）

将以下提示词粘贴给你的 AI 助手：

```
Install and configure oh-my-opencode by following the instructions here:
https://raw.githubusercontent.com/code-yeongyu/oh-my-opencode/refs/heads/master/docs/guide/installation.md
```

### 7.3 方法二：交互式安装

```bash
# 使用 bun（推荐）
bunx oh-my-opencode install

# 或使用 npx
npx oh-my-opencode install
```

安装器会询问你的订阅情况并自动配置。

### 7.4 方法三：非交互式安装

根据你的订阅情况选择对应命令：

```bash
# 只有 Claude 订阅
bunx oh-my-opencode install --no-tui \
  --claude=yes \
  --gemini=no \
  --copilot=no

# Claude + OpenAI
bunx oh-my-opencode install --no-tui \
  --claude=yes \
  --openai=yes \
  --gemini=no \
  --copilot=no

# 完整订阅（Claude Max20 + OpenAI + Gemini）
bunx oh-my-opencode install --no-tui \
  --claude=max20 \
  --openai=yes \
  --gemini=yes \
  --copilot=no

# 只有 GitHub Copilot
bunx oh-my-opencode install --no-tui \
  --claude=no \
  --gemini=no \
  --copilot=yes

# 只有 OpenCode Zen
bunx oh-my-opencode install --no-tui \
  --claude=no \
  --gemini=no \
  --copilot=no \
  --opencode-zen=yes
```

### 7.5 配置认证

#### Anthropic (Claude)

```bash
opencode auth login
# 选择 Provider: Anthropic
# 选择 Login method: Claude Pro/Max
# 在浏览器中完成 OAuth 流程
```

#### Google Gemini（使用 Antigravity OAuth）

1. 添加插件到 `opencode.json`：

```json
{
  "plugin": [
    "oh-my-opencode",
    "opencode-antigravity-auth@1.2.8"
  ]
}
```

2. 在 `oh-my-opencode.json` 中配置模型：

```json
{
  "agents": {
    "multimodal-looker": { "model": "google/antigravity-gemini-3-flash" }
  }
}
```

3. 认证：

```bash
opencode auth login
# 选择 Provider: Google
# 选择 Login method: OAuth with Google (Antigravity)
```

#### GitHub Copilot

```bash
opencode auth login
# 选择 GitHub → Authenticate via OAuth
```

### 7.6 验证安装

```bash
# 检查版本
opencode --version

# 检查配置
cat ~/.opencode/opencode.json
# 应该包含 "oh-my-opencode" 在 plugin 数组中
```

---

## 8. 使用方法

### 8.1 魔法词：`ultrawork`（或 `ulw`）

**最简单的使用方式**——只需在提示词中包含 `ultrawork` 或 `ulw`：

```
ulw 给我的 Next.js 应用添加认证功能
```

Agent 会自动：
1. 探索代码库理解现有模式
2. 通过专门的 Agent 研究最佳实践
3. 按照你的代码规范实现功能
4. 使用诊断和测试进行验证
5. 持续工作直到完成

### 8.2 Prometheus 模式（精确规划）

对于复杂或关键任务，按 **Tab** 切换到 Prometheus（规划师）模式：

**工作流程**：

1. **Prometheus 访谈你** - 作为个人顾问，研究代码库并提出澄清性问题
2. **生成计划** - 基于访谈生成详细工作计划，可选由 Momus 审查
3. **运行 `/start-work`** - Atlas 接管执行

**正确工作流**：

```
1. 按 Tab → 进入 Prometheus 模式
2. 描述工作 → Prometheus 访谈你
3. 确认计划 → 审查 .sisyphus/plans/*.md
4. 运行 /start-work → Orchestrator 执行
```

**何时使用 Prometheus**：
- 多天或多会话项目
- 关键生产变更
- 跨多个文件的复杂重构
- 需要文档化决策轨迹

### 8.3 调用特定 Agent

```
Ask @oracle to review this design and propose an architecture
Ask @librarian how this is implemented in other projects?
Ask @explore to find all API endpoints
```

### 8.4 使用内置命令

```bash
# 初始化分层 AGENTS.md
/init-deep

# 开始 Ralph Loop（持续工作直到完成）
/ralph-loop "构建一个带认证的 REST API"

# 智能重构
/refactor src/components --scope=module --strategy=safe

# 从计划开始工作
/start-work my-feature-plan
```

---

## 9. 配置选项

### 9.1 配置文件位置

| 类型 | 位置 |
|------|------|
| 项目级 | `.opencode/oh-my-opencode.json` |
| 用户级 | `~/.opencode/oh-my-opencode.json` |

### 9.2 完整配置示例

```jsonc
{
  "$schema": "https://raw.githubusercontent.com/code-yeongyu/oh-my-opencode/master/assets/oh-my-opencode.schema.json",
  
  // 覆盖特定 Agent 的模型
  "agents": {
    "Atlas": { "model": "anthropic/claude-sonnet-4-5", "variant": "max" },
    "oracle": { "model": "openai/gpt-5.2" },
    "librarian": { "model": "zai-coding-plan/glm-4.7" },
    "explore": { "model": "opencode/grok-code" },
    "multimodal-looker": { "model": "google/gemini-3-flash-preview" }
  },
  
  // 覆盖类别模型（用于成本优化）
  "categories": {
    "quick": { "model": "opencode/grok-code" },
    "visual-engineering": { "model": "google/gemini-3-pro-preview" },
    "unspecified-low": { "model": "zai-coding-plan/glm-4.7" }
  },
  
  // 禁用特定功能
  "disabled_hooks": ["comment-checker", "auto-update-checker"],
  "disabled_agents": ["multimodal-looker"],
  "disabled_mcps": ["websearch"],
  "disabled_skills": ["playwright"],
  
  // 后台任务并发限制
  "background_task": {
    "defaultConcurrency": 5,
    "providerConcurrency": {
      "anthropic": 3,
      "google": 10,
      "openai": 5
    }
  },
  
  // Ralph Loop 配置
  "ralph_loop": {
    "enabled": true,
    "default_max_iterations": 100
  },
  
  // 实验性功能
  "experimental": {
    "aggressive_truncation": true
  },
  
  // Claude Code 兼容性配置
  "claude_code": {
    "mcp": true,
    "commands": true,
    "skills": true,
    "agents": true,
    "hooks": true
  }
}
```

### 9.3 模型优先级链

系统会按以下顺序尝试提供商，直到找到可用模型：

```
原生提供商 (anthropic/, openai/, google/)
    ↓
GitHub Copilot
    ↓
OpenCode Zen
    ↓
Z.ai Coding Plan
```

### 9.4 查看可用模型

```bash
opencode models  # 列出所有可用模型
```

---

## 10. 常见问题

### 10.1 Sisyphus Agent 不工作？

**强烈建议使用 Opus 4.5 模型**。使用其他模型可能导致体验显著下降。

### 10.2 如何卸载？

1. 编辑 `~/.opencode/opencode.json`，从 `plugin` 数组中移除 `"oh-my-opencode"`
2. 删除配置文件（可选）：

```bash
rm -f ~/.opencode/oh-my-opencode.json
rm -f .opencode/oh-my-opencode.json
```

### 10.3 Claude OAuth 访问问题

截至 2026 年 1 月，Anthropic 已限制第三方 OAuth 访问。技术上仍可使用 Claude Code 订阅，但作者不推荐使用可能违反 ToS 的工具。

### 10.4 如何禁用特定功能？

在配置文件中使用 `disabled_*` 字段：

```json
{
  "disabled_hooks": ["comment-checker"],
  "disabled_agents": ["multimodal-looker"],
  "disabled_mcps": ["websearch"],
  "disabled_skills": ["playwright"]
}
```

---

## 11. 社区资源

| 资源 | 链接 |
|------|------|
| **Discord** | https://discord.gg/PUwSMR9XNk |
| **Twitter/X** | [@justsisyphus](https://x.com/justsisyphus) |
| **GitHub** | [@code-yeongyu](https://github.com/code-yeongyu) |
| **DeepWiki** | https://deepwiki.com/code-yeongyu/oh-my-opencode |
| **官方文档** | https://github.com/code-yeongyu/oh-my-opencode/tree/dev/docs |

---

## 总结

**Oh-My-OpenCode** 不只是一个插件，而是一套完整的 AI Agent 编排哲学和工具集：

| 使用场景 | 推荐方式 |
|----------|----------|
| **快速完成任务** | 输入 `ulw` + 你的需求 |
| **复杂任务精确控制** | 用 Prometheus 模式规划，然后 `/start-work` |
| **团队协作风格** | 利用后台 Agent 并行工作 |
| **省钱优化** | 配置 categories 让简单任务用便宜模型 |

**一句话总结**：

> 如果 OpenCode 是一把瑞士军刀，Oh-My-OpenCode 就是一个完整的工具箱 + 自动化工厂 + 一支 AI 开发团队。

---

## 相关链接

- [OpenCode 官方文档](https://opencode.ai/docs/)
- [Oh-My-OpenCode GitHub](https://github.com/code-yeongyu/oh-my-opencode)
- [Ultrawork Manifesto](https://github.com/code-yeongyu/oh-my-opencode/blob/dev/docs/ultrawork-manifesto.md)
- [完整功能文档](https://github.com/code-yeongyu/oh-my-opencode/blob/dev/docs/features.md)
- [配置指南](https://github.com/code-yeongyu/oh-my-opencode/blob/dev/docs/configurations.md)
