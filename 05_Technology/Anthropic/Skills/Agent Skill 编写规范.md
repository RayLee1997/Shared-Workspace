# Agent Skill 编写规范

本指南基于 Anthropic [官方文档](https://code.claude.com/docs/en/skills) 整理，适用于 Claude Code、Antigravity 及兼容 Agent Skills 标准的工具。

---

## 1. 概述：什么是 Skill？

**Agent Skill** 是一种文件系统级的扩展机制，让你能将可复用的领域知识、工作流和最佳实践打包，供 Claude 按需加载。

**核心特征：**

- **Progressive Disclosure（渐进披露）**：Claude 启动时仅加载 Skill 的元数据（名称+描述）。只有当 Skill 被触发时，才会读取完整内容——这意味着你可以安装大量 Skill 而不会占用上下文窗口。
- **Self-Contained（自包含）**：每个 Skill 是一个独立目录，包含说明文档、可执行脚本、模板等所有必要资源。

**Skills vs Prompts：**

| | Prompts | Skills |
|---|---------|--------|
| 作用范围 | 单次对话 | 跨对话复用 |
| 加载时机 | 始终在上下文中 | 按需加载 |
| 内容类型 | 纯文本指令 | 指令 + 脚本 + 资源 |

---

## 2. 目录结构

Skill 存放于 `.agent/skills/`（项目级）或 `~/.config/claude/skills/`（用户全局级）。

```
.agent/skills/
└── my-skill/               # Skill 目录名（与 name 一致）
    ├── SKILL.md            # [必须] 核心定义文件
    ├── reference.md        # [可选] 详细参考文档
    ├── examples.md         # [可选] 使用示例
    └── scripts/            # [可选] 可执行脚本
        └── helper.py
```

> **三层加载机制：**
>
> 1. **Level 1 - Metadata**：`SKILL.md` 的 YAML frontmatter，启动时加载到系统提示。
> 2. **Level 2 - Instructions**：`SKILL.md` 正文，触发时通过 bash 读取。
> 3. **Level 3 - Resources**：附加文件（.md、.py 等），仅在被引用时读取/执行。

---

## 3. SKILL.md 规范

`SKILL.md` 由 **YAML Frontmatter** + **Markdown 正文** 组成。

### 3.1 YAML Frontmatter（元数据）

```yaml
---
name: web-research                # [必须] 唯一标识符
description: >-                   # [必须] 触发条件描述
  Search the web for real-time information.
  Use for fact-checking, news, or technical research.
disable-model-invocation: false   # [可选] true = 仅用户可调用
user-invocable: true              # [可选] false = 仅模型可调用
allowed-tools:                    # [可选] 限制可用工具
  - brave_web_search
  - Read
context: fork                     # [可选] 在子代理中运行
agent: Explore                    # [可选] 指定子代理类型
---
```

**字段约束：**

| 字段 | 约束 |
|------|------|
| `name` | ≤64 字符，仅小写字母、数字、连字符，不含 `anthropic`/`claude` |
| `description` | ≤1024 字符，不含 XML 标签 |

**调用控制矩阵：**

| 场景 | `disable-model-invocation` | `user-invocable` |
|------|---------------------------|------------------|
| 用户和模型都能调用（默认） | `false` | `true` |
| 仅用户可调用（如 `/deploy`） | `true` | `true` |
| 仅模型可调用（背景知识） | `false` | `false` |

### 3.2 Markdown 正文（指令）

正文是 Claude 被触发后读取的具体"说明书"。

**推荐结构：**

```markdown
# [Skill Name]

## Overview
简述功能与适用场景。

## When to Use
- 场景 A
- 场景 B
- **不要使用**：场景 C

## Workflow
1. **Step 1**: ...
2. **Step 2**: ...

## Output Format
定义输出模板（表格、列表、标题结构等）。

## Examples
提供输入→输出的具体案例。

## Additional Resources
- 详细 API 参考见 [reference.md](reference.md)
- 使用示例见 [examples.md](examples.md)
```

---

## 4. 高级特性

### 4.1 参数传递

使用 `$ARGUMENTS` 或 `$0`/`$1`/`$2` 接收用户输入：

```yaml
---
name: fix-issue
description: Fix a GitHub issue
disable-model-invocation: true
---
Fix GitHub issue $ARGUMENTS following our coding standards.
```

调用：`/fix-issue 123`

### 4.2 动态上下文注入

使用 `!` 前缀在 Skill 加载前执行命令，将输出注入提示：

```yaml
---
name: pr-summary
description: Summarize a pull request
context: fork
agent: Explore
---
## Context
- PR diff: !`gh pr diff`
- Changed files: !`gh pr diff --name-only`

## Task
Summarize this pull request...
```

### 4.3 子代理运行

设置 `context: fork` 让 Skill 在隔离上下文中执行：

```yaml
---
name: deep-research
description: Research a topic thoroughly
context: fork
agent: Explore    # 可选：Explore, Plan, general-purpose, 或自定义
---
```

---

## 5. 最佳实践

1. **Description 是路由键**
   - ❌ `Search stuff`
   - ✅ `Search the web for real-time information, fact-checking, and technical documentation. Use when current context is insufficient.`

2. **明确"何时使用"与"何时不用"**
   - 在正文中清晰列出适用/不适用场景

3. **结构化输出**
   - 定义明确的 Markdown 模板，避免自由文本

4. **包含错误处理**
   - 说明工具调用失败时的回退策略

5. **渐进披露**
   - 把详细文档放在单独的 `.md` 文件中，用链接引用

---

## 6. 安全须知

> [!CAUTION]
> **仅使用来自可信来源的 Skill**

- **彻底审计**：检查所有文件（SKILL.md、脚本、资源）
- **警惕外部依赖**：从 URL 获取内容的 Skill 存在注入风险
- **工具滥用**：恶意 Skill 可能执行有害的 bash 命令或文件操作

---

## 7. 参考资源

- [官方文档：Extend Claude with skills](https://code.claude.com/docs/en/skills)
- [Agent Skills Overview](https://docs.claude.com/en/docs/agents-and-tools/agent-skills/overview)
- [Anthropic Skills Repo](https://github.com/anthropics/skills)
- [Awesome Agent Skills](https://github.com/VoltAgent/awesome-agent-skills)
