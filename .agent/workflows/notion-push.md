---
description: 将 Markdown 文件智能同步到 Notion（搜索→创建/更新→验证）
---

# Notion Push Workflow

智能同步 Markdown 文件到 Notion。自动搜索现有页面，支持创建新页面或更新已有页面，处理大文件自动分块。

## 工作流程概览

```
读取文件 → 解析元数据 → 搜索Notion → 
  ├─ 未找到 → 创建新页面
  └─ 已找到 → 更新现有页面
→ 处理大文件（分块） → 验证更新 → 完成
```

## 🎯 目标数据库配置

**Database Name**: `Obsidian`  
**Database ID**: `30170c56-c66e-801a-93b3-000bb5c9093f`  
**Database URL**: `https://www.notion.so/30170c56c66e801a93b3000bb5c9093f`

**📌 重要规则**:

- ✅ 创建新页面时，必须指定 `parent: { page_id: "30170c56-c66e-801a-93b3-000bb5c9093f" }`
- ✅ 更新现有页面时，使用搜索找到的 `page_id`
- ❌ 不得创建为 workspace-level 独立页面

## Steps

### Step 1: 读取并解析文件

// turbo

**操作**：

1. 使用 `view_file` 读取当前 Markdown 文件完整内容
2. 记录文件绝对路径和行数

**输出**：

- `file_path`: 文件绝对路径
- `file_content`: 文件完整内容
- `file_size`: 文件行数/字节数

---

### Step 2: 提取标题和元数据

**标题提取优先级**：

1. YAML frontmatter 的 `title` 字段
2. 第一个 `# 标题`
3. 文件名（去除 `.md`）

**元数据提取**：

- 从 frontmatter 提取 `category`, `sub-category`, `tags`
- 如无 frontmatter，从路径推断分类：
  - 路径：`04_Investments/Company Watchlist/msft/file.md`
  - Category: `Investments`
  - Sub-Category: `Company Watchlist`

**内容清理**：

- 移除 frontmatter（`---` 包裹部分）
- 保留纯 Markdown 正文

**输出**：

- `page_title`: 页面标题
- `clean_content`: 清理后的内容
- `metadata`: 分类元数据对象

---

### Step 3: 预处理 Obsidian 语法

转换 Obsidian 特有语法为标准 Markdown：

| Obsidian 语法 | 转换为 |
|--------------|--------|
| `![[image.png]]` | `![image](image.png)` |
| `[[page name]]` | `page name` |
| `[[page\|display]]` | `display` |
| `> [!NOTE]` | `> ℹ️ **Note**:` |
| `> [!TIP]` | `> 💡 **Tip**:` |
| `> [!WARNING]` | `> ⚠️ **Warning**:` |
| `> [!IMPORTANT]` | `> ❗ **Important**:` |

**输出**：

- `processed_content`: 处理后的 Markdown

---

### Step 4: 搜索现有 Notion 页面

**操作**：
使用 `mcp_notion_notion-search` 搜索标题：

```
mcp_notion_notion-search(
  query = page_title,
  query_type = "internal"
)
```

**匹配逻辑**：

- 精确匹配：`result.title == page_title`
- 模糊匹配：标题包含关键词（可选）

**输出**：

- `existing_page_id`: 找到的页面ID（或 `null`）
- `action`: `"create"` 或 `"update"`

---

### Step 5: 检查文件大小并规划更新策略

**文件大小评估**：

| 文件大小 | 行数 | 字节数 | 策略 |
|---------|------|-------|------|
| 小文件 | < 500行 | < 20KB | 一次性更新 |
| 中文件 | 500-1000行 | 20-40KB | 分2块更新 |
| 大文件 | > 1000行 | > 40KB | 分段更新（每400-500行） |

**Notion MCP 限制**：

- `create-pages` content 字段：建议 < 20,000 字符
- `update-page` new_str 字段：建议 < 20,000 字符
- 超过限制会导致 API 调用失败

**策略输出**：

- `update_strategy`: `"single"` | `"chunked"`
- `chunks`: 如需分块，生成内容块数组

---

### Step 6A: 创建新页面（若 action = "create"）

**小文件（一次性创建）**：

```javascript
mcp_notion_notion-create-pages({
  parent: {
    page_id: "30170c56-c66e-801a-93b3-000bb5c9093f"  // ⚠️ 必须指定 Obsidian 数据库
  },
  pages: [{
    properties: {
      title: page_title,
      Category: metadata.category,
      Sub-Category: metadata.sub_category
    },
    content: processed_content  // 完整内容
  }]
})
```

**大文件（占位符 + 后续更新）**：

