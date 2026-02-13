# Heimdall - Discord Bot 架构方案

> **Heimdall**：北欧神话中的守护神，守卫彩虹桥 Bifröst，连接神域与人间。
> 本方案中，Heimdall 作为 Discord 与本地 API 服务之间的桥梁，守护并转发用户请求。

---

## 概述

| 项目 | 说明 |
|------|------|
| **目标** | 通过 Discord Slash Command 调用局域网内本地 API 服务 |
| **技术栈** | Python FastAPI + Cloudflare Tunnel |
| **交互模式** | HTTP Interactions Endpoint（无需 WebSocket 长连接） |
| **公网域名** | `heimdall.raylab.club` |
| **Python 环境** | Conda 虚拟环境 `heimdall` |

---

## 一、架构设计

### 1.1 数据流图

```text
┌─────────────────────────────────────────────────────────────────────────┐
│                              Discord 用户                                │
│                        输入: /ask question:"什么是AI?"                   │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                                    │ 用户触发 Slash Command
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                           Discord 服务器                                 │
│    • 验证命令格式，打包成 JSON Payload                                   │
│    • 添加签名头 X-Signature-Ed25519, X-Signature-Timestamp              │
│    • HTTP POST 到 Interactions Endpoint URL                             │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                       Cloudflare Edge Network                            │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  heimdall.raylab.club (公网域名, 自动 HTTPS)                     │    │
│  │                         │                                        │    │
│  │           Cloudflare Tunnel (cloudflared 出站连接)               │    │
│  └─────────────────────────┼───────────────────────────────────────┘    │
└────────────────────────────┼────────────────────────────────────────────┘
                             │
                             │ 穿透到本地局域网
                             ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                            本地局域网                                    │
│  ┌───────────────────────────────────────────────────────────────────┐  │
│  │              Heimdall FastAPI 服务 (localhost:8000)                │  │
│  │              Conda Env: heimdall | Python 3.11                     │  │
│  │                                                                    │  │
│  │  ┌─────────────────────────────────────────────────────────────┐  │  │
│  │  │ 中间件: Ed25519 签名验证 (PyNaCl)                            │  │  │
│  │  └─────────────────────────────────────────────────────────────┘  │  │
│  │                              │                                     │  │
│  │                              ▼                                     │  │
│  │  ┌─────────────────────────────────────────────────────────────┐  │  │
│  │  │ 路由: POST /interactions                                     │  │  │
│  │  │   • type=1 (PING) -> PONG                                    │  │  │
│  │  │   • type=2 (APPLICATION_COMMAND) -> 命令分发                 │  │  │
│  │  └─────────────────────────────────────────────────────────────┘  │  │
│  │                              │                                     │  │
│  │                              ▼                                     │  │
│  │  ┌─────────────────────────────────────────────────────────────┐  │  │
│  │  │ 命令处理器                                                    │  │  │
│  │  │   • /ask  -> 调用 AI 推理服务                                │  │  │
│  │  │   • /query -> 查询数据库                                      │  │  │
│  │  │   • /help -> 返回帮助信息                                     │  │  │
│  │  └─────────────────────────────────────────────────────────────┘  │  │
│  │                              │                                     │  │
│  │                              ▼                                     │  │
│  │  ┌─────────────────────────────────────────────────────────────┐  │  │
│  │  │ 业务服务层 (你现有的 API 逻辑)                                │  │  │
│  │  └─────────────────────────────────────────────────────────────┘  │  │
│  └───────────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────┘
                             │
                             │ HTTP Response (JSON)
                             ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                           Discord 服务器                                 │
│              显示: Heimdall: "AI 是人工智能的缩写..."                    │
└─────────────────────────────────────────────────────────────────────────┘
```

### 1.2 核心组件

| 组件 | 职责 |
|------|------|
| **Discord** | 用户入口，触发 Slash Command，发送 HTTP POST 请求 |
| **Cloudflare Tunnel** | 将 `heimdall.raylab.club` 反向代理到本地服务，提供 HTTPS |
| **Heimdall (FastAPI)** | 签名验证 + 命令路由 + 业务处理 + 响应格式化 |

