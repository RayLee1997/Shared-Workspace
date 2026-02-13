# OpenCode Skills 完全指南

> 从零开始理解 Skills 的工作原理，并一步一步创建你的第一个 Skill。

---

## 目录

1. [Skills 是什么？](#1-skills-是什么)
2. [工作原理详解](#2-工作原理详解)
3. [动手创建你的第一个 Skill](#3-动手创建你的第一个-skill)
4. [SKILL.md 文件详解](#4-skillmd-文件详解)
5. [权限配置（进阶）](#5-权限配置进阶)
6. [常见问题排查](#6-常见问题排查)
7. [实战案例：创建 git-release Skill](#7-实战案例创建-git-release-skill)

---

## 1. Skills 是什么？

### 1.1 一句话理解

**Skills = 给 AI Agent 的"技能卡"**

就像游戏角色可以装备不同技能一样，你可以给 OpenCode Agent 创建各种"技能卡"。当 Agent 遇到特定任务时，它会自动选择合适的技能来完成工作。

### 1.2 举个例子

假设你创建了一个 `git-release` 技能：

```
你对 Agent 说：「帮我发布一个新版本」

Agent 的思考过程：
1. 「用户要发布版本...」
2. 「我有一个 git-release 技能可以用！」
3. 「让我加载这个技能的详细指令...」
4. 「按照指令执行：生成 changelog、打 tag、创建 release...」
```

### 1.3 Skills 能做什么？

| 场景 | Skill 示例 |
|------|-----------|
| 代码审查 | `code-review` - 检查代码质量和潜在问题 |
| 版本发布 | `git-release` - 自动生成发布说明和命令 |
| 文档生成 | `docs-generator` - 根据代码生成文档 |
| 测试辅助 | `test-helper` - 帮助编写和运行测试 |
| 项目规范 | `coding-standards` - 确保代码符合团队规范 |

---

## 2. 工作原理详解

### 2.1 整体流程图

```text

┌─────────────────────────────────────────────────────────────────────┐
│                        OpenCode 启动时                               │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   ① 扫描 Skills 目录                                                 |
│      ↓                                                              │
│   ┌─────────────────────────────────────────────────────────┐       │
│   │  ~/.opencode/skills/git-release/SKILL.md                │       │
│   │  ~/.opencode/skills/code-review/SKILL.md                │       │
│   │  .opencode/skills/my-project-skill/SKILL.md             │       │
│   └─────────────────────────────────────────────────────────┘       │
│      ↓                                                              │
│   ② 读取每个 SKILL.md 的 name 和 description（轻量索引）               │
│      ↓                                                              │
│   ③ 生成可用 Skills 列表，注入到 Agent 的工具描述中                     │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────────┐
│                        Agent 运行时                                  │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   Agent 看到的工具描述：                                              │
│   ┌─────────────────────────────────────────────────────────┐       │
│   │  <available_skills>                                     │       │
│   │    <skill>                                              │       │
│   │      <name>git-release</name>                           │       │
│   │      <description>创建版本发布和更新日志</description>     │       │
│   │    </skill>                                             │       │
│   │    <skill>                                              │       │
│   │      <name>code-review</name>                           │       │
│   │      <description>审查代码并提供反馈</description>        │        │
│   │    </skill>                                             │       │
│   │  </available_skills>                                    │       │
│   └─────────────────────────────────────────────────────────┘       │
│      ↓                                                              │
│   ④ Agent 根据用户请求，决定是否需要某个 Skill                          │
│      ↓                                                              │
│   ⑤ 调用 skill({ name: "git-release" }) 加载完整内容                  │
│      ↓                                                              │
│   ⑥ 按照 Skill 中的指令执行任务                                       │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### 2.2 按需加载机制

**为什么不一次性加载所有 Skills？**

因为 AI 的上下文窗口（context window）是有限的。如果你有 20 个 Skills，每个 500 字，一次性加载就占用 10000 字的上下文空间。

OpenCode 的解决方案：**按需加载**

| 阶段 | 加载内容 | 大小 |
|------|----------|------|
| 启动时 | 只读取 `name` + `description` | 约 50 字/skill |
| 需要时 | 加载完整 SKILL.md 内容 | 约 500 字/skill |

这样，即使有 100 个 Skills，启动时也只占用约 5000 字，而不是 50000 字。

### 2.3 Skills 存放位置

OpenCode 会在以下位置搜索 Skills：

| 类型 | 路径 | 适用场景 |
|------|------|----------|
| **项目级** | `.opencode/skills/<name>/SKILL.md` | 特定项目的技能 |
| **全局** | `~/.opencode/skills/<name>/SKILL.md` | 所有项目通用的技能 |
| **项目 Claude 兼容** | `.claude/skills/<name>/SKILL.md` | 兼容 Claude Code |
| **全局 Claude 兼容** | `~/.claude/skills/<name>/SKILL.md` | 兼容 Claude Code |

**发现机制**：
- **项目级**：从当前目录向上遍历，直到 git 仓库根目录
- **全局**：始终加载 `~/.opencode/skills/` 和 `~/.claude/skills/`
- **优先级**：项目级 > 全局（同名时项目级覆盖全局）

---

## 3. 动手创建你的第一个 Skill

### 3.1 选择存放位置

```bash
# 方式 1：全局 Skill（所有项目都能用）
mkdir -p ~/.opencode/skills/my-first-skill

# 方式 2：项目级 Skill（只在当前项目生效）
mkdir -p .opencode/skills/my-first-skill
```

### 3.2 创建 SKILL.md 文件

```bash
# 进入 skill 目录
cd ~/.opencode/skills/my-first-skill

# 创建文件（注意：文件名必须是大写的 SKILL.md）
touch SKILL.md
```

### 3.3 编写内容

用你喜欢的编辑器打开 `SKILL.md`，写入：

```markdown
---
name: my-first-skill
description: 我的第一个技能，用于学习 Skills 系统
---

## 我能做什么

这是一个测试技能，用于验证 Skills 系统是否正常工作。

## 使用场景

当用户说「测试一下 skills」时使用这个技能。

## 执行步骤

1. 向用户问好
2. 告诉用户这个 Skill 已成功加载
3. 列出当前目录下的文件
```

### 3.4 验证是否生效

重启 OpenCode，然后对 Agent 说：

```
测试一下 skills
```

如果 Agent 加载了你的技能并按照指令执行，恭喜你！你的第一个 Skill 创建成功了。

---

## 4. SKILL.md 文件详解

### 4.1 文件结构

```markdown
---
name: skill-name          # 必需：技能名称
description: 技能描述      # 必需：简短描述（给 Agent 看的）
license: MIT              # 可选：许可证
compatibility: opencode   # 可选：兼容性说明
metadata:                 # 可选：自定义元数据
  author: your-name
  version: 1.0.0
---

# 以下是 Skill 的正文内容
# Agent 调用 skill() 时会读取这部分

## What I do（我做什么）
...

## When to use me（何时使用）
...

## Instructions（具体指令）
...
```

### 4.2 Frontmatter 字段说明

#### 必需字段

| 字段 | 说明 | 示例 |
|------|------|------|
| `name` | 技能名称，必须与目录名一致 | `git-release` |
| `description` | 1-1024 字符的描述 | `创建版本发布和更新日志` |

#### 可选字段

| 字段 | 说明 | 示例 |
|------|------|------|
| `license` | 许可证类型 | `MIT` |
| `compatibility` | 兼容性说明 | `opencode` |
| `metadata` | 自定义键值对 | `{ author: "john" }` |

### 4.3 名称规则

`name` 字段必须满足：

| 规则 | 说明 |
|------|------|
| 长度 | 1-64 个字符 |
| 字符 | 只能用小写字母、数字、连字符 |
| 连字符 | 不能在开头或结尾，不能连续 `--` |
| 匹配 | 必须与目录名完全一致 |

**正则表达式**：`^[a-z0-9]+(-[a-z0-9]+)*$`

| 示例 | 是否有效 | 原因 |
|------|----------|------|
| `git-release` | ✅ | 符合规则 |
| `code-review` | ✅ | 符合规则 |
| `my-skill-123` | ✅ | 符合规则 |
| `Git-Release` | ❌ | 包含大写字母 |
| `-my-skill` | ❌ | 以连字符开头 |
| `my--skill` | ❌ | 连续连字符 |

### 4.4 推荐的内容结构

```markdown
---
name: your-skill-name
description: 简短描述这个技能做什么
---

## What I do（我做什么）

用列表说明这个技能的主要功能：
- 功能 1
- 功能 2
- 功能 3

## When to use me（何时使用）

描述使用场景。告诉 Agent：
- 什么时候应该用这个技能
- 什么时候不应该用
- 不确定时该怎么办（比如询问用户）

## Instructions（具体指令）

详细的执行步骤：
1. 第一步
2. 第二步
3. 第三步

## Examples（示例）- 可选

提供一些示例输入输出，帮助 Agent 理解。

## Notes（注意事项）- 可选

一些需要特别注意的点。
```

---

## 5. 权限配置（进阶）

### 5.1 为什么需要权限控制？

有些 Skills 可能包含敏感操作，你可能想要：
- 完全禁止某些 Skills
- 使用前需要用户确认
- 只允许特定 Agent 使用某些 Skills

### 5.2 在 opencode.json 中配置

```json
{
  "permission": {
    "skill": {
      "*": "allow",              // 默认允许所有
      "pr-review": "allow",      // 显式允许
      "internal-*": "deny",      // 拒绝所有 internal- 开头的
      "experimental-*": "ask"    // 需要用户确认
    }
  }
}
```

| 权限值 | 行为 |
|--------|------|
| `allow` | 立即加载，无需确认 |
| `ask` | 每次使用前提示用户批准 |
| `deny` | 完全禁止，对 Agent 隐藏 |

### 5.3 通配符模式

| 模式 | 匹配 |
|------|------|
| `*` | 所有 Skills |
| `internal-*` | 所有以 `internal-` 开头的 |
| `*-tools` | 所有以 `-tools` 结尾的 |

### 5.4 为特定 Agent 配置权限

**方式 1：在 opencode.json 中为内置 Agent 配置**

```json
{
  "agent": {
    "plan": {
      "permission": {
        "skill": {
          "internal-*": "allow"
        }
      }
    }
  }
}
```

**方式 2：在自定义 Agent 的 frontmatter 中配置**

```yaml
---
description: My custom agent
permission:
  skill:
    "documents-*": "allow"
---
```

### 5.5 禁用 Skill 工具

如果某个 Agent 完全不需要使用 Skills：

**自定义 Agent（在 AGENT.md 中）**：

```yaml
---
tools:
  skill: false
---
```

**内置 Agent（在 opencode.json 中）**：

```json
{
  "agent": {
    "plan": {
      "tools": {
        "skill": false
      }
    }
  }
}
```

---

## 6. 常见问题排查

### 6.1 Skill 不显示？

按以下清单逐项检查：

| 检查项 | 正确 | 错误 |
|--------|------|------|
| 文件名 | `SKILL.md` | `skill.md`, `Skill.md` |
| 目录结构 | `skills/git-release/SKILL.md` | `skills/SKILL.md` |
| name 字段 | `name: git-release` | 缺少或拼写错误 |
| description | `description: 描述` | 缺少 |
| 目录名匹配 | 目录 `git-release/` + `name: git-release` | 不一致 |
| 权限 | 未被 deny | 被设为 `deny` |

### 6.2 快速诊断命令

```bash
# 检查全局 Skills 目录
ls -la ~/.opencode/skills/

# 检查项目 Skills 目录
ls -la .opencode/skills/

# 查看某个 SKILL.md 的 frontmatter
head -10 ~/.opencode/skills/git-release/SKILL.md
```

### 6.3 常见错误

**错误 1：目录名和 name 不匹配**

```
# 目录
~/.opencode/skills/gitrelease/SKILL.md

# SKILL.md 内容
---
name: git-release    # ❌ 应该是 gitrelease
description: ...
---
```

**错误 2：文件名大小写错误**

```
skills/git-release/skill.md    # ❌ 必须是 SKILL.md
```

**错误 3：Frontmatter 格式错误**

```markdown
# ❌ 错误：缺少 ---
name: git-release
description: ...

# ✅ 正确
---
name: git-release
description: ...
---
```

---

## 7. 实战案例：创建 git-release Skill

现在让我们从零开始创建一个实用的 `git-release` Skill。

### 7.1 需求分析

我们希望这个 Skill 能够：
- 分析最近的 commits 和 merged PRs
- 自动生成版本号建议
- 生成 changelog
- 提供可直接复制执行的 `gh release create` 命令

### 7.2 Step 1: 创建目录

```bash
# 创建全局 Skill（所有项目都能用）
mkdir -p ~/.opencode/skills/git-release
```

### 7.3 Step 2: 创建 SKILL.md

```bash
touch ~/.opencode/skills/git-release/SKILL.md
```

### 7.4 Step 3: 编写内容

将以下内容写入 `~/.opencode/skills/git-release/SKILL.md`：

```markdown
---
name: git-release
description: 创建版本发布，自动生成 changelog 和 release 命令
license: MIT
metadata:
  author: your-name
  version: 1.0.0
---

## What I do（我做什么）

我帮助你完成版本发布的所有准备工作：

1. **分析变更**：查看自上次发布以来的所有 commits 和 merged PRs
2. **建议版本号**：根据变更类型（breaking/feature/fix）建议合适的版本号
3. **生成 Changelog**：自动整理变更内容，按类别分组
4. **提供发布命令**：生成可直接执行的 `gh release create` 命令

## When to use me（何时使用）

在以下场景使用我：
- 准备发布新版本时
- 需要生成 release notes 时
- 想要快速创建 GitHub release 时

**不确定时**：询问用户期望的版本号格式（如 semver、calver 等）

## Instructions（执行步骤）

### Step 1: 获取上次发布信息

```bash
# 获取最新的 tag
git describe --tags --abbrev=0 2>/dev/null || echo "No tags found"

# 查看自上次 tag 以来的 commits
git log $(git describe --tags --abbrev=0 2>/dev/null || echo "")..HEAD --oneline


### Step 2: 分析变更类型

将 commits 分为以下类别：
- **Breaking Changes** (💥)：包含 `BREAKING` 或 `!:` 的提交
- **Features** (✨)：以 `feat:` 开头的提交
- **Bug Fixes** (🐛)：以 `fix:` 开头的提交
- **Documentation** (📚)：以 `docs:` 开头的提交
- **Other** (🔧)：其他提交

### Step 3: 建议版本号

根据 Semantic Versioning：
- 有 Breaking Changes → 主版本号 +1（如 1.0.0 → 2.0.0）
- 有 Features → 次版本号 +1（如 1.0.0 → 1.1.0）
- 只有 Fixes → 修订号 +1（如 1.0.0 → 1.0.1）

### Step 4: 生成 Changelog

格式示例：

```markdown
## What's Changed

### 💥 Breaking Changes
- 移除了废弃的 API (#123)

### ✨ Features
- 添加了新的导出功能 (#124)
- 支持自定义主题 (#125)

### 🐛 Bug Fixes
- 修复了内存泄漏问题 (#126)

### 📚 Documentation
- 更新了 API 文档 (#127)
```

### Step 5: 生成发布命令

提供可直接复制执行的命令：

```bash
# 创建并推送 tag
git tag -a v1.2.0 -m "Release v1.2.0"
git push origin v1.2.0

# 使用 GitHub CLI 创建 release
gh release create v1.2.0 \
  --title "v1.2.0" \
  --notes "## What's Changed

### ✨ Features
- Feature 1 (#123)

### 🐛 Bug Fixes
- Fix 1 (#124)

**Full Changelog**: https://github.com/owner/repo/compare/v1.1.0...v1.2.0"
```

## Examples（示例）

**用户请求**：「帮我发布一个新版本」

**我的响应**：

1. 检查最新 tag 是 `v1.1.0`
2. 分析发现有 3 个新 features 和 2 个 bug fixes
3. 建议版本号 `v1.2.0`（因为有新 features）
4. 生成 changelog 和发布命令

## Notes（注意事项）

- 执行发布命令前，确保用户已经验证了 changelog 内容
- 如果项目没有使用 semver，询问用户期望的版本格式
- 大型项目可能需要更详细的分类（如按 scope 分组）
```

### 7.5 Step 4: 验证 Skill

重启 OpenCode，然后测试：

```
帮我准备发布一个新版本
```

Agent 应该会：
1. 加载 `git-release` skill
2. 执行 git 命令分析变更
3. 生成 changelog 和版本建议
4. 提供发布命令

### 7.6 Step 5: （可选）添加权限配置

如果你希望使用这个 Skill 前需要确认，在 `opencode.json` 中添加：

```json
{
  "permission": {
    "skill": {
      "git-release": "ask"
    }
  }
}
```

### 7.7 完整的目录结构

```
~/.opencode/
└── skills/
    └── git-release/
        └── SKILL.md
```

---

## 快速参考卡片

### 创建 Skill 的最小步骤

```bash
# 1. 创建目录
mkdir -p ~/.opencode/skills/my-skill

# 2. 创建文件
cat > ~/.opencode/skills/my-skill/SKILL.md << 'EOF'
---
name: my-skill
description: 我的技能描述
---

## What I do
- 功能 1
- 功能 2

## When to use me
描述使用场景

## Instructions
执行步骤...
EOF

# 3. 重启 OpenCode，完成！
```

### Skills 搜索路径

| 优先级 | 路径 |
|--------|------|
| 1 (高) | `.opencode/skills/` |
| 2 | `.claude/skills/` |
| 3 | `~/.opencode/skills/` |
| 4 (低) | `~/.claude/skills/` |

### 权限速查

| 值 | 效果 |
|----|------|
| `allow` | 直接加载 |
| `ask` | 需确认 |
| `deny` | 完全隐藏 |

---

## 相关链接

- [OpenCode 官方文档](https://opencode.ai/docs/)
- [Agent Skills 文档](https://opencode.ai/docs/skills/)
- [OpenCode GitHub](https://github.com/anomalyco/opencode)