1. 创建占位符页面：

```javascript
mcp_notion_notion-create-pages({
  parent: {
    page_id: "30170c56-c66e-801a-93b3-000bb5c9093f"  // ⚠️ 必须指定 Obsidian 数据库
  },
  pages: [{
    properties: { title: page_title, ... },
    content: "本报告内容较长，正在分块上传中..."
  }]
})
```

1. 获取 `new_page_id`
2. 跳转到 Step 7 执行分块更新

---

### Step 6B: 更新现有页面（若 action = "update"）

**小文件（一次性替换）**：

```javascript
mcp_notion_notion-update-page({
  data: {
    page_id: existing_page_id,
    command: "replace_content",
    new_str: processed_content
  }
})
```

**大文件（分块替换）**：
跳转到 Step 7

---

### Step 7: 大文件分块更新（仅当 update_strategy = "chunked"）

**分块策略**：

1. **首次替换**：替换前 400-500 行

```javascript
mcp_notion_notion-update-page({
  data: {
    page_id: target_page_id,
    command: "replace_content",
    new_str: chunks[0]  // 第一块内容
  }
})
```

1. **追加剩余块**：逐块 append

```javascript
for chunk in chunks[1:]:
  mcp_notion_notion-update-page({
    data: {
      page_id: target_page_id,
      command: "insert_content_after",
      selection_with_ellipsis: "...末尾",  // 定位到上一块末尾
      new_str: chunk
    }
  })
  
  // 每块之间等待 1 秒，避免 rate limit
  wait(1000ms)
```

**分块边界**：

- 在 `## 标题` 或段落边界处切分
- 每块保持语义完整性

---

### Step 8: 验证更新结果

**操作**：
使用 `mcp_notion_notion-fetch` 获取页面当前状态：

```javascript
mcp_notion_notion-fetch({
  id: target_page_id
})
```

**验证项**：

1. 页面标题是否正确
2. 内容长度是否合理（非空）
3. 属性是否正确设置

**输出**：

- `verification_status`: `"success"` | `"partial"` | `"failed"`
- `page_url`: Notion 页面链接

---

### Step 9: 报告结果

**成功**：

```
✅ 同步完成！

📄 文件: {file_name}
🔗 Notion: {page_url}
📊 状态: {action == "create" ? "新建" : "已更新"}
📏 大小: {file_size} 行 / {chunks_count} 块
⏱️ 用时: {duration} 秒
```

**部分成功**：

```
⚠️ 同步部分完成

已更新: {successful_chunks}/{total_chunks} 块
问题: {error_description}
建议: 请手动检查 Notion 页面
```

**失败**：

```
❌ 同步失败

错误: {error_message}
建议: {troubleshooting_steps}
```

---

## 批量同步扩展

如需同步多个文件，按以下顺序依次执行 Step 1-9：

```
for file in files:
  execute_workflow(file)
  wait(2000ms)  // 文件间等待2秒
```

---

## Error Handling

| 错误类型 | 处理方式 |
|---------|----------|
| **OAuth 过期** | 提示用户重新授权 MCP Server |
| **Rate Limit** (180 req/min) | 自动等待 1 分钟后重试 |
| **Page Not Found** | 自动切换为创建模式 |
| **Content Too Large** | 自动进入分块模式 |
| **Network Timeout** | 重试 3 次，失败后报告 |

---

## 技术规范

**Notion MCP Tools 使用规范**：

1. **搜索**：`mcp_notion_notion-search`
   - 参数：`query`, `query_type`
   - 可选：`page_url` 限定搜索范围到特定数据库

2. **创建**：`mcp_notion_notion-create-pages`
   - **必需参数**：`parent.page_id = "30170c56-c66e-801a-93b3-000bb5c9093f"`
   - 参数：`pages` (数组)
   - 限制：content < 20K 字符
   - ⚠️ 不指定 parent 会创建为独立页面！

3. **更新**：`mcp_notion_notion-update-page`
   - 参数：`data.page_id`, `data.command`, `data.new_str`
   - 命令：`replace_content` | `insert_content_after`

4. **获取**：`mcp_notion_notion-fetch`
   - 参数：`id`

**性能优化**：

- 批量操作间隔 ≥ 1 秒
- 单文件分块上传间隔 ≥ 1 秒
- 避免并发调用 Notion API

**数据库最佳实践**：

- ✅ 始终使用 `parent` 参数指定 Obsidian 数据库
- ✅ 搜索时可限定在数据库范围内
- ✅ 创建后验证页面位置
- ❌ 避免创建 workspace-level 独立页面
