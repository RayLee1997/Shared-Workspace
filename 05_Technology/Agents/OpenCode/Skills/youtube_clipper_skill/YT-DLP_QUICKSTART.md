# yt-dlp 快速学习入门指南

> **yt-dlp** 是一个功能强大的命令行音频/视频下载工具，支持 1000+ 个网站，是 youtube-dl 的活跃分支

---

## 目录

1. [项目概述](#1-项目概述)
2. [技术原理](#2-技术原理)
3. [安装指南](#3-安装指南)
4. [基础使用方式](#4-基础使用方式)
5. [高级功能](#5-高级功能)
6. [实用场景](#6-实用场景)
7. [常见问题](#7-常见问题)

---

## 1. 项目概述

### 1.1 基本信息
- **GitHub**: [yt-dlp/yt-dlp](https://github.com/yt-dlp/yt-dlp)
- **Star**: 144k+ 
- **License**: Unlicense
- **Python版本**: 3.10+
- **支持网站**: 1000+ 个

### 1.2 特点
- ✅ **活跃维护**: 基于 youtube-dlc 的活跃分支
- ✅ **广泛支持**: 支持YouTube、Bilibili、TikTok等主流平台
- ✅ **高质量下载**: 支持分离视频/音频流合并
- ✅ **智能格式选择**: 自动选择最佳可用格式
- ✅ **字幕支持**: 下载各种语言字幕
- ✅ **播放列表**: 批量下载播放列表

---

## 2. 技术原理

### 2.1 架构设计

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│ Extractor      │    │ Downloader     │    │ Post-Processor │
│ System         │───▶│ System         │───▶│ System         │
│                │    │                │    │                │
│ • URL解析      │    │ • 视频下载     │    │ • 格式合并     │
│ • 元数据获取    │    │ • 分片处理     │    │ • 字幕处理     │
│ • 格式选择     │    │ • 重试机制     │    │ • 元数据嵌入   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### 2.2 核心组件

| 组件 | 功能 | 技术实现 |
|-------|------|----------|
| **Extractor** | 解析网站URL，获取视频信息 | 网站特定的解析器 |
| **Downloader** | 处理视频/音频流下载 | HTTP客户端 + 分片处理 |
| **Post-Processor** | 后处理：合并、转码、字幕 | FFmpeg集成 |

### 2.3 下载流程

```
URL输入 → 格式检测 → 元数据获取 → 格式选择 → 视频下载 → 后处理 → 文件输出
   │          │           │          │          │          │          │
   │          │           │          │          │          │          │
   ▼          ▼           ▼          ▼          ▼          ▼
  解析      分析可用格式   获取标题/时长   选择最佳格式   多线程下载    合并音视频   保存到本地
```

---

## 3. 安装指南

### 3.1 推荐方式：二进制文件

#### Windows
```bash
# 下载可执行文件
curl -L -o yt-dlp.exe https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe

# 添加到PATH环境变量
# 或将yt-dlp.exe放到系统目录
```

#### macOS
```bash
# 使用Homebrew（推荐）
brew install yt-dlp

# 或下载二进制文件
curl -L -o yt-dlp https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp_macos
chmod +x yt-dlp
sudo mv yt-dlp /usr/local/bin/
```

#### Linux
```bash
# 下载二进制文件
curl -L -o ~/.local/bin/yt-dlp https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp
chmod +x ~/.local/bin/yt-dlp

# 添加到PATH（在~/.bashrc或~/.zshrc中）
export PATH="$HOME/.local/bin:$PATH"
```

### 3.2 使用pip安装

```bash
# 标准安装
python3 -m pip install -U "yt-dlp[default]"

# 不安装可选依赖
python3 -m pip install --no-deps -U yt-dlp

# 安装nightly版本
python3 -m pip install -U --pre "yt-dlp[default]"
```

### 3.3 包管理器安装

| 系统 | 命令 | 更新命令 |
|-------|--------|----------|
| **Ubuntu/Debian** | `sudo add-apt-repository ppa:yt-dlp/stable && sudo apt install yt-dlp` | `sudo apt update && sudo apt install yt-dlp` |
| **Arch Linux** | `sudo pacman -Syu yt-dlp` | `sudo pacman -Syu yt-dlp` |
| **Homebrew** | `brew install yt-dlp` | `brew upgrade yt-dlp` |
| **Scoop** | `scoop install yt-dlp` | `scoop update yt-dlp` |
| **Chocolatey** | `choco install yt-dlp` | `choco upgrade yt-dlp` |

### 3.4 依赖安装

#### FFmpeg（强烈推荐）
```bash
# Ubuntu/Debian
sudo apt install ffmpeg

# macOS
brew install ffmpeg

# Windows (chocolatey)
choco install ffmpeg

# 验证安装
ffmpeg -version
```

#### JavaScript运行时（YouTube解密需要）
```bash
# Node.js
npm install -g node

# Deno（推荐）
curl -fsSL https://deno.land/install.sh | sh
```

### 3.5 验证安装

```bash
# 检查版本
yt-dlp --version

# 检查帮助
yt-dlp --help

# 测试下载
yt-dlp --simulate "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
```

---

## 4. 基础使用方式

### 4.1 最简单的下载

```bash
# 下载最佳质量
yt-dlp "https://www.youtube.com/watch?v=VIDEO_ID"

# 指定输出文件名
yt-dlp -o "我的视频.mp4" "URL"

# 指定输出目录
yt-dlp -o "./downloads/%(title)s.%(ext)s" "URL"
```

### 4.2 格式选择

#### 查看可用格式
```bash
# 列出所有可用格式
yt-dlp -F "URL"

# 查看格式代码示例
ID   EXT   RESOLUTION FPS |   CODECS
137   mp4   1080p     30 | avc1.640028+mp4a.40.2
248   webm   1080p     30 | vp9+opus
140   m4a   audio only |  m4a.40.2
```

#### 选择特定格式
```bash
# 下载1080p视频+最佳音频
yt-dlp -f "137+140" "URL"

# 下载最佳视频+音频组合
yt-dlp -f "bv*+ba/b" "URL"

# 下载特定分辨率
yt-dlp -f "best[height<=720]" "URL"
```

### 4.3 音频下载

```bash
# 提取音频为MP3
yt-dlp -x --audio-format mp3 "URL"

# 提取最佳音频质量
yt-dlp -f "bestaudio" "URL"

# 指定音频质量（0=最佳）
yt-dlp -x --audio-quality 0 "URL"
```

### 4.4 字幕下载

```bash
# 下载所有可用字幕
yt-dlp --write-subs "URL"

# 下载指定语言字幕
yt-dlp --write-subs --sub-langs en,zh "URL"

# 下载自动生成字幕
yt-dlp --write-auto-subs "URL"

# 嵌入字幕到视频
yt-dlp --embed-subs "URL"
```

---

## 5. 高级功能

### 5.1 播放列表处理

```bash
# 下载整个播放列表
yt-dlp "PLAYLIST_URL"

# 下载播放列表中的特定范围
yt-dlp --playlist-start 5 --playlist-end 15 "PLAYLIST_URL"

# 下载指定数量的视频
yt-dlp --playlist-items 1,5,10 "PLAYLIST_URL"

# 限制下载速度
yt-dlp -r 2M "PLAYLIST_URL"
```

### 5.2 登录和认证

```bash
# 从浏览器提取cookies（推荐）
yt-dlp --cookies-from-browser chrome "URL"

# 使用cookies文件
yt-dlp --cookies cookies.txt "URL"

# 用户名密码登录（不推荐）
yt-dlp -u "username" -p "password" "URL"
```

### 5.3 网络和代理

```bash
# 使用HTTP代理
yt-dlp --proxy http://127.0.0.1:8080 "URL"

# 使用SOCKS代理
yt-dlp --proxy socks5://user:pass@127.0.0.1:1080 "URL"

# 模拟浏览器（绕过检测）
yt-dlp --impersonate chrome "URL"

# 限制并发连接
yt-dlp -N 8 "URL"
```

### 5.4 输出模板

```bash
# 复杂模板示例
yt-dlp -o "./downloads/%(uploader)s/%(upload_date>%Y-%m-%d)s/%(title)s.%(ext)s" "URL"

# 常用变量
# %(title)s       - 视频标题
# %(uploader)s    - 上传者
# %(duration)s    - 时长
# %(view_count)s  - 播放量
# %(like_count)s  - 点赞数
# %(upload_date)s - 上传日期
# %(id)s         - 视频ID
# %(ext)s        - 扩展名
```

### 5.5 实时下载

```bash
# 从开始下载直播
yt-dlp --live-from-start "LIVE_URL"

# 等待直播开始
yt-dlp --wait-for-video 300 "LIVE_URL"

# 下载HLS流
yt-dlp --hls-prefer-native "URL"
```

### 5.6 后处理选项

```bash
# 嵌入缩略图
yt-dlp --embed-thumbnail "URL"

# 嵌入元数据
yt-dlp --embed-metadata "URL"

# 转换为特定格式
yt-dlp --merge-output-format mkv "URL"

# 分割视频为片段
yt-dlp --split-chapters "URL"
```

---

## 6. 实用场景

### 6.1 下载YouTube视频

```bash
# 基础下载
yt-dlp "https://www.youtube.com/watch?v=dQw4w9WgXcQ"

# 下载4K视频
yt-dlp -f "bestvideo[height<=2160]+bestaudio" "URL"

# 下载特定章节
yt-dlp --split-chapters "URL"
```

### 6.2 下载Bilibili视频

```bash
# 下载B站视频（需要合适网络环境）
yt-dlp "https://www.bilibili.com/video/BV1xx411c7mJ"

# 下载弹幕
yt-dlp --write-subs "BILIBILI_URL"
```

### 6.3 批量下载系列

```bash
# 下载整个系列
yt-dlp --yes-playlist "SERIES_PLAYLIST_URL"

# 跳过已下载的视频
yt-dlp --download-archive downloaded.txt "PLAYLIST_URL"

# 限制同时下载数量
yt-dlp --concurrent-fragments 4 --playlist-end 10 "PLAYLIST_URL"
```

### 6.4 音频提取

```bash
# 音乐专辑下载
yt-dlp -x --audio-format mp3 --embed-metadata "PLAYLIST_URL"

# 播客下载
yt-dlp -f "bestaudio" --embed-thumbnail "PODCAST_URL"

# 批量音频转换
yt-dlp -x --audio-format mp3 --audio-quality 0 "MULTIPLE_URLS"
```

---

## 7. 常见问题

### 7.1 下载失败

#### HTTP 403/404错误
```bash
# 解决方案1：使用浏览器模拟
yt-dlp --impersonate chrome "URL"

# 解决方案2：更新到最新版本
yt-dlp --update-to nightly

# 解决方案3：使用代理
yt-dlp --proxy socks5://127.0.0.1:1080 "URL"
```

#### 网络超时
```bash
# 增加重试次数
yt-dlp --retries 10 --fragment-retries 10 "URL"

# 增加超时时间
yt-dlp --socket-timeout 60 "URL"

# 降低并发数
yt-dlp -N 4 "URL"
```

### 7.2 格式问题

#### 视频音频分离
```bash
# 确保FFmpeg已安装
ffmpeg -version

# 强制合并
yt-dlp --merge-output-format mp4 "URL"

# 使用FFmpeg后处理
yt-dlp --postprocessor-args "ffmpeg:-c:v libx264 -c:a aac" "URL"
```

#### 播放兼容性
```bash
# 下载兼容格式
yt-dlp -f "best[ext=mp4]" "URL"

# 转换为标准格式
yt-dlp --remux-video mp4 "URL"
```

### 7.3 速度优化

```bash
# 多线程下载
yt-dlp -N 16 "URL"

# 限制下载速度（避免被封）
yt-dlp -r 5M "URL"

# 使用外部下载器
yt-dlp --downloader aria2c "URL"
```

### 7.4 内存和存储问题

```bash
# 限制缓存大小
yt-dlp --cache-dir /tmp/yt-dlp-cache --max-cache-size 500M "URL"

# 及时清理缓存
yt-dlp --rm-cache-dir

# 输出到外部存储
yt-dlp -o "/mnt/external/%(title)s.%(ext)s" "URL"
```

---

## 快速参考卡

### 常用命令速查

| 功能 | 命令 | 说明 |
|------|--------|------|
| **基础下载** | `yt-dlp "URL"` | 下载最佳质量 |
| **格式列表** | `yt-dlp -F "URL"` | 查看可用格式 |
| **音频提取** | `yt-dlp -x --audio-format mp3 "URL"` | 提取MP3音频 |
| **字幕下载** | `yt-dlp --write-subs --sub-langs en "URL"` | 下载英文字幕 |
| **播放列表** | `yt-dlp --playlist-start 1 --playlist-end 5 "URL"` | 下载前5个视频 |
| **代理设置** | `yt-dlp --proxy socks5://127.0.0.1:1080 "URL"` | 使用SOCKS代理 |
| **浏览器登录** | `yt-dlp --cookies-from-browser chrome "URL"` | 使用Chrome cookies |
| **输出模板** | `yt-dlp -o "%(title)s.%(ext)s" "URL"` | 自定义文件名 |
| **详细日志** | `yt-dlp -v "URL"` | 显示调试信息 |
| **更新程序** | `yt-dlp -U` | 更新到最新版本 |

### 配置文件

创建配置文件 `~/.config/yt-dlp/config`:

```bash
# 默认配置示例
-o ~/Downloads/%(title)s.%(ext)s
-f best[height<=1080]+bestaudio
--write-subs
--embed-metadata
--embed-thumbnail
```

---

## 学习资源

### 官方资源
- **GitHub仓库**: https://github.com/yt-dlp/yt-dlp
- **官方文档**: https://github.com/yt-dlp/yt-dlp/wiki
- **安装指南**: https://github.com/yt-dlp/yt-dlp/wiki/Installation
- **格式选择**: https://github.com/yt-dlp/yt-dlp/wiki#format-selection

### 社区资源
- **帮助网站**: https://ytdlp.wiki/ytdlp-help/
- **教程集合**: https://ostechnix.com/yt-dlp-tutorial/
- **更新博客**: https://roundproxies.com/blog/yt-dlp/

---

**提示**: yt-dlp 是学习命令行工具的绝佳选择，掌握了基础用法后，可以根据需要深入学习高级功能和特定平台的配置。

---

*指南版本: v1.0*  
*最后更新: 2026-01-25*