### 1.3 为什么选择 HTTP Interactions 模式

| 特性 | Gateway (WebSocket) | HTTP Interactions |
|------|---------------------|-------------------|
| 连接方式 | 持久长连接 | 按需 HTTP 请求 |
| 运行要求 | 24/7 在线 | 仅在收到请求时运行 |
| 资源消耗 | 高 | 低 |
| 适用场景 | 需要实时事件 | Slash Commands / 按钮交互 |

**限制**：无法监听普通消息、用户加入/离开等 Gateway 事件。如需这些功能，需额外部署 Gateway Bot。

---

## 二、环境配置

### 2.1 Conda 虚拟环境

**环境已创建**：`heimdall` (Python 3.11)

```bash
# 激活环境
conda activate heimdall

# 查看环境
conda env list
```

**已安装依赖**：

| 包 | 版本 | 用途 |
|---|------|------|
| fastapi | 0.128.0 | Web 框架 |
| uvicorn | 0.40.0 | ASGI 服务器 |
| pydantic | 2.12.5 | 数据验证 |
| PyNaCl | 1.6.2 | Ed25519 签名验证 |
| httpx | 0.28.1 | 异步 HTTP 客户端 |
| python-dotenv | 1.2.1 | 环境变量管理 |

**requirements.txt**：
```txt
fastapi>=0.109.0
uvicorn[standard]>=0.27.0
pydantic>=2.5.0
pynacl>=1.5.0
httpx>=0.26.0
python-dotenv>=1.0.0
```

### 2.2 Linux 环境变量

Discord 凭证通过 **Linux 系统环境变量** 配置（非 .env 文件）：

```bash
# 添加到 ~/.bashrc 或 ~/.zshrc
export DISCORD_APPLICATION_ID="你的Application ID"
export DISCORD_PUBLIC_KEY="你的Public Key"
export DISCORD_BOT_TOKEN="你的Bot Token"

# 使配置生效
source ~/.bashrc
```

**验证环境变量**：
```bash
echo $DISCORD_APPLICATION_ID
echo $DISCORD_PUBLIC_KEY
echo $DISCORD_BOT_TOKEN
```

**Python 中读取**：
```python
import os

APPLICATION_ID = os.environ["DISCORD_APPLICATION_ID"]
PUBLIC_KEY = os.environ["DISCORD_PUBLIC_KEY"]
BOT_TOKEN = os.environ["DISCORD_BOT_TOKEN"]
```

### 2.3 Cloudflare Tunnel

**域名**: `heimdall.raylab.club`

**安装 cloudflared**：
```bash
# Linux (amd64)
curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o cloudflared
chmod +x cloudflared
sudo mv cloudflared /usr/local/bin/
```

**配置文件** (`~/.cloudflared/config.yml`)：
```yaml
tunnel: <TUNNEL_UUID>
credentials-file: /home/lenovo/.cloudflared/<TUNNEL_UUID>.json

ingress:
  - hostname: heimdall.raylab.club
    service: http://localhost:8000
  - service: http_status:404
```

**启动 Tunnel**：
```bash
cloudflared tunnel run <TUNNEL_NAME>
```

---

## 三、项目结构

```text
heimdall/
├── app/
│   ├── __init__.py
│   ├── main.py                    # FastAPI 入口
│   ├── config.py                  # 配置管理 (读取环境变量)
│   │
│   ├── middleware/
│   │   └── discord_verify.py      # Ed25519 签名验证
│   │
│   ├── routers/
│   │   └── interactions.py        # POST /interactions
│   │
│   ├── handlers/                  # 命令处理器
│   │   ├── __init__.py           # 命令注册表
│   │   ├── ask.py                # /ask 命令
│   │   ├── query.py              # /query 命令
│   │   └── help.py               # /help 命令
│   │
│   ├── services/                  # 业务逻辑
│   │   ├── ai_service.py
│   │   └── webhook.py            # Discord Webhook followup
│   │
│   ├── schemas/
│   │   └── discord.py            # Pydantic 模型
│   │
│   └── utils/
│       └── response.py           # 响应格式化
│
├── scripts/
│   └── register_commands.py       # 命令注册脚本
│
├── requirements.txt
└── README.md
```

