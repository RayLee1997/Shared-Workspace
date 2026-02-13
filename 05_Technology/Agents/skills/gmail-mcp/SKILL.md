---
name: Gmail MCP
description: 使用 Gmail MCP 发送邮件，支持从本地工作目录发送附件
---

# Gmail MCP Skill

使用 GongRzhe/Gmail-MCP-Server 发送邮件，支持附件功能。

## 前置条件

确保已完成 OAuth 配置，参考：[发送邮件mcp工具.md](file:///Users/ray/Obsidian/05_Technology/Anthropic/MCP/%E5%8F%91%E9%80%81%E9%82%AE%E4%BB%B6mcp%E5%B7%A5%E5%85%B7.md)

---

## 发送邮件（带附件）

### 1. 确认附件存在

发送附件前，先确认文件存在：

```bash
ls -la <附件绝对路径>
```

### 2. 调用 send_email

参数格式：

```json
{
  "to": ["recipient@example.com"],
  "subject": "邮件主题",
  "body": "邮件正文",
  "cc": ["cc@example.com"],
  "bcc": ["bcc@example.com"],
  "mimeType": "text/plain",
  "attachments": ["/absolute/path/to/file.pdf"]
}
```

### 参数说明

| 参数 | 类型 | 必填 | 说明 |
|------|------|:----:|------|
| `to` | string[] | ✅ | 收件人列表 |
| `subject` | string | ✅ | 邮件主题 |
| `body` | string | ✅ | 邮件正文 |
| `cc` | string[] | | 抄送列表 |
| `bcc` | string[] | | 密送列表 |
| `mimeType` | string | | `text/plain` / `text/html` / `multipart/alternative` |
| `htmlBody` | string | | HTML 正文（multipart 时使用） |
| `attachments` | string[] | | 附件**绝对路径**列表 |

---

## 常见场景

### 场景 1：发送工作目录中的文件

```
用户：把 report.pdf 发给 boss@company.com

执行步骤：
1. find_by_name 搜索 "report.pdf"
2. 确认绝对路径如 /Users/ray/Projects/report.pdf
3. 调用 send_email：
   {
     "to": ["boss@company.com"],
     "subject": "今日报告",
     "body": "请查收附件",
     "attachments": ["/Users/ray/Projects/report.pdf"]
   }
```

### 场景 2：发送 HTML 邮件

```json
{
  "to": ["marketing@example.com"],
  "subject": "季度报告",
  "mimeType": "text/html",
  "body": "<h1>Q4 报告</h1><p>详见附件</p>",
  "attachments": ["/Users/ray/Documents/Q4_Report.pdf"]
}
```

---

## 其他常用工具

### 搜索邮件

```json
{"tool": "search_emails", "arguments": {"query": "from:sender@example.com", "maxResults": 10}}
```

### 读取邮件

```json
{"tool": "read_email", "arguments": {"messageId": "182ab45cd67ef"}}
```

### 下载附件

```json
{"tool": "download_attachment", "arguments": {"messageId": "182ab45cd67ef", "attachmentId": "ANGjdJ9...", "savePath": "/Users/ray/Downloads"}}
```
