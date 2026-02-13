# Google Cloud Vertex AI 集成 Claude Opus 4.5 推理服务

> **调研时间**: 2026-01-30  
> **调研目的**: 评估通过 Google Cloud API 调用 Anthropic Claude Opus 4.5 模型的可行性、最佳实践及计费结算方案  
> **关键结论**: **推荐使用 `anthropic[vertex]` SDK**，`google-genai` SDK 不支持 Claude 模型

---

## 1. 执行摘要

### 1.1 核心结论

| 评估维度 | 结论 | 详情 |
|----------|------|------|
| **可用性** | ✅ **GA (正式发布)** | Claude Opus 4.5 于 2025 年在 Vertex AI Model Garden 正式上线 |
| **接入方式** | `anthropic[vertex]` SDK | Google 官方 `google-genai` SDK **不支持** Claude 模型 |
| **计费方式** | GCP 统一结算 | 费用合并到每月 Google Cloud 账单，无需向 Anthropic 单独付款 |
| **合规认证** | FedRAMP High | 通过 Vertex AI 访问 Claude 满足 FedRAMP High 要求 |

### 1.2 关键发现

**`google-genai` SDK 不支持 Anthropic Claude 模型**

经过深入调研，发现 Google 的 `google-genai` SDK (v1.0+) 专为 Gemini 模型架构设计，其 `generate_content` API 与 Claude 的 Messages API 不兼容：

```python
# ❌ 错误: google-genai SDK 无法调用 Claude
from google import genai
client = genai.Client(vertexai=True, location='global')
response = client.models.generate_content(
    model='publishers/anthropic/models/claude-opus-4-5',
    contents="Hello"
)
# 报错: 400 FAILED_PRECONDITION - claude-opus-4-5 is not supported in the generateContent API
```

