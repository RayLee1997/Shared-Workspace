# OpenCode 自动创建和安装美股分析师 Agent Skill 最佳实践

> 创建时间：2026-01-26
> 验证状态：✅ 已验证可用
> 适用平台：OpenCode / Claude Code

---

> 请将以下文档直接复制粘贴给 OpenCode 不需要手动执行，你只需要在 TUI 中调用技能验证结果，对报告内容不满意，可以反复修改迭代你的 SKILL.md 配置文件 ... 
> 
## 一、环境要求

### 1.1 基础环境

| 组件 | 最低版本 | 验证命令 | 状态 |
|------|----------|----------|------|
| OpenCode | 1.1.x | `opencode --version` | ✅ 1.1.35 |
| Node.js | 18+ | `node --version` | ✅ v22.22.0 |
| Python | 3.9+ | `python3 --version` | ✅ 3.9.25 |
| pip | 最新 | `pip3 --version` | ✅ |

### 1.2 推荐工具

| 工具 | 用途 | 安装状态 |
|------|------|----------|
| uv | Python 包管理器 | ✅ 已安装 |
| uvx | Python 包执行器 | ✅ 已安装 |
| edgartools | SEC EDGAR 数据访问 | ✅ 已安装 |

---

## 二、Step by Step 安装指南

### Step 1: 安装 uv 包管理器

```bash
# 安装 uv（推荐的 Python 包管理器）
curl -LsSf https://astral.sh/uv/install.sh | sh

# 将 uv 添加到 PATH（重要！）
export PATH="$HOME/.local/bin:$PATH"

# 验证安装
uv --version
# 预期输出: uv 0.9.26 或更高版本
```

**为什么需要 uv？**
- 比 pip 快 10-100 倍
- 支持 uvx 命令直接运行 MCP 服务器
- 更好的依赖解析

### Step 2: 安装 edgartools Python 库

```bash
# 安装 edgartools（SEC EDGAR 数据访问库）
pip3 install --user edgartools

# 如果遇到 hishel 版本冲突，执行：
pip3 install --user "hishel>=0.1.3,<1.0"

# 验证安装
python3 -c "from edgar import Company; print('edgartools OK')"
# 预期输出: edgartools OK
```

**重要配置 - SEC 身份设置**

SEC 要求所有 API 请求包含身份信息。在使用前必须设置：

```python
from edgar import set_identity
set_identity("Your Name your.email@example.com")
```

建议将此设置添加到 `~/.bashrc` 或创建环境变量：

```bash
# 添加到 ~/.bashrc
export EDGAR_IDENTITY="Your Name your.email@example.com"
```

### Step 3: 创建 Skill 目录结构

```bash
# 创建 skill 目录
mkdir -p ~/.config/opencode/skills/financial-report-analysis/references
mkdir -p ~/.config/opencode/skills/financial-report-analysis/scripts

# 验证目录结构
tree ~/.config/opencode/skills/financial-report-analysis/
```

预期结构：
```
~/.config/opencode/skills/financial-report-analysis/
├── SKILL.md              # 主技能定义（必需）
├── references/           # 参考文档
│   ├── metrics_definitions.md
│   └── validation_rules.md
└── scripts/              # 可执行脚本（可选）
```

### Step 4: 创建 SKILL.md 文件

创建 `~/.config/opencode/skills/financial-report-analysis/SKILL.md`：

```yaml
---
name: financial-report-analysis
description: 自动化分析公司季度财务报告，提取并验证关键财务数据，生成结构化分析报告。支持 SEC 10-K/10-Q 文件解析、多源数据交叉验证、财报电话会议摘要。
license: MIT
compatibility: opencode
metadata:
  audience: investors
  workflow: quarterly-analysis
---

# 财务报告分析技能

## 功能概述
从公司季度/年度财务报告中自动提取和验证关键数据，生成简明的财务分析报告。

## 使用时机
- 分析某公司的季度/年度财务报告
- 提取 10-K/10-Q 中的关键财务指标
- 获取财报电话会议摘要
- 验证财务数据的准确性

## 工作流程
[详细的工作流程指令...]
```

**SKILL.md 命名规则**（重要！）：
- `name`: 1-64 字符，小写字母数字 + 连字符
- `description`: 1-1024 字符，描述技能用途
- 文件名必须是 `SKILL.md`（全大写）

### Step 5: 验证 Skill 安装

```bash
# 方法 1：检查文件是否存在
ls -la ~/.config/opencode/skills/financial-report-analysis/SKILL.md

# 方法 2：启动 opencode 验证
opencode

# 在 opencode 中输入：
> 你有哪些可用的技能？
# 应该能看到 financial-report-analysis
```

### Step 6: 配置数据存储目录

```bash
# 创建数据存储目录
mkdir -p ~/Obsidian/04_Investments/store
mkdir -p ~/Obsidian/04_Investments/reports

# 设置目录权限
chmod 755 ~/Obsidian/04_Investments/store
chmod 755 ~/Obsidian/04_Investments/reports
```

---

## 三、功能验证测试

### 3.1 edgartools 功能测试

创建测试脚本 `test_edgartools.py`：

```python
#!/usr/bin/env python3
from edgar import set_identity, Company

# 设置 SEC 身份（必需）
set_identity("Financial Analyst research@example.com")

print("=" * 60)
print("财务报告分析工具链验证")
print("=" * 60)

# 测试 1: 获取公司信息
print("\n[1] 公司信息获取测试")
company = Company("AAPL")
print(f"  ✅ 公司名称: {company.name}")
print(f"  ✅ CIK: {company.cik}")

# 测试 2: 获取 SEC 文件
print("\n[2] SEC 文件获取测试")
filings_10q = company.get_filings(form="10-Q")
filings_10k = company.get_filings(form="10-K")
print(f"  ✅ 最新 10-Q 日期: {filings_10q[0].filing_date}")
print(f"  ✅ 最新 10-K 日期: {filings_10k[0].filing_date}")

print("\n" + "=" * 60)
print("验证结果: 工具链可用 ✅")
print("=" * 60)
```

