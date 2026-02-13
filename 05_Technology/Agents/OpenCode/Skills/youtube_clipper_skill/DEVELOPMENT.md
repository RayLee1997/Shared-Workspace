# YouTube Clipper Skill - 开发指南

## 快速开始

### 1. 安装依赖
```bash
# 运行自动安装脚本
./install.sh

# 或手动安装
npm install
```

### 2. 基本使用
```bash
# 基本剪辑
npx skills run youtube-clipper --url=https://youtube.com/watch?v=VIDEO_ID

# 指定时间段
npx skills run youtube-clipper --url=URL --segments=0:30-1:30,2:00-2:30

# 输出到特定平台格式
npx skills run youtube-clipper --url=URL --platform=tiktok --segments=1:00-1:30
```

## API 文档

### 核心接口

#### `checkEnvironment()`
检查运行环境是否满足要求。

```javascript
const env = await checkEnvironment();
console.log(env.versions.ytDlp); // yt-dlp版本
console.log(env.libass); // 字幕支持状态
```

#### `downloadVideo(url, options)`
下载YouTube视频。

```javascript
const videoPath = await downloadVideo('https://youtube.com/watch?v=VIDEO_ID', {
  quality: '1080p',
  format: 'mp4',
  outputPath: './downloads'
});
```

#### `createClips(videoPath, segments)`
创建视频片段。

```javascript
const clips = await createClips(videoPath, [
  { startTime: 30, endTime: 90, title: '精彩片段1' },
  { startTime: 120, endTime: 180, title: '精彩片段2' }
]);
```

#### `adaptForPlatform(clipPath, platform)`
适配特定平台格式。

```javascript
const adaptedClip = await adaptForPlatform('clip.mp4', 'tiktok');
```

### 配置选项

```javascript
const config = {
  // 下载设置
  downloadDir: './downloads',
  tempDir: './temp',
  
  // 质量设置
  defaultQuality: '1080p',
  audioQuality: 'high',
  
  // 输出设置
  outputFormats: ['mp4'],
  includeSubtitles: true,
  
  // 性能设置
  maxConcurrentDownloads: 3,
  maxConcurrentClips: 5,
  
  // 平台设置
  platforms: {
    tiktok: { aspectRatio: '9:16', maxDuration: 60 },
    instagram: { aspectRatio: '4:5', maxDuration: 90 },
    youtube: { aspectRatio: '16:9', maxDuration: 60 }
  }
};
```

## 开发环境设置

### 环境要求
- Node.js >= 14.0.0
- yt-dlp
- FFmpeg (with libass support)
- mpv (可选，用于预览)

### 开发工具
```bash
# 安装开发依赖
npm install --dev

# 运行开发模式
npm run dev

# 运行测试
npm test

# 代码检查
npm run lint

# 构建生产版本
npm run build
```

### 调试配置
```javascript
// 启用详细日志
process.env.DEBUG = 'youtube-clipper:*';

// 启用性能监控
process.env.PERFORMANCE_MONITOR = 'true';
```

## 架构详解

### 模块结构
```
src/
├── index.js              # 入口文件
├── core/
│   ├── downloader.js     # 下载管理
│   ├── clipper.js        # 剪辑处理
│   └── adapter.js        # 平台适配
├── utils/
│   ├── env-check.js      # 环境检查
│   ├── config.js         # 配置管理
│   └── logger.js         # 日志系统
├── cli/
│   ├── commands.js       # CLI命令
│   └── prompts.js        # 交互提示
└── platforms/
    ├── tiktok.js         # TikTok适配
    ├── instagram.js      # Instagram适配
    └── youtube.js        # YouTube适配
```

### 数据流
```
用户输入 → 参数验证 → 环境检查 → 视频下载 → 智能剪辑 → 平台适配 → 输出结果
```

## 测试

### 单元测试
```bash
# 运行所有测试
npm test

# 运行特定测试
npm test -- --grep "downloader"

# 生成覆盖率报告
npm run test:coverage
```

### 集成测试
```bash
# 测试完整工作流
npm run test:integration

# 测试平台适配
npm run test:platforms
```

### 测试数据
测试使用模拟数据，无需实际下载视频：
```javascript
// tests/fixtures/video-info.json
{
  "id": "test_video_id",
  "title": "Test Video",
  "duration": 600,
  "formats": [...]
}
```

## 性能优化

### 并行处理
```javascript
// 并行下载
const downloadPromises = urls.map(url => downloadVideo(url));
const videos = await Promise.all(downloadPromises);

// 并行剪辑
const clipPromises = segments.map(segment => createClip(video, segment));
const clips = await Promise.all(clipPromises);
```

### 内存管理
```javascript
// 流式处理大文件
const stream = fs.createReadStream(largeVideoPath);
stream.pipe(ffmpegProcess);

// 及时清理临时文件
process.on('exit', cleanupTempFiles);
```

### 缓存策略
```javascript
// 视频信息缓存
const videoInfoCache = new Map();

// 剪辑结果缓存
const clipCache = new LRUCache({ max: 100 });
```

## 部署

### Docker 部署
```dockerfile
FROM node:16-alpine

# 安装系统依赖
RUN apk add --no-cache ffmpeg yt-dlp mpv

# 安装应用依赖
COPY package*.json ./
RUN npm ci --only=production

# 复制应用代码
COPY . .

# 设置入口
CMD ["npm", "start"]
```

### 环境变量
```bash
# 配置文件路径
export YOUTUBE_CLIPPER_CONFIG=/path/to/config.json

# 临时目录
export YOUTUBE_CLIPPER_TEMP_DIR=/tmp/youtube-clipper

# 日志级别
export YOUTUBE_CLIPPER_LOG_LEVEL=info
```

## 故障排除

### 常见问题

#### 1. yt-dlp 下载失败
```bash
# 更新 yt-dlp
pip install --upgrade yt-dlp

# 检查网络连接
yt-dlp --test-url https://www.youtube.com
```

#### 2. FFmpeg 字幕支持问题
```bash
# 检查字幕支持
ffmpeg -filters | grep subtitles

# 重新编译 FFmpeg (如需要)
ffmpeg -configure --enable-libass
```

#### 3. 内存不足
```javascript
// 减少并发数
config.maxConcurrentDownloads = 1;
config.maxConcurrentClips = 2;

// 使用磁盘缓存
config.useDiskCache = true;
```

### 调试技巧

#### 启用详细日志
```javascript
const logger = require('./utils/logger');
logger.setLevel('debug');
```

#### 性能分析
```javascript
const performance = require('perf_hooks').performance;
const start = performance.now();
// ... 执行操作
const duration = performance.now() - start;
console.log(`Operation took ${duration}ms`);
```

## 贡献指南

### 提交代码
1. Fork 项目
2. 创建功能分支: `git checkout -b feature/new-feature`
3. 提交更改: `git commit -am 'Add new feature'`
4. 推送分支: `git push origin feature/new-feature`
5. 提交 Pull Request

### 代码规范
- 使用 ESLint 检查代码风格
- 编写单元测试覆盖新功能
- 更新相关文档

### 问题报告
- 使用 GitHub Issues 报告 bug
- 提供详细的复现步骤
- 包含环境信息和错误日志

---

*开发指南版本: v1.0*  
*最后更新: 2026-01-25*