# OpenClaw 混合云部署最佳实践

> **架构方案**: Google GCP 云端全托管 OpenClaw + Cloudflare Tunnel + 家庭本地数据 API（搜索引擎 & RAG 引擎）+ Discord 移动入口
>
> **网络方案**: Cloudflare Tunnel + Zero Trust Access

---

## 目录

1. [项目概述](#一项目概述)
2. [目标与定位](#二目标与定位)
3. [整体技术架构详解](#三整体技术架构详解)
4. [安全与风险分析](#四安全与风险分析)
5. [部署最佳实践教程](#五部署最佳实践教程)
6. [附录](#附录)

---

## 一、项目概述

### 1.1 什么是 OpenClaw

OpenClaw 是一款**开源的自托管个人 AI 助理**，由奥地利开发者 Peter Steinberger 于 2025 年底创建。与传统聊天机器人不同，OpenClaw 是一个能够**执行实际任务**的自主代理——它可以运行 shell 命令、管理文件、控制浏览器、安排日程，并通过你常用的消息应用与你交互。

### 1.2 本方案的核心变化

与传统 Gateway + Node 架构不同，**本方案采用更简洁的 API 集成模式**：

| 对比项 | 传统 Node 架构 | 本方案（API 集成） |
|--------|---------------|-------------------|
| **本地组件** | 运行 OpenClaw Node Host | 仅运行自定义 API 服务 |
| **集成方式** | WebSocket 双向通信 | HTTP RESTful API 单向调用 |
| **本地能力** | file.read/write/exec 等 | 搜索引擎 + RAG 引擎 |
| **协议复杂度** | Node 协议（OpenClaw 专有） | 标准 HTTP/JSON |
| **灵活性** | 受限于 Node 能力 | 完全自定义 API |
| **维护成本** | 需跟随 OpenClaw 升级 | 独立维护 |

### 1.3 为什么选择 API 集成模式

1. **解耦性**：本地 API 独立于 OpenClaw 版本，升级互不影响
2. **标准化**：使用通用 HTTP/JSON 协议，任何语言都可实现
3. **可复用**：同一套 API 可供其他应用（如 Web 前端、其他 AI）调用
4. **安全性**：API 粒度更细，更容易实现精确的权限控制
5. **简单性**：不需要学习 OpenClaw Node 协议，降低学习成本

### 1.4 成本估算

| 项目 | 月费用（估算） |
|------|----------------|
| GCP e2-small（无外部 IP） | $12.00 |
| GCP 30GB SSD | $2.40 |
| Cloudflare Tunnel（免费层） | $0.00 |
| Cloudflare Zero Trust（免费层，50 用户） | $0.00 |
| Discord Bot | $0.00 |
| Anthropic Claude（按量） | $5-50（取决于使用量） |
| 家庭服务器电费 | ~$5-10 |
| **总计** | **~$25-75/月** |


---

## 二、目标与定位

### 2.1 本方案的目标

构建一个**安全、实用、可扩展**的个人 AI 助理系统：

```
┌─────────────────────────────────────────────────────────────────────┐
│                           设计目标                                   │
├─────────────────────────────────────────────────────────────────────┤
│  ✅ 安全隔离    OpenClaw 完全运行在 GCP 云端，与个人数据物理隔离          │
│  ✅ 数据主权    个人数据保留在家庭本地，通过 API 按需授权访问              │
│  ✅ 标准接口    本地暴露 HTTP RESTful API，与 OpenClaw 解耦            │
│  ✅ 随时随地    通过 Discord 移动端随时与 AI 助理交互                   │
│  ✅ 成本可控    GCP e2-small 约 $15/月 + Cloudflare 免费层            │
│  ✅ 零信任安全  Cloudflare Zero Trust Access 保护所有 API 入口         │
│  ✅ 全球加速    Cloudflare CDN 提供低延迟访问                          │
└─────────────────────────────────────────────────────────────────────┘
```

### 2.2 适用场景

| 场景 | 描述 |
|------|------|
| **个人知识搜索** | 通过搜索引擎 API 检索本地文档、笔记、代码 |
| **智能问答** | 通过 RAG 引擎 API 基于个人知识库回答问题 |
| **语义检索** | 利用向量数据库进行语义相似度搜索 |
| **知识整合** | AI 助理整合本地知识与互联网信息 |
| **隐私敏感操作** | 敏感数据永不上传，仅返回处理后的结果 |

### 2.3 架构选择理由

| 架构选择 | 原因 |
|----------|------|
| **GCP 全托管 OpenClaw** | 高可用、24/7 在线、简化运维、与个人数据隔离 |
| **本地 API 服务** | 数据主权、灵活性高、标准协议、易于扩展 |
| **Discord 作为入口** | 跨平台、移动端体验好、支持 Bot API、免费 |
| **Cloudflare Tunnel** | 零信任安全、无需公网 IP、全球 CDN 加速、免费 |

---

## 三、整体技术架构详解

### 3.1 架构总览

```
                                    ┌─────────────────┐
                                    │   Discord       │
                                    │  (移动/桌面)     │
                                    └────────┬────────┘
                                             │ Bot API
                                             ▼
┌────────────────────────────────────────────────────────────────────┐
│                        Google Cloud Platform                       │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │                    GCP Compute Engine                        │  │
│  │                      (e2-small)                              │  │
│  │  ┌────────────────────────────────────────────────────────┐  │  │
│  │  │              OpenClaw Gateway (Docker)                 │  │  │
│  │  │                                                        │  │  │
│  │  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     │  │  │
│  │  │  │ Pi Agent    │  │ WebSocket   │  │ Control UI  │     │  │  │
│  │  │  │ (AI 推理)    │  │ Server      │  │ (管理面板)   │     │  │  │
│  │  │  └─────────────┘  └─────────────┘  └─────────────┘     │  │  │
│  │  │         │                                              │  │  │
│  │  │  ┌──────▼───────────────────────────────────────────┐  │  │  │
│  │  │  │              MCP / Custom Skill                  │  │  │  │
│  │  │  │                                                  │  │  │  │
│  │  │  │  ┌──────────────┐      ┌──────────────────┐      │  │  │  │
│  │  │  │  │ home-search  │      │ home-rag         │      │  │  │  │
│  │  │  │  │ (搜索引擎)    │      │ (RAG 引擎)        │      │  │  │  │
│  │  │  │  └──────────────┘      └──────────────────┘      │  │  │  │
│  │  │  └──────────────────────────────────────────────────┘  │  │  │
│  │  │                          │                             │  │  │
│  │  │               HTTP API (via Cloudflare Tunnel)         │  │  │
│  │  └────────────────────────────────────────────────────────┘  │  │
│  │                             │                                │  │
│  │                      cloudflared daemon                      │  │
│  │                    (Cloudflare Tunnel)                       │  │
│  └─────────────────────────────┼────────────────────────────────┘  │
└────────────────────────────────┼───────────────────────────────────┘
                                 │
                     Cloudflare Global Network
                    ┌────────────┴────────────┐
                    │                         │
           ┌────────▼────────┐      ┌────────▼────────┐
           │ gateway.domain  │      │ api.domain      │
           │   .com          │      │   .com          │
           │ (Control UI)    │      │ (Home APIs)     │
           └─────────────────┘      └─────────────────┘
                                             │
                              Cloudflare Tunnel (outbound)
                                             │
┌────────────────────────────────────────────┼────────────────────────┐
│                           家庭网络          │                        │
│  ┌─────────────────────────────────────────┴──────────────────────┐ │
│  │                      家庭服务器 (API Host)                       │ │
│  │                                                                │ │
│  │  ┌───────────────────────────────────────────────────────────┐ │ │
│  │  │                  cloudflared daemon                       │ │ │
│  │  │              (连接到 Cloudflare Tunnel)                    │ │ │
│  │  └───────────────────────────────────────────────────────────┘ │ │
│  │                             │                                  │ │
│  │  ┌───────────────────────────────────────────────────────────┐ │ │
│  │  │                    本地 API 服务                           │ │ │
│  │  │                                                           │ │ │
│  │  │  ┌─────────────────────┐  ┌─────────────────────────────┐ │ │ │
│  │  │  │   搜索引擎 API       │  │       RAG 引擎 API           │ │ │ │
│  │  │  │   :8001             │  │       :8002                 │ │ │ │
│  │  │  │                     │  │                             │ │ │ │
│  │  │  │ • 全文搜索           │  │ • 向量检索                   │ │ │ │
│  │  │  │ • 文件名搜索         │  │ • 语义问答                   │ │ │ │
│  │  │  │ • 元数据查询         │  │ • 知识库摘要                  │ │ │ │
│  │  │  └─────────────────────┘  └─────────────────────────────┘ │ │ │
│  │  │                                                           │ │ │
│  │  │  ┌───────────────────────────────────────────────────────┐│ │ │
│  │  │  │              个人数据目录 (只读访问)                     ││ │ │
│  │  │  │  ~/Documents  ~/Notes  ~/Projects  ~/Knowledge        ││ │ │
│  │  │  └───────────────────────────────────────────────────────┘│ │ │
│  │  └───────────────────────────────────────────────────────────┘ │ │
│  └────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────┘
```

### 3.2 组件职责说明

#### 3.2.1 GCP OpenClaw（云端全托管）

| 组件 | 职责 |
|------|------|
| **Gateway 进程** | 长驻服务，管理会话、路由消息、协调工具执行 |
| **Pi Agent** | AI 推理引擎，调用 LLM API（Anthropic/OpenAI/OpenRouter） |
| **Discord Channel** | 接收 Discord Bot 消息，路由到 Agent |
| **Control UI** | Web 管理面板，配置、监控、日志查看 |
| **MCP / Custom Skill** | 封装本地 API 调用逻辑 |
| **cloudflared** | Cloudflare Tunnel 客户端，建立安全出站连接 |

**云端处理的内容：**
- ✅ AI 推理和对话管理
- ✅ 工具调用编排
- ✅ Discord 消息处理
- ✅ 会话状态管理

**不存储的内容：**
- ❌ 个人文件和原始数据
- ❌ 本地知识库内容（仅查询结果）
- ❌ 敏感凭证（通过 Secret Manager 管理）

#### 3.2.2 家庭 API 服务（本地数据平面）

| 组件 | 职责 |
|------|------|
| **cloudflared** | 建立到 Cloudflare 的出站隧道，无需开放入站端口 |
| **搜索引擎 API** | 提供文件搜索、全文检索、元数据查询 |
| **RAG 引擎 API** | 提供向量检索、语义问答、知识摘要 |

**存储的内容：**
- ✅ 所有个人文档、笔记、项目
- ✅ 向量数据库（Embeddings）
- ✅ 搜索索引
- ✅ 敏感配置和凭证

#### 3.2.3 本地 API 设计规范

##### 搜索引擎 API 端点

```
Base URL: http://127.0.0.1:8001

┌─────────────────────────────────────────────────────────────────────┐
│                        搜索引擎 API                                  │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  POST /api/v1/search/files                                          │
│  ├── 功能: 文件名和路径搜索                                            │
│  ├── 参数: query, path, extensions[], limit, offset                 │
│  └── 返回: [{path, name, size, modified, type}]                     │
│                                                                     │
│  POST /api/v1/search/fulltext                                      │
│  ├── 功能: 全文内容搜索                                              │
│  ├── 参数: query, path, extensions[], limit, offset, highlight      │
│  └── 返回: [{path, snippet, score, highlights[]}]                   │
│                                                                     │
│  GET /api/v1/files/{path}                                          │
│  ├── 功能: 读取文件内容                                               │
│  ├── 参数: path (URL encoded), lines (可选，限制行数)                 │
│  └── 返回: {path, content, size, modified, encoding}                │
│                                                                     │
│  GET /api/v1/files/{path}/metadata                                  │
│  ├── 功能: 获取文件元数据                                             │
│  ├── 参数: path (URL encoded)                                       │
│  └── 返回: {path, size, created, modified, type, permissions}       │
│                                                                     │
│  GET /api/v1/directories/{path}                                     │
│  ├── 功能: 列出目录内容                                               │
│  ├── 参数: path, recursive (可选), depth (可选)                      │
│  └── 返回: [{name, path, type, size, modified}]                     │
│                                                                     │
│  GET /api/v1/health                                                 │
│  ├── 功能: 健康检查                                                   │
│  └── 返回: {status, version, indexed_files, last_index_time}         │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

##### RAG 引擎 API 端点

```
Base URL: http://127.0.0.1:8002

┌─────────────────────────────────────────────────────────────────────┐
│                         RAG 引擎 API                                 │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  POST /api/v1/query                                                 │
│  ├── 功能: 语义问答（核心端点）                                        │
│  ├── 参数: question, top_k, filters{}, include_sources              │
│  └── 返回: {answer, sources[], confidence, tokens_used}             │
│                                                                     │
│  POST /api/v1/retrieve                                              │
│  ├── 功能: 纯向量检索（不生成答案）                                     │
│  ├── 参数: query, top_k, filters{}, threshold                       │
│  └── 返回: [{chunk, source, score, metadata}]                       │
│                                                                     │
│  POST /api/v1/summarize                                             │
│  ├── 功能: 文档/主题摘要                                              │
│  ├── 参数: topic, sources[], max_length                             │
│  └── 返回: {summary, sources[], key_points[]}                       │
│                                                                     │
│  GET /api/v1/collections                                            │
│  ├── 功能: 列出知识库集合                                             │
│  └── 返回: [{name, description, doc_count, last_updated}]           │
│                                                                     │
│  GET /api/v1/collections/{name}/stats                               │
│  ├── 功能: 获取集合统计信息                                           │
│  └── 返回: {doc_count, chunk_count, avg_chunk_size, topics[]}       │
│                                                                     │
│  POST /api/v1/index/trigger                                         │
│  ├── 功能: 触发增量索引                                               │
│  ├── 参数: paths[], force (可选)                                     │
│  └── 返回: {job_id, status, estimated_time}                          │
│                                                                     │
│  GET /api/v1/health                                                 │
│  ├── 功能: 健康检查                                                  │
│  └── 返回: {status, version, vector_db, embedding_model}            │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

##### API 请求/响应示例

**搜索文件**

```bash
# 请求
curl -X POST https://api.yourdomain.com/api/v1/search/files \
  -H "Authorization: Bearer ${API_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "query": "会议记录",
    "path": "~/Documents",
    "extensions": [".md", ".txt", ".pdf"],
    "limit": 10
  }'

# 响应
{
  "success": true,
  "results": [
    {
      "path": "~/Documents/Work/会议记录_20260125.md",
      "name": "会议记录_20260125.md",
      "size": 2048,
      "modified": "2026-01-25T14:30:00Z",
      "type": "markdown"
    },
    {
      "path": "~/Documents/Work/会议记录_20260128.md",
      "name": "会议记录_20260128.md",
      "size": 1536,
      "modified": "2026-01-28T10:15:00Z",
      "type": "markdown"
    }
  ],
  "total": 2,
  "took_ms": 45
}
```

**RAG 语义问答**

```bash
# 请求
curl -X POST https://api.yourdomain.com/api/v1/query \
  -H "Authorization: Bearer ${API_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "question": "上周会议讨论了哪些项目进展？",
    "top_k": 5,
    "include_sources": true,
    "filters": {
      "path_prefix": "~/Documents/Work",
      "date_range": {
        "from": "2026-01-20",
        "to": "2026-01-31"
      }
    }
  }'

# 响应
{
  "success": true,
  "answer": "根据上周的会议记录，主要讨论了以下项目进展：\n\n1. **项目 A**：完成了 80% 的开发工作，预计本月底可以进入测试阶段。\n2. **项目 B**：遇到了技术难题，团队正在寻找解决方案。\n3. **项目 C**：已成功交付，客户反馈良好。",
  "sources": [
    {
      "path": "~/Documents/Work/会议记录_20260125.md",
      "chunk": "项目 A 进展：张工汇报开发完成 80%...",
      "score": 0.92
    },
    {
      "path": "~/Documents/Work/会议记录_20260128.md",
      "chunk": "项目 B 技术难题讨论...",
      "score": 0.87
    }
  ],
  "confidence": 0.89,
  "tokens_used": 156
}
```

### 3.3 Cloudflare Tunnel 网络拓扑

```
┌─────────────────────────────────────────────────────────────────────────┐
│                     Cloudflare Global Network                           │
│                                                                         │
│   ┌─────────────────────────────────────────────────────────────────┐   │
│   │                    Cloudflare Edge (全球 300+ PoP)               │   │
│   │                                                                 │   │
│   │  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐       │   │
│   │  │ Zero Trust   │    │    WAF       │    │     CDN      │       │   │
│   │  │   Access     │    │  DDoS防护     │    │    缓存      │       │   │
│   │  └──────────────┘    └──────────────┘    └──────────────┘       │   │
│   │                                                                 │   │
│   │  ┌─────────────────────────────────────────────────────────┐    │   │
│   │  │                    Tunnel Router                        │    │   │
│   │  │                                                         │    │   │
│   │  │    gateway.yourdomain.com ──► GCP Tunnel                │    │   │
│   │  │    api.yourdomain.com     ──► Home Tunnel               │    │   │
│   │  │                                                         │    │   │
│   │  └─────────────────────────────────────────────────────────┘    │   │
│   └─────────────────────────────────────────────────────────────────┘   │
│              ▲                                     ▲                    │
│              │ QUIC/HTTP2 (出站)                    │ QUIC/HTTP2 (出站)  │
│              │ 端口 7844                            │ 端口 7844          │
└──────────────┼─────────────────────────────────────┼────────────────────┘
               │                                     │
    ┌──────────┴──────────┐            ┌─────────────┴───────────┐
    │   GCP Instance      │            │    Home Server          │
    │                     │            │                         │
    │  ┌───────────────┐  │            │  ┌───────────────────┐  │
    │  │  cloudflared  │  │            │  │    cloudflared    │  │
    │  │   (daemon)    │  │            │  │     (daemon)      │  │
    │  └───────┬───────┘  │            │  └─────────┬─────────┘  │
    │          │          │            │            │            │
    │  ┌───────▼───────┐  │  HTTP API  │  ┌─────────▼─────────┐  │
    │  │   OpenClaw    │  │◄───────────┼─►│   搜索引擎 :8001   │  │
    │  │   Gateway     │  │            │  │   RAG 引擎 :8002   │  │
    │  │  :18789       │  │            │  │                   │  │
    │  └───────────────┘  │            │  └───────────────────┘  │
    └─────────────────────┘            └─────────────────────────┘
```

### 3.4 数据流详解

```
┌─────────────────────────────────────────────────────────────────────┐
│                          典型请求流程                                 │
│                                                                     │
│  用户 (Discord)                                                      │
│       │                                                             │
│       │ 1. "帮我找到上周的会议记录"                                    │
│       ▼                                                             │
│  Discord Bot API ───────────────────────────────────────────────────│
│       │                                                             │
│       │ 2. 消息路由到 Gateway                                         │
│       ▼                                                             │
│  GCP Gateway (via Cloudflare Tunnel)                                │
│       │                                                             │
│       │ 3. Pi Agent 分析意图，决定调用本地搜索 API                      │
│       ▼                                                             │
│  Pi Agent ─────► LLM API (Anthropic Claude)                         │
│       │              │                                              │
│       │              │ 4. 返回工具调用决策                            │
│       │              │    tool: "home_search"                       │
│       │              │    params: {query: "会议记录", days: 7}       │
│       ◄──────────────┘                                              │
│       │                                                             │
│       │ 5. MCP/Skill 调用本地搜索引擎 API                             │
│       │    POST https://api.yourdomain.com/api/v1/search/files      │
│       ▼                                                             │
│  Cloudflare Tunnel ──────────────────────────────────────────────── │
│       │                                                             │
│       │ 6. 请求路由到家庭服务器                                        │
│       ▼                                                             │
│  Home Server (搜索引擎 API)                                          │
│       │                                                             │
│       │ 7. 执行本地搜索，返回结果                                      │
│       │    {results: [{path: "会议记录_0125.md"}, ...]}              │
│       ▼                                                             │
│  GCP Gateway (via Cloudflare Tunnel)                                │
│       │                                                             │
│       │ 8. Agent 整理结果，生成回复                                    │
│       ▼                                                             │
│  Discord Bot API                                                    │
│       │                                                             │
│       │ 9. "找到2份会议记录：..."                                     │
│       ▼                                                             │
│  用户 (Discord)                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

### 3.5 MCP 集成方案

OpenClaw 通过 MCP (Model Context Protocol) 集成本地 API。有两种方式：

#### 方式一：使用 mcporter Skill（推荐）

```json
// ~/.openclaw/skills/home-api/SKILL.md
---
name: home-api
description: Access home server APIs for search and RAG
version: 1.0.0
mcp:
  servers:
    - name: home-search
      transport: sse
      url: https://api.yourdomain.com/mcp/search
    - name: home-rag
      transport: sse
      url: https://api.yourdomain.com/mcp/rag
---
```

#### 方式二：自定义 HTTP Skill

```markdown
---
name: home-search
description: Search files on home server
version: 1.0.0
triggers:
  - find
  - search
  - look for
  - where is
tools:
  - http
---

# Home Search Skill

## Tool: search_files

Search for files on the home server.

### Parameters
- `query` (required): Search query string
- `path` (optional): Directory to search in, default "~"
- `extensions` (optional): File extensions to filter, e.g. [".md", ".txt"]
- `limit` (optional): Max results, default 10

### Implementation

```javascript
async function search_files({ query, path = "~", extensions = [], limit = 10 }) {
  const response = await fetch("https://api.yourdomain.com/api/v1/search/files", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "Authorization": `Bearer ${env.HOME_API_TOKEN}`
    },
    body: JSON.stringify({ query, path, extensions, limit })
  });
  return response.json();
}
```

### 3.6 本地 API 服务技术栈建议

| 组件 | 推荐方案 | 说明 |
|------|---------|------|
| **Web 框架** | FastAPI (Python) / Gin (Go) | 高性能、易于开发 |
| **搜索引擎** | Meilisearch / Typesense | 全文搜索、易部署 |
| **向量数据库** | Qdrant / Chroma / Weaviate | 语义检索 |
| **Embedding 模型** | sentence-transformers / BGE | 本地运行，隐私友好 |
| **文件监控** | watchdog (Python) / fsnotify (Go) | 增量索引 |
| **部署方式** | Docker Compose | 统一管理多个服务 |

---

## 四、安全与风险分析

### 4.1 威胁模型

```



┌─────────────────────────────────────────────────────────────────┐
│                          威胁来源                                │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────┐   ┌──────────────┐    ┌──────────────┐        │
│  │ 外部攻击者     │   │ 恶意输入      │   │ API 滥用      │        │
│  │              │   │ (Prompt      │   │ (未授权调用)   │        │
│  │ 尝试直接      │   │  Injection)  │   │               │        │
│  │ 访问 API      │   │              │   │              │        │
│  └──────┬───────┘   └──────┬───────┘   └──────┬───────┘         │
│         │                  │                  │                 │
│         ▼                  ▼                  ▼                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                    攻击面                                │   │
│  ├─────────────────────────────────────────────────────────┤   │
│  │ • API 端点暴露 (已缓解: Cloudflare Zero Trust)            │   │
│  │ • API Token 泄露                                         │   │
│  │ • LLM API Key 泄露                                       │   │
│  │ • Prompt Injection 导致非授权数据访问                      │   │
│  │ • 路径遍历攻击                                            │   │
│  │ • API 速率限制绕过                                        │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

### 4.2 风险矩阵

| 风险 | 可能性 | 影响 | 缓解措施 |
|------|--------|------|----------|
| **API 端点暴露** | 低 | 高 | Cloudflare Zero Trust Access，API Token 认证 |
| **Prompt Injection** | 中 | 中 | API 返回数据过滤、路径白名单 |
| **API Token 泄露** | 低 | 高 | 定期轮换、最小权限、Secret Manager |
| **路径遍历** | 中 | 高 | 严格路径验证、chroot 限制 |
| **DDoS 攻击** | 低 | 低 | Cloudflare 自动防护、API 限流 |
| **数据泄露** | 低 | 高 | API 仅返回查询结果，不暴露原始路径 |

### 4.3 安全架构设计

```
┌─────────────────────────────────────────────────────────────────┐
│                       安全防护层次                                │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Layer 1: 边缘防护 (Cloudflare)                                  │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │ • DDoS 防护：自动过滤恶意流量                               │   │
│  │ • WAF：Web 应用防火墙规则                                  │   │
│  │ • Rate Limiting：限制请求频率 (100 req/min)                │   │
│  │ • Bot 管理：阻止自动化攻击                                  │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                │
│  Layer 2: 零信任访问控制                                         │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │ • Cloudflare Access：所有 API 访问必须通过身份验证          │   │
│  │ • Service Token：服务间认证 (GCP → Home API)              │   │
│  │ • IP 白名单：仅允许 GCP 出口 IP 访问 Home API               │   │
│  │ • 地理位置限制：限制 API 访问区域                           │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                │
│  Layer 3: API 层安全                                            │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │ • Bearer Token 认证：每个请求必须携带有效 Token             │   │
│  │ • 路径白名单：仅允许访问指定目录                            │   │
│  │ • 路径规范化：防止路径遍历攻击                              │   │
│  │ • 请求验证：严格校验输入参数                                │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                │
│  Layer 4: 数据层安全                                             │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │ • 只读访问：API 不提供写入/删除能力                         │   │
│  │ • 敏感文件过滤：自动排除 .env, credentials 等              │   │
│  │ • 返回数据脱敏：可选隐藏完整路径                            │   │
│  │ • 日志审计：记录所有 API 访问                              │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                │
│  Layer 5: 监控审计                                              │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │ • Cloudflare Analytics：访问日志和分析                     │   │
│  │ • API 访问日志：记录所有请求和响应                          │   │
│  │ • 异常检测：异常访问模式告警                                │   │
│  │ • 定期安全审计                                            │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

### 4.4 API 安全配置

#### API 服务安全配置示例

```yaml
# config.yaml
security:
  # Bearer Token 认证
  auth:
    enabled: true
    tokens:
      - name: "openclaw-gateway"
        token: "${HOME_API_TOKEN}"
        permissions: ["search", "read", "rag"]
        rate_limit: 100  # requests per minute
  
  # 路径访问控制
  paths:
    allowed:
      - "~/Documents"
      - "~/Notes"
      - "~/Projects"
      - "~/Knowledge"
    denied:
      - "~/.ssh"
      - "~/.gnupg"
      - "~/.config"
      - "~/.env*"
      - "**/credentials*"
      - "**/secret*"
      - "**/.git"
  
  # 文件类型限制
  file_types:
    allowed:
      - ".txt"
      - ".md"
      - ".pdf"
      - ".docx"
      - ".json"
      - ".yaml"
      - ".py"
      - ".js"
      - ".ts"
    max_file_size: "10MB"
  
  # 请求限制
  limits:
    max_query_length: 500
    max_results: 100
    max_file_read_size: "1MB"
    request_timeout: 30s

logging:
  level: "info"
  format: "json"
  include_request_body: false  # 不记录请求体（隐私）
  include_response_body: false # 不记录响应体
```

#### Cloudflare Access 策略（API 端点）

```json
{
  "name": "Home API Access",
  "decision": "allow",
  "include": [
    {
      "service_token": {
        "token_id": "your-service-token-id"
      }
    }
  ],
  "require": [],
  "exclude": []
}
```

### 4.5 安全最佳实践清单

- [ ] 启用 Cloudflare Zero Trust Access
- [ ] 配置 Service Token 用于 GCP → Home API 认证
- [ ] 设置 API Rate Limiting
- [ ] 配置路径白名单，排除敏感目录
- [ ] 启用 WAF 规则
- [ ] 配置 API 访问日志
- [ ] 定期轮换 API Token
- [ ] 启用异常访问告警
- [ ] 定期审计 API 访问日志

---

## 五、部署最佳实践教程

### 5.1 前置准备

#### 5.1.1 账户和工具

| 项目                | 要求                 | 获取方式                             |
| ----------------- | ------------------ | -------------------------------- |
| **GCP 账户**        | 启用计费               | https://console.cloud.google.com |
| **Cloudflare 账户** | 免费版足够              | https://dash.cloudflare.com      |
| **域名**            | 托管在 Cloudflare     | 可在 Cloudflare 购买或转入              |
| **Discord 账户**    | 创建 Bot             | https://discord.com/developers   |
| **Anthropic API** | Claude API Key     | https://console.anthropic.com    |
| **家庭服务器**         | Linux/macOS，Docker | 现有设备                             |
|                   |                    |                                  |
|                   |                    |                                  |

## 附录

### A. 完整配置文件参考

<details>
<summary>GCP Gateway 完整配置 (~/.openclaw/openclaw.json)</summary>

```json
{
  "gateway": {
    "auth": {
      "token": "${GATEWAY_AUTH_TOKEN}"
    },
    "bind": "127.0.0.1",
    "port": 18789
  },
  "agent": {
    "model": "anthropic/claude-sonnet-4-5",
    "systemPrompt": "You are a helpful personal AI assistant. You have access to the user's home server through search and RAG APIs. When the user asks about their files, documents, or knowledge, use the appropriate home API tools."
  },
  "channels": {
    "discord": {
      "enabled": true,
      "token": "${DISCORD_BOT_TOKEN}",
      "dmPolicy": "pairing",
      "guilds": {
        "*": {
          "requireMention": true
        }
      }
    }
  },
  "exec": {
    "approvals": {
      "security": "deny"
    }
  },
  "tools": {
    "allow": [
      "sessions_list",
      "sessions_history",
      "discord",
      "http"
    ],
    "deny": [
      "exec",
      "process",
      "browser",
      "nodes",
      "canvas"
    ]
  },
  "skills": {
    "paths": ["~/.openclaw/skills"]
  }
}
```

</details>

<details>
<summary>Home API 安全配置 (config.yaml)</summary>

```yaml
security:
  auth:
    enabled: true
    tokens:
      - name: "openclaw-gateway"
        token: "${HOME_API_TOKEN}"
        permissions: ["search", "read", "rag"]
        rate_limit: 100

  paths:
    allowed:
      - "~/Documents"
      - "~/Notes"
      - "~/Projects"
      - "~/Knowledge"
    denied:
      - "~/.ssh"
      - "~/.gnupg"
      - "~/.config"
      - "~/.env*"
      - "**/credentials*"
      - "**/secret*"
      - "**/.git"
      - "**/node_modules"

  file_types:
    allowed:
      - ".txt"
      - ".md"
      - ".pdf"
      - ".docx"
      - ".json"
      - ".yaml"
      - ".yml"
    max_file_size: "10MB"

  limits:
    max_query_length: 500
    max_results: 100
    max_file_read_size: "1MB"
    request_timeout: 30s

logging:
  level: "info"
  format: "json"
  file: "/var/log/home-api/access.log"
```

</details>

<details>
<summary>Docker Compose 完整配置</summary>

```yaml
version: '3.8'

services:
  search-api:
    build: ./search-api
    container_name: home-search-api
    ports:
      - "127.0.0.1:8001:8001"
    volumes:
      - ~/Documents:/data/documents:ro
      - ~/Notes:/data/notes:ro
      - ~/Projects:/data/projects:ro
      - ~/Knowledge:/data/knowledge:ro
      - ./data/search-index:/data/index
      - ./search-api/config.yaml:/app/config.yaml:ro
    environment:
      - HOME_API_TOKEN=${HOME_API_TOKEN}
      - MEILI_URL=http://meilisearch:7700
      - MEILI_MASTER_KEY=${MEILI_MASTER_KEY}
    depends_on:
      - meilisearch
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8001/api/v1/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  meilisearch:
    image: getmeili/meilisearch:v1.6
    container_name: meilisearch
    ports:
      - "127.0.0.1:7700:7700"
    volumes:
      - ./data/meili:/meili_data
    environment:
      - MEILI_MASTER_KEY=${MEILI_MASTER_KEY}
      - MEILI_ENV=production
    restart: unless-stopped

  rag-api:
    build: ./rag-api
    container_name: home-rag-api
    ports:
      - "127.0.0.1:8002:8002"
    volumes:
      - ~/Documents:/data/documents:ro
      - ~/Notes:/data/notes:ro
      - ~/Knowledge:/data/knowledge:ro
      - ./data/vector-db:/data/vector-db
      - ./rag-api/config.yaml:/app/config.yaml:ro
    environment:
      - HOME_API_TOKEN=${HOME_API_TOKEN}
      - QDRANT_URL=http://qdrant:6333
      - EMBEDDING_MODEL=BAAI/bge-small-zh-v1.5
    depends_on:
      - qdrant
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8002/api/v1/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  qdrant:
    image: qdrant/qdrant:v1.7.4
    container_name: qdrant
    ports:
      - "127.0.0.1:6333:6333"
    volumes:
      - ./data/qdrant:/qdrant/storage
    restart: unless-stopped

  nginx:
    image: nginx:alpine
    container_name: home-api-gateway
    ports:
      - "127.0.0.1:8080:80"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
    depends_on:
      - search-api
      - rag-api
    restart: unless-stopped

networks:
  default:
    name: home-api-network
```

</details>

### B. 参考链接

| 资源 | 链接 |
|------|------|
| OpenClaw 官方文档 | https://docs.openclaw.ai |
| OpenClaw GitHub | https://github.com/openclaw/openclaw |
| Cloudflare Tunnel 文档 | https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/ |
| Cloudflare Zero Trust | https://developers.cloudflare.com/cloudflare-one/ |
| Cloudflare Access | https://developers.cloudflare.com/cloudflare-one/policies/access/ |
| FastAPI 文档 | https://fastapi.tiangolo.com/ |
| Meilisearch 文档 | https://www.meilisearch.com/docs |
| Qdrant 文档 | https://qdrant.tech/documentation/ |
| Discord Developer | https://discord.com/developers/docs |
| GCP Compute Engine | https://cloud.google.com/compute/docs |


---

#OpenClaw #GCP #Discord #CloudflareTunnel #ZeroTrust #最佳实践 #混合部署 #个人AI助理 #RAG #搜索引擎
