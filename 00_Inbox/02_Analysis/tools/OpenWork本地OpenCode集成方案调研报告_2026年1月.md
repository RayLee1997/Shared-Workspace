# Open Claude Cowork 深度调研报告

## 执行摘要

通过对 Open Claude Cowork 项目的深度代码分析和文档研究，我发现了关键的架构设计和灵活的使用方案。本报告详细说明 API Key 需求、本地 OpenCode 集成方案，以及多种替代实现路径。

---

## 1. API Key 需求分析

### 1.1 双 Provider 架构

Open Claude Cowork 采用插件化的 Provider 架构，支持两种独立的 AI 服务提供商：

| Provider | API Key 需求 | 支持的模型 | 说明 |
|----------|-------------|-----------|------|
| **Claude Provider** | 需要 `ANTHROPIC_API_KEY` | Claude Opus 4.5, Sonnet 4.5, Haiku 4.5 | 直接使用 Anthropic 官方 API |
| **Opencode Provider** | 需要 `OPENCODE_API_KEY` 或连接本地 Server | 70+ 模型 (包括免费模型) | 通过 OpenCode 生态系统访问多种 LLM |

### 1.2 关键发现

**重要发现**: Opencode Provider **完全不依赖 Anthropic API Key**，这是一个重要的设计选择，为没有 Anthropic API Key 的用户提供了完整的替代方案。

---

## 2. 使用本地 OpenCode 作为 Server 的技术方案

### 2.1 OpenCode Server 架构

OpenCode 本身就是一个完整的 HTTP Server，通过以下命令启动：

```bash
# 启动独立服务器
opencode serve --port 4096 --hostname 127.0.0.1
```

服务器特性：
- **端口**: 默认 4096，可自定义
- **OpenAPI 3.1 规范**: 在 `http://localhost:4096/doc` 提供完整的 API 文档
- **认证**: 支持密码保护 (`OPENCODE_SERVER_PASSWORD`)
- **CORS**: 支持跨域配置

### 2.2 Open Claude Cowork 中的集成支持

在 `server/providers/opencode-provider.js` 中已经预置了连接现有服务器的逻辑：

```javascript
// 构造函数支持现有服务器连接
constructor(config = {}) {
  this.useExistingServer = config.useExistingServer || false;
  this.existingServerUrl = config.existingServerUrl || null;
}

// 初始化时的连接逻辑
async initialize() {
  if (this.useExistingServer && this.existingServerUrl) {
    console.log('[Opencode] Connecting to existing server:', this.existingServerUrl);
    this.client = createOpencodeClient({
      baseUrl: this.existingServerUrl
    });
  } else {
    // 创建新的 OpenCode 服务器实例
    const { client, server } = await createOpencode({
      hostname: this.hostname,
      port: this.port
    });
  }
}
```

### 2.3 集成步骤

要让 Open Claude Cowork 连接到本地 OpenCode Server，需要：

1. **修改 Provider 初始化配置**
   在 `server/providers/index.js` 中修改 Opencode Provider 的初始化：

   ```javascript
   // 原代码
   const opencodeProvider = getProvider('opencode');
   
   // 修改为
   const opencodeProvider = getProvider('opencode', {
     useExistingServer: true,
     existingServerUrl: 'http://127.0.0.1:4096'
   });
   ```

2. **启动本地 OpenCode Server**
   ```bash
   # 安装 OpenCode (如果未安装)
   npm install -g opencode-ai
   
   # 启动服务器
   opencode serve --port 4096
   ```

3. **配置 LLM Provider**
   在本地 OpenCode 中配置您选择的 LLM Provider（可以使用免费方案）

---

## 3. 替代使用方案

### 3.1 方案一：直接使用 OpenCode (推荐)

最简单的方案是直接使用 OpenCode，它本身就是功能完整的 AI 编程助手：

```bash
# 安装
curl -fsSL https://opencode.ai/install | bash

# 或者使用 npm
npm install -g opencode-ai

# 启动 TUI
opencode
```

**优势**：
- 无需额外配置
- 支持内置的 Agent 系统（build/plan 模式）
- 完整的工具集成（文件操作、Shell、Git 等）
- 支持 **75+ 个 LLM Provider**

### 3.2 OpenCode 支持的免费 LLM 方案

OpenCode 通过 `@opencode-ai/sdk` 支持 75+ 个 LLM Provider，包括多个免费选项：

#### 免费方案详情

