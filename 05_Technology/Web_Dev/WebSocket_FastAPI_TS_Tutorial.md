---
tags:
  - tech/web
  - tutorial
  - fastapi
  - typescript
  - engineering/implementation
created: 2026-02-02
updated: 2026-02-02
---

# WebSocket 全栈入门实战：FastAPI + TypeScript

这份指南提供了一个最小可行产品 (MVP) 的 WebSocket 实现。我们将构建一个简单的 **实时聊天/回显服务**。

**技术栈：**
- **Backend**: Python (FastAPI) - 现代、高性能、原生支持异步。
- **Frontend**: TypeScript (Vite) - 类型安全的前端开发。

---

## 1. 后端实现 (FastAPI)

FastAPI 处理 WebSocket 非常优雅，因为它基于 Starlette 和 asyncio。

### 1.1 环境准备

```bash
mkdir websocket-demo
cd websocket-demo
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install fastapi "uvicorn[standard]"
```

### 1.2 连接管理器 (Connection Manager)

在真实工程中（如 **Heimdall**），你不仅需要接受连接，还需要管理它们（广播消息、处理断连）。我们需要一个 `ConnectionManager` 类。

创建 `main.py`:

```python
from typing import List
from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

# 允许跨域 (对于本地开发前端必须配置)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 生产环境请替换为具体域名
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# --- 核心：连接管理器 ---
class ConnectionManager:
    def __init__(self):
        # 存放所有活跃的 WebSocket 连接
        self.active_connections: List[WebSocket] = []

    async def connect(self, websocket: WebSocket):
        await websocket.accept()
        self.active_connections.append(websocket)

    def disconnect(self, websocket: WebSocket):
        self.active_connections.remove(websocket)

    async def send_personal_message(self, message: str, websocket: WebSocket):
        await websocket.send_text(message)

    async def broadcast(self, message: str):
        # 向所有连接的客户端发送消息
        for connection in self.active_connections:
            await connection.send_text(message)

manager = ConnectionManager()

# --- 路由 ---

@app.get("/")
async def get():
    return {"status": "ok", "message": "WebSocket Server Running"}

@app.websocket("/ws/{client_id}")
async def websocket_endpoint(websocket: WebSocket, client_id: int):
    await manager.connect(websocket)
    try:
        while True:
            # 1. 等待接收客户端消息 (阻塞直到有消息)
            data = await websocket.receive_text()
            
            # 2. 处理业务逻辑 (这里简单地广播出去)
            await manager.send_personal_message(f"你发送了: {data}", websocket)
            await manager.broadcast(f"客户端 #{client_id} 说: {data}")
            
    except WebSocketDisconnect:
        # 3. 处理断开连接
        manager.disconnect(websocket)
        await manager.broadcast(f"客户端 #{client_id} 离开了聊天室")
```

### 1.3 启动后端

```bash
# 启动在 localhost:8000
uvicorn main:app --reload
```

---

## 2. 前端实现 (TypeScript)

我们将使用 Vite 快速搭建一个轻量级的 TypeScript 项目。

### 2.1 环境准备

```bash
# 在 websocket-demo 目录下
npm create vite@latest frontend -- --template vanilla-ts
cd frontend
npm install
```

### 2.2 实现 WebSocket 客户端

修改 `src/main.ts`。这里展示了如何处理连接生命周期和类型安全。

```typescript
import './style.css'

// 生成一个随机 ID 模拟用户
const clientId = Date.now();
const wsUrl = `ws://localhost:8000/ws/${clientId}`;

// 简单的 UI HTML
document.querySelector<HTMLDivElement>('#app')!.innerHTML = `
  <div>
    <h2>WebSocket Demo (Client #${clientId})</h2>
    <div class="card">
      <input type="text" id="messageInput" placeholder="输入消息..." />
      <button id="sendBtn">发送</button>
    </div>
    <div id="messages" style="text-align:left; border:1px solid #333; padding:10px; height:300px; overflow-y:scroll;">
      <!-- 消息将出现在这里 -->
    </div>
  </div>
`

