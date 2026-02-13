# Obsidian Gemini Scribe 最佳实践指南 (2026版)

这份指南旨在帮助你从零开始，将 **Gemini Scribe** 打造成为 Obsidian 笔记系统中的核心 **AI Agent**。无论你是刚接触 Obsidian 的新手，还是追求极致效率的极客，都能从中找到适合你的配置方案。

## 第一阶段：小白入门 (The Basics) —— 5分钟快速上手

在这个阶段，我们的目标是让插件“跑起来”，无需复杂的设置。

### 1. 核心安装与配置
1.  **安装插件**：
    *   打开 Obsidian 设置 -> `Community Plugins` (社区插件) -> 关闭 `Safe Mode` (安全模式)。
    *   点击 `Browse` (浏览)，搜索 `Gemini Scribe` (注意：旧版本可能叫 Obsidian Gemini)，点击 `Install` 并 `Enable`。
2.  **获取 API Key**：
    *   访问 [Google AI Studio](https://aistudio.google.com/)。
    *   登录你的 Google 账号，点击 `Get API key` -> `Create API key in new project`。
    *   复制生成的以 `AIza` 开头的长字符串。
3.  **填入配置**：
    *   回到 Obsidian 设置 -> 找到 `Gemini Scribe` 插件设置页。
    *   在 `API Key` 栏粘贴刚才复制的 Key。
    *   **Model Selection (模型选择)**：
        *   推荐选择 `gemini-2.0-flash`。它的速度极快，且在 2026 年拥有非常慷慨的免费额度，非常适合日常润色、翻译和简单问答；
        *   深度推理任务时，请选择 `gemini-1.5-pro`。

### 2. 第一次使用
*   **侧边栏对话**：点击 Obsidian 界面右侧边栏出现的 Gemini 图标（通常是一个星星形状）。这会打开一个聊天窗口，你可以像使用 ChatGPT 一样直接跟它聊天。
*   **基础命令**：
    *   在笔记中选中一段文字。
    *   按下 `Cmd + P` (Mac) 或 `Ctrl + P` (Windows) 打开命令面板。
    *   输入 `Gemini`，选择 `Gemini Scribe: Run Prompt`。
    *   插件会处理你选中的文字并返回结果。

---

## 第二阶段：中级进阶 (Custom Agents) —— 打造你的私人助手

在这个阶段，我们将不再手动输入重复的指令，而是建立一套“指令库”，这是提升效率的核心。

### 1. 建立 Prompt (提示词) 文件夹
不要每次都手打 "请帮我翻译这段话..."。
1.  在你的 Obsidian 文件夹结构中，插件默认创建一个专门存放提示词的文件夹 `gemini-scribe/Prompts`。
2.  进入 `Gemini Scribe` 插件 Session Setting 设置页（右上角两个纵排的齿轮标志），找到 `Custom Prompt` 选项，选择你自定义的 Custom System Prompt。
3.  **重要**：这样配置后，你在该文件夹下创建的每一个 `.md` 文件，都会自动变成一个可选的 AI Agent System Prompt。

### 2. 核心变量配置 (Variables)
在 `.md` 提示词文件中，你可以使用 Handlebars 语法 `{{variable}}` 来动态注入内容。以下是必须掌握的四个变量：

| 变量 | 含义 | 用途 |
| :--- | :--- | :--- |
| `{{selection}}` | 选中的文本 | **最常用**。用于翻译、润色、代码解释。 |
| `{{current_note}}` | 当前全文 | 用于总结全文、提取待办事项、RAG 问答。 |
| `{{date}}` | **当前日期** | **至关重要** (见下文详解)。 |
| `{{time}}` | 当前时间 | 辅助记录精确的时间戳。 |

### 3. 特别强调：为什么 `{{date}}` 对联网搜索至关重要？
在 2026 年的 AI 工作流中，**时间感知 (Temporal Awareness)** 是区分“傻瓜机器人”和“智能助理”的关键。

**场景 A：处理搜索结果**
当你将 Google 搜索结果（例如：“Tesla stock up 5% today”）粘贴到笔记中供 AI 分析时，如果 AI 不知道今天是哪一天，它就无法理解“today”是指 2026 年 2 月 2 日还是 2025 年的某一天。
*   **配置建议**：在你的所有 System Prompt 开头加上：
    ```markdown
    Current Date: {{date}} {{time}}
    ```
    这样，AI 就能准确推断出你提供的相对时间（"Yesterday", "Last week"）具体是指哪一天。

**场景 B：激活 Google Search Grounding 
如果你使用的 Gemini API 模型开启了 Search Grounding（搜索落地），模型需要知道当前时间来判断哪些新闻是“旧闻”，Gemini 3 Pro 支持联网搜索的能力。
*   **没有日期**：AI 可能会引用 2024 年的数据来回答 2026 年的问题。
*   **有日期**：AI 会意识到：“用户问的是 2026 年 2 月的财报，我的训练数据只到 2025 年，我必须进行搜索或查找最新上下文。”

### 4. 实战示例：创建一个“全能调查员”
在 `gemini-scribe/Prompts` 下新建 `Investigator.md`：

```markdown
# Role
你是一位精通 OSINT (开源情报) 的调查专家。

# Context
当前时间：{{date}} {{time}}
注意：请基于此时间点，判断以下信息的新鲜度。

# Task
请分析以下文本（可能是搜索结果或新闻片段），提取关键实体和时间线：
{{selection}}

# Output
使用简体中文，按时间倒序排列事件。
```

---

## 第三阶段：高级配置 (Power User) —— 自动化与第二大脑

在这个阶段，我们将让 AI 深度理解你的知识库。

### 1. 开启 RAG (语义搜索)
这是让 AI 拥有“记忆”的关键。
*   **设置**：在插件设置中开启 `Enable Semantic Search` (启用语义搜索)。
*   **作用**：当你提问时，插件会自动扫描你的笔记库，找到相关的信息作为参考。
*   **用法**：在提示词中使用 `{{vault_context}}` 变量。
    *   *示例*：“根据我笔记里的内容 ({{vault_context}})，总结一下我上周关于 OpenClaw 项目的进展。”

### 2. Frontmatter 绑定 (特定笔记专用 AI)
你可以让某篇笔记“绑定”特定的 AI 角色。在笔记最开头的 YAML 区域添加：

```yaml
---
gemini-scribe-prompt: "[[Deep Investigation Agent]]"
gemini-model: "gemini-1.5-pro"
---
```

当你在这篇笔记中呼出 Gemini 时，它会自动加载 `Deep Investigation Agent` 这个提示词模板，并切换到更强大的 `1.5-pro` 模型。

### 3. 快捷键工作流 (Workflow)
为了极致效率，建议在 Obsidian 设置 -> `Hotkeys` 中绑定快捷键：
*   `Alt + G`：打开 Gemini 聊天面板。
*   `Alt + D`：运行自定义 Prompt 列表。

---

## 最佳实践总结 (针对 Ray 的工作流)

| 场景           | 推荐模型               | 推荐功能                  | 操作建议                                      |
| :----------- | :----------------- | :-------------------- | :---------------------------------------- |
| **日常润色/翻译**  | `gemini-3.0-flash` | Custom Prompt         | 使用 `{{selection}}` 快速处理选中段落。              |
| **时效性分析**    | `gemini-3.0-flash` | **{{date}} Variable** | **必配**。确保 AI 知道今天是 2026年，避免时空错乱。          |
| **深度调查/RAG** | `gemini-3.0-pro`   | RAG Context           | 使用 `{{vault_context}}` 让 AI 结合历史笔记进行综合分析。 |