---

## 四、Discord 配置

### 4.1 开发者门户配置

1. **创建 Application**: https://discord.com/developers/applications
2. **获取凭证** (设置为 Linux 环境变量):
   - `DISCORD_APPLICATION_ID` - Application ID
   - `DISCORD_PUBLIC_KEY` - Public Key (签名验证用)
   - `DISCORD_BOT_TOKEN` - Bot Token (创建 Bot 后获取)
3. **配置 Interactions Endpoint URL**:
   - 填入 `https://heimdall.raylab.club/interactions`
   - 需要服务运行并通过验证后才能保存
4. **邀请 Bot**:
   - OAuth2 > URL Generator
   - Scopes: `bot`, `applications.commands`
   - Permissions: `Send Messages`, `Use Slash Commands`

### 4.2 Slash Command 注册

通过 REST API 注册命令（一次性操作）：

| 类型 | API | 生效时间 |
|------|-----|---------|
| Guild | `PUT /applications/{app_id}/guilds/{guild_id}/commands` | 立即 |
| Global | `PUT /applications/{app_id}/commands` | 最长 1 小时 |

---

## 五、关键实现

### 5.1 Ed25519 签名验证

Discord 每个请求都带有签名头，必须验证：

```text
请求头:
  X-Signature-Ed25519: <signature>
  X-Signature-Timestamp: <timestamp>

验证流程:
1. message = timestamp + raw_body
2. 使用 DISCORD_PUBLIC_KEY 验证 signature
3. 通过 -> 处理请求
4. 失败 -> 返回 401
```

**注意**: Discord 会定期发送错误签名测试，必须正确返回 401，否则 Endpoint 会被禁用。

### 5.2 交互类型

| Type | 名称 | 处理方式 |
|------|------|---------|
| 1 | PING | 返回 `{"type": 1}` (PONG) |
| 2 | APPLICATION_COMMAND | 分发到命令处理器 |
| 3 | MESSAGE_COMPONENT | 处理按钮/下拉菜单 |
| 4 | AUTOCOMPLETE | 返回自动补全建议 |
| 5 | MODAL_SUBMIT | 处理模态框提交 |

### 5.3 响应类型

| Type | 名称 | 用途 |
|------|------|------|
| 1 | PONG | 响应 PING |
| 4 | CHANNEL_MESSAGE_WITH_SOURCE | 发送消息 |
| 5 | DEFERRED_CHANNEL_MESSAGE_WITH_SOURCE | 延迟响应 |
| 6 | DEFERRED_UPDATE_MESSAGE | 延迟更新 |
| 7 | UPDATE_MESSAGE | 更新原消息 |

### 5.4 延迟响应（处理耗时操作）

Discord 要求 **3 秒内**响应，超时显示"交互失败"。

处理耗时操作的流程：
```text
1. 收到命令 -> 立即返回 Type 5 (DEFERRED)
2. Discord 显示 "Heimdall 正在思考..."
3. 后台异步处理业务逻辑
4. 通过 Webhook 发送最终响应:
   POST https://discord.com/api/webhooks/{app_id}/{interaction_token}
   Body: { "content": "处理完成！结果是..." }
```

Followup 消息有 **15 分钟**时效限制。

---

## 六、启动服务

### 6.1 开发模式

```bash
# 激活 conda 环境
conda activate heimdall

# 启动 FastAPI (热重载)
cd ~/path/to/heimdall
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

### 6.2 生产模式

```bash
# 激活 conda 环境
conda activate heimdall

# 启动 FastAPI (多 worker)
uvicorn app.main:app --host 0.0.0.0 --port 8000 --workers 4
```

### 6.3 Systemd 服务 (可选)

创建 `/etc/systemd/system/heimdall.service`：

```ini
[Unit]
Description=Heimdall Discord Bot
After=network.target

