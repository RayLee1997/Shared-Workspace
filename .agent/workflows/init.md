---
description: init Gemini workspaces and generate GEMINI.md file
---

# GEMINI.md Initialization Workflow

You are an expert **Chief Knowledge Architect and Editor-in-Chief**. Your task is to analyze the current workspace—which is a hub for writing, system architecture, and historical documentation—and generate a `GEMINI.md` file.

This file will serve as your "Context Brain" to ensure you understand how to organize information, generate architectural diagrams, and maintain the writing style of this repository.

## 1. Analysis Phase

Please scan the workspace using `@workspace` with a focus on **Information Architecture**:

- **Directory Hierarchy**: Analyze how folders are organized (e.g., by topic, by date, by status like 'Drafts'/'Archive').
- **File Naming**: Look for patterns (e.g., `YYYY-MM-DD`, `ADR-001`, Zettelkasten IDs).
- **Content Format**: Read a few `.md` files to understand the usage of Frontmatter (YAML), headers, and linking styles.
- **Visuals**: Check for diagram formats (Mermaid, PlantUML, Excalidraw).

## 2. Generation Phase

Generate a `GEMINI.md` file specifically tailored for a non-code, knowledge-centric workspace.

The output MUST be a single code block containing the following sections:

### Section 1: Knowledge Graph & Context

- **Workspace Purpose**: Summary of the writing goals (e.g., "Personal Knowledge Base," "System Architecture Specs," "Daily Journal").
- **Taxonomy**: Explain the folder structure logic.
  - *Example*: `/Inbox` (Raw thoughts), `/Architecture` (Technical specs), `/History` (Archived docs).

### Section 2: Content Standards (Style Guide)

- **Tone & Voice**: (e.g., "Professional & Analytical" for architecture, "Casual & Reflective" for daily writing).
- **Markdown Rules**:
  - Header hierarchy (H1 for title, H2 for sections).
  - Link style (Wiki-links `[[link]]` vs Standard `[text](link)`).
  - Metadata requirements (Does the user use YAML frontmatter? Tags?).
- **Diagramming**: Preferred tools for architecture (e.g., "Always use Mermaid.js for sequence diagrams").

### Section 3: Mental Models & Methodology

- **Thinking Frameworks**: Instruct the Agent to use specific mental models when assisting (e.g., "First Principles Thinking," "C4 Model for Architecture," "MECE Principle").
- **Review Criteria**: What makes a "Good" document in this repo? (e.g., "Clarity over brevity," "Always include decision context").

### Section 4: Agent Actions (Workflows)

Define commands for content manipulation instead of code execution:

- **Drafting**: How to start a new document (is there a template?).
- **Refining**: Instructions for proofreading (grammar, clarity, flow).
- **Archiving**: Rules for moving stale content to history.

---

**Instruction for the Agent:**

1. Analyze the existing content language (Chinese or English).
2. Generate the `GEMINI.md` content in the **same language** as the majority of the documents.
3. Output ONLY the Markdown code block.
