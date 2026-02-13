# Claude Code vs Google Antigravity: Ecosystem & MCP Comparison (2026)

> **Date**: 2026-02-03
> **Context**: Comparative analysis of the two dominant AI engineering platforms.
> **Related**: [[Google Antigravity AI IDE Developer Guide]], [[通过 Brave Search MCP 构建 Web Deep Research 技能]]

---

## 1. Executive Summary: The Standardization War

As of early 2026, the AI engineering landscape has bifurcated into two distinct philosophies, both converging on the **Model Context Protocol (MCP)** as the shared standard for tool interoperability.

*   **Claude Code (Anthropic)**: A CLI-first "Digital Employee" focused on **Quality, Logic, and SaaS Integration**. It excels at connecting your code to the broader digital world (Slack, Notion, Jira).
*   **Google Antigravity**: An AI-native IDE (Mission Control) focused on **Speed, Local Depth, and "Vibe Coding"**. It excels at rapid iteration and managing multiple parallel agents within a local repository.

**Key Trend**: The emergence of **MCP Apps** (SEP-1865) in Jan 2026 has shifted the battleground from "text-based tools" to "interactive UI widgets" embedded directly in the chat stream.

---

## 2. Platform Comparison Matrix

| Feature | **Claude Code** | **Google Antigravity** |
| :--- | :--- | :--- |
| **Form Factor** | **CLI** + Web/Mobile Companion | **IDE** (Modified VS Code/Windsurf) |
| **Primary Model** | Claude 4.5 Opus / Sonnet 4.5 | Gemini 3 Pro / Deep Think |
| **Core Philosophy** | **"The Thoughtful Architect"**<br>Precision, clean code, cross-platform comms. | **"The Speed Demon"**<br>Rapid prototyping, multiple agents, visual verification. |
| **Skill Handling** | **Progressive Disclosure**<br>Loads skills lazily to save tokens. | **Hard-Coded / Local**<br>Optimized for zero-latency local tool execution. |
| **Best For...** | Surgical bug fixes, refactoring, writing docs, updating Jira/Slack. | New feature build-out, "Vibe Coding" (Vision-to-Code), full-stack debugging. |

---

## 3. The Ecosystem: MCP & Skills

Both platforms use MCP, meaning **Skills are largely interoperable**. A skill written for Claude Code (like your `brave-search-mcp`) can often run in Antigravity with minimal configuration.

### 3.1 Claude Code Ecosystem
*   **Focus**: **SaaS & Cloud Connectivity**.
*   **Mechanism**: Uses YAML/Markdown definitions. It employs a "Progressive Disclosure" strategy—it only reads the `description` of a skill initially. Only when it decides to *use* the skill does it load the full API definition, saving context window space.
*   **Killer Feature**: **MCP Apps (Interactive UIs)**.
    *   Instead of saying "I updated the Jira ticket," Claude Code renders a **live, interactive Jira widget** in the terminal/web UI.
    *   Supported by: Slack, Canva, Figma, Box, Monday.com.

### 3.2 Antigravity Ecosystem
*   **Focus**: **Local Machine Mastery**.
*   **Mechanism**: Treats skills as "Local Extensions". It grants the IDE direct permission to spawn processes, read databases, or execute `kubectl` commands with near-zero latency.
*   **Killer Feature**: **The Verification Loop**.
    *   Antigravity doesn't just "call a tool"; it wraps tool usage in a loop: *Generate Code -> Run Linter Skill -> Run Test Skill -> Fix*.
    *   Your `97_OpenCode/Skills` directory is effectively a library of "Verifiers" for Antigravity.

---

## 4. "OpenCode" Integration Strategy

Your current vault structure (`97_OpenCode`) is perfectly positioned to serve as a **Shared Skill Repository** for both platforms.

### Recommended Directory Structure
```text
97_OpenCode/
├── Skills/
│   ├── common/           # Pure MCP servers (Brave, Filesystem, Memory)
│   │   └── brave-search/
│   ├── claude/           # SaaS connectors (Slack, Jira, GitHub Remote)
│   └── antigravity/      # Local dev tools (Linter, Local DB, Simulator)
├── mcp_config.json       # Master configuration for Claude Code
└── .agent/               # Symlinked configuration for Antigravity
```

### The Hybrid Workflow (Best Practice)
Most power users in 2026 use both:

1.  **Heavy Lifting (Antigravity)**: Open the IDE to build a new feature. Use the "Mission Control" view to spawn 3 agents (Backend, Frontend, QA) to build out the code structure rapidly.
2.  **Polish & Comms (Claude Code)**: Switch to the terminal. Use `claude code` to:
    *   Review the changes (Claude's logic is often superior for code review).
    *   Write the PR description.
    *   Update the team in Slack.
    *   Update documentation in Notion.

---

## 5. Summary

*   **Antigravity** is your **Factory**: It builds things fast, locally, and visually.
*   **Claude Code** is your **Manager**: It checks quality, handles communication, and connects to external business systems.
*   **MCP** is the **Universal Language** that lets them share tools (like your Brave Search skill).
