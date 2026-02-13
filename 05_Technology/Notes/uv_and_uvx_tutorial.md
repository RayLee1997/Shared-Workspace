# UV 和 UVX 入门教程 - CentOS 9 环境

## 概述

`uv` 是由 Astral 开发的现代化 Python 包管理器，使用 Rust 编写，速度比 pip 快 10-100 倍。它集成了多个传统工具的功能，是 Python 开发的一站式解决方案。

`uvx` 是 `uv tool run` 的别名，专门用于运行 Python 工具而无需安装。

## 主要特性

### uv 的优势
- **超快速度**：比 pip 快 10-100 倍的包安装速度
- **一体化工具**：替换 pip、virtualenv、pip-tools、pipx 等工具
- **智能依赖解析**：快速解决复杂的依赖关系
- **跨平台支持**：支持 Linux、macOS、Windows
- **Python 版本管理**：自动安装和管理多个 Python 版本

### uvx 的优势
- **临时环境**：为每个工具创建隔离的临时环境
- **无需安装**：直接运行工具而不污染全局环境
- **自动缓存**：重复使用已安装的工具版本

## CentOS 9 安装

### 方法一：使用官方安装脚本（推荐）
```bash
# 使用 curl 安装
curl -LsSf https://astral.sh/uv/install.sh | sh

# 或使用 wget 安装
wget -qO- https://astral.sh/uv/install.sh | sh
```

### 方法二：使用包管理器
```bash
# 使用 pip 安装（如果已有 Python）
pip install uv

# 使用 dnf（如果仓库中有）
sudo dnf install uv
```

### 安装后配置
```bash
# 重新加载 shell 配置
source ~/.bashrc

# 验证安装
uv --version
uvx --version
```

## uv 核心功能

### 1. 项目管理
```bash
# 创建新项目
uv init my-project
cd my-project

# 添加依赖
uv add requests pandas

# 添加开发依赖
uv add --dev pytest black

# 移除依赖
uv remove requests

# 同步环境
uv sync

# 运行项目
uv run python main.py
```

### 2. 虚拟环境管理
```bash
# 创建虚拟环境
uv venv

# 激活环境（传统方式）
source .venv/bin/activate

# 使用 uv 运行命令（自动激活）
uv run python script.py
```

### 3. Python 版本管理
```bash
# 安装最新 Python
uv python install

# 安装特定版本
uv python install 3.11

# 列出已安装版本
uv python list

# 设置项目 Python 版本
uv python pin 3.11
```

### 4. 包管理
```bash
# 安装包
uv add numpy

# 从 requirements.txt 安装
uv pip install -r requirements.txt

# 导出依赖
uv export --format requirements-txt > requirements.txt

# 查看依赖树
uv tree
```

## uvx 工具运行

### 基本用法
```bash
# 运行工具而不安装
uvx ruff

# 带参数运行
uvx pycowsay "Hello from uv"

# 运行特定版本
uvx ruff==0.1.0

# 从 URL 运行
uvx https://github.com/user/repo.git
```

### 常用工具示例
```bash
# 代码格式化
uvx black .

# 代码检查
uvx flake8 my_script.py

# 类型检查
uvx mypy my_module.py

# 测试
uvx pytest

# 数据分析
uvx jupyter notebook

# HTTP 请求
uvx httpie GET https://api.example.com
```

### 工具安装和管理
```bash
# 安装工具到全局
uv tool install ruff

# 列出已安装工具
uv tool list

# 卸载工具
uv tool uninstall ruff

# 升级工具
uv tool install --upgrade ruff
```

## 实际使用场景

### 场景1：新项目开发
```bash
# 1. 创建项目
uv init data-analysis
cd data-analysis

# 2. 添加依赖
uv add pandas matplotlib seaborn

# 3. 创建分析脚本
uv run python analysis.py

# 4. 运行测试
uv add --dev pytest
uv run pytest
```

### 场景2：现有项目迁移
```bash
# 1. 从 requirements.txt 迁移
uv pip install -r requirements.txt
uv add $(uv export --format requirements-txt | grep -v '#' | tr '\n' ' ')

# 2. 生成 pyproject.toml
uv init --app
```

### 场景3：CI/CD 环境
```bash
# 快速安装依赖
uv pip install -r requirements.txt --system

# 运行质量检查
uvx ruff check .
uvx mypy src/
```

