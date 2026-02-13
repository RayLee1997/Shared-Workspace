
## 本地安装目录结构

| 路径                               | 内容                                                       |
| -------------------------------- | -------------------------------------------------------- |
| `/home/lenovo/.config/opencode/` | `package.json`, `node_modules/` (插件依赖)                   |
| `/home/lenovo/.opencode/`        | `opencode.json`, `package.json`, `node_modules/`, `bin/` |

## 配置加载优先级分析

根据 OpenCode 的设计模式和你的实际配置情况：

### 1. 主配置文件 (`opencode.json`)

**加载顺序**（从高到低优先级）：

1. **项目级配置**：`<project>/.opencode/opencode.json` 或 `<project>/opencode.json`
2. **用户级配置**：`~/.opencode/opencode.json` ✅ 你当前使用的
3. **XDG 配置**：`~/.config/opencode/opencode.json`（如果存在）

你的主配置文件在 `~/.opencode/opencode.json`，这是**用户级配置**。

### 2. 两个目录的不同用途

| 目录                    | 主要用途                                     |
| --------------------- | ---------------------------------------- |
| `~/.opencode/`        | **主要配置目录** - 存放 `opencode.json`、插件、二进制文件 |
| `~/.config/opencode/` | **XDG 兼容目录** - 主要用于插件/扩展的 npm 依赖         |

### 3. 你的当前配置

```
~/.opencode/
├── bin/                    # OpenCode 二进制文件
├── opencode.json           # 主配置文件 ← 实际生效
├── package.json            # 插件依赖
└── node_modules/           # 插件

~/.config/opencode/
├── package.json            # 另一套插件依赖
└── node_modules/           # @opencode-ai/plugin v1.1.31
```

### 4. 关键发现

1. **主配置生效位置**：`~/.opencode/opencode.json` 是你当前生效的配置
2. **插件可能重复**：两个目录都有 `node_modules`，可能存在重复安装
3. **Skills/Agents 位置**：
   - 全局 Skills：`~/.config/opencode/skills/` 或 `~/.opencode/skills/`
   - 全局 Agents：`~/.config/opencode/agents/` 或 `~/.opencode/agents/`

## 建议

1. **统一配置目录**：建议只使用 `~/.opencode/` 作为主配置目录
2. **检查 `~/.config/opencode/` 的用途**：如果只是存放插件依赖，可以考虑合并到 `~/.opencode/`
3. **创建 Skills 目录**：如果要使用全局 Skills，在 `~/.opencode/skills/` 或 `~/.config/opencode/skills/` 创建

需要我帮你进一步确认 OpenCode 官方文档中关于配置加载优先级的详细说明吗？



