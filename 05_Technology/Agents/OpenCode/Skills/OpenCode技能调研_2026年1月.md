# OpenCode Agent Skills 综合调研报告

> 调研时间：2026-01-25
> 调研工具：Brave Search + 官方文档 + GitHub 生态
> 调研范围：opencode.ai 产品的技能系统及社区流行技能

---

## 一、OpenCode Skills 概述

### 1.1 什么是 OpenCode Skills？
Agent Skills 是 OpenCode 的核心扩展机制，允许用户通过 `SKILL.md` 文件定义可重用的指令集。这些技能让 AI 编码助手能够：
- 发现并按需加载领域特定的知识
- 执行标准化的工作流程
- 与外部服务、API 和工具交互

**关键特性**：
- **按需加载**：技能仅在需要时被加载到上下文中，不占用永久内存
- **跨平台兼容**：遵循 [Agent Skills 开放标准](https://agentskills.io)，可在 Claude Code、Cursor、VS Code、Gemini CLI 等多个平台使用
- **模块化设计**：每个技能独立成文件夹，包含指令、脚本和资源

### 1.2 技能文件结构

```
my-skill/
├── SKILL.md          # 必需 - 技能定义和指令
├── scripts/          # 可选 - 可执行脚本
│   └── helper.py
├── references/       # 可选 - 参考文档
│   └── api-docs.md
└── assets/           # 可选 - 输出模板
    └── template.html
```

### 1.3 SKILL.md 文件格式

```yaml
---
name: git-release
description: Create consistent releases and changelogs
license: MIT
compatibility: opencode
metadata:
  audience: maintainers
  workflow: github
---

## What I do
- Draft release notes from merged PRs
- Propose a version bump
- Provide a copy-pasteable `gh release create` command

## When to use me
Use this when you are preparing a tagged release.
```

**必需字段**：
- `name`：技能名称（1-64 字符，小写字母+数字+连字符）
- `description`：技能描述（1-1024 字符）

---

## 二、最流行的 OpenCode Skills 分类

### 2.1 Git 与版本控制类 ⭐⭐⭐⭐⭐

| 技能名称                     | 描述                                        | 流行度 |
| ------------------------ | ----------------------------------------- | --- |
| **git-commits**          | 撰写规范的 Git 提交信息，遵循 Conventional Commits 规范 | 极高  |
| **git-release**          | 自动化版本发布，生成 changelog 和发布说明                | 高   |
| **draft-commit-message** | 根据代码变更自动草拟提交信息                            | 高   |
| **git-worktrees**        | 零摩擦管理 git worktrees，自动同步文件                | 中   |

**社区反馈**：Git commit 技能是用户最常创建的首个自定义技能，能显著提升日常开发效率。

### 2.2 代码审查与测试类 ⭐⭐⭐⭐⭐

| 技能名称 | 描述 | 流行度 |
|---------|------|--------|
| **code-review** | 自动化代码审查，检测安全漏洞和最佳实践 | 极高 |
| **webapp-testing** | 使用 Playwright 进行 Web 应用测试 | 高 |
| **tdd** | 测试驱动开发工作流指导 | 高 |
| **debugging** | 系统化的调试方法论和流程 | 中 |

### 2.3 文档与写作类 ⭐⭐⭐⭐

| 技能名称 | 描述 | 流行度 |
|---------|------|--------|
| **docs-writer** | 生成清晰、全面的技术文档 | 高 |
| **skill-creator** | 指导创建新的 OpenCode Skills | 高 |
| **pr-review** | 生成 Pull Request 描述和审查意见 | 中 |

### 2.4 特定技术栈类 ⭐⭐⭐⭐

| 技能名称 | 描述 | 流行度 |
|---------|------|--------|
| **kubernetes-manifests** | 生成 Kubernetes 部署配置 | 高 |
| **api-routes** | 快速创建 API 路由和端点 | 高 |
| **unit-tests** | 为代码自动生成单元测试 | 高 |
| **n8n-workflows** | n8n 工作流自动化专家指导 | 中 |
| **expo-deployment** | Expo 应用部署技能 | 中 |
| **vercel-deploy** | Vercel 项目部署 | 中 |

### 2.5 工作流自动化类 ⭐⭐⭐

| 技能名称 | 描述 | 流行度 |
|---------|------|--------|
| **trello-integration** | Trello 看板、列表和卡片管理 | 中 |
| **linear-issues** | Linear 问题跟踪集成 | 中 |
| **background-agents** | Claude Code 风格的后台代理异步委派 | 中 |

---

## 三、重要技能生态项目

### 3.1 Superpowers 框架 ⭐⭐⭐⭐⭐

**重要性**：极高 | **来源**：[obra/superpowers](https://github.com/obra/superpowers)

Superpowers 是最成熟的技能框架，包含 20+ 经过实战测试的技能：
- TDD（测试驱动开发）
- 调试技巧
- 协作模式
- `/brainstorm`、`/write-plan`、`/execute-plan` 命令

**特色功能**：
- 通过钩子自动注入系统提示
- 工具翻译层（将 Claude Code 工具映射到 OpenCode）
- 支持 skills-search 工具

### 3.2 Awesome OpenCode 资源库 ⭐⭐⭐⭐

**来源**：[awesome-opencode/awesome-opencode](https://github.com/awesome-opencode/awesome-opencode)

精选的 OpenCode 插件、主题、代理和资源集合，包括：
- **动态技能加载器**：自动发现项目、用户和插件目录的技能
- **技能管理系统**：组织和跟踪 OpenCode 能力
- **会话管理**：支持多代理协作

### 3.3 OpenCode Skills 插件 ⭐⭐⭐⭐

**历史地位**：这是首个为 OpenCode 带来技能支持的社区插件

**来源**：[malhashemi/opencode-skills](https://github.com/malhashemi/opencode-skills)

**重要里程碑**：
- 该插件的功能已于 **v1.0.190** 版本被 OpenCode 原生集成
- 证明了社区对技能支持的强烈需求
- 为官方实现提供了验证和反馈

### 3.4 OpenSkills 通用加载器 ⭐⭐⭐

**来源**：[numman-ali/openskills](https://github.com/numman-ali/openskills)

将 Anthropic 的技能系统带到所有 AI 编码代理：
- Claude Code
- Cursor
- Windsurf
- Aider
- Codex
- 任何能读取 AGENTS.md 的工具

---

## 四、技能使用最佳实践

### 4.1 技能设计原则

1. **指令式语言**：使用清晰的指令而非描述
2. **XML 标签**（针对 Anthropic 模型）：提高模型遵从度
3. **限制数量**：过多技能会增加认知负担，建议限制活跃技能数量
4. **精确触发描述**：`description` 字段是语义路由器，决定何时激活技能

### 4.2 技能存放位置

**项目级**（高优先级）：
```
.opencode/skills/<name>/SKILL.md
.claude/skills/<name>/SKILL.md
```

**全局级**（低优先级）：
```
~/.config/opencode/skills/<name>/SKILL.md
~/.claude/skills/<name>/SKILL.md
```

### 4.3 权限配置

```json
{
  "permission": {
    "skill": {
      "*": "allow",
      "pr-review": "allow",
      "internal-*": "deny",
      "experimental-*": "ask"
    }
  }
}
```

| 权限值 | 行为 |
|--------|------|
| `allow` | 技能立即加载 |
| `deny` | 技能对代理隐藏，访问被拒绝 |
| `ask` | 加载前提示用户批准 |

---

## 五、推荐技能优先级排序

### 第一梯队（必装） 🥇

| 技能 | 原因 |
|------|------|
| Git Commits | 每日使用频率最高，提升提交质量 |
| Code Review | 自动化代码审查，提前发现问题 |
| TDD | 建立良好的测试习惯 |

### 第二梯队（强烈推荐） 🥈

| 技能 | 原因 |
|------|------|
| Debugging | 系统化调试流程 |
| Docs Writer | 维护高质量文档 |
| API Routes | 快速搭建后端服务 |

### 第三梯队（按需选用） 🥉

| 技能 | 适用场景 |
|------|----------|
| Kubernetes | 云原生部署 |
| Playwright Testing | 前端 E2E 测试 |
| n8n Workflows | 工作流自动化 |
| Trello/Linear | 项目管理集成 |

---

## 六、技能发展趋势

### 6.1 原生集成

- **v1.0.190**：OpenCode 正式原生支持技能系统
- 不再需要第三方插件
- 现有 SKILL.md 文件可直接迁移

### 6.2 开放标准化

- [agentskills.io](https://agentskills.io) 推动跨平台兼容
- 同一技能可在 Claude Code、Cursor、Codex 等多工具使用
- 社区资源共享成为可能

### 6.3 智能技能选择

社区正在开发：
- 基于意图的技能自动排序（使用 Haiku 分析）
- 无摩擦的自动注入工作流
- 更精确的触发条件匹配

---

## 七、补充说明

### 技能系统的核心价值

1. **知识持久化**：将重复解释的内容固化为可重用指令
2. **上下文节省**：按需加载，不占用永久上下文窗口
3. **团队协作**：技能可通过 Git 共享和版本控制
4. **跨项目复用**：全局技能可在所有项目中使用

### 注意事项

- 添加/修改技能后需重启 OpenCode
- 技能名称必须与包含它的目录名匹配
- 避免同时激活过多技能（建议 < 10 个）
- 使用 `deny` 权限隐藏不需要的技能

---

## 参考来源汇总

| # | 来源 | 类型 | 可信度 |
|---|------|------|--------|
| 1 | [OpenCode 官方文档 - Skills](https://opencode.ai/docs/skills) | 官方 | 高 |
| 2 | [GitHub - opencode-ai/opencode](https://github.com/opencode-ai/opencode) | 官方仓库 | 高 |
| 3 | [obra/superpowers](https://github.com/obra/superpowers) | 社区核心项目 | 高 |
| 4 | [awesome-opencode](https://github.com/awesome-opencode/awesome-opencode) | 社区精选 | 中-高 |
| 5 | [malhashemi/opencode-skills](https://github.com/malhashemi/opencode-skills) | 历史插件 | 中 |
| 6 | [OpenCode Tools 文档](https://opencode.ai/docs/tools/) | 官方 | 高 |
| 7 | [Reddit r/opencodeCLI](https://www.reddit.com/r/opencodeCLI/) | 社区讨论 | 中 |
| 8 | [Medium - Writing OpenCode Agent Skills](https://jpcaparas.medium.com/writing-opencode-agent-skills-a-practical-guide-with-examples-870ff24eec66) | 技术博客 | 中 |
| 9 | [FreeCodeCamp - Integrate AI into Terminal](https://www.freecodecamp.org/news/integrate-ai-into-your-terminal-using-opencode/) | 教程 | 中 |
| 10 | [Blog - Superpowers for OpenCode](https://blog.fsck.com/2025/11/24/Superpowers-for-OpenCode/) | 技术博客 | 中 |

---

#OpenCode #Skills #AI编程 #调研 #2026