## 高级配置

### 配置文件
在 `~/.config/uv/uv.toml` 中配置：
```toml
[tool.uv]
# 缓存目录
cache-dir = "/tmp/uv-cache"

# 索引配置
index-url = "https://pypi.tuna.tsinghua.edu.cn/simple/"

# 默认 Python 版本
default-python = "3.11"
```

### 环境变量
```bash
# 设置缓存目录
export UV_CACHE_DIR="/tmp/uv-cache"

# 设置代理
export UV_HTTP_PROXY="http://proxy.example.com:8080"

# 设置索引
export UV_INDEX_URL="https://pypi.tuna.tsinghua.edu.cn/simple/"
```

## 性能优化技巧

### 1. 缓存管理
```bash
# 查看缓存信息
uv cache info

# 清理缓存
uv cache clean

# 清理特定包的缓存
uv cache clean --package requests
```

### 2. 并行安装
```bash
# 使用默认并行设置
uv add requests numpy pandas

# 限制并行数
UV_CONCURRENT_DOWNLOADS=4 uv add requests numpy pandas
```

### 3. 离线模式
```bash
# 使用本地缓存
uv sync --offline

# 预下载依赖
uv sync --refresh
```

## 故障排除

### 常见问题

#### 1. 权限问题
```bash
# 用户安装
curl -LsSf https://astral.sh/uv/install.sh | sh

# 或使用 sudo
sudo curl -LsSf https://astral.sh/uv/install.sh | sh
```

#### 2. 网络问题
```bash
# 使用国内镜像
uv add requests --index-url https://pypi.tuna.tsinghua.edu.cn/simple/

# 或设置环境变量
export UV_INDEX_URL="https://pypi.tuna.tsinghua.edu.cn/simple/"
```

#### 3. Python 版本问题
```bash
# 安装缺失的 Python 版本
uv python install 3.11

# 检查可用版本
uv python list

# 设置项目 Python 版本
uv python pin 3.11
```

#### 4. 依赖冲突
```bash
# 详细解析信息
uv add requests --verbose

# 强制重新解析
uv sync --refresh

# 查看依赖树
uv tree
```

## 最佳实践

### 1. 项目结构
```
my-project/
├── pyproject.toml      # 项目配置和依赖
├── uv.lock             # 锁定文件（不要手动编辑）
├── src/
│   └── my_project/
└── tests/
```

### 2. 依赖管理
- 生产依赖用 `uv add`
- 开发依赖用 `uv add --dev`
- 定期运行 `uv tree` 检查依赖关系
- 使用 `uv.lock` 确保可重现构建

### 3. 环境管理
- 使用 `uv run` 而不是手动激活虚拟环境
- 项目级配置优于全局配置
- 定期清理缓存：`uv cache clean`

### 4. 团队协作
- 提交 `pyproject.toml` 和 `uv.lock`
- 使用 `uv sync` 快速设置开发环境
- 统一使用 uv 工具链

## 迁移指南

### 从 pip 迁移
```bash
# 替换 pip install
pip install requests → uv add requests

# 替换 pip install -r
pip install -r requirements.txt → uv sync

# 替换 venv
python -m venv venv → uv venv
```

### 从 poetry 迁移
```bash
# 转换 poetry.lock
pip install poetry-to-uv
poetry-to-uv

# 手动转换依赖
poetry add requests → uv add requests
```

### 从 pipx 迁移
```bash
# pipx install → uv tool install
pipx install ruff → uv tool install ruff

# pipx run → uvx
pipx run ruff → uvx ruff
```

## 总结

uv 和 uvx 为 Python 开发带来了革命性的改进：

- **速度优势**：大幅提升包安装和依赖解析速度
- **简化工具链**：一个工具替代多个传统工具
- **现代化体验**：类似 npm/yarn 的开发体验
- **企业级特性**：支持缓存、离线模式、企业镜像

对于 CentOS 9 用户来说，uv 提供了稳定可靠的 Python 包管理解决方案，特别适合需要高效率和环境隔离的开发场景。

## 参考资源

- [官方文档](https://docs.astral.sh/uv/)
- [GitHub 仓库](https://github.com/astral-sh/uv)
- [快速开始指南](https://docs.astral.sh/uv/getting-started/installation/)
- [命令参考](https://docs.astral.sh/uv/reference/cli/)

---

*最后更新：2025年1月*