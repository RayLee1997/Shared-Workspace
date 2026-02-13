#!/bin/bash

# YouTube Clipper Skill - 安装脚本
# 适用于 Ubuntu/Debian, CentOS/RHEL, macOS, Windows(WSL)

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检测操作系统
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command -v apt-get &> /dev/null; then
            echo "ubuntu"
        elif command -v yum &> /dev/null; then
            echo "centos"
        elif command -v dnf &> /dev/null; then
            echo "fedora"
        else
            echo "linux_unknown"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    else
        echo "unknown"
    fi
}

# 检查命令是否存在
command_exists() {
    command -v "$1" &> /dev/null
}

# 安装包管理器
install_package_manager() {
    local os=$1
    case $os in
        "ubuntu")
            if ! command_exists apt-get; then
                log_error "apt-get not found. Please use a different installation method."
                exit 1
            fi
            ;;
        "centos"|"fedora")
            if ! command_exists yum && ! command_exists dnf; then
                log_error "yum/dnf not found. Please use a different installation method."
                exit 1
            fi
            ;;
        "macos")
            if ! command_exists brew; then
                log_info "Installing Homebrew..."
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            fi
            ;;
    esac
}

# 安装依赖
install_dependencies() {
    local os=$1
    log_info "Installing dependencies for $os..."
    
    case $os in
        "ubuntu")
            sudo apt-get update
            sudo apt-get install -y yt-dlp ffmpeg libass-dev mpv
            ;;
        "centos")
            sudo yum install -y epel-release
            sudo yum install -y yt-dlp ffmpeg libass mpv
            ;;
        "fedora")
            sudo dnf install -y yt-dlp ffmpeg libass mpv
            ;;
        "macos")
            brew install yt-dlp ffmpeg libass mpv
            ;;
        *)
            log_warn "Unknown OS: $os. Please install dependencies manually:"
            echo "  - yt-dlp: pip install yt-dlp"
            echo "  - ffmpeg: https://ffmpeg.org/download.html"
            echo "  - libass: Usually included with ffmpeg"
            echo "  - mpv: https://mpv.io/installation/"
            ;;
    esac
}

# 验证安装
verify_installation() {
    log_info "Verifying installation..."
    
    # 检查 yt-dlp
    if command_exists yt-dlp; then
        local yt_dlp_version=$(yt-dlp --version 2>/dev/null | head -n1)
        log_info "✓ yt-dlp installed: $yt_dlp_version"
    else
        log_error "✗ yt-dlp not found"
        return 1
    fi
    
    # 检查 ffmpeg
    if command_exists ffmpeg; then
        local ffmpeg_version=$(ffmpeg -version 2>/dev/null | grep "ffmpeg version" | head -n1)
        log_info "✓ ffmpeg installed: $ffmpeg_version"
    else
        log_error "✗ ffmpeg not found"
        return 1
    fi
    
    # 检查字幕支持
    if ffmpeg -filters 2>&1 | grep -q "subtitles"; then
        log_info "✓ subtitles filter available"
    else
        log_warn "⚠ subtitles filter not found - subtitle processing may not work"
    fi
    
    # 检查 mpv
    if command_exists mpv; then
        local mpv_version=$(mpv --version 2>/dev/null | head -n1)
        log_info "✓ mpv installed: $mpv_version"
    else
        log_warn "⚠ mpv not found - video preview not available"
    fi
    
    log_info "Installation verification completed!"
}

# 安装 Node.js 依赖
install_node_dependencies() {
    log_info "Installing Node.js dependencies..."
    
    if command_exists npm; then
        npm install -g npx
    elif command_exists yarn; then
        yarn global add npx
    else
        log_warn "npm/yarn not found. Please install Node.js and npm manually."
    fi
}

# 创建配置文件
create_config() {
    local config_dir="$HOME/.config/youtube-clipper"
    local config_file="$config_dir/config.json"
    
    log_info "Creating configuration directory..."
    mkdir -p "$config_dir"
    
    if [[ ! -f "$config_file" ]]; then
        log_info "Creating default configuration..."
        cat > "$config_file" << EOF
{
  "downloadDir": "$HOME/Downloads/youtube-clips",
  "tempDir": "/tmp/youtube-clipper",
  "outputFormats": ["mp4"],
  "defaultQuality": "1080p",
  "includeSubtitles": true,
  "maxConcurrentDownloads": 3,
  "cleanupTempFiles": true,
  "platforms": {
    "tiktok": {
      "aspectRatio": "9:16",
      "maxDuration": 60
    },
    "instagram": {
      "aspectRatio": "4:5", 
      "maxDuration": 90
    },
    "youtube": {
      "aspectRatio": "16:9",
      "maxDuration": 60
    }
  }
}
EOF
        log_info "Configuration created at: $config_file"
    else
        log_info "Configuration file already exists: $config_file"
    fi
}

# 主函数
main() {
    log_info "Starting YouTube Clipper Skill installation..."
    
    # 检测操作系统
    local os=$(detect_os)
    log_info "Detected OS: $os"
    
    # 安装包管理器
    install_package_manager "$os"
    
    # 安装依赖
    install_dependencies "$os"
    
    # 验证安装
    verify_installation
    
    # 安装 Node.js 依赖
    install_node_dependencies
    
    # 创建配置
    create_config
    
    log_info "✅ YouTube Clipper Skill installation completed successfully!"
    log_info "You can now use the skill with: npx skills add https://github.com/op7418/youtube-clipper-skill --skill youtube-clipper"
    
    # 创建示例使用命令
    echo ""
    log_info "Example usage:"
    echo "  npx skills run youtube-clipper --url=https://youtube.com/watch?v=VIDEO_ID --segments=0:30-1:30,2:00-2:30"
}

# 运行主函数
main "$@"