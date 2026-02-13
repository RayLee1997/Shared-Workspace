# 关键资源清单

## 核心仓库

### 主要实现
- **op7418/Youtube-clipper-skill**
  - URL: https://github.com/op7418/Youtube-clipper-skill
  - 类型: Agent Skill实现
  - 特点: 自动化环境检测、完整剪辑流程
  - 安装: `npx skills add https://github.com/op7418/youtube-clipper-skill --skill youtube-clipper`

### 同类工具
- **jipraks/yt-short-clipper**
  - URL: https://github.com/jipraks/yt-short-clipper
  - 类型: 短视频转换工具
  - 特点: 专注短视频平台格式适配
  - Star: 86, Fork: 29 (截至调研时间)

### 其他相关项目
- **Zero/yt-clipper**
  - URL: https://gitgud.io/Zero/yt-clipper/-/tree/main
  - 平台: GitLab
  - 状态: 开发中

## 技术文档

### FFmpeg相关
- **Using FFmpeg to Trim Long YouTube Videos Lightning Fast**
  - URL: https://linuxcreative.com/articles/using-ffmpeg-to-trim-long-youtube-videos-lightning-fast/
  - 作者: Wesley Sinks
  - 发布: 2023-07-17
  - 内容: 详细的yt-dlp + FFmpeg使用指南

### 社区讨论
- **using yt-dlp to download part of a video**
  - URL: https://forum.videohelp.com/threads/409094-using-yt-dlp-to-download-part-of-a-video
  - 平台: VideoHelp Forum
  - 内容: yt-dlp部分下载技术讨论

## AI增强方案

### 工作流模板
- **Extract viral-worthy clips from YouTube videos with Gemini AI & FFmpeg editing**
  - URL: https://n8n.io/workflows/11584-extract-viral-worthy-clips-from-youtube-videos-with-gemini-ai-and-ffmpeg-editing/
  - 平台: n8n
  - 作者: Habeeb Mohammed
  - 特点: AI分析 + 专业视频编辑结合

## 生态系统

### 技能市场
- **The Agent Skills Directory**
  - URL: https://skills.sh/
  - 描述: AI助手技能分发平台
  - 支持的Agent: OpenCode, Claude Code, Cursor, Windsurf等
  - 安装方式: `npx skills add <owner/repo>`

### 趋势参考
- **GitHunt - Trending Github Repositories**
  - URL: https://kamranahmed.info/githunt
  - 用途: 追踪相关项目的趋势变化

## 工具链

### 核心依赖
- **yt-dlp**
  - 官方文档: https://github.com/yt-dlp/yt-dlp
  - 功能: YouTube视频下载
  - 特点: 活跃维护，功能丰富

- **FFmpeg**
  - 官方网站: https://ffmpeg.org/
  - 功能: 视频处理和剪辑
  - 特点: 专业级视频处理工具

### 相关工具
- **mpv**
  - 功能: 视频预览播放器
  - 用途: 剪辑结果预览

## 技术示例

### 常用命令
```bash
# 环境检查
yt-dlp --version
ffmpeg -version
ffmpeg -filters 2>&1 | grep subtitles

# 下载视频
yt-dlp -f 244+140 https://www.youtube.com/watch?v=VIDEO_ID

# 剪辑视频
yt-dlp --downloader ffmpeg --downloader-args "ffmpeg_i1:ss 997 -to 2512" URL
```

### 安装依赖
```bash
# 大多数Linux包管理器支持
sudo apt install yt-dlp ffmpeg mpv  # Ubuntu/Debian
sudo yum install yt-dlp ffmpeg mpv  # CentOS/RHEL
```

---

*更新时间: 2026-01-25*