| Provider | 免费模型 | 配置方式 | 说明 |
|----------|---------|-----------|------|
| **OpenCode Zen** | opencode/big-pickle (推理模型) | `/connect` 命令选择 opencode | OpenCode 团队测试验证 |
| **Ollama** | 本地模型 | 配置本地服务器地址 | 完全离线运行 |
| **LM Studio** | 本地模型 | 配置本地服务器地址 | 支持多种模型架构 |
| **Hugging Face** | 多个开源模型 | 配置 Hugging Face Token | 通过 Inference Providers 访问 |

#### 配置示例

```bash
# 启动 OpenCode 后，使用 /connect 命令
opencode

# 在 TUI 中选择 Provider 并配置 API Key
# 或者设置环境变量
export OPENCODE_API_KEY=your-key
```

### 3.3 其他有价值的 Provider

| Provider | 特点 | 适用场景 |
|----------|-------|----------|
| **GitLab Duo** | 集成 GitLab 工具 | GitLab 重度用户 |
| **OpenRouter** | 模型路由聚合 | 成本优化 |
| **Cloudflare AI Gateway** | 统一计费 | 企业用户 |
| **Together AI** | 高性能推理 | 开发者 |

---

## 4. 实施建议

### 4.1 推荐实施方案

**对于大多数用户，推荐直接使用 OpenCode**：

1. **安装 OpenCode**
   ```bash
   curl -fsSL https://opencode.ai/install | bash
   ```

2. **配置免费 Provider**
   - 使用 OpenCode Zen（免费推理模型）
   - 或配置 Ollama（本地模型）

3. **开始使用**
   ```bash
   opencode
   ```

### 4.2 如果必须使用 Open Claude Cowork

如果您确实需要使用 Open Claude Cowork 的特定功能（如 Composio 集成、多聊天界面等）：

1. **修改代码配置**
   - 编辑 `server/providers/index.js`
   - 在 Opencode Provider 初始化时传入本地服务器配置

2. **双服务架构**
   - Terminal 1: `opencode serve --port 4096`
   - Terminal 2: `cd server && npm start`

3. **配置指南**
   - 在本地 OpenCode 中配置 LLM Provider
   - 确保两个服务都能正常启动

---

## 5. 技术架构图

```text

┌─────────────────────────────────────────────────────────────┐
│                Open Claude Cowork                           │
│  ┌─────────────────────────────────────────────┐            │
│  │           Backend Server                    │            │
│  │  ┌─────────┐  ┌────────────────┐            │            │
│  │  │Claude   │  │   Opencode     │            │            │
│  │  │Provider │  │   Provider     │            │      │              
│  │  └─────────┘  └────────────────┘            │      │
│  │         │              │                    │      │
│  │  ┌─────────────────────────────────┐        │      │
│  │  │     HTTP API Endpoint           │   │      │
│  │  │   (localhost:3001)              │   │      │
│  │  └─────────────────────────────────┘   │      │
│  └─────────────────────────────────────────────┘      │
│                                                       │
│  ┌─────────────────────────────────────────────┐   │
│  │          Local OpenCode Server            │   │
│  │  ┌─────────────────────────────────┐      │   │
│  │  │     HTTP Server                 │      │   │
│  │  │   (localhost:4096)              │◄─────┤
│  │  └─────────────────────────────────┘      │   │
│  │                                           │   │
│  │  ┌─────────────────────────────────┐      │   │
│  │  │    75+ LLM Providers            │      │   │
│  │  │ (OpenCode Zen, Ollama,          │      │   │
│  │  │  Hugging Face, etc.)            │      │   │
│  │  └─────────────────────────────────┘      │   │
│  └─────────────────────────────────────────────┘      │
└─────────────────────────────────────────────────────────┘
```

---

## 6. 结论

### 关键发现

1. **Open Claude Cowork 不强制需要 Anthropic API Key**
   - Opencode Provider 提供了完整替代方案
   - 两个 Provider 可以独立运行

2. **本地 OpenCode 集成完全可行**
   - 代码中已有完整支持
   - 只需要简单的配置修改

3. **丰富的免费替代方案**
   - OpenCode Zen: 免费推理模型
   - Ollama: 本地模型
   - 多种其他免费/开源选项

### 推荐决策

**对于没有 Anthropic API Key 的用户**：

1. **首选方案**: 直接使用 OpenCode
   - 更简单的架构
   - 更好的性能
   - 更丰富的功能

2. **次选方案**: Open Claude Cowork + 本地 OpenCode
   - 需要额外的配置工作
   - 适合需要 Open Claude Cowork 特定功能的用户

这种设计体现了 Open Claude Cowork 项目的灵活性，用户可以根据自己的需求选择最适合的使用方式，而不被强制绑定到特定的 AI 服务提供商。

---

*调研时间: 2026年1月25日*
*调研工具: 代码分析 + 文档研究*
*项目版本: Open Claude Cowork v1.0.0*