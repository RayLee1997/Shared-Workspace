# Anthropic Python SDK 通用 Agent SDK 改造可行性调研

> 调研时间：2026-01-30
> 调研目的：评估基于 Anthropic Python SDK 架构，改造为支持多 LLM 后端的通用 Agent SDK 的可行性

---

## 1. 执行摘要

### 1.1 核心结论

| 评估维度                | 结论                                  | 可行性   |
| ------------------- | ----------------------------------- | ----- |
| SDK 架构可扩展性          | 支持 `base_url` 和自定义 `http_client` 注入 | **高** |
| MCP 协议独立性           | MCP SDK 与 LLM 提供商完全解耦               | **高** |
| 消息格式兼容性             | 需要 Content Blocks ↔ 标准格式转换层         | **中** |
| Function Calling 兼容 | MCP 工具定义与 OpenAI 格式高度相似             | **高** |
| 整体改造可行性             | **推荐执行**                            | **高** |

### 1.2 推荐方案

采用 **LLM Provider 抽象层** 方案：
- 保留 MCP SDK 作为工具/技能管理层
- 新增 `LLMProvider` 接口抽象 LLM 调用
- 实现 `ToolTranslator` 处理格式转换
- 支持 Anthropic/OpenAI/本地模型无缝切换

---

## 2. Anthropic Python SDK 架构分析

### 2.1 SDK 概览