[Service]
Type=simple
User=lenovo
Environment="PATH=/home/lenovo/miniconda3/envs/heimdall/bin"
Environment="DISCORD_APPLICATION_ID=xxx"
Environment="DISCORD_PUBLIC_KEY=xxx"
Environment="DISCORD_BOT_TOKEN=xxx"
WorkingDirectory=/home/lenovo/path/to/heimdall
ExecStart=/home/lenovo/miniconda3/envs/heimdall/bin/uvicorn app.main:app --host 0.0.0.0 --port 8000
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

```bash
sudo systemctl daemon-reload
sudo systemctl enable heimdall
sudo systemctl start heimdall
```

---

## 七、实施路线图

### Phase 1: 基础设施 ✅
- [x] 创建 Conda 环境 `heimdall`
- [x] 安装 Python 依赖
- [ ] 配置 Linux 环境变量 (DISCORD_*)
- [ ] Discord Developer Portal 创建 Application
- [ ] 配置 Cloudflare Tunnel 指向 `heimdall.raylab.club`

### Phase 2: 核心开发
- [ ] 初始化 FastAPI 项目结构
- [ ] 实现 Ed25519 签名验证中间件
- [ ] 实现 PING/PONG 响应
- [ ] 通过 Cloudflare Tunnel 暴露服务
- [ ] 在 Discord 保存 Interactions Endpoint URL

### Phase 3: 命令实现
- [ ] 编写命令注册脚本
- [ ] 注册测试命令到 Guild
- [ ] 实现基础命令处理

### Phase 4: 业务集成
- [ ] 集成 AI/数据库服务
- [ ] 实现延迟响应机制
- [ ] 完整命令流程测试

### Phase 5: 生产优化
- [ ] 错误处理与日志
- [ ] 注册 Global Commands
- [ ] 配置 systemd 服务

---

## 八、参考资源

### 官方文档
- [Discord Developer Portal](https://discord.com/developers/applications)
- [Discord Interactions](https://discord.com/developers/docs/interactions/overview)
- [Cloudflare Tunnel](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/)

### 相关库
- [PyNaCl](https://pynacl.readthedocs.io/) - Ed25519 签名
- [FastAPI](https://fastapi.tiangolo.com/) - Web 框架
- [httpx](https://www.python-httpx.org/) - 异步 HTTP 客户端

### 示例项目
- [discord/cloudflare-sample-app](https://github.com/discord/cloudflare-sample-app)
- [LiBa001/discord-interactions-example](https://github.com/LiBa001/discord-interactions-example)

---

## 九、FAQ

**Q: 为什么不用 discord.py？**
discord.py 面向 Gateway (WebSocket) 模式，需要维护长连接。HTTP Interactions 更轻量，FastAPI + PyNaCl 是更简洁的选择。

**Q: Cloudflare Tunnel vs ngrok？**
ngrok 免费版每次重启 URL 会变；Cloudflare Tunnel 绑定自己的域名，URL 固定，完全免费。

**Q: 3 秒超时怎么办？**
使用延迟响应：先返回 Type 5 (DEFERRED)，后台处理完后通过 Webhook Followup 发送结果。

**Q: 需要数据库吗？**
简单请求-响应模式不需要。如需存储用户偏好、对话历史，可在 FastAPI 中集成数据库。

**Q: 为什么用环境变量而不是 .env 文件？**
Linux 系统环境变量更安全，不会被意外提交到 Git，也便于在 systemd 服务中配置。

---

## 快速参考

| 项目 | 值 |
|------|---|
| **Conda 环境** | `heimdall` |
| **Python 版本** | 3.11 |
| **公网域名** | `heimdall.raylab.club` |
| **本地端口** | `8000` |
| **Endpoint URL** | `https://heimdall.raylab.club/interactions` |
| **环境变量** | `DISCORD_APPLICATION_ID`, `DISCORD_PUBLIC_KEY`, `DISCORD_BOT_TOKEN` |

---

*文档版本: 1.1*
*更新时间: 2026-01-28*
*技术栈: Conda + Python 3.11, FastAPI 0.128.0, PyNaCl 1.6.2, cloudflared*