**GitHub Issue**: [googleapis/python-genai#1134](https://github.com/googleapis/python-genai/issues/1134) 确认了这一限制。

---

## 2. 技术架构

### 2.1 Vertex AI Model Garden 架构

![[GCP_ANTHROPIC_VERTEX.png]]

### 2.2 SDK 对比分析

| 特性 | `google-genai` | `anthropic[vertex]` |
|------|----------------|---------------------|
| **主要用途** | Gemini 模型专用 | Claude 模型专用 |
| **底层 API** | `GenerateContent` API | Claude `Messages` API |
| **Claude 支持** | ❌ 不支持 | ✅ 完整支持 |
| **Gemini 支持** | ✅ 完整支持 | ❌ 不支持 |
| **认证方式** | Google ADC | Google ADC |
| **计费** | GCP 账单 | GCP 账单 |
| **维护方** | Google | Anthropic |

### 2.3 端点类型 (Opus 4.5)

从 Claude Sonnet 4.5 开始，Vertex AI 提供两种端点类型：

| 端点类型 | 特点 | 定价 |
|----------|------|------|
| **Global** | 动态路由，最大可用性 | 标准价格 |
| **Regional** | 固定区域，数据驻留保证 | **+10% 溢价** |

```python
# Global 端点 (推荐)
client = AnthropicVertex(region="global", project_id="...")

# Regional 端点 (数据驻留需求)
client = AnthropicVertex(region="us-east5", project_id="...")
```

---

## 3. 实施指南

### 3.1 前置条件

#### 3.1.1 GCP 项目配置

1. **创建/选择 GCP 项目**
2. **启用 Vertex AI API**:
   ```bash
   gcloud services enable aiplatform.googleapis.com
   ```
3. **在 Model Garden 中启用 Claude Opus 4.5**:
   - 访问 [Vertex AI Model Garden](https://console.cloud.google.com/vertex-ai/model-garden)
   - 搜索 "Claude Opus 4.5"
   - 点击 **Enable**
   - 填写 Anthropic 使用协议表单

#### 3.1.2 认证配置

**本地开发**:
```bash
gcloud auth application-default login
```

**生产环境 (Service Account)**:
```bash
# 创建 Service Account
gcloud iam service-accounts create claude-agent \
    --display-name="Claude Agent"

# 授予 Vertex AI User 角色
gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
    --member="serviceAccount:claude-agent@YOUR_PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/aiplatform.user"

# 下载密钥 (或使用 Workload Identity)
gcloud iam service-accounts keys create key.json \
    --iam-account=claude-agent@YOUR_PROJECT_ID.iam.gserviceaccount.com

# 设置环境变量
export GOOGLE_APPLICATION_CREDENTIALS="path/to/key.json"
```

#### 3.1.3 配额检查

默认配额可能较低，建议在生产前申请提升：

```bash
# 查看当前配额
gcloud alpha services quota list \
    --service=aiplatform.googleapis.com \
    --filter="metric:anthropic"
```

常见配额限制：
- `online_prediction_requests_per_minute_per_base_model`: 60 RPM
- `online_prediction_input_tokens_per_minute_per_base_model`: 15,000 TPM
- `online_prediction_output_tokens_per_minute_per_base_model`: 1,500 TPM

### 3.2 SDK 安装

```bash
# 安装 Anthropic SDK with Vertex AI 支持
pip install "anthropic[vertex]"

# 验证安装
python -c "from anthropic import AnthropicVertex; print('OK')"
```

### 3.3 基础代码示例

#### 3.3.1 同步调用

```python
"""
Claude Opus 4.5 on Vertex AI - 基础示例
"""
from anthropic import AnthropicVertex

# 初始化客户端
client = AnthropicVertex(
    region="global",  # 推荐: 使用 global 端点避免 10% 溢价
    project_id="your-gcp-project-id"
)

# 基础调用
message = client.messages.create(
    model="claude-opus-4-5",  # 或使用完整版本号 "claude-opus-4-5@20251101"
    max_tokens=1024,
    messages=[
        {
            "role": "user",
            "content": "Explain the concept of quantum entanglement in simple terms."
        }
    ]
)

print(message.content[0].text)
```

#### 3.3.2 异步调用

```python
"""
Claude Opus 4.5 on Vertex AI - 异步示例
"""
import asyncio
from anthropic import AsyncAnthropicVertex

async def main():
    client = AsyncAnthropicVertex(
        region="global",
        project_id="your-gcp-project-id"
    )
    
    message = await client.messages.create(
        model="claude-opus-4-5",
        max_tokens=1024,
        messages=[
            {"role": "user", "content": "Write a haiku about cloud computing."}
        ]
    )
    
    print(message.content[0].text)

asyncio.run(main())
```

#### 3.3.3 流式响应

```python
"""
Claude Opus 4.5 on Vertex AI - 流式响应
"""
from anthropic import AnthropicVertex

client = AnthropicVertex(region="global", project_id="your-project-id")

with client.messages.stream(
    model="claude-opus-4-5",
    max_tokens=1024,
    messages=[{"role": "user", "content": "Write a short story about AI."}]
) as stream:
    for text in stream.text_stream:
        print(text, end="", flush=True)
```

#### 3.3.4 工具调用 (Function Calling)

```python
"""
Claude Opus 4.5 on Vertex AI - 工具调用
"""
from anthropic import AnthropicVertex
import json

client = AnthropicVertex(region="global", project_id="your-project-id")

# 定义工具
tools = [
    {
        "name": "get_weather",
        "description": "Get the current weather in a given location",
        "input_schema": {
            "type": "object",
            "properties": {
                "location": {
                    "type": "string",
                    "description": "The city and state, e.g. San Francisco, CA"
                },
                "unit": {
                    "type": "string",
                    "enum": ["celsius", "fahrenheit"],
                    "description": "Temperature unit"
                }
            },
            "required": ["location"]
        }
    }
]

# 调用模型
message = client.messages.create(
    model="claude-opus-4-5",
    max_tokens=1024,
    tools=tools,
    messages=[
        {"role": "user", "content": "What's the weather like in Tokyo?"}
    ]
)

# 处理工具调用
for block in message.content:
    if block.type == "tool_use":
        print(f"Tool: {block.name}")
        print(f"Input: {json.dumps(block.input, indent=2)}")
        
        # 执行工具并返回结果
        tool_result = {"temperature": 22, "condition": "sunny", "unit": "celsius"}
        
        # 继续对话
        follow_up = client.messages.create(
            model="claude-opus-4-5",
            max_tokens=1024,
            tools=tools,
            messages=[
                {"role": "user", "content": "What's the weather like in Tokyo?"},
                {"role": "assistant", "content": message.content},
                {
                    "role": "user",
                    "content": [
                        {
                            "type": "tool_result",
                            "tool_use_id": block.id,
                            "content": json.dumps(tool_result)
                        }
                    ]
                }
            ]
        )
        print(f"\nFinal Response: {follow_up.content[0].text}")
```

### 3.4 与 Gemini 混合使用

如果您的应用同时需要 Gemini 和 Claude，推荐使用**双客户端模式**：

```python
"""
双客户端模式: 同时使用 Gemini 和 Claude
"""
from google import genai
from anthropic import AnthropicVertex

# Gemini 客户端
gemini_client = genai.Client(
    vertexai=True,
    project="your-project-id",
    location="us-central1"
)

# Claude 客户端
claude_client = AnthropicVertex(
    project_id="your-project-id",
    region="global"
)

async def hybrid_workflow(query: str):
    """
    示例: 使用 Claude 进行深度分析，使用 Gemini 进行快速摘要
    """
    # Step 1: Claude 深度分析
    analysis = claude_client.messages.create(
        model="claude-opus-4-5",
        max_tokens=2048,
        messages=[{"role": "user", "content": f"Provide detailed analysis: {query}"}]
    )
    analysis_text = analysis.content[0].text
    
    # Step 2: Gemini 快速摘要
    summary = gemini_client.models.generate_content(
        model="gemini-2.0-flash",
        contents=f"Summarize this in 3 bullet points:\n{analysis_text}"
    )
    
    return {
        "detailed_analysis": analysis_text,
        "summary": summary.text
    }
```

---

## 4. 计费与结算

### 4.1 计费模式

Vertex AI 上的 Claude 模型支持两种计费模式：

| 模式 | 适用场景 | 特点 |
|------|----------|------|
| **Pay-as-you-go** | 开发测试、低流量生产 | 按实际使用量计费 |
| **Provisioned Throughput** | 高流量生产环境 | 固定费用，保证吞吐量 |

### 4.2 Pay-as-you-go 定价 (Claude Opus 4.5)

| 端点类型 | Input Tokens | Output Tokens |
|----------|--------------|---------------|
| **Global** | $15.00 / 1M tokens | $75.00 / 1M tokens |
| **Regional** | $16.50 / 1M tokens (+10%) | $82.50 / 1M tokens (+10%) |

> **注意**: 定价可能随时更新，请以 [Vertex AI 官方定价页面](https://cloud.google.com/vertex-ai/generative-ai/pricing) 为准。

### 4.3 成本估算示例

| 场景 | 月请求量 | Input Tokens | Output Tokens | 月成本 (Global) |
|------|----------|--------------|---------------|-----------------|
| 轻度使用 | 1,000 | 100K | 50K | ~$5.25 |
| 中度使用 | 10,000 | 1M | 500K | ~$52.50 |
| 重度使用 | 100,000 | 10M | 5M | ~$525.00 |

### 4.4 账单查看与管理

#### 4.4.1 查看账单

1. 访问 [Cloud Billing Console](https://console.cloud.google.com/billing)
2. 选择 **Reports** 标签
3. 筛选条件:
   - Service: `Vertex AI`
   - SKU: 包含 `anthropic` 或 `claude`

#### 4.4.2 设置预算告警

```bash
# 使用 gcloud 创建预算告警
gcloud billing budgets create \
    --billing-account=YOUR_BILLING_ACCOUNT_ID \
    --display-name="Claude API Budget" \
    --budget-amount=100USD \
    --threshold-rule=percent=50,basis=CURRENT_SPEND \
    --threshold-rule=percent=90,basis=CURRENT_SPEND \
    --threshold-rule=percent=100,basis=CURRENT_SPEND \
    --filter-services=services/aiplatform.googleapis.com
```

#### 4.4.3 成本优化建议

| 策略 | 节省潜力 | 实施复杂度 |
|------|----------|-----------|
| 使用 Global 端点 | 10% | 低 |
| 优化 Prompt 长度 | 20-40% | 中 |
| 使用缓存 (Prompt Caching) | 50-90% | 中 |
| 选择合适模型 (Sonnet vs Opus) | 30-50% | 低 |
| Provisioned Throughput | 取决于使用量 | 高 |

---

## 5. 最佳实践

### 5.1 安全与合规

| 实践 | 描述 |
|------|------|
| **最小权限原则** | 仅授予 `roles/aiplatform.user` 角色 |
| **Service Account** | 生产环境使用专用 SA，避免用户凭证 |
| **VPC Service Controls** | 敏感环境启用 VPC-SC 限制数据外流 |
| **Private Service Connect** | 通过 PSC 私有访问 Vertex AI，避免公网传输 |
| **Audit Logging** | 启用 Cloud Audit Logs 记录所有 API 调用 |

### 5.2 可靠性

| 实践 | 描述 |
|------|------|
| **配额预申请** | 生产前申请足够配额 |
| **重试机制** | SDK 内置重试，可自定义 `max_retries` |
| **超时设置** | 设置合理的 `timeout` 避免长时间阻塞 |
| **降级策略** | 实现 Claude → Sonnet → Haiku 降级路径 |

```python
# 重试和超时配置示例
client = AnthropicVertex(
    region="global",
    project_id="your-project-id",
    max_retries=3,  # 自动重试次数
    timeout=120.0   # 超时时间 (秒)
)
```

### 5.3 可观测性

| 实践 | 描述 |
|------|------|
| **Request-Response Logging** | 在 Vertex AI 设置中启用，用于审计和调试 |
| **Cloud Monitoring** | 监控 API 延迟、错误率、Token 使用量 |
| **成本追踪** | 使用 Labels 区分不同环境/团队的费用 |

```python
# 添加请求头用于追踪
import httpx
from anthropic import AnthropicVertex, DefaultHttpxClient

client = AnthropicVertex(
    region="global",
    project_id="your-project-id",
    default_headers={
        "X-Environment": "production",
        "X-Team": "ai-platform",
        "X-Request-ID": "unique-request-id"  # 用于日志关联
    }
)
```

### 5.4 性能优化

| 实践 | 描述 |
|------|------|
| **流式响应** | 使用 `stream()` 减少首字节延迟 |
| **批量处理** | 合并小请求减少 API 调用次数 |
| **Prompt Caching** | 利用 Anthropic Prompt Caching 减少重复处理 |
| **连接池** | 复用 httpx 客户端，避免频繁建立连接 |

---

## 6. 故障排除

### 6.1 常见错误

| 错误 | 原因 | 解决方案 |
|------|------|----------|
| `PERMISSION_DENIED` | 未启用 Claude 模型或缺少权限 | 在 Model Garden 启用模型，检查 IAM 权限 |
| `QUOTA_EXCEEDED` | 超出配额限制 | 申请配额提升或降低请求频率 |
| `NOT_FOUND` | 模型名称错误或区域不支持 | 检查模型名称，确认区域支持 |
| `FAILED_PRECONDITION` | 使用 google-genai SDK 调用 Claude | 改用 `anthropic[vertex]` SDK |

### 6.2 调试技巧

```python
import logging

# 启用详细日志
logging.basicConfig(level=logging.DEBUG)

# 查看原始请求/响应
client = AnthropicVertex(
    region="global",
    project_id="your-project-id"
)

# 使用 with_raw_response 获取完整响应信息
response = client.messages.with_raw_response.create(
    model="claude-opus-4-5",
    max_tokens=100,
    messages=[{"role": "user", "content": "Hello"}]
)

print(f"Status: {response.status_code}")
print(f"Headers: {response.headers}")
print(f"Content: {response.parse()}")
```

---

## 7. 与现有项目集成建议 (Heimdall)

### 7.1 当前架构分析

Heimdall 项目当前使用 `google-genai` SDK 调用 Gemini 模型。若要支持 Claude Opus 4.5，需要：

1. **新增依赖**: `anthropic[vertex]`
2. **新增 Provider**: 实现 `ClaudeVertexProvider`
3. **配置扩展**: 添加 Claude 相关环境变量

### 7.2 建议的集成方案

```python
# app/sdk/claude/__init__.py (新增)
"""
Claude on Vertex AI 集成模块
"""
from anthropic import AnthropicVertex, AsyncAnthropicVertex
from typing import AsyncIterator, Optional

class ClaudeVertexService:
    """Claude Vertex AI 服务封装"""
    
    def __init__(
        self,
        project_id: str,
        region: str = "global",
        model: str = "claude-opus-4-5"
    ):
        self.client = AsyncAnthropicVertex(
            region=region,
            project_id=project_id
        )
        self.model = model
    
    async def ask(
        self,
        question: str,
        system_prompt: Optional[str] = None,
        max_tokens: int = 4096
    ) -> str:
        """单次问答"""
        messages = [{"role": "user", "content": question}]
        
        response = await self.client.messages.create(
            model=self.model,
            max_tokens=max_tokens,
            system=system_prompt,
            messages=messages
        )
        
        return response.content[0].text
    
    async def ask_stream(
        self,
        question: str,
        system_prompt: Optional[str] = None,
        max_tokens: int = 4096
    ) -> AsyncIterator[str]:
        """流式问答"""
        messages = [{"role": "user", "content": question}]
        
        async with self.client.messages.stream(
            model=self.model,
            max_tokens=max_tokens,
            system=system_prompt,
            messages=messages
        ) as stream:
            async for text in stream.text_stream:
                yield text
```

### 7.3 环境变量配置

```bash
# .env (新增)
# Claude on Vertex AI Configuration
CLAUDE_VERTEX_PROJECT_ID=your-gcp-project-id
CLAUDE_VERTEX_REGION=global
CLAUDE_VERTEX_MODEL=claude-opus-4-5
```

---

## 8. 参考资源

### 8.1 官方文档

| 资源 | URL |
|------|-----|
| Vertex AI Claude 文档 | https://cloud.google.com/vertex-ai/generative-ai/docs/partner-models/claude |
| Claude Opus 4.5 Model Card | https://console.cloud.google.com/vertex-ai/publishers/anthropic/model-garden/claude-opus-4-5 |
| Anthropic Vertex SDK | https://docs.anthropic.com/en/api/claude-on-vertex-ai |
| Vertex AI 定价 | https://cloud.google.com/vertex-ai/generative-ai/pricing |

### 8.2 示例代码

| 资源 | URL |
|------|-----|
| Google Cloud Samples | https://github.com/GoogleCloudPlatform/vertex-ai-samples/blob/main/notebooks/official/generative_ai/anthropic_claude_3_intro.ipynb |
| Anthropic Codelabs | https://codelabs.developers.google.com/codelabs/anthropic-on-vertexai-psc |

### 8.3 相关调研报告

- [Anthropic_SDK_通用Agent_SDK改造可行性调研](Anthropic_SDK_通用Agent_SDK改造可行性调研.md)
- [Gemini_API_兼容性调研报告](./Gemini_API_兼容性调研报告.md)

---

## 9. 结论

### 9.1 可行性评估

| 维度 | 评估 | 说明 |
|------|------|------|
| **技术可行性** | ✅ 高 | 使用 `anthropic[vertex]` SDK 可完整访问 Claude Opus 4.5 |
| **成本可行性** | ✅ 高 | GCP 统一计费，支持预算控制 |
| **合规可行性** | ✅ 高 | FedRAMP High 认证，满足企业合规需求 |
| **集成复杂度** | ⚠️ 中 | 需要新增 SDK 依赖和 Provider 实现 |

### 9.2 推荐方案

1. **SDK 选择**: 使用 `anthropic[vertex]` SDK (不是 `google-genai`)
2. **端点选择**: 默认使用 Global 端点节省 10% 成本
3. **认证方式**: 生产环境使用 Service Account + Workload Identity
4. **可观测性**: 启用 Request-Response Logging 和 Cloud Monitoring
5. **成本控制**: 设置 Budget Alerts，优化 Prompt 长度

### 9.3 下一步行动

- [ ] 在 Model Garden 中启用 Claude Opus 4.5
- [ ] 创建专用 Service Account
- [ ] 申请生产配额
- [ ] 实现 `ClaudeVertexService` 集成模块
- [ ] 设置 Budget Alerts

---

**报告版本**: v1.0  
**最后更新**: 2026-01-30  
**标签**: #Claude #VertexAI #GCP #集成调研 #2026