**仓库**: [anthropics/anthropic-sdk-python](https://github.com/anthropics/anthropic-sdk-python)

**核心特性**:
- Python 3.9+ 支持
- 同步/异步双模式 (`Anthropic` / `AsyncAnthropic`)
- 基于 `httpx` 的 HTTP 客户端
- 完整的类型定义 (Pydantic v1/v2 兼容)
- 流式响应支持 (SSE)
- 内置重试和错误处理

### 2.2 架构层次

```text

┌─────────────────────────────────────────────────────────┐
│                    Public API Layer                     │
│  Anthropic / AsyncAnthropic (用户入口)                   │
│  - api_key 认证                                         │
│  - base_url 配置                                        │
│  - 资源属性访问 (.messages, .completions)                │
├─────────────────────────────────────────────────────────┤
│                   Resource Layer                        │
│  Messages / Completions / Beta                          │
│  - .create() 方法                                       │
│  - 参数验证                                              │
│  - 响应模型映射                                           │
├─────────────────────────────────────────────────────────┤
│                   HTTP Client Layer                     │
│  BaseClient / AsyncBaseClient                           │
│  - 请求构建 (FinalRequestOptions)                        │
│  - 重试逻辑                                              │
│  - 错误分类                                              │
├─────────────────────────────────────────────────────────┤
│                   Transport Layer                       │
│  httpx.Client / httpx.AsyncClient                       │
│  - 可自定义注入                                           │
│  - 代理支持                                              │
└─────────────────────────────────────────────────────────┘
```

### 2.3 关键扩展点

#### 2.3.1 Base URL 覆盖

```python
from anthropic import Anthropic

# 方式1: 构造函数参数
client = Anthropic(
    base_url="http://localhost:8080/v1"  # 指向本地代理
)

# 方式2: 环境变量
# export ANTHROPIC_BASE_URL=http://localhost:8080/v1
```

#### 2.3.2 自定义 HTTP Client

```python
import httpx
from anthropic import Anthropic, DefaultHttpxClient

client = Anthropic(
    base_url="http://my.proxy.server:8000",
    http_client=DefaultHttpxClient(
        proxy="http://my.proxy.example.com",
        transport=httpx.HTTPTransport(local_address="0.0.0.0"),
    ),
)
```

#### 2.3.3 自定义 Headers

```python
client = Anthropic(
    default_headers={
        "anthropic-version": "2023-06-01",
        "X-Custom-Header": "value"
    }
)
```

### 2.4 消息格式 (Content Blocks)

Anthropic 使用独特的 **Content Blocks** 结构：

```python
# Anthropic 消息格式
{
    "role": "user",
    "content": [
        {"type": "text", "text": "Hello"},
        {"type": "image", "source": {"type": "base64", "data": "..."}}
    ]
}

# Anthropic 工具调用响应
{
    "role": "assistant",
    "content": [
        {"type": "text", "text": "Let me search for that."},
        {
            "type": "tool_use",
            "id": "toolu_01A09q90qw90lq917835lgs",
            "name": "web_search",
            "input": {"query": "latest news"}
        }
    ]
}
```

**对比 OpenAI 格式**:

```python
# OpenAI 消息格式
{
    "role": "user",
    "content": "Hello"  # 简单字符串
}

# OpenAI 工具调用响应
{
    "role": "assistant",
    "content": "Let me search for that.",
    "tool_calls": [
        {
            "id": "call_abc123",
            "type": "function",
            "function": {
                "name": "web_search",
                "arguments": "{\"query\": \"latest news\"}"
            }
        }
    ]
}
```

### 2.5 改造难点分析

| 难点 | 描述 | 解决方案 |
|------|------|----------|
| Content Blocks 差异 | Anthropic 使用数组结构 | 实现双向转换器 |
| Tool Use 格式 | ID 格式、参数结构不同 | 统一中间格式 |
| Streaming 格式 | SSE delta 结构不同 | 流式适配器 |
| 多模态支持 | 图片编码方式不同 | 统一 multimodal 处理 |

---

## 3. Model Context Protocol (MCP) 集成分析

### 3.1 MCP 概览

**仓库**: [modelcontextprotocol/python-sdk](https://github.com/modelcontextprotocol/python-sdk)

**核心概念**:
- **Resources**: 类似 GET 端点，用于加载上下文数据
- **Tools**: 类似 POST 端点，执行操作并产生副作用
- **Prompts**: 可复用的 LLM 交互模板

### 3.2 MCP 与 LLM 的解耦

**关键发现**: MCP SDK 本身 **不依赖** 任何特定 LLM SDK。

```python
# MCP Client 示例 - 注意 anthropic 是单独导入的
from mcp import ClientSession, StdioServerParameters
from mcp.client.stdio import stdio_client
from anthropic import Anthropic  # <-- 可替换为任何 LLM 客户端

class MCPClient:
    def __init__(self):
        self.session: Optional[ClientSession] = None
        self.anthropic = Anthropic()  # <-- 替换点
```

### 3.3 MCP 工具定义格式

```python
# MCP 工具定义 (JSON Schema)
{
    "name": "get_weather",
    "description": "Get weather for a location",
    "inputSchema": {
        "type": "object",
        "properties": {
            "location": {
                "type": "string",
                "description": "City name"
            }
        },
        "required": ["location"]
    }
}
```

**与 OpenAI Function 格式对比**:

```python
# OpenAI Function 定义
{
    "type": "function",
    "function": {
        "name": "get_weather",
        "description": "Get weather for a location",
        "parameters": {  # <-- 字段名不同
            "type": "object",
            "properties": {
                "location": {
                    "type": "string",
                    "description": "City name"
                }
            },
            "required": ["location"]
        }
    }
}
```

**转换复杂度**: **低** - 仅需字段重命名

### 3.4 MCP 集成模式

```text

┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   MCP Server    │     │   Agent/Client  │     │   LLM Backend   │
│  (Tools/Data)   │◄───►│   (Orchestrator)│◄───►│  (Claude/GPT)   │
└─────────────────┘     └─────────────────┘     └─────────────────┘
        │                       │                       │
        │   list_tools()        │                       │
        │◄──────────────────────│                       │
        │   [tool definitions]  │                       │
        │──────────────────────►│                       │
        │                       │   convert to LLM fmt  │
        │                       │──────────────────────►│
        │                       │   tool_use response   │
        │                       │◄──────────────────────│
        │   call_tool(name,args)│                       │
        │◄──────────────────────│                       │
        │   [result]            │                       │
        │──────────────────────►│                       │
```

---

## 4. 通用 Agent SDK 设计方案

### 4.1 目标架构

```text

┌─────────────────────────────────────────────────────────────────┐
│                        Generic Agent SDK                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐   │
│  │ AgentRunner  │  │ ToolManager  │  │ SessionManager       │   │
│  │ (主协调器)    │  │ (MCP 集成)    │  │ (会话/历史管理)       │   │
│  └──────┬───────┘  └──────┬───────┘  └──────────────────────┘   │
│         │                 │                                     │
│         ▼                 ▼                                     │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │                   LLMProvider Interface                 │    │
│  │  + generate(messages, tools) -> Response                │    │
│  │  + stream(messages, tools) -> AsyncIterator[Chunk]      │    │
│  └─────────────────────────────────────────────────────────┘    │
│         │                 │                 │                   │
│         ▼                 ▼                 ▼                   │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐      │
│  │ Anthropic   │  │ OpenAI      │  │ GenericREST         │      │
│  │ Provider    │  │ Provider    │  │ Provider            │      │
│  │ (Claude)    │  │ (GPT-4)     │  │ (Ollama/vLLM/etc)   │      │
│  └─────────────┘  └─────────────┘  └─────────────────────┘      │
│                                                                 │
├─────────────────────────────────────────────────────────────────┤
│                      ToolTranslator                             │
│  + mcp_to_anthropic(tools) -> list[AnthropicTool]               │
│  + mcp_to_openai(tools) -> list[OpenAIFunction]                 │
│  + response_to_mcp_call(response) -> CallToolRequest            │
└─────────────────────────────────────────────────────────────────┘
```

### 4.2 核心接口定义

#### 4.2.1 LLMProvider 抽象基类

```python
from abc import ABC, abstractmethod
from dataclasses import dataclass
from typing import AsyncIterator, Optional

@dataclass
class Message:
    """统一消息格式"""
    role: str  # "user" | "assistant" | "system" | "tool"
    content: str
    tool_calls: Optional[list["ToolCall"]] = None
    tool_call_id: Optional[str] = None  # For tool results

@dataclass
class ToolCall:
    """统一工具调用格式"""
    id: str
    name: str
    arguments: dict

@dataclass
class LLMResponse:
    """统一响应格式"""
    content: str
    tool_calls: list[ToolCall]
    usage: Optional[dict] = None
    raw_response: Optional[dict] = None  # 原始响应保留

class LLMProvider(ABC):
    """LLM 提供商抽象接口"""
    
    @abstractmethod
    async def generate(
        self,
        messages: list[Message],
        tools: Optional[list[dict]] = None,
        **kwargs
    ) -> LLMResponse:
        """生成响应"""
        pass
    
    @abstractmethod
    async def stream(
        self,
        messages: list[Message],
        tools: Optional[list[dict]] = None,
        **kwargs
    ) -> AsyncIterator[str]:
        """流式生成"""
        pass
```

#### 4.2.2 ToolTranslator

```python
class ToolTranslator:
    """MCP 工具定义转换器"""
    
    @staticmethod
    def mcp_to_openai(mcp_tools: list[dict]) -> list[dict]:
        """MCP 格式 -> OpenAI Function 格式"""
        return [
            {
                "type": "function",
                "function": {
                    "name": tool["name"],
                    "description": tool.get("description", ""),
                    "parameters": tool.get("inputSchema", {})
                }
            }
            for tool in mcp_tools
        ]
    
    @staticmethod
    def mcp_to_anthropic(mcp_tools: list[dict]) -> list[dict]:
        """MCP 格式 -> Anthropic Tool 格式"""
        return [
            {
                "name": tool["name"],
                "description": tool.get("description", ""),
                "input_schema": tool.get("inputSchema", {})
            }
            for tool in mcp_tools
        ]
    
    @staticmethod
    def openai_response_to_tool_calls(response: dict) -> list[ToolCall]:
        """OpenAI 响应 -> 统一 ToolCall"""
        tool_calls = []
        for tc in response.get("tool_calls", []):
            tool_calls.append(ToolCall(
                id=tc["id"],
                name=tc["function"]["name"],
                arguments=json.loads(tc["function"]["arguments"])
            ))
        return tool_calls
```

### 4.3 实现示例: GenericRESTProvider

```python
import httpx
from typing import AsyncIterator

class GenericRESTProvider(LLMProvider):
    """
    通用 REST API 提供商
    支持 OpenAI 兼容接口 (Ollama, vLLM, LM Studio, etc.)
    """
    
    def __init__(
        self,
        base_url: str = "http://localhost:11434/v1",
        api_key: str = "ollama",  # Ollama 不需要真实 key
        model: str = "llama3.2",
        timeout: float = 120.0
    ):
        self.base_url = base_url.rstrip("/")
        self.api_key = api_key
        self.model = model
        self._client = httpx.AsyncClient(timeout=timeout)
    
    async def generate(
        self,
        messages: list[Message],
        tools: Optional[list[dict]] = None,
        **kwargs
    ) -> LLMResponse:
        """调用 OpenAI 兼容的 chat/completions 端点"""
        
        # 转换消息格式
        api_messages = [
            {"role": m.role, "content": m.content}
            for m in messages
        ]
        
        payload = {
            "model": self.model,
            "messages": api_messages,
            **kwargs
        }
        
        if tools:
            payload["tools"] = tools
        
        response = await self._client.post(
            f"{self.base_url}/chat/completions",
            json=payload,
            headers={"Authorization": f"Bearer {self.api_key}"}
        )
        response.raise_for_status()
        data = response.json()
        
        choice = data["choices"][0]
        message = choice["message"]
        
        return LLMResponse(
            content=message.get("content", ""),
            tool_calls=ToolTranslator.openai_response_to_tool_calls(message),
            usage=data.get("usage"),
            raw_response=data
        )
    
    async def stream(
        self,
        messages: list[Message],
        tools: Optional[list[dict]] = None,
        **kwargs
    ) -> AsyncIterator[str]:
        """流式生成"""
        # ... SSE 处理逻辑
        pass
```

### 4.4 Agent 运行循环

```python
class AgentRunner:
    """
    Agent 运行器
    协调 LLM 和 MCP 工具执行
    """
    
    def __init__(
        self,
        llm_provider: LLMProvider,
        mcp_client: MCPClient,
        max_iterations: int = 10
    ):
        self.llm = llm_provider
        self.mcp = mcp_client
        self.max_iterations = max_iterations
        self.history: list[Message] = []
    
    async def run(self, user_input: str) -> str:
        """执行 Agent 循环"""
        
        # 添加用户消息
        self.history.append(Message(role="user", content=user_input))
        
        # 获取 MCP 工具
        mcp_tools = await self.mcp.list_tools()
        llm_tools = ToolTranslator.mcp_to_openai(mcp_tools)
        
        for _ in range(self.max_iterations):
            # 调用 LLM
            response = await self.llm.generate(
                messages=self.history,
                tools=llm_tools
            )
            
            # 添加助手响应
            self.history.append(Message(
                role="assistant",
                content=response.content,
                tool_calls=response.tool_calls
            ))
            
            # 如果没有工具调用，返回最终结果
            if not response.tool_calls:
                return response.content
            
            # 执行工具调用
            for tool_call in response.tool_calls:
                result = await self.mcp.call_tool(
                    tool_call.name,
                    tool_call.arguments
                )
                
                # 添加工具结果
                self.history.append(Message(
                    role="tool",
                    content=str(result),
                    tool_call_id=tool_call.id
                ))
        
        return "Max iterations reached"
```

---

## 5. 实施路线图

### 5.1 Phase 1: 基础框架 (Week 1)

| 任务 | 描述 | 优先级 |
|------|------|--------|
| 项目初始化 | 创建 `generic-agent-sdk/` 目录结构 | P0 |
| 类型定义 | 实现 `Message`, `ToolCall`, `LLMResponse` | P0 |
| LLMProvider 接口 | 定义抽象基类 | P0 |
| ToolTranslator | 实现 MCP ↔ OpenAI/Anthropic 转换 | P0 |

### 5.2 Phase 2: Provider 实现 (Week 2)

| 任务 | 描述 | 优先级 |
|------|------|--------|
| AnthropicProvider | 封装官方 SDK | P0 |
| OpenAIProvider | 封装 openai SDK | P0 |
| GenericRESTProvider | 支持 OpenAI 兼容 API | P1 |
| 流式响应支持 | 实现 `stream()` 方法 | P1 |

### 5.3 Phase 3: MCP 集成 (Week 3)

| 任务 | 描述 | 优先级 |
|------|------|--------|
| MCPClient 封装 | 简化 MCP 连接管理 | P0 |
| AgentRunner | 实现 Agent 循环 | P0 |
| 多 MCP Server 支持 | 支持连接多个 MCP 服务 | P1 |
| Skills 动态加载 | 运行时加载/卸载 MCP 服务 | P1 |

### 5.4 Phase 4: 多 Agent 协同 (Week 4)

| 任务 | 描述 | 优先级 |
|------|------|--------|
| Agent 间通信 | 实现消息传递机制 | P1 |
| 任务分发 | 实现 Orchestrator 模式 | P1 |
| 共享上下文 | Agent 间状态共享 | P2 |
| 监控/调试 | 添加日志和追踪 | P2 |

---

## 6. 风险与挑战

### 6.1 技术风险

| 风险 | 影响 | 缓解措施 |
|------|------|----------|
| 消息格式不兼容 | 部分模型不支持 tool_use | 降级到纯文本 + JSON 解析 |
| 流式响应差异 | SSE 格式不一致 | 实现适配器层 |
| Token 限制差异 | 不同模型上下文长度不同 | 动态截断 + 摘要 |
| 本地模型能力差异 | 小模型 function calling 不稳定 | 提供 fallback 策略 |

### 6.2 建议的缓解策略

1. **渐进式实现**: 先支持 OpenAI 兼容 API，再扩展其他格式
2. **降级机制**: 当 function calling 失败时，回退到提示词工程
3. **模型能力探测**: 运行时检测模型是否支持特定功能
4. **抽象层测试**: 为每个 Provider 编写完整的集成测试

---

## 7. 参考资源

### 7.1 官方文档

| 资源 | URL |
|------|-----|
| Anthropic Python SDK | https://github.com/anthropics/anthropic-sdk-python |
| MCP Python SDK | https://github.com/modelcontextprotocol/python-sdk |
| MCP 规范 | https://spec.modelcontextprotocol.io |
| MCP 官方教程 | https://modelcontextprotocol.io/docs/develop/build-client |

### 7.2 相关项目

| 项目 | 描述 |
|------|------|
| LiteLLM | 统一 LLM API 代理，支持 100+ 模型 |
| LangChain | 流行的 LLM 应用框架 |
| Vercel AI SDK | TypeScript LLM SDK，支持多 Provider |

### 7.3 关键代码位置

```text

anthropic-sdk-python/
├── src/anthropic/
│   ├── _client.py          # 主客户端类，base_url 配置
│   ├── _base_client.py     # HTTP 请求处理，可扩展点
│   ├── _types.py           # 请求/响应类型定义
│   └── resources/
│       └── messages.py     # messages.create() 实现

model-context-protocol/python-sdk/
├── src/mcp/
│   ├── client/             # MCP 客户端实现
│   │   └── session.py      # ClientSession
│   ├── server/             # MCP 服务端实现
│   │   └── fastmcp/        # 高级服务端框架
│   └── types.py            # MCP 协议类型
```

---

## 8. 结论

基于本次调研，**将 Anthropic SDK 架构改造为通用 Agent SDK 是完全可行的**。

### 8.1 核心优势

1. **MCP 协议独立性**: MCP 本身不绑定任何 LLM，是理想的工具管理层
2. **SDK 扩展点充足**: Anthropic SDK 提供了 `base_url` 和 `http_client` 注入能力
3. **格式转换简单**: MCP 工具定义与 OpenAI Function 高度相似
4. **生态系统成熟**: 已有 LiteLLM 等项目验证了多 LLM 统一调用的可行性

### 8.2 推荐下一步

1. **立即开始**: 创建项目骨架，实现 `LLMProvider` 接口
2. **优先支持**: OpenAI 兼容 API (覆盖 Ollama/vLLM/DeepSeek)
3. **保持兼容**: 保留 Anthropic 原生支持作为参考实现
4. **渐进迭代**: 先实现单 Agent，再扩展到多 Agent 协同

---

## 附录 A: 快速验证代码

以下代码可用于验证 Anthropic SDK 的 `base_url` 重定向能力：

```python
"""
验证 Anthropic SDK 可以重定向到本地代理
"""
import anthropic

# 指向 LiteLLM 或其他 OpenAI 兼容代理
client = anthropic.Anthropic(
    base_url="http://localhost:4000/anthropic",  # LiteLLM proxy
    api_key="sk-any-key"  # 代理可能不验证
)

# 测试调用
response = client.messages.create(
    model="claude-3-sonnet-20240229",
    max_tokens=100,
    messages=[{"role": "user", "content": "Hello"}]
)

print(response.content[0].text)
```

---

#Anthropic #MCP #AgentSDK #调研 #2026
