# 技术实现方案

## 架构设计

### 核心组件架构
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Input Handler │    │  Download Manager│    │  Clip Processor │
│                 │    │                 │    │                 │
│ • URL解析       │───▶│ • yt-dlp集成     │───▶│ • FFmpeg剪辑    │
│ • 参数验证      │    │ • 进度监控      │    │ • 字幕处理      │
│ • 错误处理      │    │ • 临时文件管理  │    │ • 格式转换      │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│  Config Manager │    │  Temp Storage   │    │  Output Manager │
│                 │    │                 │    │                 │
│ • 环境配置      │    │ • 下载缓存      │    │ • 文件输出      │
│ • 依赖检查      │    │ • 剪辑缓存      │    │ • 元数据生成    │
│ • 默认设置      │    │ • 清理策略      │    │ • 批量导出      │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 详细实现

### 1. 环境检测模块

#### 依赖检查
```typescript
interface EnvironmentCheck {
  ytDlp: boolean;
  ffmpeg: boolean;
  libass: boolean;
  versions: {
    ytDlp?: string;
    ffmpeg?: string;
  };
}

async function checkEnvironment(): Promise<EnvironmentCheck> {
  const checks: EnvironmentCheck = {
    ytDlp: false,
    ffmpeg: false,
    libass: false,
    versions: {}
  };

  // 检查yt-dlp
  try {
    const ytDlpVersion = await execCommand('yt-dlp --version');
    checks.ytDlp = true;
    checks.versions.ytDlp = ytDlpVersion.trim();
  } catch (error) {
    console.error('yt-dlp not found:', error);
  }

  // 检查FFmpeg
  try {
    const ffmpegVersion = await execCommand('ffmpeg -version');
    checks.ffmpeg = true;
    checks.versions.ffmpeg = parseFFmpegVersion(ffmpegVersion);
    
    // 检查字幕支持
    const subtitleSupport = await execCommand('ffmpeg -filters 2>&1 | grep subtitles');
    checks.libass = subtitleSupport.includes('subtitles');
  } catch (error) {
    console.error('FFmpeg not found:', error);
  }

  return checks;
}
```

#### 自动安装提示
```bash
# Ubuntu/Debian
sudo apt update && sudo apt install yt-dlp ffmpeg libass-dev

# macOS
brew install yt-dlp ffmpeg

# Windows (使用Chocolatey)
choco install yt-dlp ffmpeg

# 或使用pip
pip install yt-dlp
```

### 2. 下载管理模块

#### 视频信息获取
```typescript
interface VideoInfo {
  id: string;
  title: string;
  duration: number;
  formats: VideoFormat[];
  subtitles: SubtitleInfo[];
  thumbnail: string;
}

async function getVideoInfo(url: string): Promise<VideoInfo> {
  const command = `yt-dlp --dump-json "${url}"`;
  const output = await execCommand(command);
  const data = JSON.parse(output);
  
  return {
    id: data.id,
    title: data.title,
    duration: data.duration,
    formats: data.formats,
    subtitles: data.subtitles,
    thumbnail: data.thumbnail
  };
}
```

#### 智能格式选择
```typescript
function selectOptimalFormat(formats: VideoFormat[]): VideoFormat[] {
  // 优先选择1080p视频 + 高质量音频
  const videoFormat = formats.find(f => 
    f.height === 1080 && f.vcodec !== 'none' && f.acodec === 'none'
  );
  
  const audioFormat = formats.find(f => 
    f.acodec !== 'none' && f.vcodec === 'none'
  );
  
  return [videoFormat, audioFormat].filter(Boolean);
}
```

### 3. 智能剪辑模块

#### 时间段处理
```typescript
interface ClipSegment {
  startTime: number;
  endTime: number;
  title?: string;
  includeSubtitles: boolean;
}

async function createClip(
  videoPath: string, 
  segment: ClipSegment,
  outputPath: string
): Promise<void> {
  const ffmpegArgs = [
    '-i', videoPath,
    '-ss', segment.startTime.toString(),
    '-to', segment.endTime.toString(),
    '-c', 'copy', // 避免重新编码以提高速度
    '-avoid_negative_ts', '1'
  ];
  
  if (segment.includeSubtitles) {
    ffmpegArgs.push(
      '-vf', 'subtitles=subtitle.ass',
      '-c:a', 'copy'
    );
  }
  
  ffmpegArgs.push(outputPath);
  
  await execCommand(`ffmpeg ${ffmpegArgs.join(' ')}`);
}
```