// --- WebSocket 逻辑 ---

// 1. 初始化连接
const ws = new WebSocket(wsUrl);

const messagesDiv = document.querySelector<HTMLDivElement>('#messages')!;
const input = document.querySelector<HTMLInputElement>('#messageInput')!;
const sendBtn = document.querySelector<HTMLButtonElement>('#sendBtn')!;

// 2. 监听连接打开
ws.onopen = () => {
  console.log("Connected to WebSocket server");
  addMessage("系统: 已连接到服务器", "system");
};

// 3. 监听接收消息
ws.onmessage = (event: MessageEvent) => {
  console.log("Received:", event.data);
  addMessage(event.data, "server");
};

// 4. 监听关闭/错误
ws.onclose = () => {
  console.log("Disconnected");
  addMessage("系统: 连接已断开", "error");
};

// 5. 发送消息
const sendMessage = () => {
  if (input.value && ws.readyState === WebSocket.OPEN) {
    ws.send(input.value);
    input.value = '';
  } else {
    alert("连接未打开");
  }
};

// --- UI 辅助函数 ---

function addMessage(text: string, type: 'system' | 'server' | 'error' = 'server') {
  const p = document.createElement('p');
  p.textContent = text;
  if (type === 'system') p.style.color = '#888';
  if (type === 'error') p.style.color = 'red';
  - [ ] messagesDiv.appendChild(p);¬¬
  messagesDiv.scrollTop = messagesDiv.scrollHeight; // 自动滚动到底部
}

// 绑定事件
sendBtn.addEventListener('click', sendMessage);
input.addEventListener('keypress', (e) => {
  if (e.key === 'Enter') sendMessage();
});
```

### 2.3 启动前端

```bash
npm run dev
# 通常运行在 http://localhost:5173
```

---

## 3. 测试验证 (Verification)

1. 确保后端 (`uvicorn`) 正在运行。
2. 打开前端页面 (`http://localhost:5173`)。
3. 打开**第二个**浏览器标签页，访问同一个前端地址（这会模拟第二个用户）。
4. 在标签页 A 输入消息并发送。
5. **观察结果**：
   - 标签页 A 收到 "你发送了..."。
   - 标签页 B 收到 "客户端 #... 说: ..."。
π   - 这证明了全双工通信和广播功能正常工作。

---

## 4. 工程注意事项 (Engineering Notes)

对于你的 **Heimdall** 和 **PersonaPlex** 项目，请注意以下几点：

1.  **重连机制 (Reconnection Logic)**:
    - 这里的示例没有处理自动重连。在生产环境中（特别是移动端 iOS），网络经常波动。你需要编写逻辑在 `ws.onclose` 时通过 `setTimeout` 尝试重新连接。
    - *推荐库*: 前端可以使用 `reconnecting-websocket` 库来自动处理。

2.  **心跳 (Heartbeat/Ping-Pong)**:
    - FastAPI/Starlette 默认会处理底层的 Ping/Pong 帧，但在应用层实现一个定时的 "ping" 消息是个好习惯，可以确保负载均衡器（如 Cloudflare）不会因为“连接空闲”而切断连接。

3.  **鉴权 (Authentication)**:
    - WebSocket 握手是一个 HTTP 请求。你可以在 URL 参数中传递 Token (`ws://host/ws?token=xyz`) 或者在 Header 中（浏览器原生 JS WebSocket 不支持自定义 Header，通常用 Protocol 字段或 URL 参数变通）。
    - 在 FastAPI 的 `websocket_endpoint` 函数最开始验证这个 Token，如果无效直接 `await websocket.close(code=1008)`。

4.  **状态管理**:
    - `ConnectionManager` 在这里是内存级别的。如果你的后端部署了多个实例（多进程/多服务器），内存是不共享的。
    - **进阶架构**: 使用 **Redis Pub/Sub** 来在不同的后端实例之间同步 WebSocket 消息。这对于扩展 **Heimdall** 的规模至关重要。
