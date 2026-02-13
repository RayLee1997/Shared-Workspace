# Notion Push Workflow - 目标数据库配置更新

**更新时间**: 2026-02-08 15:10  
**更新内容**: 强制所有页面必须创建到指定的 Obsidian 数据库

---

## ✅ 已完成的修改

### 1. 添加目标数据库配置（顶部）

在 workflow 开头添加了强制数据库配置：

```markdown
## 🎯 目标数据库配置（强制）

**⚠️ 重要**: 所有页面必须创建/更新到以下数据库：

- **Database Name**: `Obsidian`
- **Database ID**: `30170c56-c66e-801a-93b3-000bb5c9093f`
- **Database URL**: `https://www.notion.so/30170c56c66e801a93b3000bb5c9093f`

**禁止行为**:
- ❌ 不得创建到其他数据库
- ❌ 不得创建为独立页面（workspace-level）
- ✅ 所有页面必须使用 `parent: { page_id: "30170c56-c66e-801a-93b3-000bb5c9093f" }`
```

### 2. 更新 Step 4: 搜索现有页面

添加了数据库范围搜索的说明：

```javascript
// 选项1: 全局搜索（默认）
mcp_notion_notion-search(
  query = page_title,
  query_type = "internal"
)

// 选项2: 限定在 Obsidian 数据库内搜索
mcp_notion_notion-search(
  page_url = "https://www.notion.so/30170c56c66e801a93b3000bb5c9093f",
  query = page_title,
  query_type = "internal"
)
```

### 3. 更新 Step 6A: 创建新页面

**强制添加 `parent` 参数**：

```javascript
mcp_notion_notion-create-pages({
  parent: {
    page_id: "30170c56-c66e-801a-93b3-000bb5c9093f"  // ⚠️ 强制使用 Obsidian 数据库
  },
  pages: [{
    properties: {
      title: page_title,
      Category: metadata.category,
      Sub-Category: metadata.sub_category
    },
    content: processed_content
  }]
})
```

**对比之前**：

- ❌ 旧版本：没有 `parent`，会创建为 workspace-level 独立页面
- ✅ 新版本：强制 `parent`，所有页面都在 Obsidian 数据库下

---

## 🔐 安全保障

### 强制规则

1. **创建页面**: 必须指定 `parent.page_id = "30170c56-c66e-801a-93b3-000bb5c9093f"`
2. **更新页面**: 使用搜索找到的 `page_id`（已在数据库内）
3. **验证**: 更新后使用 `fetch` 确认页面在正确数据库下

### 典型错误（现已避免）

```javascript
// ❌ 错误：没有 parent，会创建为独立页面
mcp_notion_notion-create-pages({
  pages: [{ properties: {...}, content: "..." }]
})

// ✅ 正确：指定 parent，创建到 Obsidian 数据库
mcp_notion_notion-create-pages({
  parent: { page_id: "30170c56-c66e-801a-93b3-000bb5c9093f" },
  pages: [{ properties: {...}, content: "..." }]
})
```

---

## 📋 使用清单

在执行 workflow 时，确保：

- [ ] ✅ Step 6A 创建时使用了正确的 `parent.page_id`
- [ ] ✅ Step 4 搜索时可选限定在数据库内
- [ ] ✅ Step 8 验证页面在正确数据库下
- [ ] ✅ 不创建 workspace-level 独立页面

---

**总结**: 现在所有通过 `/notion-push` 创建的页面都会自动归属到 `Obsidian` 数据库，保证数据组织的一致性！
