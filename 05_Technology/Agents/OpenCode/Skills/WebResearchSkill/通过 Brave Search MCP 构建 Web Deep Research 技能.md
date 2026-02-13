# OpenCode 安裝搜索引擎技能完全指南

> 本指南将帮助你在 OpenCode 中配置 Brave Search MCP 工具，并创建 Web Research 技能，实现智能网络搜索和深度研究功能。

---

## 目录

1. [前置条件](#前置条件)
2. [第一部分：获取 Brave Search API](#第一部分获取-brave-search-api)
3. [第二部分：配置 Brave Search MCP](#第二部分配置-brave-search-mcp)
4. [第三部分：创建 Web Research 技能](#第三部分创建-web-research-技能)
5. [第四部分：使用指南](#第四部分使用指南)
6. [高级配置](#高级配置)
7. [故障排除](#故障排除)

---

## 前置条件

### 环境要求
- OpenCode 已安装并正常运行
- Node.js 18+ 已安装
- npm 包管理器可用
- 稳定的网络连接

### 关键目录
| 目录 | 用途 |
|------|------|
| `~/.config/opencode/` | OpenCode 配置目录 |
| `~/.config/opencode/skills/` | 技能安装目录 |
| `~/.config/opencode/config.json` | 主配置文件 |

---

## 第一部分：获取 Brave Search API

### 步骤 1.1：注册 Brave 开发者账号
1. 访问 [Brave Search API 官网](https://brave.com/search/api/)
2. 点击 "Get Started" 注册开发者账号
3. 完成邮箱验证

### 步骤 1.2：选择订阅计划
推荐选择 **AI Data 订阅计划**（$5/月），包含：
- 每月 15,000 次搜索请求
- 支持 Web Search、News Search、Video Search
- 支持 Summarizer API
- 适合个人开发者使用

### 步骤 1.3：获取 API 密钥
1. 登录 Brave 开发者控制台
2. 进入 API Keys 页面
3. 点击 "Create API Key"
4. 复制并妥善保存 API 密钥

> **安全提示**：API 密钥是敏感信息，请勿将其提交到公开代码仓库。

---

## 第二部分：配置 Brave Search MCP

### 方式一：通过 OpenCode TUI 自动配置（推荐）

这是最简单的配置方式，直接在 OpenCode 对话框中操作：

**第一步：告知工作目录**
```
我的 OpenCode 配置目录在 ~/.config/opencode
```

**第二步：请求安装 MCP**
```
请帮我安装 brave-search-mcp 工具，我的 API Key 是：BSA_xxxxxxxx
```

**第三步：验证安装**
```
请检查 brave-search-mcp 是否安装成功，并执行一次测试搜索
```

### 方式二：手动配置

#### 步骤 2.1：检查配置环境
```bash
# 检查配置目录是否存在
ls -la ~/.config/opencode/

# 如果不存在，创建目录
mkdir -p ~/.config/opencode/
```

#### 步骤 2.2：安装 Brave Search MCP
```bash
# 全局安装（推荐）
npm install -g @modelcontextprotocol/server-brave-search

# 验证安装
npx @modelcontextprotocol/server-brave-search --version
```

#### 步骤 2.3：编辑配置文件
编辑 `~/.config/opencode/config.json`，添加 MCP 服务器配置：

```json
{
  "mcpServers": {
    "brave-search": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-brave-search"],
      "env": {
        "BRAVE_API_KEY": "BSA_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
      }
    }
  }
}
```

#### 步骤 2.4：验证配置
```bash
# 重启 OpenCode 使配置生效
# 然后在 OpenCode 中测试搜索功能
```

### 配置文件完整示例

参考配置：

```json
{
  "mcpServers": {
    "brave-search": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-brave-search"],
      "env": {
        "BRAVE_API_KEY": "BSA_your_api_key_here"
      }
    }
  }
}
```

---

## 第三部分：创建 Web Research 技能

### 方式一：通过 OpenCode TUI 自动创建（推荐）

**第一步：学习技能创建规范**
```
请学习 OpenCode Skills 官方文档，了解如何创建自定义技能
```

**第二步：指定技能目录**
```
我的技能安装目录在 ~/.config/opencode/skills/
```

**第三步：创建技能**
```
请为我创建一个 web-research 技能，使用 Brave Search API 进行网络搜索研究
```

**第四步：测试技能**
```
请测试 web-research 技能是否正常工作，并告诉我如何使用
```

### 方式二：手动创建技能

#### 步骤 3.1：创建技能目录结构
```bash
mkdir -p ~/.config/opencode/skills/web-research
```

目录结构：
```
~/.config/opencode/skills/
└── web-research/
    ├── skill.md          # 技能定义文件
    └── README.md         # 技能说明文档
```

#### 步骤 3.2：创建技能定义文件
创建 `~/.config/opencode/skills/web-research/skill.md`：

```markdown
---
name: web-research
description: 使用 Brave Search MCP 工具联网检索，引用来源，再基于证据推理回答。适用于需要最新信息、事实核查、引用来源的场景。
---

## 技能说明

你是一个专业的网络研究助手，能够使用 Brave Search 进行深度网络搜索和信息整合。

## 工作流程

### 1. 理解查询意图
- 分析用户的搜索需求
- 确定需要搜索的关键词和角度
- 判断是否需要多轮搜索

### 2. 执行搜索
使用 Brave Search MCP 工具进行搜索：
- `brave_web_search`: 通用网页搜索
- `brave_news_search`: 新闻搜索
- `brave_video_search`: 视频搜索
- `brave_image_search`: 图片搜索
- `brave_local_search`: 本地商户搜索

### 3. 分析和整合结果
- 筛选高质量、相关性强的结果
- 交叉验证多个来源的信息
- 提取关键事实和数据

### 4. 生成回答
- 基于搜索结果给出准确回答
- 引用信息来源（附带链接）
- 标注信息的时效性
- 指出不确定或矛盾的地方

## 搜索策略

### 基础搜索参数
- `count`: 搜索结果数量（1-20）
- `freshness`: 时效性过滤
  - `pd`: 过去24小时
  - `pw`: 过去一周
  - `pm`: 过去一个月
  - `py`: 过去一年
- `search_lang`: 搜索语言（默认 en）
- `country`: 搜索地区

### 深度研究模式
当需要深入研究某个主题时：
1. 先进行广泛搜索，了解主题概况
2. 根据初步结果，生成更具体的子查询
3. 针对每个子查询进行定向搜索
4. 整合所有搜索结果，形成完整报告

## 输出格式

### 标准回答格式
```
## 搜索结果摘要

[基于搜索结果的回答内容]

## 信息来源
1. [来源标题](URL) - 简要说明
2. [来源标题](URL) - 简要说明

## 补充说明
- 信息时效性说明
- 可能的局限性
```

## 注意事项
- 始终标注信息来源
- 区分事实与观点
- 注意信息的时效性
- 对于敏感话题保持中立客观
```

#### 步骤 3.3：创建说明文档
创建 `~/.config/opencode/skills/web-research/README.md`：

```markdown
# Web Research 技能

## 简介
使用 Brave Search API 进行智能网络搜索和深度研究。

## 前置条件
- 已配置 brave-search MCP 服务器
- 有效的 Brave Search API 密钥

## 使用方法

### 在 OpenCode 中加载技能
技能会自动加载，或使用命令 `/skill web-research`

### 触发条件
当用户询问需要联网搜索的问题时，自动触发此技能。

## 支持的搜索类型
- 网页搜索
- 新闻搜索
- 视频搜索
- 图片搜索
- 本地商户搜索
```

---

## 第四部分：使用指南

### 基础使用

#### 简单搜索
直接在 OpenCode 中提问需要联网查询的问题：
```
最近有什么关于 AI 的重大新闻？
```

#### 指定搜索类型
```
搜索关于 "机器学习" 的最新视频教程
```

#### 限定时间范围
```
搜索过去一周内关于 "量子计算" 的新闻
```

### 深度研究模式

#### 主题研究
```
请深入研究 "大语言模型的发展趋势"，包括：
1. 技术进展
2. 主要厂商动态
3. 应用场景
4. 未来展望
```

#### 对比分析
```
对比分析 GPT-4、Claude 3 和 Gemini 的性能差异，引用最新的评测数据
```

### 搜索参数控制

| 参数 | 说明 | 示例值 |
|------|------|--------|
| `count` | 结果数量 | 1-20 |
| `freshness` | 时效性 | pd/pw/pm/py |
| `search_lang` | 语言 | en/zh-hans/jp |
| `country` | 地区 | US/CN/JP |
| `safesearch` | 安全搜索 | off/moderate/strict |

---

## 高级配置

### 搜索参数优化
在技能中可以预设搜索参数：
```json
{
  "searchOptions": {
    "count": 10,
    "freshness": "pw",
    "text_decorations": true,
    "spellcheck": true,
    "result_filter": ["web", "news", "videos"]
  }
}
```

### 多语言搜索
```json
{
  "search_lang": "zh-hans",
  "ui_lang": "zh-CN",
  "country": "CN"
}
```

### 新闻专项搜索
```json
{
  "result_filter": ["news"],
  "freshness": "pd",
  "extra_snippets": true
}
```

---

## 故障排除

### 常见问题及解决方案

#### 问题 1：API 密钥无效
**症状**：搜索请求返回 401 错误
**解决方案**：
1. 检查 API 密钥是否正确复制
2. 确认订阅是否激活
3. 检查配置文件中的密钥格式

#### 问题 2：MCP 服务未启动
**症状**：找不到 brave-search 工具
**解决方案**：
1. 检查 config.json 语法是否正确
2. 确认 npm 包已正确安装
3. 重启 OpenCode

#### 问题 3：网络连接问题
**症状**：搜索超时或连接失败
**解决方案**：
1. 检查网络连接
2. 确认能访问 api.search.brave.com
3. 检查是否需要配置代理

#### 问题 4：技能未加载
**症状**：技能无法触发
**解决方案**：
1. 检查技能文件路径是否正确
2. 验证 skill.md 语法
3. 检查技能目录权限

### 调试命令

```bash
# 测试 API 连接
curl -H "X-Subscription-Token: YOUR_API_KEY" \
     "https://api.search.brave.com/res/v1/web/search?q=test"

# 检查 npm 包安装
npm list -g @modelcontextprotocol/server-brave-search

# 验证配置文件语法
cat ~/.config/opencode/config.json | python3 -m json.tool

# 检查技能文件
ls -la ~/.config/opencode/skills/web-research/
```

### 日志查看
```bash
# 启用详细日志模式运行 OpenCode
opencode --verbose

# 查看 MCP 服务日志
tail -f ~/.config/opencode/logs/mcp.log
```

---

## 附录

### 相关资源
- [Brave Search API 文档](https://brave.com/search/api/)
- [OpenCode 官方文档](https://opencode.ai/docs)
- [MCP 协议规范](https://modelcontextprotocol.io/)

---

> **提示**：本指南持续更新中，如有问题欢迎反馈。
