# Gmail MCP Server 配置指南

> 让 Claude Desktop 能够发送、读取和管理 Gmail 邮件

**项目**: [GongRzhe/Gmail-MCP-Server](https://github.com/GongRzhe/Gmail-MCP-Server)

---

## 快速安装

```bash
npx -y @smithery/cli install @gongrzhe/server-gmail-autoauth-mcp --client claude
```

安装后 Claude Desktop 配置文件会自动添加：

```json
{
  "mcpServers": {
    "server-gmail-autoauth-mcp": {
      "command": "npx",
      "args": ["-y", "@smithery/cli@latest", "run", "@gongrzhe/server-gmail-autoauth-mcp"]
    }
  }
}
```

---

## OAuth 配置详解

### Step 1: 创建 Google Cloud 项目

1. 访问 [Google Cloud Console](https://console.cloud.google.com/)
2. 点击顶部「Select a project」→「New Project」
3. 输入项目名称（如 `gmail-mcp`），点击「Create」

### Step 2: 启用 Gmail API

1. 在左侧菜单选择「APIs & Services」→「Library」
2. 搜索 `Gmail API`
3. 点击「Enable」启用

### Step 3: 配置 OAuth 同意屏幕

1. 前往「APIs & Services」→「OAuth consent screen」
2. 选择「External」，点击「Create」
3. 填写必要信息：
   - **App name**: `Gmail MCP`
   - **User support email**: 你的邮箱
   - **Developer contact**: 你的邮箱
4. 点击「Save and Continue」
5. 在「Scopes」页面，点击「Add or Remove Scopes」，添加：

   ```
   https://www.googleapis.com/auth/gmail.modify
   https://www.googleapis.com/auth/gmail.send
   https://www.googleapis.com/auth/gmail.readonly
   ```

6. 在「Test users」页面，**添加你的 Gmail 地址**

### Step 4: 创建 OAuth 凭证

1. 前往「APIs & Services」→「Credentials」
2. 点击「Create Credentials」→「OAuth client ID」
3. Application type: 选择 **「Desktop app」**
4. Name: `Gmail MCP Client`
5. 点击「Create」
6. 点击「Download JSON」下载凭证文件

### Step 5: 放置凭证文件

```bash
# 创建配置目录
mkdir -p ~/.gmail-mcp

# 移动并重命名下载的 JSON 文件
mv ~/Downloads/client_secret_*.json ~/.gmail-mcp/gcp-oauth.keys.json

# 验证文件已就位
ls -la ~/.gmail-mcp/
```

> [!IMPORTANT]
> 文件必须重命名为 `gcp-oauth.keys.json` 并放在 `~/.gmail-mcp/` 目录

### Step 6: 完成 OAuth 认证

```bash
# 运行认证（会自动打开浏览器）
npx -y @smithery/cli run @gongrzhe/server-gmail-autoauth-mcp
```

执行后会：

1. 自动打开浏览器
2. 登录 Google 账号并授权
3. 在 `~/.gmail-mcp/` 目录生成 `token.json`

### Step 7: 重启 Claude Desktop

认证完成后，重启 Claude Desktop 即可使用 Gmail 功能。

---

## 文件结构

认证完成后，`~/.gmail-mcp/` 目录应包含：

```
~/.gmail-mcp/
├── gcp-oauth.keys.json  # OAuth 客户端凭证（你放置的）
└── token.json           # 访问令牌（自动生成的）
```

---

## 可用工具

| 工具 | 功能 |
|------|------|
| `send_email` | 发送邮件（支持附件） |
| `read_email` | 读取邮件 |
| `search_emails` | 搜索邮件 |
| `draft_email` | 创建草稿 |
| `modify_email` | 修改邮件状态 |
| `delete_email` | 删除邮件 |
| `download_attachment` | 下载附件 |
| `list_email_labels` | 列出标签 |
| `create_label` | 创建标签 |
| `batch_modify_emails` | 批量修改 |

---

## 使用示例

### 发送邮件

```
请发送邮件给 example@gmail.com，主题"会议提醒"，内容"明天上午10点开会"
```

### 发送带附件的邮件

```
请把 /Users/ray/Documents/report.pdf 作为附件发送给 boss@company.com
```

### 搜索邮件

```
搜索最近7天来自 support@example.com 的邮件
```

---

## 参考链接

- [Gmail-MCP-Server GitHub](https://github.com/GongRzhe/Gmail-MCP-Server)
- [Google Cloud Console](https://console.cloud.google.com/)
- [Gmail API 文档](https://developers.google.com/gmail/api)
