# OpenCode YouTube Clipper Skill 完全指南

> 将 YouTube 长视频智能转换为适合 TikTok、Instagram Reels、YouTube Shorts 的短视频剪辑

---

## 目录

1. [功能概述](#1-功能概述)
2. [工具列表](#2-工具列表)
3. [安装指南](#3-安装指南)
4. [核心工作流程](#4-核心工作流程)
5. [在 OpenCode 中使用](#5-在-opencode-中使用)
6. [常见问题](#6-常见问题)

---

## 1. 功能概述

### 1.1 核心能力

| 功能 | 描述 |
|------|------|
| **视频下载** | 从 YouTube 下载指定视频，保留原始质量 |
| **智能剪辑** | 基于时间段精确裁剪视频片段 |
| **平台适配** | 自动转换为 TikTok/Instagram/YouTube Shorts 格式 |
| **字幕处理** | 提取、叠加字幕到剪辑视频中 |
| **批量处理** | 支持多个时间段并行剪辑 |

### 1.2 支持的输出平台

| 平台 | 分辨率 | 宽高比 | 最大时长 |
|------|--------|--------|----------|
| TikTok | 1080x1920 | 9:16 | 60秒 |
| Instagram Reels | 1080x1350 | 4:5 | 90秒 |
| YouTube Shorts | 1920x1080 | 16:9 | 60秒 |

### 1.3 输入输出

- **输入**: YouTube 视频 URL + 剪辑时间段列表
- **输出**: 裁剪后的视频文件（MP4格式）+ 可选字幕文件

---

## 2. 工具列表

### 2.1 系统依赖（必需）

| 工具 | 版本要求 | 用途 | 官方文档 |
|------|----------|------|----------|
| **yt-dlp** | 最新版 | YouTube 视频下载 | https://github.com/yt-dlp/yt-dlp |
| **FFmpeg** | 4.0+ | 视频剪辑与格式转换 | https://ffmpeg.org/ |
| **Node.js** | 14.0+ | 运行环境 | https://nodejs.org/ |

### 2.2 可选依赖

| 工具 | 用途 |
|------|------|
| **libass** | 字幕渲染支持 |
| **mpv** | 剪辑结果预览 |

### 2.3 Node.js 依赖

```json
{
  "commander": "CLI 命令解析",
  "chalk": "终端彩色输出",
  "ora": "加载动画",
  "inquirer": "交互式提示",
  "fs-extra": "文件系统扩展"
}
```

---

## 3. 安装指南

### 3.1 一键安装（推荐）

```bash
# 在 OpenCode 项目目录下运行
npx skills add https://github.com/op7418/youtube-clipper-skill --skill youtube-clipper
```

### 3.2 手动安装系统依赖

#### Ubuntu/Debian
```bash
sudo apt update
sudo apt install -y yt-dlp ffmpeg libass-dev mpv
```

#### CentOS/RHEL
```bash
sudo yum install -y epel-release
sudo yum install -y yt-dlp ffmpeg libass mpv
```

#### Fedora
```bash
sudo dnf install -y yt-dlp ffmpeg libass mpv
```

#### macOS
```bash
brew install yt-dlp ffmpeg libass mpv
```

#### Windows (WSL/Chocolatey)
```bash
choco install yt-dlp ffmpeg
```

#### 使用 pip 安装 yt-dlp
```bash
pip install yt-dlp
```

### 3.3 验证安装

```bash
# 检查 yt-dlp
yt-dlp --version

# 检查 FFmpeg
ffmpeg -version

# 检查字幕支持
ffmpeg -filters 2>&1 | grep subtitles
```

### 3.4 配置文件

安装后会在 `~/.config/youtube-clipper/config.json` 创建默认配置：

```json
{
  "downloadDir": "$HOME/Downloads/youtube-clips",
  "tempDir": "/tmp/youtube-clipper",
  "outputFormats": ["mp4"],
  "defaultQuality": "1080p",
  "includeSubtitles": true,
  "maxConcurrentDownloads": 3,
  "cleanupTempFiles": true,
  "platforms": {
    "tiktok": { "aspectRatio": "9:16", "maxDuration": 60 },
    "instagram": { "aspectRatio": "4:5", "maxDuration": 90 },
    "youtube": { "aspectRatio": "16:9", "maxDuration": 60 }
  }
}
```

---

## 4. 核心工作流程

### 4.1 六阶段工作流

```text

┌──────────────────────────────────────────────────────────────────┐
│                    YouTube Clipper 工作流程                       │
├──────────────────────────────────────────────────────────────────┤
│                                                                  │
│  阶段1: 环境检测                                                  │
│  ├─ 检查 yt-dlp 是否可用                                         │
│  ├─ 检查 FFmpeg 版本和功能                                        │
│  └─ 验证 libass 字幕支持                                          │
│           │                                                      │
│           ▼                                                      │
│  阶段2: 参数解析                                                  │
│  ├─ 解析 YouTube URL                                             │
│  ├─ 验证时间段格式                                                │
│  └─ 确定输出平台和格式                                            │
│           │                                                      │
│           ▼                                                      │
│  阶段3: 视频信息获取                                              │
│  ├─ 获取视频元数据 (标题、时长、格式)                              │
│  ├─ 选择最优下载格式                                              │
│  └─ 检查字幕可用性                                                │
│           │                                                      │
│           ▼                                                      │
│  阶段4: 视频下载                                                  │
│  ├─ 使用 yt-dlp 下载视频                                         │
│  ├─ 下载字幕 (如可用)                                             │
│  └─ 保存到临时目录                                                │
│           │                                                      │
│           ▼                                                      │
│  阶段5: 智能剪辑                                                  │
│  ├─ 使用 FFmpeg 精确裁剪                                          │
│  ├─ 叠加字幕 (可选)                                               │
│  └─ 批量处理多个片段                                              │
│           │                                                      │
│           ▼                                                      │
│  阶段6: 输出适配                                                  │
│  ├─ 转换为目标平台格式                                            │
│  ├─ 调整分辨率和宽高比                                            │
│  └─ 生成元数据文件                                                │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

### 4.2 核心命令详解

#### 环境检查命令
```bash
# 检查 yt-dlp 版本
yt-dlp --version

# 检查 FFmpeg 版本
ffmpeg -version

# 检查字幕过滤器支持
ffmpeg -filters 2>&1 | grep subtitles
```

#### 视频下载命令
```bash
# 获取视频信息
yt-dlp --dump-json "https://youtube.com/watch?v=VIDEO_ID"

# 下载指定格式
yt-dlp -f "bestvideo[height<=1080]+bestaudio" -o "output.mp4" URL

# 下载并直接剪辑指定时间段
yt-dlp --downloader ffmpeg --downloader-args "ffmpeg_i:-ss 30 -to 90" URL
```

#### 视频剪辑命令
```bash
# 基础剪辑 (无需重新编码，速度最快)
ffmpeg -i input.mp4 -ss 00:00:30 -to 00:01:30 -c copy output.mp4

# 带字幕剪辑
ffmpeg -i input.mp4 -ss 30 -to 90 -vf "subtitles=subtitle.ass" output.mp4

# 平台适配 (TikTok 9:16)
ffmpeg -i input.mp4 -vf "scale=1080:1920:force_original_aspect_ratio=decrease,pad=1080:1920:(ow-iw)/2:(oh-ih)/2" -t 60 output_tiktok.mp4
```

### 4.3 数据流示意

```text

用户输入 (URL + 时间段)
        │
        ▼
┌───────────────────┐
│   Input Handler   │ ──▶ URL解析、参数验证
└───────────────────┘
        │
        ▼
┌───────────────────┐
│ Download Manager  │ ──▶ yt-dlp 下载、进度监控
└───────────────────┘
        │
        ▼
┌───────────────────┐
│  Clip Processor   │ ──▶ FFmpeg 剪辑、字幕处理
└───────────────────┘
        │
        ▼
┌───────────────────┐
│  Output Manager   │ ──▶ 平台适配、文件输出
└───────────────────┘
        │
        ▼
输出文件 (MP4 + 元数据)
```

---

## 5. 在 OpenCode 中使用

### 5.1 安装 Skill 到 OpenCode

```bash
# 方法一：使用 npx skills 命令
npx skills add https://github.com/op7418/youtube-clipper-skill --skill youtube-clipper

# 方法二：手动添加到 AGENTS.md 或项目配置
```

### 5.2 基本使用方式

安装 skill 后，在 OpenCode 对话中可以直接请求视频剪辑任务：

#### 示例对话 1：基本剪辑
```
用户: 帮我从这个视频 https://youtube.com/watch?v=abc123 剪辑 1:30 到 2:30 的片段

OpenCode: 好的，我来帮你剪辑这个视频片段。
[执行环境检查]
[下载视频]
[剪辑指定时间段]
已完成！剪辑文件保存在: ~/Downloads/youtube-clips/abc123_clip_1.mp4
```

#### 示例对话 2：多片段 + 平台适配
```
用户: 从这个播客视频剪辑3个精彩片段，分别是 5:00-5:30, 12:00-12:45, 25:00-25:30，输出 TikTok 格式

OpenCode: 好的，我来帮你剪辑3个片段并转换为TikTok格式。
[执行工作流...]
已完成！生成了3个TikTok格式的剪辑：
- clip_1_tiktok.mp4 (30秒)
- clip_2_tiktok.mp4 (45秒)
- clip_3_tiktok.mp4 (30秒)
```

### 5.3 命令行直接使用

```bash
# 基本剪辑
npx skills run youtube-clipper --url=https://youtube.com/watch?v=VIDEO_ID

# 指定多个时间段
npx skills run youtube-clipper --url=URL --segments=0:30-1:30,2:00-2:30

# 指定输出平台
npx skills run youtube-clipper --url=URL --platform=tiktok --segments=1:00-1:30

# 包含字幕
npx skills run youtube-clipper --url=URL --segments=0:30-1:30 --subtitles
```

### 5.4 API 编程使用

```javascript
// 在 Node.js 项目中使用
const { checkEnvironment, downloadVideo, createClips, adaptForPlatform } = require('youtube-clipper-skill');

// 1. 环境检查
const env = await checkEnvironment();
console.log('yt-dlp version:', env.versions.ytDlp);
console.log('Subtitle support:', env.libass);

// 2. 下载视频
const videoPath = await downloadVideo('https://youtube.com/watch?v=VIDEO_ID', {
  quality: '1080p',
  format: 'mp4',
  outputPath: './downloads'
});

// 3. 创建剪辑
const clips = await createClips(videoPath, [
  { startTime: 30, endTime: 90, title: '精彩片段1' },
  { startTime: 120, endTime: 180, title: '精彩片段2' }
]);

// 4. 平台适配
const tiktokClip = await adaptForPlatform(clips[0], 'tiktok');
```

### 5.5 配置自定义

编辑 `~/.config/youtube-clipper/config.json`：

```json
{
  "downloadDir": "./my-clips",
  "defaultQuality": "720p",
  "includeSubtitles": false,
  "maxConcurrentDownloads": 5,
  "platforms": {
    "custom": {
      "aspectRatio": "1:1",
      "maxDuration": 120
    }
  }
}
```

### 5.6 环境变量配置

```bash
# 设置配置文件路径
export YOUTUBE_CLIPPER_CONFIG=/path/to/config.json

# 设置临时目录
export YOUTUBE_CLIPPER_TEMP_DIR=/tmp/my-clipper

# 设置日志级别
export YOUTUBE_CLIPPER_LOG_LEVEL=debug
```

---

## 6. 常见问题

### 6.1 yt-dlp 下载失败

**问题**: 视频下载报错或速度很慢

**解决方案**:
```bash
# 更新 yt-dlp 到最新版
pip install --upgrade yt-dlp

# 检查网络连接
yt-dlp --test-url https://www.youtube.com

# 使用代理
yt-dlp --proxy socks5://127.0.0.1:1080 URL
```

### 6.2 FFmpeg 字幕不生效

**问题**: 字幕没有叠加到视频中

**解决方案**:
```bash
# 检查字幕过滤器是否可用
ffmpeg -filters 2>&1 | grep subtitles

# 如果没有，需要重新编译 FFmpeg 或安装带 libass 的版本
# Ubuntu
sudo apt install ffmpeg libass-dev

# macOS
brew reinstall ffmpeg --with-libass
```

### 6.3 内存不足

**问题**: 处理大视频时内存溢出

**解决方案**:
```javascript
// 在配置中减少并发数
{
  "maxConcurrentDownloads": 1,
  "maxConcurrentClips": 2
}
```

### 6.4 时间戳格式问题

**问题**: 时间段解析错误

**正确格式**:
- `30` - 30秒
- `1:30` - 1分30秒
- `1:30:00` - 1小时30分钟
- `30-90` - 从30秒到90秒
- `1:00-2:30` - 从1分钟到2分30秒

### 6.5 输出文件损坏

**问题**: 生成的视频无法播放

**解决方案**:
```bash
# 检查输出文件完整性
ffprobe output.mp4

# 如果使用 -c copy 出现问题，尝试重新编码
ffmpeg -i input.mp4 -ss 30 -to 90 -c:v libx264 -c:a aac output.mp4
```

---

## 附录

### A. 相关资源链接

| 资源 | 链接 |
|------|------|
| 主项目仓库 | https://github.com/op7418/Youtube-clipper-skill |
| Agent Skills 市场 | https://skills.sh/ |
| yt-dlp 文档 | https://github.com/yt-dlp/yt-dlp |
| FFmpeg 文档 | https://ffmpeg.org/documentation.html |

### B. 同类工具对比

| 工具 | 特点 | GitHub |
|------|------|--------|
| youtube-clipper-skill | Agent Skill 集成 | op7418/Youtube-clipper-skill |
| yt-short-clipper | 专注短视频转换 | jipraks/yt-short-clipper |
| Gemini AI + FFmpeg | AI 智能识别片段 | n8n 工作流模板 |

### C. 版权提醒

- 遵守 YouTube 服务条款
- 注意第三方视频版权保护
- 仅用于个人学习和合法用途
- 避免未经授权的下载和再分发

---

*指南版本: v1.0*  
*最后更新: 2026-01-25*  
*适用于: OpenCode 及兼容的 AI Agent 平台*