运行测试：
```bash
python3 test_edgartools.py
```

预期输出：
```
============================================================
财务报告分析工具链验证
============================================================

[1] 公司信息获取测试
  ✅ 公司名称: Apple Inc.
  ✅ CIK: 320193

[2] SEC 文件获取测试
  ✅ 最新 10-Q 日期: 2025-08-01
  ✅ 最新 10-K 日期: 2025-10-31

============================================================
验证结果: 工具链可用 ✅
============================================================
```

### 3.2 Skill 触发测试

在 opencode 中测试技能触发：

```
用户: 帮我分析苹果公司最新一季度的财务报告

预期行为:
1. opencode 应该自动加载 financial-report-analysis 技能
2. 按照 SKILL.md 中定义的工作流程执行
3. 从 SEC EDGAR 获取数据
4. 进行数据验证
5. 生成报告并保存
```

---

## 四、可选：MCP 服务器配置

### 4.1 配置 Financial Datasets MCP（推荐）

创建或编辑 `~/.config/opencode/config.json`：

```json
{
  "mcp": {
    "servers": {
      "financial-datasets": {
        "command": "npx",
        "args": [
          "-y",
          "@anthropic/mcp-remote",
          "https://mcp.financialdatasets.ai/mcp"
        ],
        "env": {
          "FINANCIAL_DATASETS_API_KEY": "${FINANCIAL_DATASETS_API_KEY}"
        }
      }
    }
  }
}
```

获取 API Key：
1. 访问 https://financialdatasets.ai
2. 注册账号
3. 在 Dashboard 获取 API Key
4. 设置环境变量：
   ```bash
   export FINANCIAL_DATASETS_API_KEY="your-api-key"
   ```

### 4.2 配置 Alpha Vantage MCP（可选）

```json
{
  "mcp": {
    "servers": {
      "alpha-vantage": {
        "command": "npx",
        "args": [
          "-y",
          "@anthropic/mcp-remote",
          "https://mcp.alphavantage.co/mcp"
        ],
        "env": {
          "ALPHA_VANTAGE_API_KEY": "${ALPHA_VANTAGE_API_KEY}"
        }
      }
    }
  }
}
```

获取免费 API Key：https://www.alphavantage.co/support/

---

## 五、常见问题排查

### Q1: Skill 未被 opencode 发现

**检查清单**：
- [ ] 文件名是否为 `SKILL.md`（全大写）
- [ ] frontmatter 是否包含 `name` 和 `description`
- [ ] `name` 是否符合命名规则（小写字母数字+连字符）
- [ ] 目录路径是否正确

**调试命令**：
```bash
# 检查文件格式
head -20 ~/.config/opencode/skills/financial-report-analysis/SKILL.md
```

### Q2: edgartools 报错 "User-Agent identity is not set"

**解决方案**：
```python
from edgar import set_identity
set_identity("Your Name your.email@example.com")
```

### Q3: edgartools 报错 "hishel" 相关错误

**解决方案**：
```bash
pip3 install --user "hishel>=0.1.3,<1.0"
```

### Q4: MCP 服务器连接失败

**检查清单**：
- [ ] API Key 是否正确设置
- [ ] 网络是否可访问外部服务
- [ ] npx 是否可用（`which npx`）

---

## 六、文件清单汇总

### 已安装的工具

| 工具 | 版本 | 安装位置 |
|------|------|----------|
| uv | 0.9.26 | `~/.local/bin/uv` |
| uvx | 0.9.26 | `~/.local/bin/uvx` |
| edgartools | 4.6.3 | Python site-packages |

### 已创建的文件

| 文件 | 路径 | 用途 |
|------|------|------|
| SKILL.md | `~/.config/opencode/skills/financial-report-analysis/SKILL.md` | 主技能定义 |
| metrics_definitions.md | `.../references/metrics_definitions.md` | 财务指标定义 |
| validation_rules.md | `.../references/validation_rules.md` | 验证规则 |

### 数据存储目录

| 目录 | 用途 |
|------|------|
| `~/Obsidian/04_Investments/store/` | 原始财务数据存储 |
| `~/Obsidian/04_Investments/reports/` | 分析报告存储 |
| `~/Obsidian/04_Investments/skills/` | 技能开发文档 |

---

## 七、下一步建议

1. **测试 Skill 触发**
   ```
   在 opencode 中输入：
   > 分析微软 (MSFT) 2025年第三季度财务报告
   ```

2. **获取 API Key**（可选但推荐）
   - Financial Datasets: https://financialdatasets.ai
   - Alpha Vantage: https://www.alphavantage.co/support/

3. **自定义报告模板**
   - 根据需要修改 `~/Obsidian/04_Investments/reports/` 目录下的报告格式

4. **持续优化 SKILL.md**
   - 根据实际使用情况调整工作流程
   - 添加更多验证规则

---

## 参考来源

| # | 来源 | 类型 |
|---|------|------|
| 1 | [OpenCode Skills 文档](https://opencode.ai/docs/skills/) | 官方文档 |
| 2 | [edgartools GitHub](https://github.com/dgunning/edgartools) | 开源项目 |
| 3 | [Agent Skills 规范](https://github.com/anthropics/skills) | 官方规范 |
| 4 | [SEC EDGAR](https://www.sec.gov/edgar) | 官方数据源 |

---

#OpenCode #AgentSkill #财务分析 #SEC #安装指南 #最佳实践
