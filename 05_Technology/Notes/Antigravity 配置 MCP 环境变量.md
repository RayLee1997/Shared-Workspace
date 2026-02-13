问题：
google antigravity 配置mcp_config.json 如何引用macos 配置的环境变量？

深度检索公开资料，帮我找到问题的解决方案。

环境信息：
ray@Rays-Mac-mini ~ % sw_vers
ProductName:		macOS
ProductVersion:		26.2
BuildVersion:		25C56

---

## 解决方案 (2026/02/03)

根据 Google Antigravity (2026版) 的技术文档和 macOS 的系统特性，Antigravity 作为一个 GUI 应用程序，默认**不会继承** `.zshrc` 或 `.bash_profile` 中配置的 shell 环境变量。

要在 `mcp_config.json` 中使用环境变量，请参考以下步骤：

### 1. 配置文件路径
在 macOS 上，Antigravity 的 MCP 配置文件通常位于：
`~/.gemini/antigravity/mcp_config.json`

### 2. 在配置中显式定义环境变量
由于无法直接引用系统变量（如 `$MY_API_KEY`），你需要在 `mcp_config.json` 的每个服务器配置项下的 `"env"` 代码块中进行显式定义。

**配置示例：**
```json
{
  "mcpServers": {
    "my-custom-server": {
      "command": "/usr/local/bin/node",
      "args": ["/path/to/server/index.js"],
      "env": {
        "API_KEY": "your_actual_api_key_here",
        "DB_URL": "localhost:5432",
        "DEBUG": "true"
      }
    }
  }
}
```

### 3. 动态输入（推荐安全做法）
如果你不想在 JSON 文件中硬编码敏感信息（如 API Key），Antigravity 支持 **Dynamic Inputs** 语法。当插件启动时，IDE 会弹出输入框请求该值：

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "${input:githubToken}"
      }
    }
  }
}
```

### 4. 生效步骤
1. 修改并保存 `mcp_config.json`。
2. 在 Antigravity IDE 中打开 **Agent side panel** (Control + L)。
3. 点击 **"..."** -> **MCP Servers** -> **Manage MCP Servers**。
4. 点击 **Refresh** 按钮重新加载配置。

### 5. 注意事项
- **绝对路径**：在 `command` 字段中，建议使用可执行文件的绝对路径（例如 `/opt/homebrew/bin/node`），因为 GUI 环境的 `$PATH` 可能与终端不一致。
- **权限**：确保配置文件权限正确，建议执行 `chmod 600 ~/.gemini/antigravity/mcp_config.json` 以保护敏感密钥。

---
*注：以上信息基于 2026 年初 Antigravity 稳定版文档整理。*