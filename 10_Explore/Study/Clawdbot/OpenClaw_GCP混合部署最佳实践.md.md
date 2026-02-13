# OpenClaw GCP 混合部署最佳实践

  

> **架构方案**: GCP 云端 Gateway + 家庭本地 Node（个人数据 API）+ Discord 移动入口

>

> 编写时间：2026年2月

>

> 基于 [OpenClaw 深度调研报告](./OpenClaw深度调研报告_2026年2月.md) 整理

  

---

  

## 目录

  

1. [项目概述与演进历史](#一项目概述与演进历史)

2. [目标与定位](#二目标与定位)

3. [整体技术架构详解](#三整体技术架构详解)

4. [安全与风险分析](#四安全与风险分析)

5. [部署最佳实践教程](#五部署最佳实践教程)

  

---

  

## 一、项目概述与演进历史

  

### 1.1 什么是 OpenClaw

  

OpenClaw 是一款**开源的自托管个人 AI 助理**，由奥地利开发者 Peter Steinberger 于 2025 年底创建。与传统聊天机器人不同，OpenClaw 是一个能够**执行实际任务**的自主代理——它可以运行 shell 命令、管理文件、控制浏览器、安排日程，并通过你常用的消息应用与你交互。

  

**核心特性：**

- 🦞 **本地优先**：运行在你自己的设备上，数据不离开你的控制

- 🔌 **多渠道整合**：统一接入 Discord、WhatsApp、Telegram、Slack 等 10+ 消息平台

- 🤖 **代理驱动**：不只是回答问题，而是执行任务

- 🔄 **持续运行**：24/7 后台运行，支持定时任务和主动通知

- 🧩 **模型无关**：支持 Claude、GPT、Gemini 或本地模型（Ollama）

  

### 1.2 演进历程

  

```text

  

2025年11月 2025年12月 2026年1月 2026年1月末

│ │ │ │

▼ ▼ ▼ ▼

┌─────────┐ ┌──────────┐ ┌────────────────┐ ┌───────────┐

│Clawdbot │────►│获得关注 │─────►│病毒式传播 │───►│ OpenClaw │

│ 发布 │ │(Claude │ │72h 60K+ stars │ │ 定名 │

└─────────┘ │ Code后) │ │Anthropic商标 │ │100K+stars │

└──────────┘ │请求→Moltbot │ └───────────┘

└────────────────┘

```

  

| 时间节点 | 事件 | 意义 |

|----------|------|------|

| 2025年11月 | Clawdbot 公开发布 | 项目诞生 |

| 2025年12月 | Claude Code 发布后开始获得关注 | 开发者社区认可 |

| 2026年1月24-27日 | 72小时内获得 60,000+ GitHub stars | 病毒式传播 |

| 2026年1月 | 因 Anthropic 商标请求更名为 Moltbot | 合规调整 |

| 2026年1月末 | 最终定名 OpenClaw，累计 100K+ stars | 身份稳定 |

| 2026年1月31日 | OpenClawd.ai 推出托管服务 | 生态成熟 |

  

### 1.3 创始人背景

  

Peter Steinberger 是一位奥地利开发者，此前以约 **1.19 亿美元**将其公司 PSPDFKit 出售给 Insight Partners。这一背景为项目提供了可信度和持续维护的保障。

  

---

  

## 二、目标与定位

  

### 2.1 本方案的目标

  

构建一个**安全、实用、可扩展**的个人 AI 助理系统：

  

```text

  

┌─────────────────────────────────────────────────────────────────────┐

│ 设计目标 │

├─────────────────────────────────────────────────────────────────────┤

│ ✅ 安全隔离 Gateway 运行在 GCP 云端，与个人数据物理隔离 │

│ ✅ 数据主权 个人数据保留在家庭本地服务器，按需授权访问 │

│ ✅ 随时随地 通过 Discord 移动端随时与 AI 助理交互 │

│ ✅ 成本可控 GCP e2-small 约 $15/月 + 家庭服务器零额外成本 │

│ ✅ 隐私保护 Tailscale 私有网络，不暴露公网端口 │

└─────────────────────────────────────────────────────────────────────┘

```

  

### 2.2 适用场景

  

| 场景 | 描述 |

|------|------|

| **个人知识管理** | 让 AI 助理访问你的笔记、文档、代码库并回答问题 |

| **生活自动化** | 通过 Discord 安排日程、管理任务、发送提醒 |

| **文件检索** | "帮我找到上周那份关于项目预算的 PDF" |

| **跨设备同步** | 在手机上发起任务，AI 在家庭服务器上执行 |

| **隐私敏感操作** | 处理个人财务、健康记录等敏感数据 |

  

### 2.3 为什么选择这个架构

  

| 架构选择 | 原因 |

|----------|------|

| **GCP 运行 Gateway** | 高可用、24/7 在线、与个人数据隔离、全球网络加速 |

| **家庭服务器作为 Node** | 数据主权、零数据传输成本、利用现有硬件 |

| **Discord 作为入口** | 跨平台、移动端体验好、支持 Bot API、免费 |

| **Tailscale 连接** | 零配置 VPN、端到端加密、NAT 穿透、无需公网 IP |

  

---

  

## 三、整体技术架构详解

  

### 3.1 架构总览

  

```text

  
  

┌─────────────────┐

│ Discord │

│ (移动/桌面) │

└────────┬────────┘

│ Bot API

▼

┌────────────────────────────────────────────────────────────────────┐

│ Google Cloud Platform │

│ ┌──────────────────────────────────────────────────────────────┐ │

│ │ GCP Compute Engine │ │

│ │ (e2-small) │ │

│ │ ┌────────────────────────────────────────────────────────┐ │ │

│ │ │ OpenClaw Gateway (Docker) │ │ │

│ │ │ │ │ │

│ │ │ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ │ │ │

│ │ │ │ Pi Agent │ │ WebSocket │ │ Control UI │ │ │ │

│ │ │ │ (AI 推理) │ │ Server │ │ (管理面板) │ │ │ │

│ │ │ └─────────────┘ └─────────────┘ └─────────────┘ │ │ │

│ │ │ │ │ │ │ │ │

│ │ │ └────────────────┴────────────────┘ │ │ │

│ │ │ │ │ │ │

│ │ │ ws://127.0.0.1:18789 │ │ │

│ │ └────────────────────────────────────────────────────────┘ │ │

│ │ │ │ │

│ │ Tailscale Serve │ │

│ └─────────────────────────────┼────────────────────────────────┘ │

└────────────────────────────────┼───────────────────────────────────┘

│

Tailscale VPN

(端到端加密)

│

┌────────────────────────────────┼────────────────────────────────────┐

│ 家庭网络 │

│ ┌─────────────────────────────┴────────────────────────────────┐ │

│ │ 家庭服务器 (Home Node) │ │

│ │ │ │

│ │ ┌─────────────────────────────────────────────────────────┐ │ │

│ │ │ OpenClaw Node Host │ │ │

│ │ │ │ │ │

│ │ │ ┌──────────────┐ ┌──────────────┐ ┌──────────────┐ │ │ │

│ │ │ │ system.run │ │ file.read │ │ Personal │ │ │ │

│ │ │ │ (命令执行) │ │ file.write │ │ Data API │ │ │ │

│ │ │ └──────────────┘ └──────────────┘ └──────────────┘ │ │ │

│ │ │ │ │ │

│ │ │ ┌──────────────────────────────────────────────────┐ │ │ │

│ │ │ │ 个人数据目录 │ │ │ │

│ │ │ │ ~/Documents ~/Notes ~/Projects ~/Photos │ │ │ │

│ │ │ └──────────────────────────────────────────────────┘ │ │ │

│ │ └────────────────────────────────────────────────────────┘ │ │

│ └─────────────────────────────────────────────────────────────┘ │

└───────────────────────────────────────────────────────────────────┘

```

  

### 3.2 组件职责说明

  

#### 3.2.1 GCP Gateway（云端控制平面）

  

| 组件 | 职责 |

|------|------|

| **Gateway 进程** | 长驻服务，管理会话、路由消息、协调工具执行 |

| **Pi Agent** | AI 推理引擎，调用 LLM API（Anthropic/OpenAI/OpenRouter） |

| **WebSocket Server** | 统一控制平面，Node 和客户端通过 WS 连接 |

| **Discord Channel** | 接收 Discord Bot 消息，路由到 Agent |

| **Control UI** | Web 管理面板，配置、监控、日志查看 |

  

**不存储的内容：**

- ❌ 个人文件和数据

- ❌ 敏感凭证（通过 Secret Manager 管理）

- ❌ 长期对话历史（可选持久化到家庭 Node）

  

#### 3.2.2 Home Node（家庭服务器）

  

| 组件 | 职责 |

|------|------|

| **Node Host** | 连接 Gateway，暴露本地能力 |

| **system.run** | 受控命令执行（白名单机制） |

| **file.read/write** | 文件系统访问（限定目录） |

| **Personal Data API** | 自定义 Skill 提供结构化数据访问 |

  

**存储的内容：**

- ✅ 所有个人文档、笔记、项目

- ✅ 对话历史（可选）

- ✅ 敏感配置和凭证

- ✅ 本地数据库（SQLite/JSON）

  

#### 3.2.3 Discord（移动入口）

  

| 功能 | 说明 |

|------|------|

| **DM 对话** | 与 Bot 私聊，一对一交互 |

| **服务器频道** | 在特定频道 @bot 触发 |

| **斜杠命令** | `/ask`、`/search`、`/remind` 等快捷操作 |

| **移动通知** | 任务完成、定时提醒推送到手机 |

  

### 3.3 数据流详解

  

```text

  

┌─────────────────────────────────────────────────────────────────────┐

│ 典型请求流程 │

│ │

│ 用户 (Discord) │

│ │ │

│ │ 1. "帮我找到上周的会议记录" │

│ ▼ │

│ Discord Bot API ──────────────────────────────────────────────────│

│ │ │

│ │ 2. 消息路由到 Gateway │

│ ▼ │

│ GCP Gateway │

│ │ │

│ │ 3. Pi Agent 分析意图，决定调用 Home Node │

│ ▼ │

│ Pi Agent ─────► LLM API (Anthropic Claude) │

│ │ │ │

│ │ │ 4. 返回工具调用决策 │

│ │ │ tool: "file.search" │

│ │ │ params: {pattern: "*会议*", date: "7d"} │

│ ◄──────────────┘ │

│ │ │

│ │ 5. 通过 Tailscale 调用 Home Node │

│ ▼ │

│ Home Node (via Tailscale) │

│ │ │

│ │ 6. 执行文件搜索，返回结果 │

│ │ files: ["会议记录_0125.md", "会议记录_0128.md"] │

│ ▼ │

│ GCP Gateway │

│ │ │

│ │ 7. Agent 整理结果，生成回复 │

│ ▼ │

│ Discord Bot API │

│ │ │

│ │ 8. "找到2份会议记录：..." │

│ ▼ │

│ 用户 (Discord) │

└─────────────────────────────────────────────────────────────────────┘

```

  

### 3.4 WebSocket 协议

  

Gateway 与 Node 之间的通信基于 JSON over WebSocket：

  

```json

// Node 连接握手

{

"type": "connect",

"role": "node",

"nodeId": "home-server",

"token": "node_auth_token",

"capabilities": ["system.run", "file.read", "file.write", "file.search"]

}

  

// Gateway 调用 Node

{

"type": "node.invoke",

"nodeId": "home-server",

"command": "file.search",

"params": {

"pattern": "*会议*",

"path": "~/Documents",

"maxAge": "7d"

},

"requestId": "req_abc123"

}

  

// Node 返回结果

{

"type": "node.response",

"requestId": "req_abc123",

"success": true,

"data": {

"files": [

{"path": "~/Documents/会议记录_0125.md", "size": 2048},

{"path": "~/Documents/会议记录_0128.md", "size": 1536}

]

}

}

```

  

### 3.5 Tailscale 网络拓扑

  

```

┌─────────────────────────────────────────────────────────────────┐

│ Tailscale Tailnet │

│ (私有虚拟网络 100.x.x.x) │

│ │

│ ┌─────────────────┐ ┌─────────────────┐ │

│ │ GCP Instance │ │ Home Server │ │

│ │ 100.64.0.1 │◄────────────►│ 100.64.0.2 │ │

│ │ │ WireGuard │ │ │

│ │ Gateway │ Encrypted │ Node Host │ │

│ └─────────────────┘ └─────────────────┘ │

│ │ │ │

│ │ Tailscale Serve │ │

│ │ (HTTPS proxy) │ │

│ ▼ │ │

│ https://gcp-gateway.tail1234.ts.net │ │

│ │ │

│ ┌─────────────────┐ │ │

│ │ Mobile Phone │ │ │

│ │ 100.64.0.3 │─────────────────────--┘ │

│ │ (可选) │ │

│ └─────────────────┘ │

└─────────────────────────────────────────────────────────────────┘

```

  

**Tailscale 关键特性：**

- **NAT 穿透**：家庭服务器无需公网 IP 或端口转发

- **端到端加密**：WireGuard 协议，流量全程加密

- **身份认证**：设备绑定 Tailscale 账户，自动认证

- **Serve/Funnel**：安全暴露服务，无需开放防火墙

  

---

  

## 四、安全与风险分析

  

### 4.1 威胁模型

  

```text

  

┌─────────────────────────────────────────────────────────────────┐

│ 威胁来源 │

├─────────────────────────────────────────────────────────────────┤

│ │

│ ┌──────────────┐ ┌──────────────┐ ┌──────────────┐ │

│ │ 外部攻击者 │ │ 恶意输入 │ │ 供应链攻击 │ │

│ │ │ │ (Prompt │ │ (恶意 Skill) │ │

│ │ 尝试直接 │ │ Injection) │ │ │ │

│ │ 访问Gateway │ │ │ │ │ │

│ └──────┬───────┘ └──────┬───────┘ └──────┬───────┘ │

│ │ │ │ │

│ ▼ ▼ ▼ │

│ ┌─────────────────────────────────────────────────────────┐ │

│ │ 攻击面 │ │

│ ├─────────────────────────────────────────────────────────┤ │

│ │ • Gateway 端口暴露 (已缓解: Tailscale Serve) │ │

│ │ • Discord Bot Token 泄露 │ │

│ │ • LLM API Key 泄露 │ │

│ │ • Prompt Injection 导致非授权操作 │ │

│ │ • 恶意 Skill 执行任意代码 │ │

│ │ • Home Node 被入侵导致数据泄露 │ │

│ └─────────────────────────────────────────────────────────┘ │

└─────────────────────────────────────────────────────────────────┘

```

  

### 4.2 风险矩阵

  

| 风险 | 可能性 | 影响 | 缓解措施 |

|------|--------|------|----------|

| **Gateway 公网暴露** | 低 | 高 | Tailscale Serve，不开放公网端口 |

| **Prompt Injection** | 中 | 高 | 工具白名单、执行审批、沙箱隔离 |

| **API Key 泄露** | 低 | 中 | GCP Secret Manager、环境变量注入 |

| **Discord Token 泄露** | 低 | 中 | 定期轮换、最小权限 Bot |

| **恶意 Skill** | 中 | 高 | 仅使用官方/审核过的 Skill |

| **Home Node 入侵** | 低 | 高 | Tailscale ACL、命令白名单、目录限制 |

| **LLM 提供商数据泄露** | 低 | 中 | 敏感操作本地处理，谨慎发送内容 |

  

### 4.3 安全架构设计

  

```text

  

┌─────────────────────────────────────────────────────────────────┐

│ 安全防护层次 │

├─────────────────────────────────────────────────────────────────┤

│ │

│ Layer 1: 网络隔离 │

│ ┌─────────────────────────────────────────────────────────┐ │

│ │ • Gateway 绑定 127.0.0.1，不直接暴露 │ │

│ │ • Tailscale Serve 代理访问，自动 HTTPS │ │

│ │ • Home Node 无公网 IP，仅 Tailscale 可达 │ │

│ │ • GCP 防火墙仅允许 Tailscale 和 SSH (可选) │ │

│ └─────────────────────────────────────────────────────────┘ │

│ │

│ Layer 2: 认证授权 │

│ ┌─────────────────────────────────────────────────────────┐ │

│ │ • Gateway auth token（fail-closed） │ │

│ │ • Node pairing approval（显式配对） │ │

│ │ • Discord DM pairing（私聊需认证） │ │

│ │ • Tailscale 身份验证（设备+用户双因素） │ │

│ └─────────────────────────────────────────────────────────┘ │

│ │

│ Layer 3: 执行控制 │

│ ┌─────────────────────────────────────────────────────────┐ │

│ │ • Exec Approvals（命令执行审批/白名单） │ │

│ │ • 工具 allow/deny 列表 │ │

│ │ • 文件访问目录限制（chroot-like） │ │

│ │ • Docker 沙箱隔离（Gateway 层） │ │

│ └─────────────────────────────────────────────────────────┘ │

│ │

│ Layer 4: 监控审计 │

│ ┌─────────────────────────────────────────────────────────┐ │

│ │ • GCP Cloud Logging（Gateway 日志） │ │

│ │ • 命令执行历史记录 │ │

│ │ • Tailscale 连接日志 │ │

│ │ • 定期安全审计：openclaw security audit │ │

│ └─────────────────────────────────────────────────────────┘ │

└────────────────────────────────────────────────────────────────┘

```

  

### 4.4 安全配置清单

  

#### Gateway 安全配置 (GCP)

  

```json

// ~/.openclaw/openclaw.json

{

"gateway": {

"auth": {

"token": "${GATEWAY_AUTH_TOKEN}", // 从 Secret Manager 注入

"password": "${GATEWAY_PASSWORD}"

},

"bind": "127.0.0.1", // 仅本地绑定

"port": 18789

},

"agent": {

"model": "anthropic/claude-sonnet-4-5"

},

"exec": {

"approvals": {

"security": "deny", // Gateway 不执行本地命令

"allowlist": []

}

},

"tools": {

"deny": ["exec", "process", "browser"] // Gateway 禁用高危工具

}

}

```

  

#### Home Node 安全配置

  

```json

// ~/.openclaw/node-config.json

{

"node": {

"id": "home-server",

"capabilities": ["file.read", "file.write", "file.search", "system.run"]

},

"exec": {

"approvals": {

"security": "allowlist",

"allowlist": [

"ls", "cat", "head", "tail", "grep", "find",

"wc", "sort", "uniq", "date", "pwd"

],

"denylist": [

"rm -rf", "sudo", "chmod 777", "curl | bash",

"wget -O- | sh", "eval", "exec"

]

}

},

"files": {

"allowedPaths": [

"~/Documents",

"~/Notes",

"~/Projects",

"~/Downloads"

],

"deniedPaths": [

"~/.ssh",

"~/.gnupg",

"~/.config/openclaw/credentials",

"/etc",

"/var"

]

}

}

```

  

### 4.5 官方安全声明

  

> **"There is no 'perfectly secure' setup."** — OpenClaw 官方文档

  

请务必理解：

- OpenClaw 设计上强调功能优先，安全是**配置选项**而非内置保证

- 本方案通过架构隔离和严格配置来缓解风险

- 不建议用于处理高度敏感数据（金融、医疗等）

- 定期更新和安全审计是必要的持续工作

  

---

  

## 五、部署最佳实践教程

  

### 5.1 前置准备

  

#### 5.1.1 账户和工具

  

| 项目 | 要求 | 获取方式 |

|------|------|----------|

| **GCP 账户** | 启用计费 | https://console.cloud.google.com |

| **Tailscale 账户** | 免费版足够 | https://tailscale.com |

| **Discord 账户** | 创建 Bot | https://discord.com/developers |

| **Anthropic API** | Claude API Key | https://console.anthropic.com |

| **家庭服务器** | Linux/macOS，Node.js ≥22 | 现有设备 |

  

#### 5.1.2 安装 gcloud CLI

  

```bash

# macOS

brew install google-cloud-sdk

  

# Linux

curl https://sdk.cloud.google.com | bash

exec -l $SHELL

  

# 初始化

gcloud init

gcloud auth login

```

  

#### 5.1.3 创建 GCP 项目

  

```bash

# 创建项目

gcloud projects create openclaw-personal --name="OpenClaw Personal"

  

# 设置默认项目

gcloud config set project openclaw-personal

  

# 启用 Compute Engine API

gcloud services enable compute.googleapis.com

  

# 启用 Secret Manager API

gcloud services enable secretmanager.googleapis.com

```

  

### 5.2 Step 1: 设置 Tailscale

  

#### 5.2.1 创建 Tailscale 账户

  

1. 访问 https://tailscale.com 注册账户

2. 进入 Admin Console: https://login.tailscale.com/admin

  

#### 5.2.2 生成 Auth Key

  

```bash

# 在 Tailscale Admin Console 中:

# Settings → Keys → Generate auth key

#

# 选项:

# - Reusable: No (一次性使用更安全)

# - Ephemeral: No

# - Pre-authorized: Yes

# - Tags: tag:server (可选)

#

# 记录生成的 key: tskey-auth-xxxxx

```

  

#### 5.2.3 配置 ACL (可选但推荐)

  

在 Tailscale Admin Console → Access Controls 中添加：

  

```json

{

"acls": [

// 允许所有设备互相访问（简化版）

{"action": "accept", "src": ["*"], "dst": ["*:*"]},

// 或更严格的规则：

// {"action": "accept", "src": ["tag:server"], "dst": ["tag:server:*"]},

// {"action": "accept", "src": ["autogroup:member"], "dst": ["tag:server:18789"]}

],

"tagOwners": {

"tag:server": ["autogroup:admin"]

}

}

```

  

### 5.3 Step 2: 创建 Discord Bot

  

#### 5.3.1 创建 Application

  

1. 访问 https://discord.com/developers/applications

2. 点击 "New Application"

3. 命名：`OpenClaw Personal`

4. 进入 Bot 设置页面

  

#### 5.3.2 配置 Bot

  

```

# 在 Bot 页面:

  

1. 点击 "Reset Token" 生成 Bot Token

- 记录 Token: MTIzNDU2Nzg5... (仅显示一次!)

  

2. 启用 Privileged Gateway Intents:

☑️ MESSAGE CONTENT INTENT

☑️ SERVER MEMBERS INTENT (如需群组功能)

  

3. 在 OAuth2 → URL Generator:

- Scopes: bot, applications.commands

- Bot Permissions:

☑️ Send Messages

☑️ Read Message History

☑️ Use Slash Commands

☑️ Attach Files

☑️ Embed Links

```

  

#### 5.3.3 邀请 Bot 到服务器

  

1. 复制生成的 OAuth2 URL

2. 在浏览器打开，选择你的服务器

3. 授权 Bot 加入

  

### 5.4 Step 3: 部署 GCP Gateway

  

#### 5.4.1 存储敏感凭证到 Secret Manager

  

```bash

# 创建 secrets

echo -n "your-anthropic-api-key" | \

gcloud secrets create anthropic-api-key --data-file=-

  

echo -n "your-discord-bot-token" | \

gcloud secrets create discord-bot-token --data-file=-

  

echo -n "your-gateway-auth-token" | \

gcloud secrets create gateway-auth-token --data-file=-

  

echo -n "tskey-auth-xxxxx" | \

gcloud secrets create tailscale-auth-key --data-file=-

  

# 验证

gcloud secrets list

```

  

#### 5.4.2 创建 VM 实例

  

```bash

# 创建实例

gcloud compute instances create openclaw-gateway \

--zone=asia-east1-a \

--machine-type=e2-small \

--boot-disk-size=30GB \

--boot-disk-type=pd-balanced \

--image-family=debian-12 \

--image-project=debian-cloud \

--tags=openclaw \

--metadata-from-file=startup-script=startup-script.sh \

--service-account=default \

--scopes=cloud-platform

```

  

#### 5.4.3 创建启动脚本 (startup-script.sh)

  

```bash

#!/bin/bash

set -e

  

# ============================================

# OpenClaw GCP Gateway Startup Script

# ============================================

  

LOG_FILE="/var/log/openclaw-setup.log"

exec > >(tee -a "$LOG_FILE") 2>&1

echo "=== OpenClaw Setup Started at $(date) ==="

  

# 1. 系统更新

apt-get update && apt-get upgrade -y

apt-get install -y curl git jq

  

# 2. 安装 Node.js 22

curl -fsSL https://deb.nodesource.com/setup_22.x | bash -

apt-get install -y nodejs

  

# 3. 安装 Docker

curl -fsSL https://get.docker.com | sh

systemctl enable docker

systemctl start docker

  

# 4. 安装 Tailscale

curl -fsSL https://tailscale.com/install.sh | sh

  

# 5. 获取 Secrets

TAILSCALE_KEY=$(gcloud secrets versions access latest --secret="tailscale-auth-key")

ANTHROPIC_KEY=$(gcloud secrets versions access latest --secret="anthropic-api-key")

DISCORD_TOKEN=$(gcloud secrets versions access latest --secret="discord-bot-token")

GATEWAY_TOKEN=$(gcloud secrets versions access latest --secret="gateway-auth-token")

  

# 6. 启动 Tailscale

tailscale up --authkey="$TAILSCALE_KEY" --hostname=openclaw-gateway

  

# 7. 创建 openclaw 用户

useradd -m -s /bin/bash openclaw || true

usermod -aG docker openclaw

  

# 8. 安装 OpenClaw

sudo -u openclaw bash << 'OPENCLAW_SETUP'

cd ~

npm install -g openclaw@latest

  

# 创建配置目录

mkdir -p ~/.openclaw

  

# 写入配置

cat > ~/.openclaw/openclaw.json << EOF

{

"gateway": {

"auth": {

"token": "${GATEWAY_TOKEN}"

},

"bind": "127.0.0.1",

"port": 18789

},

"agent": {

"model": "anthropic/claude-sonnet-4-5"

},

"channels": {

"discord": {

"enabled": true,

"token": "${DISCORD_TOKEN}",

"dmPolicy": "pairing"

}

},

"exec": {

"approvals": {

"security": "deny"

}

},

"tools": {

"deny": ["exec", "process"]

}

}

EOF

  

# 设置环境变量

cat > ~/.openclaw/.env << EOF

ANTHROPIC_API_KEY=${ANTHROPIC_KEY}

DISCORD_BOT_TOKEN=${DISCORD_TOKEN}

EOF

OPENCLAW_SETUP

  

# 9. 创建 systemd 服务

cat > /etc/systemd/system/openclaw-gateway.service << 'EOF'

[Unit]

Description=OpenClaw Gateway

After=network.target tailscaled.service

  

[Service]

Type=simple

User=openclaw

WorkingDirectory=/home/openclaw

EnvironmentFile=/home/openclaw/.openclaw/.env

ExecStart=/usr/bin/openclaw gateway --port 18789

Restart=always

RestartSec=10

  

[Install]

WantedBy=multi-user.target

EOF

  

# 10. 启动服务

systemctl daemon-reload

systemctl enable openclaw-gateway

systemctl start openclaw-gateway

  

# 11. 配置 Tailscale Serve

sleep 10 # 等待 Gateway 启动

tailscale serve --bg https+insecure://127.0.0.1:18789

  

echo "=== OpenClaw Setup Completed at $(date) ==="

```

  

#### 5.4.4 部署并验证

  

```bash

# 上传启动脚本并创建实例

gcloud compute instances create openclaw-gateway \

--zone=asia-east1-a \

--machine-type=e2-small \

--boot-disk-size=30GB \

--image-family=debian-12 \

--image-project=debian-cloud \

--metadata-from-file=startup-script=startup-script.sh \

--scopes=cloud-platform

  

# 等待 5-10 分钟，检查日志

gcloud compute ssh openclaw-gateway --zone=asia-east1-a --command="tail -100 /var/log/openclaw-setup.log"

  

# 检查服务状态

gcloud compute ssh openclaw-gateway --zone=asia-east1-a --command="systemctl status openclaw-gateway"

  

# 检查 Tailscale 状态

gcloud compute ssh openclaw-gateway --zone=asia-east1-a --command="tailscale status"

```

  

### 5.5 Step 4: 部署 Home Node

  

#### 5.5.1 在家庭服务器上安装 Tailscale

  

```bash

# Linux

curl -fsSL https://tailscale.com/install.sh | sh

sudo tailscale up --hostname=home-server

  

# macOS

brew install tailscale

tailscale up --hostname=home-server

```

  

#### 5.5.2 安装 OpenClaw Node

  

```bash

# 安装 Node.js 22+

# Ubuntu/Debian

curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -

sudo apt-get install -y nodejs

  

# macOS

brew install node@22

  

# 安装 OpenClaw

npm install -g openclaw@latest

```

  

#### 5.5.3 配置 Home Node

  

```bash

# 创建配置目录

mkdir -p ~/.openclaw

  

# 创建 Node 配置

cat > ~/.openclaw/node-config.json << 'EOF'

{

"node": {

"id": "home-server",

"name": "Home Server",

"gateway": "wss://openclaw-gateway.tail12345.ts.net",

"token": "your-gateway-auth-token"

},

"capabilities": {

"system.run": true,

"file.read": true,

"file.write": true,

"file.search": true

},

"exec": {

"approvals": {

"security": "allowlist",

"allowlist": [

"ls", "cat", "head", "tail", "grep", "find", "wc",

"sort", "uniq", "date", "pwd", "tree", "file",

"stat", "du -sh", "df -h"

]

}

},

"files": {

"allowedPaths": [

"~/Documents",

"~/Notes",

"~/Projects",

"~/Downloads",

"~/Pictures"

]

}

}

EOF

```

  

#### 5.5.4 创建自定义 Personal Data Skill

  

```bash

# 创建 Skill 目录

mkdir -p ~/.openclaw/skills/personal-data

  

# 创建 SKILL.md

cat > ~/.openclaw/skills/personal-data/SKILL.md << 'EOF'

---

name: personal-data

description: Access and search personal files and notes on the home server

version: 1.0.0

author: self

triggers:

- find my

- search for

- look for

- where is

tools:

- file.read

- file.search

- system.run

---

  

# Personal Data Access Skill

  

This skill provides access to personal files stored on the home server.

  

## Capabilities

  

- Search files by name or content

- Read document contents

- List directory contents

- Get file metadata

  

## Usage Examples

  

- "Find my tax documents from 2025"

- "Search for notes containing 'project ideas'"

- "What's in my Downloads folder?"

- "Read the meeting notes from last week"

  

## Security

  

- Only files in allowed directories are accessible

- No deletion or modification of system files

- All access is logged

EOF

  

# 创建辅助脚本

cat > ~/.openclaw/skills/personal-data/search.sh << 'EOF'

#!/bin/bash

# Search files by pattern

pattern="$1"

path="${2:-$HOME/Documents}"

find "$path" -type f -name "*$pattern*" 2>/dev/null | head -20

EOF

chmod +x ~/.openclaw/skills/personal-data/search.sh

```

  

#### 5.5.5 启动 Node Host

  

```bash

# 手动启动测试

openclaw node host --config ~/.openclaw/node-config.json --verbose

  

# 创建 systemd 服务 (Linux)

sudo cat > /etc/systemd/system/openclaw-node.service << 'EOF'

[Unit]

Description=OpenClaw Node Host

After=network.target tailscaled.service

  

[Service]

Type=simple

User=your-username

WorkingDirectory=/home/your-username

ExecStart=/usr/bin/openclaw node host --config /home/your-username/.openclaw/node-config.json

Restart=always

RestartSec=10

  

[Install]

WantedBy=multi-user.target

EOF

  

sudo systemctl daemon-reload

sudo systemctl enable openclaw-node

sudo systemctl start openclaw-node

  

# macOS launchd

cat > ~/Library/LaunchAgents/com.openclaw.node.plist << 'EOF'

<?xml version="1.0" encoding="UTF-8"?>

<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">

<plist version="1.0">

<dict>

<key>Label</key>

<string>com.openclaw.node</string>

<key>ProgramArguments</key>

<array>

<string>/usr/local/bin/openclaw</string>

<string>node</string>

<string>host</string>

</array>

<key>RunAtLoad</key>

<true/>

<key>KeepAlive</key>

<true/>

</dict>

</plist>

EOF

  

launchctl load ~/Library/LaunchAgents/com.openclaw.node.plist

```

  

### 5.6 Step 5: 配置 Discord 集成

  

#### 5.6.1 验证 Bot 连接

  

在 Discord 中向 Bot 发送私信：

  

```

你好，你能做什么？

```

  

如果收到回复，说明基础连接正常。

  

#### 5.6.2 配置 DM Pairing

  

首次私信时，需要完成配对：

  

```bash

# 在 GCP Gateway 上查看配对请求

gcloud compute ssh openclaw-gateway --zone=asia-east1-a \

--command="openclaw pairing list"

  

# 批准配对

gcloud compute ssh openclaw-gateway --zone=asia-east1-a \

--command="openclaw pairing approve discord <pairing-code>"

```

  

#### 5.6.3 配置服务器频道

  

在你的 Discord 服务器中创建 `#ai-assistant` 频道，然后配置 Gateway：

  

```bash

# SSH 到 GCP 实例

gcloud compute ssh openclaw-gateway --zone=asia-east1-a

  

# 编辑配置

nano ~/.openclaw/openclaw.json

```

  

添加频道配置：

  

```json

{

"channels": {

"discord": {

"enabled": true,

"token": "${DISCORD_BOT_TOKEN}",

"dmPolicy": "pairing",

"guilds": {

"*": {

"requireMention": true

},

"your-server-id": {

"allowFrom": ["*"],

"channels": {

"ai-assistant": {

"requireMention": false,

"skills": ["personal-data"],

"systemPrompt": "You are a helpful personal assistant with access to the user's home server files."

}

}

}

}

}

}

}

```

  

重启 Gateway：

  

```bash

sudo systemctl restart openclaw-gateway

```

  

### 5.7 Step 6: 验证完整系统

  

#### 5.7.1 测试基础对话

  

在 Discord 私信中：

  

```

你好，现在几点了？

```

  

#### 5.7.2 测试 Home Node 连接

  

```

我的 home-server 节点在线吗？

```

  

#### 5.7.3 测试文件访问

  

```

帮我列出 Documents 文件夹的内容

```

  

```

搜索我最近修改的笔记文件

```

  

```

读取一下 ~/Documents/notes.md 的内容

```

  

#### 5.7.4 检查日志

  

```bash

# GCP Gateway 日志

gcloud compute ssh openclaw-gateway --zone=asia-east1-a \

--command="journalctl -u openclaw-gateway -f"

  

# Home Node 日志

journalctl -u openclaw-node -f # Linux

# 或

tail -f ~/.openclaw/logs/node.log

```

  

### 5.8 运维与监控

  

#### 5.8.1 定期安全审计

  

```bash

# 每周运行

openclaw security audit --fix

  

# 检查暴露的端口

gcloud compute ssh openclaw-gateway --zone=asia-east1-a \

--command="ss -tlnp"

```

  

#### 5.8.2 更新 OpenClaw

  

```bash

# GCP Gateway

gcloud compute ssh openclaw-gateway --zone=asia-east1-a --command="

sudo -u openclaw npm update -g openclaw@latest

sudo systemctl restart openclaw-gateway

"

  

# Home Node

npm update -g openclaw@latest

sudo systemctl restart openclaw-node # Linux

# 或

launchctl unload ~/Library/LaunchAgents/com.openclaw.node.plist

launchctl load ~/Library/LaunchAgents/com.openclaw.node.plist

```

  

#### 5.8.3 备份配置

  

```bash

# 备份 GCP 配置

gcloud compute ssh openclaw-gateway --zone=asia-east1-a --command="

tar -czf /tmp/openclaw-backup.tar.gz ~/.openclaw

"

gcloud compute scp openclaw-gateway:/tmp/openclaw-backup.tar.gz ./backup/ --zone=asia-east1-a

  

# 备份 Home Node 配置

tar -czf ~/openclaw-home-backup.tar.gz ~/.openclaw

```

  

#### 5.8.4 成本监控

  

```bash

# 查看 GCP 费用

gcloud billing accounts list

gcloud billing projects describe openclaw-personal

  

# 预估月费：

# - e2-small: ~$13/月

# - 30GB disk: ~$2/月

# - 网络出口: ~$1/月 (取决于使用量)

# - 总计: ~$16/月

```

  

### 5.9 故障排除

  

#### 常见问题

  

| 问题 | 可能原因 | 解决方案 |

|------|----------|----------|

| Discord Bot 无响应 | Token 错误或 Intent 未启用 | 检查 Token，启用 MESSAGE CONTENT INTENT |

| Home Node 离线 | Tailscale 断连 | 检查 `tailscale status`，重新认证 |

| 文件访问被拒 | 路径不在白名单 | 检查 `files.allowedPaths` 配置 |

| 命令执行失败 | 不在 allowlist | 添加命令到 `exec.approvals.allowlist` |

| Gateway 启动失败 | 端口冲突或配置错误 | 检查日志 `journalctl -u openclaw-gateway` |

  

#### 诊断命令

  

```bash

# Gateway 健康检查

curl http://127.0.0.1:18789/health

  

# Node 连接状态

openclaw nodes list

  

# Tailscale 诊断

tailscale status

tailscale ping openclaw-gateway # 从 Home Node

tailscale ping home-server # 从 GCP

  

# OpenClaw 诊断

openclaw doctor

```

  

---

  

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

"systemPrompt": "You are a helpful personal AI assistant. You have access to a home server with the user's personal files. Be concise and helpful."

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

"agents": {

"list": [

{

"id": "default",

"workspace": "~/.openclaw/workspace"

}

]

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

"nodes"

],

"deny": [

"exec",

"process",

"browser"

]

},

"nodes": {

"allowRemote": true

}

}

```

  

</details>

  

<details>

<summary>Home Node 完整配置 (~/.openclaw/node-config.json)</summary>

  

```json

{

"node": {

"id": "home-server",

"name": "Home Server",

"gateway": "wss://openclaw-gateway.tail12345.ts.net",

"token": "${GATEWAY_AUTH_TOKEN}"

},

"capabilities": {

"system.run": true,

"file.read": true,

"file.write": false,

"file.search": true,

"file.list": true

},

"exec": {

"approvals": {

"security": "allowlist",

"allowlist": [

"ls", "ls -la", "ls -lh",

"cat", "head", "head -n", "tail", "tail -n",

"grep", "grep -r", "grep -i",

"find", "find . -name", "find . -type",

"wc", "wc -l",

"sort", "uniq",

"date", "pwd",

"tree", "tree -L",

"file",

"stat",

"du -sh",

"df -h"

],

"denylist": [

"rm", "rmdir",

"mv", "cp",

"chmod", "chown",

"sudo", "su",

"curl", "wget",

"eval", "exec",

"bash -c", "sh -c",

"|", "&&", "||", ";", ">", ">>", "<"

]

}

},

"files": {

"allowedPaths": [

"~/Documents",

"~/Notes",

"~/Projects",

"~/Downloads",

"~/Pictures",

"~/Music"

],

"deniedPaths": [

"~/.ssh",

"~/.gnupg",

"~/.config",

"~/.local",

"~/.*",

"/etc",

"/var",

"/usr",

"/bin",

"/sbin"

],

"maxFileSize": "10MB",

"allowedExtensions": [

".txt", ".md", ".json", ".yaml", ".yml",

".pdf", ".doc", ".docx",

".xls", ".xlsx", ".csv",

".jpg", ".jpeg", ".png", ".gif",

".py", ".js", ".ts", ".go", ".rs",

".sh", ".bash"

]

},

"logging": {

"level": "info",

"file": "~/.openclaw/logs/node.log"

}

}

```

  

</details>

  

### B. 参考链接

  

| 资源 | 链接 |

|------|------|

| OpenClaw 官方文档 | https://docs.openclaw.ai |

| OpenClaw GitHub | https://github.com/openclaw/openclaw |

| GCP 部署文档 | https://docs.openclaw.ai/platforms/gcp |

| Discord 集成文档 | https://docs.openclaw.ai/channels/discord |

| Tailscale 文档 | https://docs.openclaw.ai/gateway/tailscale |

| Node 配置文档 | https://docs.openclaw.ai/nodes |

| 安全指南 | https://docs.openclaw.ai/gateway/security |

| Tailscale 官方 | https://tailscale.com/kb |

| Discord Developer | https://discord.com/developers/docs |

| GCP Compute Engine | https://cloud.google.com/compute/docs |

  

### C. 成本估算

  

| 项目 | 月费用（估算） |

|------|----------------|

| GCP e2-small | $13.00 |

| GCP 30GB SSD | $2.40 |

| GCP 网络出口 (1GB) | $0.12 |

| Tailscale (免费版) | $0.00 |

| Discord Bot | $0.00 |

| Anthropic Claude (按量) | $5-50 (取决于使用量) |

| **总计** | **~$20-70/月** |

  

---

  

#OpenClaw #GCP #Discord #Tailscale #最佳实践 #混合部署 #个人AI助理