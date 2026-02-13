# Antigravity 安装 Gmail MCP Server 踩坑记

本文记录了在 Antigravity IDE 中配置 `gmail-mcp-server` 时遇到的各种坑及最终解决方案。

## 1. 自动认证失效问题

**现象**：使用 `npx ... auth` 命令完成认证显示成功，但 Claude 调用时一直提示 "No access"。
**原因**：

1. `Smithery` 包装器运行环境隔离，生成的 `token.json` 未能持久化到本地预期目录。
2. Antigravity IDE 的 MCP 进程启动时环境变量加载机制与终端不同。

## 2. 坑一：Redirect URI Mismatch (端口问题)

**尝试**：编写 Python 脚本手动认证。
**报错**：`redirect_uri_mismatch`。
**原因**：`flow.run_local_server(port=0)` 会随机分配端口，但 Google Cloud Console 必须配置精确的回跳地址。
**解决**：

- 强制脚本使用 `port=8080`。
- 在 GCP Console -> Credentials 中添加 `http://localhost:8080/` 到 Authorized redirect URIs。

## 3. 坑二：Token 格式不兼容 (大坑！)

**尝试**：Python 脚本成功生成 `token.json`，但 MCP Server 依然读不到。
**原因**：

- **Python (`google-auth-oauthlib`) 生成格式**：

  ```json
  { "token": "...", "expiry": "2026-02-05T..." }
  ```

- **Node.js (`@gongrzhe/gmail-mcp-server`) 需要格式**：

  ```json
  { "access_token": "...", "expiry_date": 1770267392000 }
  ```

**解决**：编写转换脚本，将字段名映射 (`token` -> `access_token`) 并将 ISO 时间转为毫秒时间戳。

## 4. 坑三：环境变量命名陷阱

**尝试**：在 `mcp_config.json` 中配置路径，但不起作用。
**原因**：查阅服务器源码 (`dist/index.js`) 发现，环境变量命名与直觉不符：

- **直觉**：`GMAIL_TOKEN_PATH` 指向 token，`GMAIL_CREDENTIALS_PATH` 指向 OAuth 密钥。
- **实际**：
  - `GMAIL_CREDENTIALS_PATH` -> **Token 文件路径** (!!!)
  - `GMAIL_OAUTH_PATH` -> **OAuth 密钥文件路径**

## 5. 最终解决方案 (Best Practice)

### 第一步：准备文件

确保 `~/.gmail-mcp/` 目录下有两个文件：

1. `gcp-oauth.keys.json` (从 GCP 下载的 OAuth 客户端密钥)
2. `credentials.json` (Node.js 格式的 Access Token)

### 第二步：IDE 配置

在 `mcp_config.json` 中使用**直连模式** (避开 Smithery) 并显式指定环境变量：

```json
"server-gmail-autoauth-mcp": {
  "command": "npx",
  "args": [
    "-y",
    "@gongrzhe/server-gmail-autoauth-mcp"
  ],
  "env": {
    "GMAIL_OAUTH_PATH": "/Users/ray/.gmail-mcp/gcp-oauth.keys.json",
    "GMAIL_CREDENTIALS_PATH": "/Users/ray/.gmail-mcp/credentials.json"
  }
}
```

### 第三步：Reload Window

Antigravity IDE 需要 Reload Window 才能重新加载 MCP 配置和环境变量。

## 附录：救援脚本代码

如果将来需要再次重新认证，可以使用以下脚本。这些脚本曾用于解决认证问题，现已归档于此。

### manual_auth.py (手动认证)

```python
import os
import json
from google_auth_oauthlib.flow import InstalledAppFlow
from google.oauth2.credentials import Credentials

# Scopes verified from documentation
SCOPES = [
    'https://www.googleapis.com/auth/gmail.readonly',
    'https://www.googleapis.com/auth/gmail.send',
    'https://www.googleapis.com/auth/gmail.modify',
    'https://www.googleapis.com/auth/gmail.settings.basic'
]

CREDENTIALS_PATH = os.path.expanduser('~/.gmail-mcp/gcp-oauth.keys.json')
TOKEN_PATH = os.path.expanduser('~/.gmail-mcp/token.json')

def authenticate():
    print(f"Checking credentials at: {CREDENTIALS_PATH}")
    if not os.path.exists(CREDENTIALS_PATH):
        print("Error: Credentials file not found!")
        return

    print("Starting OAuth flow on port 8080...")
    flow = InstalledAppFlow.from_client_secrets_file(CREDENTIALS_PATH, SCOPES)
    # Using fixed port 8080 to match GCP Console configuration
    try:
        creds = flow.run_local_server(port=8080)
    except OSError:
        print("Error: Port 8080 is in use. Please kill other processes using this port.")
        return

    # Save the credentials for the next run
    print(f"Saving token to: {TOKEN_PATH}")
    with open(TOKEN_PATH, 'w') as token:
        token.write(creds.to_json())
    
    print("Authentication successful! Token saved.")
    print("Please restart Claude Desktop now.")

if __name__ == '__main__':
    authenticate()
```

### fix_token.py (格式转换)

```python
import json
import os
from datetime import datetime

TOKEN_PATH = os.path.expanduser('~/.gmail-mcp/credentials.json')

def fix_token():
    with open(TOKEN_PATH, 'r') as f:
        data = json.load(f)
    
    new_data = {}
    
    # Map 'token' to 'access_token'
    if 'token' in data:
        new_data['access_token'] = data['token']
    elif 'access_token' in data:
        new_data['access_token'] = data['access_token']
        
    # Keep refresh_token
    if 'refresh_token' in data:
        new_data['refresh_token'] = data['refresh_token']
        
    # Fix expiry
    if 'expiry' in data:
        # Parse ISO format "2026-02-05T04:56:32Z" to timestamp (ms)
        dt = datetime.strptime(data['expiry'], "%Y-%m-%dT%H:%M:%SZ")
        # Assuming UTC
        timestamp_ms = int(dt.timestamp() * 1000)
        new_data['expiry_date'] = timestamp_ms
    elif 'expiry_date' in data:
        new_data['expiry_date'] = data['expiry_date']
        
    # Copy scope/token_type if needed
    new_data['token_type'] = 'Bearer'
    new_data['scope'] = " ".join(data.get('scopes', []))
    
    with open(TOKEN_PATH, 'w') as f:
        json.dump(new_data, f, indent=2)
    
    print("Fixed token saved to:", TOKEN_PATH)

if __name__ == '__main__':
    fix_token()
```
