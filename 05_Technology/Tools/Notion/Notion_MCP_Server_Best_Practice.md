# Notion MCP Server 最佳实践

> 适用于 **Google AI IDE Antigravity** + 远程 Notion MCP Server + 自定义 Agent Workflow

## 概述

本文档记录了使用 Notion 官方远程 MCP Server 实现 "本地 Markdown → Notion" 发布流程的最佳实践。

### 为什么选择远程 MCP

| 对比项 | 远程 MCP（本方案） | 本地 MCP |
|---|---|---|
| 设置方式 | OAuth 授权，一键连接 | 手动配置 Token |
| Markdown 处理 | ✅ `notion-create-pages` 原生支持 | ❌ Agent 自行转 Notion Blocks |
| 图片/文件上传 | ✅ 支持 [File Upload API](https://developers.notion.com/guides/data-apis/working-with-files-and-media) | ❌ 仅接受外部 URL |
| 长文档分批 | ✅ 服务端内部处理 | ❌ 手动分批 ≤100 blocks |
| H4-H6 / 深嵌套 | ✅ 服务端自动降级处理 | ❌ Agent 手动降级 |
| 表格转换 | ✅ 服务端自动 | ❌ 手动构建 `table` + `table_row` JSON |
| Token 消耗 | ✅ 响应针对 AI 优化，减少 Token | ❌ 原始 API JSON 体积大 |
| 长期维护 | ✅ 官方主推、持续迭代 | ⚠️ 可能被弃用 |

**结论**：远程 MCP 将本地方案中需要 Agent 手动处理的 6 个关键挑战全部内化，大幅简化工作流。

---

## 1. Notion 端配置

### 1.1 权限准备

远程 MCP 使用 **OAuth 授权**，首次连接时会弹出 Notion 登录和授权页面，无需手动创建 Integration Token。

> [!TIP]
> 如果后续还需要使用本地 MCP 或直接调用 API，可保留已创建的 Integration Token 作为备用。

### 1.2 目标 Database

确保目标数据库存在以下 Properties：

| Property 名称 | 类型 | 用途 |
|---|---|---|
| `Title` | Title（默认） | 文章标题 |
| `Category` | Select / Multi-select | 一级分类 |
| `Sub-Category` | Select / Multi-select | 二级分类 |
| `Source` | URL（可选） | 原始文件路径 |

### 1.3 当前配置

| 配置项         | 值                                      |
| ----------- | -------------------------------------- |
| Database ID | `301s-xx-x-x`                          |
| API Key（备用） | `ntn_sdfsdf3s17845x7RcrdssdfsdfsdfsdD` |

---

## 2. Antigravity IDE 配置

### 方案 A：原生远程 MCP（如 IDE 支持 Streamable HTTP）

```json
{
  "mcpServers": {
    "notion": {
      "url": "https://mcp.notion.com/mcp"
    }
  }
}
```

### 方案 B：通过 mcp-remote 桥接（如 IDE 仅支持 STDIO）

```json
{
  "mcpServers": {
    "notion": {
      "command": "npx",
      "args": ["-y", "mcp-remote", "https://mcp.notion.com/mcp"]
    }
  }
}
```

### 方案 C：本地 MCP 降级方案

如远程 MCP 不可用，可使用本地服务器：

```json
{
  "mcpServers": {
    "notion": {
      "command": "npx",
      "args": ["-y", "@notionhq/notion-mcp-server"],
      "env": {
        "NOTION_TOKEN": "ntn_3sdfsdfsdfsdfsdfsdfoD"
      }
    }
  }
}
```

> [!NOTE]
> 配置后**重启 IDE**。首次使用时浏览器会弹出 Notion OAuth 授权页面（方案 A/B），完成授权即可。

---

## 3. 远程 MCP 工具集

远程 MCP 提供 **15 个高级工具**，以下为与发布流程相关的核心工具：

| 工具 | 功能 | 发布场景用途 |
|---|---|---|
| `notion-create-pages` | 创建页面，**原生支持 Markdown** | ✅ 核心：创建文章页面并写入内容 |
| `notion-update-page` | 更新页面内容和属性 | 更新已有文章 |
| `notion-search` | 搜索工作区内容 | 检查是否已发布过（去重） |
| `notion-query-data-sources` | 跨数据库查询 | 查询分类列表 |
| `notion-query-database-view` | 查询数据库视图 | 按视图获取文章列表 |
| `notion-fetch` | 获取页面内容 | 读取已有页面进行对比 |
| `notion-create-comment` | 添加评论 | 为页面添加发布备注 |

### 关键优势：`notion-create-pages`

该工具接受 **Markdown 格式内容**，服务端自动完成：

- Markdown → Notion Blocks 转换
- 表格、代码块、列表等复杂元素的处理
- 内联格式（加粗、斜体、链接）的正确映射
- 长文档的自动分批处理
- 文件/图片上传

**这意味着 Agent Workflow 中不再需要手动处理 Markdown 转换逻辑。**

---

## 4. 定价与限制

| 项目 | 说明 |
|---|---|
| **费用** | **$0** — Free Plan 即可使用 |
| **通用速率** | 180 请求/分钟 |
| **搜索速率** | 30 请求/分钟 |
| **Blocks** | 个人版单用户 = 无限 |
| **文件大小** | 单文件上限 5MB（Free Plan）|

---

## 5. 本地 vs 远程：Markdown 处理差异总结

当使用**本地 MCP**时，以下 Markdown 元素需要 Agent 在工作流中手动处理：

| 挑战 | 本地 MCP（需手动处理） | 远程 MCP（内置处理） |
|---|---|---|
| Markdown → Blocks | Agent 逐元素转为 JSON | ✅ 直接传 Markdown |
| 图片上传 | 仅支持外部 URL | ✅ File Upload API |
| 表格 | 手动构建 `table` + `table_row` | ✅ 自动转换 |
| 代码块语言映射 | 需匹配 Notion 枚举值 | ✅ 自动映射 |
| H4-H6 降级 | Agent 手动降级到 H3 | ✅ 自动处理 |
| rich_text 拆分 | 手动拆分为 annotations 段 | ✅ 自动解析 |
| 超长段落（>2000字符） | 手动拆分 | ✅ 自动处理 |
| >100 blocks 分批 | 手动分批 + 速率控制 | ✅ 服务端处理 |
| 嵌套列表（>2层） | 手动扁平化 | ✅ 自动降级 |

## 参考资料

- [Notion MCP 概述](https://developers.notion.com/docs/mcp)
- [连接指南](https://developers.notion.com/guides/mcp/get-started-with-mcp)
- [支持的工具列表](https://developers.notion.com/guides/mcp/mcp-supported-tools)
- [安全最佳实践](https://developers.notion.com/guides/mcp/mcp-security-best-practices)
- [File Upload API](https://developers.notion.com/guides/data-apis/working-with-files-and-media)
- [本地 MCP Server GitHub](https://github.com/makenotion/notion-mcp-server)
- [mcp-remote 桥接包](https://www.npmjs.com/package/mcp-remote)
