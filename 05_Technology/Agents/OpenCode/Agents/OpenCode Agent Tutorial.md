
# OpenCode Agent Tutorial

## 目录

1. [Agent 设计思想概述](#1-agent-设计思想概述)
2. [Agent 架构与工作原理](#2-agent-架构与工作原理)
3. [内置 Agent 详解](#3-内置-agent-详解)
4. [创建本地 Agent](#4-创建本地-agent)
5. [Agent 配置选项详解](#5-agent-配置选项详解)
6. [权限与工具管理](#6-权限与工具管理)
7. [Agent 扩展机制](#7-agent-扩展机制)
8. [与 OpenCode CLI 集成](#8-与-opencode-cli-集成)
9. [最佳实践与示例](#9-最佳实践与示例)

---

## 1. Agent 设计思想概述

### 1.1 核心理念

OpenCode Agent 的设计基于以下核心理念：

- **专业化分工**：不同的 Agent 专注于不同的任务类型（构建、规划、探索等）
- **权限隔离**：通过细粒度的权限控制，确保 Agent 只能执行授权的操作
- **可组合性**：Primary Agent 可以调用 Subagent 完成子任务
- **可配置性**：几乎所有行为都可以通过配置文件定制

### 1.2 Agent 类型

OpenCode 有两种 Agent 类型：

| 类型 | 说明 | 交互方式 |
|------|------|----------|
| **Primary Agent** | 主要助手，直接与用户交互 | 使用 **Tab** 键切换 |
| **Subagent** | 专门化助手，由 Primary Agent 调用 | 使用 **@mention** 或自动调用 |

---

## 2. Agent 架构与工作原理

### 2.1 架构图

```text

┌─────────────────────────────────────────────────────────────────┐
│                         OpenCode CLI                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐         │
│  │    Build    │◄──►│    Plan     │    │  Custom...  │         │
│  │  (Primary)  │    │  (Primary)  │    │  (Primary)  │         │
│  └──────┬──────┘    └─────────────┘    └─────────────┘         │
│         │                                                       │
│         │ Task Tool                                             │
│         ▼                                                       │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐         │
│  │   General   │    │   Explore   │    │  Custom...  │         │
│  │ (Subagent)  │    │ (Subagent)  │    │ (Subagent)  │         │
│  └─────────────┘    └─────────────┘    └─────────────┘         │
│                                                                 │
├─────────────────────────────────────────────────────────────────┤
│                          Tools Layer                            │
│  ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐ ┌──────────┐     │
│  │ bash │ │ edit │ │ read │ │ grep │ │ glob │ │ MCP/自定义│     │
│  └──────┘ └──────┘ └──────┘ └──────┘ └──────┘ └──────────┘     │
├─────────────────────────────────────────────────────────────────┤
│                      Configuration Layer                        │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐            │
│  │ opencode.json│ │  AGENTS.md   │ │ agents/*.md  │            │
│  └──────────────┘ └──────────────┘ └──────────────┘            │
└─────────────────────────────────────────────────────────────────┘
```

### 2.2 工作流程

1. **初始化**：加载配置文件（全局 → 项目 → 自定义）
2. **Agent 选择**：用户选择或默认使用 Primary Agent
3. **提示处理**：Agent 接收用户输入并生成响应
4. **工具调用**：根据需要调用 Tools（受权限控制）
5. **子任务委托**：复杂任务可委托给 Subagent
6. **结果返回**：Agent 将结果呈现给用户

### 2.3 配置优先级

```
Remote Config (.well-known/opencode) 
    ↓ 覆盖
Global Config (~/.opencode/opencode.json)
    ↓ 覆盖
Custom Config (OPENCODE_CONFIG 环境变量)
    ↓ 覆盖
Project Config (opencode.json)
    ↓ 合并
.opencode/ 目录 (agents, commands, plugins)
```

---

## 3. 内置 Agent 详解

### 3.1 Build Agent (Primary)

**用途**：默认的开发 Agent，具有全部工具权限

```json
{
  "agent": {
    "build": {
      "mode": "primary",
      "tools": {
        "write": true,
        "edit": true,
        "bash": true
      }
    }
  }
}
```

### 3.2 Plan Agent (Primary)

**用途**：规划和分析，限制修改权限

```json
{
  "agent": {
    "plan": {
      "mode": "primary",
      "permission": {
        "edit": "ask",
        "bash": "ask"
      }
    }
  }
}
```

### 3.3 General Subagent

**用途**：通用子 Agent，用于研究复杂问题和执行多步骤任务

- 具有完整工具访问权限（除 todo）
- 可进行文件修改
- 适合并行执行多个工作单元

### 3.4 Explore Subagent

**用途**：快速只读探索代码库

- 无法修改文件
- 快速文件模式匹配
- 代码关键词搜索

---

## 4. 创建本地 Agent

### 4.1 方式一：使用 CLI 创建

```bash
opencode agent create
```

此命令会引导你完成：
1. 选择保存位置（全局/项目）
2. 输入描述
3. 生成系统提示和标识符
4. 选择工具访问权限
5. 创建 Markdown 配置文件

### 4.2 方式二：手动创建 Markdown 文件

**存放位置**：
- 全局：`~/.opencode/agents/`
- 项目：`.opencode/agents/`

**文件命名**：文件名即为 Agent 名称（如 `review.md` → `review` Agent）

**示例：代码审查 Agent**

```markdown
---
description: Reviews code for best practices and potential issues
mode: subagent
model: anthropic/claude-sonnet-4-20250514
temperature: 0.1
tools:
  write: false
  edit: false
  bash: false
permission:
  edit: deny
  bash:
    "*": ask
    "git diff": allow
    "git log*": allow
---

You are in code review mode. Focus on:

- Code quality and best practices
- Potential bugs and edge cases
- Performance implications
- Security considerations

Provide constructive feedback without making direct changes.
```

### 4.3 方式三：JSON 配置

在 `opencode.json` 中配置：

```json
{
  "$schema": "https://opencode.ai/config.json",
  "agent": {
    "code-reviewer": {
      "description": "Reviews code for best practices and potential issues",
      "mode": "subagent",
      "model": "anthropic/claude-sonnet-4-20250514",
      "temperature": 0.1,
      "prompt": "{file:./prompts/code-review.txt}",
      "tools": {
        "write": false,
        "edit": false
      }
    },
    "docs-writer": {
      "description": "Writes and maintains project documentation",
      "mode": "subagent",
      "prompt": "You are a technical writer. Create clear, comprehensive documentation.",
      "tools": {
        "bash": false
      }
    }
  }
}
```

---

## 5. Agent 配置选项详解

### 5.1 基础选项

| 选项 | 类型 | 必需 | 说明 |
|------|------|------|------|
| `description` | string | 是 | Agent 简短描述 |
| `mode` | string | 否 | `primary`/`subagent`/`all`，默认 `all` |
| `model` | string | 否 | 指定 LLM 模型，格式 `provider/model-id` |
| `prompt` | string | 否 | 自定义系统提示 |
| `temperature` | number | 否 | 0.0-1.0，控制随机性 |
| `disable` | boolean | 否 | 禁用该 Agent |
| `hidden` | boolean | 否 | 从 @ 自动完成中隐藏 |

### 5.2 Tools 配置

```json
{
  "agent": {
    "readonly": {
      "tools": {
        "write": false,
        "edit": false,
        "bash": false,
        "mymcp_*": false  // 使用通配符
      }
    }
  }
}
```

### 5.3 权限配置

```json
{
  "agent": {
    "secure-build": {
      "permission": {
        "edit": "ask",
        "bash": {
          "*": "ask",
          "git status *": "allow",
          "rm *": "deny"
        },
        "webfetch": "deny"
      }
    }
  }
}
```

权限值：
- `"allow"` - 无需审批
- `"ask"` - 需要用户确认
- `"deny"` - 禁止操作

### 5.4 Task 权限（控制子 Agent 调用）

```json
{
  "agent": {
    "orchestrator": {
      "mode": "primary",
      "permission": {
        "task": {
          "*": "deny",
          "orchestrator-*": "allow",
          "code-reviewer": "ask"
        }
      }
    }
  }
}
```

### 5.5 高级选项

```json
{
  "agent": {
    "deep-thinker": {
      "description": "Uses high reasoning for complex problems",
      "model": "openai/gpt-5",
      "maxSteps": 10,           // 最大迭代次数
      "reasoningEffort": "high", // 传递给 provider 的额外参数
      "textVerbosity": "low"
    }
  }
}
```

---

## 6. 权限与工具管理

### 6.1 内置工具列表

| 工具 | 说明 | 权限配置键 |
|------|------|-----------|
| `bash` | 执行 shell 命令 | `bash` |
| `edit` | 修改文件 | `edit` |
| `write` | 创建/覆盖文件 | `edit` |
| `read` | 读取文件 | `read` |
| `grep` | 搜索文件内容 | `grep` |
| `glob` | 文件模式匹配 | `glob` |
| `list` | 列出目录 | `list` |
| `webfetch` | 获取 URL 内容 | `webfetch` |
| `skill` | 加载 Skill | `skill` |
| `task` | 调用子 Agent | `task` |

### 6.2 MCP 服务器集成

```json
{
  "mcp": {
    "sentry": {
      "type": "remote",
      "url": "https://mcp.sentry.dev/mcp",
      "oauth": {},
      "enabled": true
    },
    "local-db": {
      "type": "local",
      "command": ["npx", "-y", "my-mcp-server"],
      "environment": {
        "DB_URL": "postgres://localhost/mydb"
      }
    }
  }
}
```

### 6.3 自定义工具

在 `.opencode/tools/` 中创建 TypeScript 文件：

```typescript
// .opencode/tools/database.ts
import { tool } from "@opencode-ai/plugin"

export default tool({
  description: "Query the project database",
  args: {
    query: tool.schema.string().describe("SQL query to execute"),
  },
  async execute(args) {
    // 实现逻辑
    return `Executed query: ${args.query}`
  },
})
```

---

## 7. Agent 扩展机制

### 7.1 Rules (AGENTS.md)

创建 `AGENTS.md` 提供项目上下文：

```markdown
# My Project

## Structure
- `src/` - Source code
- `tests/` - Test files

## Coding Standards
- Use TypeScript strict mode
- Follow ESLint rules

## Important Files
When working on authentication: @src/auth/README.md
```

### 7.2 Skills

在 `.opencode/skills/<name>/SKILL.md` 创建可复用技能：

```markdown
---
name: git-release
description: Create consistent releases and changelogs
license: MIT
---

## What I do
- Draft release notes from merged PRs
- Propose a version bump
- Provide `gh release create` command

## When to use me
Use this when preparing a tagged release.
```

Agent 可通过 `skill` 工具加载：
```
skill({ name: "git-release" })
```

### 7.3 Commands

创建自定义命令 `.opencode/commands/test.md`：

```markdown
---
description: Run tests with coverage
agent: build
model: anthropic/claude-sonnet-4-20250514
---

Run the full test suite with coverage report.
Focus on failing tests and suggest fixes.

Current test status:
!`npm test`
```

使用：`/test`

### 7.4 Plugins

创建 `.opencode/plugins/my-plugin.ts`：

```typescript
import type { Plugin, tool } from "@opencode-ai/plugin"

export const MyPlugin: Plugin = async ({ client, $ }) => {
  return {
    // 监听事件
    "session.idle": async (event) => {
      await $`osascript -e 'display notification "Done!"'`
    },
    
    // 添加工具
    tool: {
      mytool: tool({
        description: "My custom tool",
        args: { input: tool.schema.string() },
        async execute(args) {
          return `Processed: ${args.input}`
        },
      }),
    },
    
    // Hook 工具执行
    "tool.execute.before": async (input, output) => {
      if (input.tool === "bash" && output.args.command.includes("rm")) {
        throw new Error("Blocked dangerous command")
      }
    },
  }
}
```

---

## 8. 与 OpenCode CLI 集成

### 8.1 TUI 模式

```bash
# 启动 TUI
opencode

# 指定 Agent
opencode --agent plan

# 继续上次会话
opencode -c
```

### 8.2 非交互模式

```bash
# 直接运行提示
opencode run "Explain closures in JavaScript"

# 指定模型和 Agent
opencode run --model anthropic/claude-sonnet-4-20250514 --agent plan "Review this code"

# 附加文件
opencode run -f src/main.ts "Analyze this file"
```

### 8.3 服务器模式

```bash
# 启动 API 服务器
opencode serve --port 4096

# 启动带 Web UI 的服务器
opencode web --port 4096 --hostname 0.0.0.0

# 附加到运行中的服务器
opencode attach http://localhost:4096
```

### 8.4 使用 SDK

```typescript
import { createOpencode } from "@opencode-ai/sdk"

const { client } = await createOpencode({
  port: 4096,
  config: {
    model: "anthropic/claude-sonnet-4-20250514",
  },
})

// 创建会话
const session = await client.session.create({
  body: { title: "My session" }
})

// 发送提示
const result = await client.session.prompt({
  path: { id: session.id },
  body: {
    model: { providerID: "anthropic", modelID: "claude-sonnet-4-20250514" },
    parts: [{ type: "text", text: "Hello!" }],
  },
})
```

---

## 9. 最佳实践与示例

### 9.1 安全审计 Agent

```markdown
---
description: Performs security audits and identifies vulnerabilities
mode: subagent
temperature: 0.1
tools:
  write: false
  edit: false
  bash: false
permission:
  read:
    "*": allow
    "*.env*": deny
---

You are a security expert. Focus on identifying potential security issues.

Look for:
- Input validation vulnerabilities
- Authentication and authorization flaws
- Data exposure risks
- Dependency vulnerabilities
- Configuration security issues

Report findings with severity levels and remediation suggestions.
```

### 9.2 文档编写 Agent

```markdown
---
description: Writes and maintains project documentation
mode: subagent
tools:
  bash: false
---

You are a technical writer. Create clear, comprehensive documentation.

Focus on:
- Clear explanations
- Proper structure
- Code examples
- User-friendly language
```

### 9.3 完整项目配置示例

```json
{
  "$schema": "https://opencode.ai/config.json",
  "model": "anthropic/claude-sonnet-4-20250514",
  "theme": "opencode",
  
  "permission": {
    "*": "allow",
    "bash": {
      "*": "ask",
      "git *": "allow",
      "npm *": "allow"
    }
  },
  
  "agent": {
    "build": {
      "mode": "primary",
      "temperature": 0.3
    },
    "plan": {
      "mode": "primary",
      "permission": {
        "edit": "deny",
        "bash": "deny"
      }
    },
    "reviewer": {
      "description": "Code review specialist",
      "mode": "subagent",
      "temperature": 0.1,
      "tools": {
        "edit": false,
        "write": false
      }
    }
  },
  
  "mcp": {
    "context7": {
      "type": "remote",
      "url": "https://mcp.context7.com/mcp"
    }
  },
  
  "instructions": [
    "CONTRIBUTING.md",
    "docs/coding-standards.md"
  ]
}
```

---

## 总结

OpenCode Agent 系统提供了一个灵活、可扩展的 AI 编程助手框架。通过理解其设计思想和配置机制，你可以：

1. **创建专业化 Agent** - 针对特定任务定制行为和权限
2. **组合使用 Agent** - Primary Agent 协调 Subagent 完成复杂任务
3. **扩展功能** - 通过 Skills、Commands、Plugins 和 MCP 扩展能力
4. **集成工作流** - 通过 CLI、SDK 或 Server 模式集成到现有流程

如有问题，可参考：
- 官方文档：https://opencode.ai/docs
- GitHub：https://github.com/anomalyco/opencode
- Discord 社区：https://opencode.ai/discord