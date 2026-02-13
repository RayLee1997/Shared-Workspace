# OpenClaw 深度调研报告

> 调研时间：2026-02-15  
> 基于原有调研报告深度扩展

---

## 目录

- [一、项目概述与演进历程](#一项目概述与演进历程)
- [二、技术架构深度解析](#二技术架构深度解析)
- [三、Agent 架构设计](#三agent-架构设计)
- [四、上下文管理机制](#四上下文管理机制)
- [五、工具系统与 MCP 集成](#五工具系统与-mcp-集成)
- [六、Skills 技能系统](#六skills-技能系统)
- [七、模型提供商支持](#七模型提供商支持)
- [八、安全架构与风险分析](#八安全架构与风险分析)
- [九、部署方案详解](#九部署方案详解)
- [十、消息渠道集成](#十消息渠道集成)
- [十一、CLI 命令速查](#十一cli-命令速查)
- [十二、生态系统与社区](#十二生态系统与社区)
- [十三、与竞品对比](#十三与竞品对比)
- [十四、已知限制与注意事项](#十四已知限制与注意事项)
- [十五、总结与建议](#十五总结与建议)

---

## 一、项目概述与演进历程

### 1.1 项目简介

OpenClaw 是一款开源的自托管个人 AI 助理软件，由奥地利开发者 **Peter Steinberger**（曾以约1.19亿美元出售 PSPDFKit 给 Insight Partners）于2025年底创建。项目最初名为 **Clawdbot**，后因 Anthropic 商标异议更名为 **Moltbot**，最终于2026年初定名为 **OpenClaw**。

### 1.2 发展里程碑

| 时间 | 事件 |
|------|------|
| 2025年11月 | 以 Clawdbot 名称公开发布 |
| 2025年12月 | Claude Code 发布后开始获得关注 |
| 2026年1月24-27日 | 经历病毒式传播，72小时内获得 60,000+ GitHub stars |
| 2026年1月 | 因 Anthropic 商标请求更名为 Moltbot |
| 2026年1月末 | 最终更名为 OpenClaw，累计超过 100,000 GitHub stars |
| 2026年1月31日 | OpenClawd.ai 推出托管服务平台 |

### 1.3 核心定位

- **本地优先（Local-First）**：运行在用户自有设备上，数据与上下文本地存储
- **代理驱动（Agent-Driven）**：不仅是对话助手，更是能"执行任务"的自主代理
- **多渠道整合**：统一接入 WhatsApp、Telegram、Slack、Discord、Signal、iMessage、Microsoft Teams、Matrix 等消息渠道
- **持续运行**：支持后台 daemon 运行，可执行定时任务和主动通知

---

## 二、技术架构深度解析

### 2.1 整体架构图

```
WhatsApp / Telegram / Slack / Discord / Google Chat / Signal / iMessage / 
BlueBubbles / Microsoft Teams / Matrix / Zalo / WebChat
                              │
                              ▼
               ┌───────────────────────────────┐
               │          Gateway              │
               │       (控制平面)               │
               │   ws://127.0.0.1:18789        │
               │   http://<host>:18793/canvas  │
               └──────────────┬────────────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        │                     │                     │
        ▼                     ▼                     ▼
   ┌─────────┐         ┌─────────────┐        ┌──────────┐
   │Pi Agent │         │  CLI/WebUI  │        │  Nodes   │
   │ (RPC)   │         │             │        │(设备能力) │
   └─────────┘         └─────────────┘        └──────────┘
                                                    │
                              ┌─────────────────────┼─────────────────────┐
                              │                     │                     │
                              ▼                     ▼                     ▼
                         ┌─────────┐          ┌─────────┐          ┌─────────┐
                         │ macOS   │          │   iOS   │          │ Android │
                         │ Node    │          │  Node   │          │  Node   │
                         └─────────┘          └─────────┘          └─────────┘
```


### 2.2 Gateway 控制平面

Gateway 是 OpenClaw 的核心组件，作为长驻进程承担以下职责：

| 功能模块              | 说明                           |
| ----------------- | ---------------------------- |
| **会话管理**          | 管理消息渠道连接与会话生命周期              |
| **WebSocket API** | 统一 WS 控制平面，支持客户端订阅事件流        |
| **Control UI**    | 提供 Web 控制面板（同端口复用 HTTP + WS） |
| **WebChat**       | 内置 Web 聊天界面                  |
| **Canvas Host**   | A2UI 视觉工作区托管（端口18793）        |

**关键配置参数：**
- 默认端口：`18789`（WebSocket + HTTP）
- Canvas 端口：`18793`
- 认证：默认强制要求 Gateway auth token

### 2.3 WebSocket 协议规范

```json
// 连接握手
{
  "type": "connect",
  "role": "operator|node|client",
  "token": "auth_token"
}

// 事件类型
- agent/presence: 代理状态
- health: 健康检查
- heartbeat: 心跳
- cron: 定时任务事件
- node.invoke: 节点远程调用
```

**协议特性：**
- JSON over WebSocket
- 严格的 connect 握手流程
- 请求-响应具备类型校验与幂等机制
- Gateway auth 默认必须（fail-closed 策略）

### 2.4 Node 设备能力系统

Node 是连接到 Gateway 的伴侣设备，以 `role: "node"` 身份通过 WebSocket 连接，暴露本地能力：

| 平台 | 支持的能力 |
|------|-----------|
| **macOS** | Canvas、Camera、Screen Recording、system.run、system.notify、Accessibility、Automation/AppleScript |
| **iOS** | Canvas (WKWebView)、Screen snapshot、Camera capture、Location、Talk mode、Voice wake |
| **Android** | Canvas、Camera、Screen record、Location、SMS send（需权限）、Notifications |
| **Headless** | system.run、system.which、exec approvals |

**Node 调用示例：**
```bash
# 获取位置
openclaw nodes location get --node <idOrNameOrIp> --accuracy precise

# 相机拍照
openclaw nodes camera snap --node <nodeId>
```

### 2.5 浏览器控制（CDP）

OpenClaw 通过 Chrome DevTools Protocol (CDP) 实现浏览器自动化：

- **本地模式**：openclaw 管理的 Chrome/Chromium 实例
- **远程模式**：支持 Browserless 等托管 CDP 服务
- **功能**：页面快照、表单填写、数据抓取、文件下载

**配置示例：**
```json
{
  "browser": {
	    "profiles": {
      "default": {
        "cdpPort": 9222,
        "cdpUrl": "ws://127.0.0.1:9222"
      }
    }
  }
}
```

### 2.6 Canvas 与 A2UI

Canvas 是代理驱动的可视化工作区：

- **A2UI (Agent-to-UI)**：代理向 UI 推送内容的协议
- **实时渲染**：支持动态内容更新
- **跨平台**：macOS/iOS/Android 节点均支持 Canvas 渲染

---

## 三、Agent 架构设计

### 3.1 Pi Agent 代理引擎

OpenClaw 采用 **Pi Coding Agent** 作为核心代理引擎（legacy Claude/Codex/Gemini/Opencode 路径已移除）。Pi 是由 Mario Zechner 开发的最小化编码代理，强调"可解释的简洁性"而非"复杂的巧妙"。

#### 3.1.1 Pi Agent 设计哲学

```
┌─────────────────────────────────────────────────────────────────┐
│                      Pi Agent 核心设计                           │
├─────────────────────────────────────────────────────────────────┤
│  • 最小化设计：核心代码精简，易于理解和扩展                           │
│  • 模型无关：支持多种 LLM 提供商                                    │
│  • 可塑性：像粘土一样可以被 AI 自身改造和扩展                         │
│  • 无内置 MCP：通过 mcporter 等外部工具支持 MCP                     │
└─────────────────────────────────────────────────────────────────┘
```

#### 3.1.2 Pi SDK 核心组件

| 组件 | 功能 |
|------|------|
| **pi-ai** | 统一 LLM API，支持多提供商（Anthropic、OpenAI、Google、xAI、Groq 等） |
| **Tool Calling** | 基于 TypeBox 的工具调用，支持 JSON Schema 验证 |
| **Streaming** | 流式输出支持，包括部分 JSON 解析 |
| **Token Tracking** | 跨提供商的 token 和成本追踪 |

**配置示例（~/.openclaw/openclaw.json）：**
```json
{
  "agent": {
    "model": "anthropic/claude-opus-4-5"
  }
}
```

**推荐配置**：
- Anthropic Pro/Max (100/200) + Opus 4.5
- 优势：长上下文能力强、prompt injection 抵抗力更好

### 3.2 Agentic Loop（代理循环）

OpenClaw 的核心是一个完整的 **Agentic Loop**，这是将用户消息转化为实际行动和最终回复的权威路径。

#### 3.2.1 循环流程

```

┌─────────────────────────────────────────────────────────────────────────┐
│                         Agentic Loop 执行流程                            │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
                    ┌───────────────────────────────┐
                    │         1. Intake             │
                    │      接收用户消息               │
                    └───────────────┬───────────────┘
                                    │
                                    ▼
                    ┌───────────────────────────────┐
                    │    2. Context Assembly        │
                    │   组装上下文（系统提示、         │
                    │   记忆、会话历史、工具定义）      │
                    └───────────────┬───────────────┘
                                    │
                                    ▼
                    ┌───────────────────────────────┐
                    │    3. Model Inference         │
                    │      调用 LLM 推理             │
                    └───────────────┬───────────────┘
                                    │
                        ┌───────────┴───────────┐
                        │                       │
                        ▼                       ▼
              ┌─────────────────┐     ┌─────────────────┐
              │  工具调用请求？   │     │   文本响应       │
              │    Yes          │     │   (无工具调用)   │
              └────────┬────────┘     └────────┬────────┘
                       │                       │
                       ▼                       │
              ┌─────────────────┐              │
              │ 4.Tool Execution│              │
              │   执行工具调用    │              │
              └────────┬────────┘              │
                       │                       │
                       ▼                       │
              ┌─────────────────┐              │
              │  追加工具结果     │              │
              │  返回步骤 3      │              │
              └────────┬────────┘              │
                       │                       │
                       └───────────┬───────────┘
                                   │
                                   ▼
                    ┌───────────────────────────────┐
                    │    5. Streaming Replies       │
                    │      流式输出响应               │
                    └───────────────┬───────────────┘
                                    │
                                    ▼
                    ┌───────────────────────────────┐
                    │    6. Persistence             │
                    │   持久化会话状态                │
                    └───────────────────────────────┘
```

#### 3.2.2 循环特性

| 特性 | 说明 |
|------|------|
| **串行执行** | 每个会话同一时间只有一个循环在运行 |
| **事件发射** | 循环过程中发射 lifecycle 和 stream 事件 |
| **工具循环** | 工具调用 → 执行 → 追加结果 → 继续推理，直到无工具调用 |
| **状态一致性** | 确保会话状态在循环结束后保持一致 |

#### 3.2.3 插件钩子（Extension Points）

OpenClaw 在代理循环中提供多个扩展点：

```javascript
// 可用的生命周期钩子
{
  "before_agent_start": "在循环开始前注入上下文或覆盖系统提示",
  "agent_end": "循环结束后检查最终消息列表和运行元数据",
  "before_compaction": "观察或注释压缩周期（压缩前）",
  "after_compaction": "观察或注释压缩周期（压缩后）",
  "before_tool_call": "拦截工具参数",
  "after_tool_call": "拦截工具结果"
}
```

### 3.3 多代理路由

OpenClaw 支持将不同的消息渠道路由到隔离的代理：

```json
{
  "agents": {
    "list": [
      {
        "id": "personal",
        "workspace": "~/.openclaw/workspace-personal"
      },
      {
        "id": "work",
        "workspace": "~/.openclaw/workspace-work"
      }
    ]
  },
  "channels": {
    "routing": {
      "whatsapp": { "agent": "personal" },
      "slack:work-channel": { "agent": "work" }
    }
  }
}
```

**会话隔离特性：**
- 独立的会话密钥
- 独立的对话历史
- 独立的工作空间
- 独立的工具访问权限
- 独立的记忆/上下文

---

## 四、上下文管理机制

### 4.1 记忆系统（Memory）

OpenClaw 实现了多层记忆系统，支持跨会话的持久化状态。

#### 4.1.1 记忆文件结构

```
~/.openclaw/workspace/
├── IDENTITY.md          # 代理身份定义
├── SOUL.md              # 代理个性和行为准则
├── MEMORY.md            # 长期记忆（策略、偏好、持久事实）
└── memory/
    ├── 2026-02-14.md    # 昨日日志
    └── 2026-02-15.md    # 今日日志（追加写入）
```

#### 4.1.2 记忆类型

| 类型 | 文件 | 用途 | 加载时机 |
|------|------|------|----------|
| **身份记忆** | IDENTITY.md | 定义代理身份和角色 | 会话开始时 |
| **个性记忆** | SOUL.md | 定义行为准则和个性 | 会话开始时 |
| **长期记忆** | MEMORY.md | 存储决策、偏好、持久事实 | 主私密会话 |
| **日志记忆** | memory/YYYY-MM-DD.md | 日常笔记和运行上下文 | 今日+昨日 |

#### 4.1.3 记忆写入指令

```bash
# 指示 OpenClaw 记住某事
"Remember that I prefer dark mode in all applications"

# 代理会自动写入到适当的记忆文件
# 决策/偏好 → MEMORY.md
# 日常笔记 → memory/YYYY-MM-DD.md
```

### 4.2 会话管理（Session）

#### 4.2.1 会话状态追踪

```json
{
  "sessionId": "agent:personal:whatsapp:+1234567890",
  "contextTokens": 45000,      // 当前上下文 token 数
  "contextWindow": 200000,     // 模型上下文窗口
  "compactionCount": 2,        // 已执行的压缩次数
  "messageCount": 156          // 消息数量
}
```

#### 4.2.2 会话生命周期

```
┌─────────────────────────────────────────────────────────────────┐
│                       会话生命周期                                │
└─────────────────────────────────────────────────────────────────┘

  创建              活跃               压缩             终止
   │                 │                  │                │
   ▼                 ▼                  ▼                ▼
┌──────┐         ┌──────┐          ┌───────┐         ┌──────┐
│ New  │────────►│Active│────────► │Compact│───────► │ End  │
│      │         │      │          │       │         │      │
└──────┘         └──────┘          └───────┘         └──────┘
                     │                  ▲
                     │                  │
                     └──────────────────┘
                     (上下文接近阈值时)
```

### 4.3 上下文压缩（Compaction）

当会话上下文接近模型的上下文窗口限制时，OpenClaw 会触发自动压缩。

#### 4.3.1 压缩触发条件

```
压缩触发条件：
contextTokens > contextWindow - reserveTokens

其中：
- contextTokens: 当前上下文使用的 token 数
- contextWindow: 模型的上下文窗口大小
- reserveTokens: 为提示和下一次模型输出保留的 headroom
```

#### 4.3.2 压缩模式

| 模式 | 说明 |
|------|------|
| **default** | 默认压缩策略 |
| **safeguard** | 分块摘要，适用于超长历史 |

#### 4.3.3 压缩流程

```
┌─────────────────────────────────────────────────────────────────┐
│                      Compaction 流程                             │
└─────────────────────────────────────────────────────────────────┘

1. 检测到上下文接近阈值
         │
         ▼
2. 触发 Memory Flush（静默代理回合）
   - 提示模型将重要信息写入 memory/YYYY-MM-DD.md
   - 模型通常回复 NO_REPLY
         │
         ▼
3. 执行 Compaction
   - 将历史对话发送给 AI 请求摘要
   - 用摘要替换完整历史
         │
         ▼
4. 保留最近消息
   - 保留 firstKeptEntryId 之后的消息
   - 确保最近上下文完整
         │
         ▼
5. 持久化压缩结果
   - 写入 sessions.json
   - 更新 compactionCount
```

#### 4.3.4 Compaction 配置

```json
{
  "agents": {
    "defaults": {
      "compaction": {
        "mode": "safeguard",
        "reserveTokensFloor": 24000,
        "memoryFlush": {
          "enabled": true,
          "softThresholdTokens": 6000,
          "systemPrompt": "Session nearing compaction. Store durable memories now.",
          "prompt": "Write any lasting notes to memory/YYYY-MM-DD.md; reply with NO_REPLY if nothing to store."
        }
      }
    }
  }
}
```

### 4.4 会话修剪（Session Pruning）

与 Compaction 不同，Session Pruning 是非持久化的临时修剪：

| 特性 | Compaction | Session Pruning |
|------|------------|-----------------|
| **持久化** | 是 | 否 |
| **方式** | 摘要替换 | 直接删除/标记 |
| **触发** | 上下文接近阈值 | 缓存 TTL 过期 |
| **配置** | compaction.mode | contextPruning.mode |

**Pruning 配置示例：**
```json
{
  "agents": {
    "defaults": {
      "contextPruning": {
        "mode": "cache-ttl",
        "ttl": "1h"
      }
    }
  }
}
```

### 4.5 Token 管理最佳实践

#### 4.5.1 Token 消耗来源

| 来源 | 说明 | 优化建议 |
|------|------|----------|
| **大输出工具** | config.schema、status --all | 在隔离会话中执行 |
| **Cron 任务** | 频繁触发代理回合 | 只在有发现时唤醒代理 |
| **上下文累积** | 历史对话不断增长 | 启用积极压缩 |
| **工具定义** | 大量工具占用上下文 | 按需加载工具 |

#### 4.5.2 Token 优化配置

```json
{
  "agents": {
    "defaults": {
      "contextTokens": 100000,    // 限制上下文大小
      "compaction": {
        "mode": "safeguard"       // 使用安全压缩模式
      }
    }
  }
}
```

---

## 五、工具系统与 MCP 集成

### 5.1 内置工具概览

OpenClaw 提供了丰富的内置工具集：

#### 5.1.1 工具分类

```
┌─────────────────────────────────────────────────────────────────┐
│                    OpenClaw 内置工具体系                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐              │
│  │   文件操作   │  │   执行操作   │  │  浏览器操作  │              │
│  ├─────────────┤  ├─────────────┤  ├─────────────┤             │
│  │ read        │  │ exec        │  │ browser     │             │
│  │ write       │  │ process     │  │ (CDP控制)    │             │
│  │ edit        │  │             │  │             │             │
│  │ apply_patch │  │             │  │             │             │
│  └─────────────┘  └─────────────┘  └─────────────┘             │
│                                                                │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐             │
│  │   会话操作   │  │   节点操作   │  │   定时任务   │             │
│  ├─────────────┤  ├─────────────┤  ├─────────────┤             │
│  │sessions_list│  │ nodes       │  │ cron        │             │
│  │sessions_hist│  │ canvas      │  │             │             │
│  │sessions_send│  │ camera      │  │             │             │
│  │sessions_spawn│ │ location    │  │             │             │
│  └─────────────┘  └─────────────┘  └─────────────┘             │
│                                                                │
└────────────────────────────────────────────────────────────────┘
```

#### 5.1.2 工具详细说明

| 工具 | 功能 | 风险等级 |
|------|------|----------|
| **read** | 读取文件内容 | 低 |
| **write** | 写入文件内容 | 中 |
| **edit** | 编辑文件内容 | 中 |
| **apply_patch** | 应用补丁 | 中 |
| **exec** | 执行命令（前台） | 高 |
| **process** | 进程管理（后台、poll、send-keys） | 高 |
| **browser** | 浏览器自动化（CDP） | 中 |
| **canvas** | Canvas/A2UI 操作 | 低 |
| **nodes** | 节点调用 | 中 |
| **cron** | 定时任务管理 | 中 |

### 5.2 Exec 工具详解

#### 5.2.1 基本用法

```json
// 前台执行
{"tool": "exec", "command": "ls -la"}

// 后台执行 + 轮询
{"tool": "exec", "command": "npm run build", "yieldMs": 1000}
{"tool": "process", "action": "poll", "sessionId": "<id>"}

// 发送按键 (tmux 风格)
{"tool": "process", "action": "send-keys", "sessionId": "<id>", "keys": ["Enter"]}
{"tool": "process", "action": "send-keys", "sessionId": "<id>", "keys": ["C-c"]}
{"tool": "process", "action": "send-keys", "sessionId": "<id>", "keys": ["Up", "Up", "Enter"]}

// 提交命令
{"tool": "process", "action": "submit", "sessionId": "<id>"}

// 粘贴文本（默认括号模式）
{"tool": "process", "action": "paste", "sessionId": "<id>", "text": "line1\nline2\n"}
```

#### 5.2.2 Exec Approvals 执行审批

```json
{
  "exec": {
    "approvals": {
      "security": "ask",        // deny | ask | allow
      "allowlist": [
        "ls", "cat", "grep", "find", "pwd"
      ],
      "denylist": [
        "rm -rf", "sudo", "chmod 777"
      ]
    }
  }
}
```

### 5.3 工具策略配置

#### 5.3.1 允许/拒绝列表

```json
{
  "tools": {
    "allow": ["read", "write", "edit", "apply_patch", "exec", "process"],
    "deny": ["browser", "canvas", "nodes", "cron", "discord", "gateway"]
  }
}
```

#### 5.3.2 按代理配置工具

```json
{
  "agents": {
    "list": [
      {
        "id": "personal",
        "tools": {
          "allow": ["*"],
          "deny": []
        }
      },
      {
        "id": "family",
        "tools": {
          "allow": ["read"],
          "deny": ["write", "edit", "apply_patch", "exec", "process", "browser"]
        }
      },
      {
        "id": "work",
        "tools": {
          "allow": ["read", "write", "apply_patch", "exec"],
          "deny": ["browser", "gateway", "discord"]
        }
      }
    ]
  }
}
```

### 5.4 沙箱系统（Sandbox）

#### 5.4.1 沙箱模式

| 模式 | 说明 |
|------|------|
| **off** | 禁用沙箱 |
| **all** | 所有工具在沙箱中执行 |

#### 5.4.2 沙箱配置

```json
{
  "agents": {
    "list": [
      {
        "id": "work",
        "sandbox": {
          "mode": "all",
          "scope": "shared",
          "workspaceRoot": "/tmp/work-sandboxes",
          "workspaceAccess": "ro",        // 只读工作区
          "browser": {
            "enabled": true,
            "allowHostControl": false     // 禁止控制主机浏览器
          }
        }
      }
    ]
  }
}
```

#### 5.4.3 默认沙箱工具列表

```
允许列表 (allowlist):
- bash, process, read, write, edit
- sessions_list, sessions_history, sessions_send, sessions_spawn

拒绝列表 (denylist):
- browser, canvas, nodes, cron, discord, gateway
```

### 5.5 MCP 集成

OpenClaw 通过 **Model Context Protocol (MCP)** 接口与 100+ 第三方服务集成。

#### 5.5.1 MCP 架构

```
┌─────────────────────────────────────────────────────────────────┐
│                      MCP 集成架构                                │
└─────────────────────────────────────────────────────────────────┘

  OpenClaw Gateway
         │
         ▼
  ┌─────────────┐
  │  mcporter   │  ← MCP CLI 桥接器
  └──────┬──────┘
         │
    ┌────┴────┬────────┬────────┬────────┐
    ▼         ▼        ▼        ▼        ▼
┌───────┐ ┌───────┐ ┌───────┐ ┌───────┐ ┌───────┐
│Notion │ │GitHub │ │Stripe │ │FileFS │ │Custom │
│ MCP   │ │ MCP   │ │ MCP   │ │ MCP   │ │ MCP   │
└───────┘ └───────┘ └───────┘ └───────┘ └───────┘
```

#### 5.5.2 MCP 配置方式

**方式一：通过 mcporter Skill**

OpenClaw 官方推荐使用 `mcporter` skill 来调用 MCP 服务：

```bash
# mcporter CLI 用法
mcporter list                    # 列出可用的 MCP 服务
mcporter tools <server>          # 列出服务的工具
mcporter call <server> <tool>    # 调用工具
```

**方式二：原生 MCP 配置（实验性）**

```json
{
  "agents": {
    "list": [
      {
        "id": "main",
        "mcp": {
          "servers": [
            {
              "name": "notion",
              "command": "npx",
              "args": ["-y", "@notionhq/mcp"]
            },
            {
              "name": "filesystem",
              "command": "npx",
              "args": ["-y", "@anthropic/mcp-fs", "/path"]
            },
            {
              "name": "github",
              "command": "npx",
              "args": ["-y", "@modelcontextprotocol/server-github"],
              "env": {
                "GITHUB_TOKEN": "your-token-here"
              }
            }
          ]
        }
      }
    ]
  }
}
```

#### 5.5.3 MCP 工具调用流程

```
用户请求
    │
    ▼
OpenClaw 判断需要 MCP 工具
    │
    ▼
通过 mcporter 或原生 MCP 调用
    │
    ▼
MCP Server 执行操作
    │
    ▼
返回结果给 OpenClaw
    │
    ▼
OpenClaw 将结果追加到上下文
    │
    ▼
继续 Agentic Loop（如需要更多工具调用）
```

#### 5.5.4 常用 MCP 服务

| MCP 服务 | 功能 |
|----------|------|
| **@notionhq/mcp** | Notion 集成 |
| **@modelcontextprotocol/server-github** | GitHub 操作 |
| **@modelcontextprotocol/server-filesystem** | 文件系统访问 |
| **@stripe/mcp** | Stripe 支付集成 |
| **atlassian-mcp** | Jira/Confluence 集成 |
| **deepwiki** | GitHub 仓库文档查询 |

### 5.6 浏览器自动化

#### 5.6.1 CDP 控制

```json
{
  "browser": {
    "profiles": {
      "default": {
        "cdpPort": 9222,
        "cdpUrl": "ws://127.0.0.1:9222"
      }
    }
  }
}
```

#### 5.6.2 浏览器工具特性

- **Accessibility Tree**：使用无障碍树而非像素坐标，更省 token、更可靠
- **Snapshots**：页面快照
- **Actions**：点击、输入、滚动等操作
- **Uploads**：文件上传支持
- **Profiles**：多配置文件管理

### 5.7 Canvas 操作

```bash
# A2UI 推送
openclaw nodes canvas a2ui push --node <id> --text "Hello from A2UI"

# 执行 JavaScript
openclaw nodes invoke --node "<Node Name>" --command canvas.eval \
  --params '{"code":"console.log(\"Hello World\");"}'

# 截图
openclaw nodes invoke --node "<Node Name>" --command canvas.snapshot

# 导航
openclaw nodes invoke --node "<Node Name>" --command canvas.navigate \
  --params '{"url":"https://example.com"}'
```

---

## 六、Skills 技能系统

### 6.1 技能架构

OpenClaw 使用 **AgentSkills 兼容** 的技能文件夹格式，遵循 Anthropic 定义的 Agent Skill 开放标准：

```
skill-name/
├── SKILL.md        # 包含 YAML frontmatter 和指令
├── scripts/        # 可执行脚本
└── resources/      # 资源文件
```

### 6.2 技能生命周期

1. **发现**：启动时扫描技能目录
2. **注入**：符合条件的技能通过 `formatSkillsForPrompt` 注入系统提示
3. **热重载**：skills watcher 启用时支持运行时刷新
4. **跨节点**：Linux Gateway 可使用 macOS 节点上的 macOS-only 技能

### 6.3 技能生态

| 平台 | 说明 |
|------|------|
| **ClawdHub** | 官方技能注册中心（clawdhub.com） |
| **GitHub openclaw/skills** | 官方技能仓库存档 |
| **awesome-openclaw-skills** | 社区精选技能列表（700+ 技能） |

**热门技能类别：**
- 文件管理与自动化
- Web 浏览与数据抓取
- 日历与邮件管理
- 社交媒体集成
- 智能家居控制
- 编码辅助（coding-agent、pi-orchestration）
- 深度研究（research skill 使用 Gemini CLI）
- MCP 集成（mcporter、atlassian-mcp、deepwiki）

---

## 七、模型提供商支持

### 7.1 内置支持的提供商

| 提供商 | 模型示例 | 认证方式 |
|--------|----------|----------|
| **Anthropic** | claude-opus-4-5, claude-sonnet-4.5 | API Key / OAuth |
| **OpenAI** | gpt-4, gpt-4-turbo | API Key |
| **Google** | gemini-pro-1.5 | API Key |
| **OpenRouter** | openrouter/auto（自动选择最优模型） | API Key |
| **Ollama** | llama-4, mixtral（本地） | 自动检测 |
| **LM Studio** | 本地模型 | 本地 API |

### 7.2 自定义提供商配置

支持 OpenAI/Anthropic 兼容的自定义端点：

```json
{
  "models": {
    "providers": {
      "moonshot": {
        "baseUrl": "https://api.moonshot.ai/v1",
        "apiKey": "${MOONSHOT_API_KEY}",
        "api": "openai-completions",
        "models": [{"id": "kimi-k2.5", "name": "Kimi K2.5"}]
      }
    }
  }
}
```

---

## 八、安全架构与风险分析

### 8.1 官方安全立场

> "There is no 'perfectly secure' setup." — OpenClaw 官方文档

OpenClaw 明确承认安全是配置选项而非内置保证，这需要用户具备安全意识。

### 8.2 已知安全风险

| 风险类型 | 描述 | 严重程度 |
|----------|------|----------|
| **Prompt Injection** | 恶意消息操纵模型执行不安全操作 | 高 |
| **RCE（远程代码执行）** | CVE-2025-6514 (mcp-remote) 等漏洞 | 高 |
| **暴露的 Gateway** | 安全研究发现 42,000+ 实例公开暴露 | 高 |
| **凭证明文存储** | 默认配置下凭证存储在本地文件中 | 中 |
| **恶意技能** | 第三方技能可能泄露数据或执行恶意代码 | 中 |

### 8.3 安全缓解措施

#### 8.3.1 Gateway 认证

```json
{
  "gateway": {
    "auth": {
      "token": "your-secure-token",
      "password": "your-secure-password"
    }
  }
}
```

- 默认强制认证（fail-closed）
- onboard wizard 自动生成 token

#### 8.3.2 Docker 沙箱隔离

```bash
# 推荐的 Docker 安全配置
docker run -d \
  --name openclaw \
  --user nonroot \
  --cap-drop=ALL \
  --read-only \
  --security-opt="no-new-privileges:true" \
  --security-opt seccomp=default.json \
  -v /path/to/config:/config:ro \
  openclaw/openclaw
```

**关键安全配置：**
- 非 root 用户运行
- 删除所有 capabilities
- 只读文件系统
- seccomp/AppArmor 配置文件
- 禁止挂载敏感目录（Docker socket、主文件系统）

#### 8.3.3 工具策略控制

- **allow/deny 列表**：细粒度控制可用工具
- **sandbox 模式**：非主会话工具执行隔离在 Docker
- **渠道策略差异化**：不同消息渠道可配置不同权限

### 8.4 安全最佳实践

1. **永远不要在个人主机上直接运行** — 使用 VPS 或 Docker 隔离
2. **启用 Gateway 认证** — 确保 token/password 已配置
3. **使用 Tailscale/VPN** — 避免直接暴露到公网
4. **定期轮换凭证** — gateway token、API keys、channel tokens
5. **最小权限原则** — 仅启用必需的工具和技能
6. **监控和审计** — 定期检查 Gateway 日志和会话记录
7. **运行 security audit**：`openclaw security audit --fix`

---

## 九、部署方案详解

### 9.1 方案 A：本地安装（推荐用于开发/测试）

```bash
# 1. 安装 CLI（需要 Node.js ≥22）
npm install -g openclaw@latest

# 2. 运行 Onboarding Wizard
openclaw onboard --install-daemon

# 3. 验证状态
openclaw gateway status

# 4. 访问控制台
open http://127.0.0.1:18789/
```

### 9.2 方案 B：Docker 部署（推荐用于生产）

```bash
# 克隆仓库
git clone https://github.com/openclaw/openclaw.git
cd openclaw

# 运行 Docker 安装脚本
./docker-setup.sh

# 或使用 docker-compose
docker-compose up -d
```

### 9.3 方案 C：云服务部署

| 平台 | 特点 | 参考成本 |
|------|------|----------|
| **DigitalOcean 1-Click** | 预配置安全规则、Docker 隔离 | $6/月起 |
| **Hetzner** | 性价比高，ARM 架构 | €4/月起 |
| **AWS EC2** | 灵活配置 | $10/月起 |
| **Cloudflare Moltworker** | Serverless 架构，Workers + R2 | $5/月起 |

### 9.4 方案 D：混合部署

```
┌──────────────────┐      ┌──────────────────┐
│  VPS/Cloud       │      │  Local Mac/PC    │
│  (Gateway)       │◄────►│  (Node)          │
│  低成本服务器      │      │  提供本地能力      │
└──────────────────┘      └──────────────────┘
```

**优势**：Gateway 运行在安全隔离的云环境，本地设备作为 Node 提供 UI/Camera/Browser 能力。

---

## 十、消息渠道集成

### 10.1 支持的渠道

| 渠道 | 配置方式 | 备注 |
|------|----------|------|
| WhatsApp | `openclaw channels login`（扫码） | 使用 Web 协议 |
| Telegram | Bot token 配置 | 支持群组 |
| Slack | OAuth / Bot token | 支持 Workspace |
| Discord | Bot token | 支持服务器 |
| Signal | Signal CLI | 需要注册号码 |
| iMessage | BlueBubbles / 原生 | 仅 macOS |
| Microsoft Teams | App 配置 | 企业环境 |
| Matrix | Homeserver 配置 | 去中心化 |
| WebChat | 内置 | 默认启用 |

### 10.2 渠道路由

```json
{
  "channels": {
    "routing": {
      "whatsapp": {
        "agent": "personal",
        "workspace": "main"
      },
      "slack:work-channel": {
        "agent": "work",
        "workspace": "work"
      }
    }
  }
}
```

---

## 十一、CLI 命令速查

```bash
# 安装与配置
openclaw onboard --install-daemon    # 引导安装
openclaw doctor                      # 诊断问题
openclaw update --channel stable     # 更新版本

# Gateway 管理
openclaw gateway status              # 查看状态
openclaw gateway --port 18789        # 启动 Gateway

# 模型管理
openclaw models list                 # 列出可用模型
openclaw models set <provider/model> # 设置默认模型
openclaw models auth login --provider anthropic  # 认证

# 消息渠道
openclaw channels login              # 登录渠道（扫码）
openclaw channels list               # 列出已连接渠道

# 代理交互
openclaw agent --message "任务描述"   # 发送任务
openclaw message send --to +xxx --message "内容"  # 发送消息

# Node 管理
openclaw nodes list                  # 列出节点
openclaw nodes location get --node <id>  # 获取位置
openclaw nodes camera snap --node <id>   # 拍照

# 安全
openclaw security audit --fix        # 安全审计
openclaw sandbox-explain             # 解释沙箱配置

# 会话管理
/status                              # 查看当前会话状态（模型、token、成本）
/compact                             # 手动触发压缩
/reset                               # 重置会话
```

---

## 十二、生态系统与社区

### 12.1 官方资源

| 资源 | 链接 |
|------|------|
| 官网 | https://openclaw.ai |
| 文档 | https://docs.openclaw.ai |
| GitHub | https://github.com/openclaw/openclaw |
| Discord | 官方社区 |
| ClawdHub | https://clawdhub.com（技能注册中心） |

### 12.2 衍生项目

| 项目 | 说明 |
|------|------|
| **Moltbook** | AI 代理社交网络（2026年1月） |
| **MoltHub** | Bot 能力市场 |
| **Lobster** | Workflow shell，将技能/工具组合成管道 |
| **Clawdinators** | 社区管理工具 |
| **onlycrabs.ai** | SOUL.md 注册中心（系统 lore 共享） |

### 12.3 托管服务

| 服务 | 提供商 | 特点 |
|------|--------|------|
| OpenClawd.ai | 官方合作 | 托管 Clawdbot，安全由基础设施层处理 |
| DigitalOcean 1-Click | DigitalOcean | 预配置安全 |
| Cloudflare Moltworker | Cloudflare | Serverless，$5/月 |

---

## 十三、与竞品对比

| 特性 | OpenClaw | Claude Code | GitHub Copilot | Open Interpreter |
|------|----------|-------------|----------------|------------------|
| 开源 | ✅ | ❌ | ❌ | ✅ |
| 本地部署 | ✅ | ❌ | ❌ | ✅ |
| 多渠道消息 | ✅ | ❌ | ❌ | ❌ |
| 后台运行 | ✅ | ❌ | ❌ | ❌ |
| 模型无关 | ✅ | ❌ (Claude) | ❌ (GPT) | ✅ |
| 技能系统 | ✅ | ✅ | ❌ | 插件 |
| 设备能力 | ✅ | ❌ | ❌ | 有限 |
| MCP 支持 | ✅ (via mcporter) | 原生 | ❌ | 有限 |
| 持久记忆 | ✅ | 有限 | ❌ | ❌ |

---

## 十四、已知限制与注意事项

### 14.1 技术限制

1. **Node.js 版本要求**：需要 Node.js ≥22
2. **Windows 支持**：仅通过 WSL2 支持
3. **内存需求**：建议 ≥2GB RAM（最低 512MB-1GB）
4. **iOS 后台限制**：Canvas/Camera 命令需要前台运行

### 14.2 使用注意

1. **ToS 风险**：使用第三方工具（OpenClaw、OpenCode、Cline）配合 Claude Pro/Max 可能违反 Anthropic ToS，存在封号风险
2. **成本控制**：定时任务和自动化可能导致 LLM token 费用快速增长
3. **安全责任**：OpenClaw 不适合处理高价值个人账户或生产系统
4. **技能质量**：第三方技能可能存在漏洞或恶意代码

---

## 十五、总结与建议

### 15.1 适用场景

✅ **推荐使用**：
- 开发者测试和学习 AI 代理技术
- 非关键任务自动化（文件整理、信息汇总）
- 隔离环境中的生产力工具实验
- 技术爱好者的个人项目

⚠️ **谨慎使用**：
- 处理敏感数据或凭证
- 连接到生产系统
- 作为唯一的任务执行渠道

❌ **不建议使用**：
- 高安全要求的企业环境
- 财务或医疗等关键领域
- 缺乏技术背景的普通用户

### 15.2 部署建议

| 用途 | 推荐方案 |
|------|----------|
| 学习/测试 | 本地安装 + 沙箱 |
| 个人生产力 | Docker + VPS + Tailscale |
| 团队使用 | 云托管服务（DigitalOcean/OpenClawd） |

### 15.3 未来展望

OpenClaw 代表了 AI 代理从"说话"到"做事"的范式转变。尽管存在安全挑战，但其开源、本地优先的设计理念在隐私意识日益增强的环境中具有重要价值。随着社区成熟和安全实践完善，OpenClaw 有望成为个人 AI 助理领域的重要开源选择。

---

## 参考来源

| # | 来源 | 类型 | 可信度 |
|---|------|------|--------|
| 1 | [OpenClaw 官网](https://openclaw.ai/) | 官方 | 高 |
| 2 | [OpenClaw GitHub](https://github.com/openclaw/openclaw) | 官方 | 高 |
| 3 | [OpenClaw 文档](https://docs.openclaw.ai/) | 官方 | 高 |
| 4 | [Wikipedia - OpenClaw](https://en.wikipedia.org/wiki/OpenClaw) | 百科 | 中-高 |
| 5 | [DigitalOcean OpenClaw 指南](https://www.digitalocean.com/community/tutorials/how-to-run-openclaw) | 教程 | 中-高 |
| 6 | [Pulumi 部署指南](https://www.pulumi.com/blog/deploy-openclaw-aws-hetzner/) | 教程 | 中-高 |
| 7 | [IBM Think - OpenClaw 分析](https://www.ibm.com/think/news/clawdbot-ai-agent-testing-limits-vertical-integration) | 分析 | 中-高 |
| 8 | [Cisco Security Blog](https://blogs.cisco.com/ai/personal-ai-agents-like-openclaw-are-a-security-nightmare) | 安全分析 | 高 |
| 9 | [Composio 安全指南](https://composio.dev/blog/secure-openclaw-moltbot-clawdbot-setup) | 安全教程 | 中-高 |
| 10 | [AIMultiple 研究](https://research.aimultiple.com/moltbot/) | 研究 | 中 |
| 11 | [Medium 安全研究](https://maordayanofficial.medium.com/the-sovereign-ai-security-crisis-42-000-exposed-openclaw-instances) | 安全研究 | 中 |
| 12 | [CNET 报道](https://www.cnet.com/tech/services-and-software/from-clawdbot-to-moltbot-to-openclaw/) | 媒体 | 中 |
| 13 | [OpenRouter 集成文档](https://openrouter.ai/docs/guides/guides/openclaw-integration) | 官方 | 高 |
| 14 | [VoltAgent awesome-openclaw-skills](https://github.com/VoltAgent/awesome-openclaw-skills) | 社区 | 中 |
| 15 | [Pi Agent 博客 - Armin Ronacher](https://lucumr.pocoo.org/2026/1/31/pi/) | 技术博客 | 高 |
| 16 | [Pi Coding Agent - Mario Zechner](https://mariozechner.at/posts/2025-11-30-pi-coding-agent/) | 技术博客 | 高 |
| 17 | [1Password OpenClaw 分析](https://1password.com/blog/its-openclaw) | 安全分析 | 高 |
| 18 | [Dev.to OpenClaw 教程](https://dev.to/mechcloud_academy/unleashing-openclaw-the-ultimate-guide-to-local-ai-agents-for-developers-in-2026-3k0h) | 教程 | 中 |

---

#OpenClaw #调研 #2026 #AI代理 #本地优先 #开源 #AgentArchitecture #ContextManagement #Tools
