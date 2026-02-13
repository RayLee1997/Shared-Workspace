---
description: 当用户输入 /create-moc 时触发。用于全盘扫描工作区，生成结构化的内容索引（Map of Content），保存至 09_MOC 目录。
---

# Map of Content (MOC) Generation Workflow

Role: **Chief Librarian & Knowledge Gardener**

Your strict objective is to generate a master index file (MOC) for the current Obsidian workspace. This entry point allows the user to navigate their "Second Brain" efficiently.

## 1. Analysis Phase (Scan)

1. **Read `GEMINI.md`**: Understand the current taxonomy (P.A.R.A + JD) and file naming conventions.
2. **Scan Directories**:
    - List the root directory to confirm the active folders (00-99).
    - Recursively list subdirectories (depth 2) to identify active projects and areas.
    - *Crucial*: Identify the "Focus" or "Active" projects in `03_Productions`, `04_Investments`, and `07_Investigation`.

## 2. Construction Phase (Drafting)

You will create/update the file: `/Users/ray/Obsidian/09_MOC/Home.md`.

**Content Structure:**

### Header

- Title: `Home` or `Dashboard` (Use H1)
- Frontmatter:

    ```yaml
    tags:
      - MOC
      - Dashboard
    updated: YYYY-MM-DD
    ```

### Section 1: 🎯 Current Focus (当务之急)

- List the 3-5 most recently modified or high-priority project files.
- Use `[[Link]]` syntax.

### Section 2: 🗺️ System Atlas (知识地图)

Create a visual or structured list matching the `GEMINI.md` Taxonomy.

**Format**:

- **00 Inbox**: `[[00_Inbox/Inbox|📥 Inbox]]`
- **01-03 Projects & Output**:
  - `[[01_Research/Index|01 Research]]`
  - `[[03_Productions/Index|03 Productions]]`
- **04-06 Areas & Resources**:
  - `[[04_Investments/Index|04 Investments]]` (Highlight key tickers like `[[TSM]]`, `[[NVDA]]`)
  - `[[05_Technology/Index|05 Technology]]`
  - `[[07_Investigation/Index|07 Investigation]]`
- **09-99 Archives & Meta**:
  - `[[09_MOC/Home|09 MOC]]`
  - `[[99_Archives/Index|99 Archives]]`

### Section 3: 📊 Status (Optional Mermaid)

- If useful, generate a simple Mermaid `mindmap` or `graph` showing the top-level structure.
- Adhere to "Healing Dream" style (as defined in `GEMINI.md`).

## 3. Execution Phase

1. **Generate content** based on the real-time file listing.
2. **Write to file**: `/Users/ray/Obsidian/09_MOC/Home.md`.
    - *Note*: If `Home.md` already exists, you may read it first to preserve custom sections, OR overwrite if instructed (default to overwrite for this workflow).

## Rules

- **Links**: ALWAYS use `[[WikiLink]]` format.
- **Language**: Bilingual (Chinese/English) as per `GEMINI.md`.
- **Aesthetics**: Use Icons (emoji) for folder links to make it visual.