#### 批量剪辑处理
```typescript
async function processBatchClips(
  videoPath: string,
  segments: ClipSegment[],
  outputDir: string
): Promise<string[]> {
  const outputFiles: string[] = [];
  
  // 并行处理以提高效率
  const promises = segments.map(async (segment, index) => {
    const outputPath = path.join(outputDir, `clip_${index + 1}.mp4`);
    await createClip(videoPath, segment, outputPath);
    return outputPath;
  });
  
  const results = await Promise.all(promises);
  outputFiles.push(...results);
  
  return outputFiles;
}
```

### 4. 输出管理模块

#### 元数据生成
```typescript
interface ClipMetadata {
  title: string;
  description: string;
  tags: string[];
  duration: number;
  originalUrl: string;
  timestamp: string;
}

function generateMetadata(
  videoInfo: VideoInfo,
  segment: ClipSegment
): ClipMetadata {
  return {
    title: `${videoInfo.title} - Clip (${segment.startTime}s-${segment.endTime}s)`,
    description: `Clip from ${videoInfo.title}`,
    tags: extractTags(videoInfo.title),
    duration: segment.endTime - segment.startTime,
    originalUrl: videoInfo.id,
    timestamp: new Date().toISOString()
  };
}
```

#### 平台适配输出
```typescript
interface PlatformConfig {
  resolution: { width: number; height: number };
  aspectRatio: string;
  maxDuration: number;
  format: string;
}

const PLATFORMS: Record<string, PlatformConfig> = {
  tiktok: {
    resolution: { width: 1080, height: 1920 },
    aspectRatio: '9:16',
    maxDuration: 60,
    format: 'mp4'
  },
  instagram: {
    resolution: { width: 1080, height: 1350 },
    aspectRatio: '4:5',
    maxDuration: 90,
    format: 'mp4'
  },
  youtube: {
    resolution: { width: 1920, height: 1080 },
    aspectRatio: '16:9',
    maxDuration: 60,
    format: 'mp4'
  }
};

async function adaptForPlatform(
  inputPath: string,
  outputPath: string,
  platform: string
): Promise<void> {
  const config = PLATFORMS[platform];
  if (!config) throw new Error(`Unsupported platform: ${platform}`);
  
  const ffmpegArgs = [
    '-i', inputPath,
    '-vf', `scale=${config.resolution.width}:${config.resolution.height}:force_original_aspect_ratio=decrease,pad=${config.resolution.width}:${config.resolution.height}:(ow-iw)/2:(oh-ih)/2`,
    '-c:a', 'copy',
    '-t', config.maxDuration.toString(),
    outputPath
  ];
  
  await execCommand(`ffmpeg ${ffmpegArgs.join(' ')}`);
}
```

## 性能优化

### 1. 并行处理
- 使用Worker Pool处理多个剪辑任务
- I/O密集型操作与CPU密集型操作分离
- 智能任务调度避免资源竞争

### 2. 缓存策略
- 下载视频缓存，避免重复下载
- 剪辑片段缓存，支持快速预览
- 元数据缓存，提高响应速度

### 3. 内存管理
- 流式处理大文件，避免内存溢出
- 及时清理临时文件
- 监控内存使用情况

## 错误处理

### 网络错误处理
```typescript
async function downloadWithRetry(url: string, maxRetries = 3): Promise<string> {
  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      return await downloadVideo(url);
    } catch (error) {
      if (attempt === maxRetries) throw error;
      
      const delay = Math.pow(2, attempt) * 1000; // 指数退避
      await new Promise(resolve => setTimeout(resolve, delay));
    }
  }
  throw new Error('Download failed after maximum retries');
}
```

### 时间戳验证
```typescript
function validateTimeSegment(
  startTime: number, 
  endTime: number, 
  videoDuration: number
): void {
  if (startTime < 0 || endTime <= startTime) {
    throw new Error('Invalid time segment');
  }
  
  if (endTime > videoDuration) {
    throw new Error('Time segment exceeds video duration');
  }
}
```

## 安全考虑

### 1. 输入验证
- URL格式验证
- 时间戳范围检查
- 文件路径安全检查

### 2. 资源限制
- 最大文件大小限制
- 并发任务数量限制
- 磁盘空间使用监控

### 3. 权限控制
- 临时文件权限设置
- 输出目录访问控制
- 命令执行权限限制

---

*实现方案版本: v1.0*  
*最后更新: 2026-01-25*