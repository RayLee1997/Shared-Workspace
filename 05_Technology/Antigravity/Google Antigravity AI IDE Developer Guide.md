# Google Antigravity AI IDE 开发者指南 (2026版)

> **版本**: 1.0  
> **日期**: 2026-02-03  
> **适用对象**: 全栈开发者, AI 工程师, 移动应用开发者  
> **状态**: Active

---

## 1. 什么是 Google Antigravity?

Google Antigravity 是 Google 于 2025 年底推出的下一代 **AI 原生集成开发环境 (IDE)**。与传统的 "Copilot" 模式（AI 仅作为代码补全工具）不同，Antigravity 将 **AI Agents** 视为第一类公民。

### 核心理念：验证循环 (The Verification Loop)
Antigravity 的核心不仅仅是生成代码，而是**验证代码**。它引入了一个自主的迭代循环：
1.  **Generate**: 根据自然语言指令生成代码。
2.  **Analyze**: 运行静态分析（如 `dart analyze`, ESLint）。
3.  **Test**: 执行单元测试。
4.  **Run**: 尝试构建并运行应用（Headless 模式）。
5.  **Perceive**: 通过计算机视觉（Vision API）查看运行结果截图，确认像素级渲染是否正确。

只有当所有步骤通过，Agent 才会提交修改。

---

## 2. 快速入门 (Getting Started)

### 安装与访问
Antigravity 提供两种形态：
*   **Web IDE**: 基于浏览器的全云端环境（类似 Project IDX 的进化版），无需本地配置，直接连接 Google Cloud 算力。
*   **Desktop App**: 基于 VS Code 核心魔改的本地客户端，支持本地 LLM (Gemini Nano) 加速。

### 创建第一个项目
在 Antigravity 欢迎界面，你可以直接通过 Prompt 创建项目：

**推荐 Prompt 示例**:
> "Create a Flutter app named 'MindFlow'. It should be a personal journaling app using Riverpod for state management and local storage. Support Dark Mode."

Antigravity 会自动：
1.  生成项目骨架。
2.  配置 `pubspec.yaml` 或 `package.json`。
3.  设置 CI/CD 风格的本地验证流水线。

---

## 3. 核心功能详解

### 3.1 AI Agents 与 Context
在 Antigravity 中，你不是在写代码，而是在**指挥** Agent。
*   **Chat Panel**: 右侧不仅是聊天框，更是任务控制台。你可以下达复杂的重构指令。
*   **Multi-file Awareness**: Agent 默认拥有整个项目的上下文，能同时修改 Model、View 和 Controller 文件。

### 3.2 规则系统 (.agent/rules)
这是控制 Agent 行为的最重要机制。通过在项目根目录创建 `.agent/rules` 文件夹，你可以定义 Agent 的行为准则。

**示例结构**:
```
my_app/
├── .agent/
│   └── rules/
│       ├── FLUTTER_BEST_PRACTICES.md
│       ├── ARCHITECTURE.md
│       └── UI_DESIGN_SYSTEM.md
```

**规则文件内容示例 (FLUTTER_BEST_PRACTICES.md)**:
```markdown
# Flutter Coding Rules
1. Always use `const` constructors where possible.
2. Use `ConsumerWidget` from Riverpod instead of `StatefulWidget` for state access.
3. Split widgets if indentation exceeds 4 levels.
4. Never use `print()`; use `log()` from `dart:developer`.
```
*提示：定义清晰的 Rules 是防止 Agent 产生"幻觉"代码的关键。*

### 3.3 验证与伪影 (Artifacts)
当 Agent 完成任务时，它不会直接修改你的代码，而是生成一个 **Artifact**（变更集）。
*   **Diff View**: 清晰展示所有变更。
*   **Verification Report**: 展示分析、测试和运行截图的结果。
*   **Accept/Reject**: 你可以一键接受，或在对话框中要求修正（"The button color is wrong, make it blue"）。

---

## 4. 进阶工作流 (Advanced Workflow)

### 4.1 处理 "死循环" (Dead Loops)
有时 Agent 会陷入 "修复 -> 报错 -> 尝试修复 -> 引入新错误" 的循环。
*   **现象**: 左下角的 Agent 状态栏一直在旋转，步数超过 10 步。
*   **解决方案**:
    1.  点击 **Stop** 强制停止。
    2.  使用 **Undo** 回退到上一个稳定状态（Antigravity 自动为每一步 Agent 操作建立快照）。
    3.  **优化 Prompt**: 提供更具体的错误信息或指导（例如："Don't try to fix the dependency using `npm audit fix`, just downgrade package X to version 1.2.3"）。

### 4.2 跨平台开发策略
*   **Flutter**: Antigravity 的"黄金搭档"。由于 Dart 强类型和 Flutter 统一的渲染引擎，Agent 的成功率极高。
    *   *技巧*: 让 Agent 编写 Widget Tests，这能显著提高代码稳定性。
*   **React Native**: 建议配合 **Expo** 使用。
    *   *警告*: 避免让 Agent 直接修改 `ios/` 或 `android/` 原生目录，除非你非常清楚自己在做什么。建议在 Rules 中明确："Do not modify native code unless explicitly asked."

### 4.3 视觉辅助编程 (Vibe Coding)
利用 Gemini 的视觉能力：
1.  画一个草图（手绘）。
2.  拍照或截图。
3.  拖入 Antigravity 对话框。
4.  Prompt: "Implement this UI using Flutter/React Native."

---

## 5. 最佳实践 (Best Practices)

### 提示词工程 (Prompt Engineering for IDE)
*   **Role Play**: "You are a senior Flutter engineer focused on performance."
*   **Step-by-Step**: "First, create the data model. Then, create the repository. Finally, build the UI." (分步指令比一次性大指令更有效)
*   **Reference**: "Use the style defined in `lib/theme/app_theme.dart`."

### 目录结构管理
保持清晰的目录结构有助于 Agent 理解项目：
*   `lib/core/`: 存放通用组件和工具。
*   `lib/features/`: 按功能模块划分业务代码。
*   *Agent 倾向于模仿现有的文件结构，所以保持一个高质量的"样板文件"非常有用。*

---

## 6. 常见问题 (Troubleshooting)

| 问题现象                    | 可能原因           | 解决方案                                                                     |
| :---------------------- | :------------- | :----------------------------------------------------------------------- |
| **Agent 引入不存在的包**       | 训练数据过时或幻觉      | 在 `.agent/rules` 中指定允许使用的包列表，或明确要求 "Check pub.dev/npm before importing"。 |
| **Web 构建运行缓慢**          | 验证循环在等待浏览器加载   | 在开发阶段优先使用 Headless 模式或仅运行单元测试。                                           |
| **样式在 iOS/Android 不一致** | (RN) 使用了平台特定组件 | 强制 Agent 使用跨平台组件库 (如 gluestack-ui, Tamagui) 或 Flutter。                   |
| **代码被改乱了**              | 上下文窗口溢出或指令模糊   | 使用 Git 进行版本控制；一次只给 Agent 一个明确的小任务。                                       |

---

## 7. 资源与参考
*   **快捷键**: `Cmd+K` (唤起 Agent), `Cmd+Shift+V` (查看验证报告)
*   **相关文档**: [[Flutter vs React Native 在 Google Antigravity 中的社区反馈对比]]
*   **官方社区**: discord.gg/google-antigravity

---
*注：本文档基于 2026 年 2 月的技术状态编写，Antigravity 更新迅速，请以官方最新说明为准。*
