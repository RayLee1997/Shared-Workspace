# Google Cloud GPU 租赁与开源模型部署指南 (配合 Cloudflare Tunnel)

## 概述

本教程指导如何在 Google Cloud Platform (GCP) 上租赁 GPU 服务器，部署开源大语言模型 (LLM)，并通过 Cloudflare Tunnel 安全地对外提供 API 服务。

**目标**：
- 在 GCP 上低成本租赁高性能 GPU (T4/L4/A100)
- 使用 vLLM 或 Ollama 部署开源模型 (如 Llama 3, Qwen 2)
- 使用 Cloudflare Tunnel 将本地 API (localhost:8000) 映射到公网域名
- 配置 Cloudflare Access 保护接口，防止被盗刷

## 前置条件

- Google Cloud Platform 账号 (建议申请 $300 赠金)
- Cloudflare 账号
- 一个已托管到 Cloudflare 的域名
- 基本的 Linux 命令行操作能力

---

## 第一部分：GCP GPU 实例创建

### 步骤 1.1：申请 GPU 配额 (Quota)

新账号通常默认 GPU 配额为 0。

1. 登录 [Google Cloud Console](https://console.cloud.google.com/)。
2. 导航至 **IAM & Admin** > **Quotas**。
3. 搜索 "GPUs (all regions)" 或特定区域 (如 "NVIDIA T4 GPUs")。
4. 如果 Limit 为 0，点击 **Edit Quotas**，申请将配额提升至 1 或更多。
5. 等待 Google 审批 (通常需要几小时到 1 天)。

### 步骤 1.2：创建 VM 实例

1. 导航至 **Compute Engine** > **VM instances**。
2. 点击 **Create Instance**。
3. **Machine configuration**:
   - Series: **N1** (配合 T4) 或 **G2** (配合 L4，性价比高)
   - Machine type: `n1-standard-4` (4 vCPU, 15GB RAM) 或 `g2-standard-4`
4. **GPU**:
   - 点击 "Change" (在 CPU 选项附近) 或展开 "Advanced options"。
   - 添加 GPU，例如 **NVIDIA Tesla T4** (1个)。
   - *注意：确保勾选 "Switch to on-demand" 如果 Spot 实例没有库存。*
5. **Boot disk**:
   - 点击 **Change**。
   - **Operating System**: **Deep Learning on Linux** (推荐)。
   - **Version**: **Deep Learning VM with CUDA 11.8 M110** (或其他最新稳定版)。
   - *选择 Deep Learning 镜像会自动安装 NVIDIA 驱动和 Docker，省去大量配置时间。*
   - Size: 至少 **100 GB** (模型权重文件很大)。
6. **Firewall**: 勾选 "Allow HTTP traffic" 和 "Allow HTTPS traffic"。
7. 点击 **Create**。

---

## 第二部分：环境配置与模型部署

SSH 连接到刚创建的 VM 实例。

### 步骤 2.1：验证 GPU 驱动

```bash
nvidia-smi
# 应该能看到 GPU 型号和 CUDA 版本
```

### 步骤 2.2：使用 vLLM 部署模型 (推荐)

我们将使用 Docker 运行 [vLLM](https://github.com/vllm-project/vllm)，它推理速度极快，支持 OpenAI 兼容 API。

1. **设置 HuggingFace Token (如果下载受限模型)**:
   ```bash
   export HF_TOKEN="your_huggingface_token"
   ```

2. **运行 Docker 容器**:
   以部署 `Qwen/Qwen2-7B-Instruct` 为例：

   ```bash
   sudo docker run --runtime nvidia --gpus all \
       -v ~/.cache/huggingface:/root/.cache/huggingface \
       -p 8000:8000 \
       --ipc=host \
       vllm/vllm-openai:latest \
       --model Qwen/Qwen2-7B-Instruct
   ```
   
   *参数说明*：
   - `--model`: 指定 HuggingFace 模型名称 (会自动下载)。
   - `-p 8000:8000`: 暴露 8000 端口。
   - `--ipc=host`: 防止内存溢出。

3. **测试本地 API**:
   ```bash
   curl http://localhost:8000/v1/models
   ```

### 备选方案：使用 Ollama (更简单)

如果 vLLM 配置太复杂，可以使用 Ollama：

```bash
# 安装 Ollama
curl -fsSL https://ollama.com/install.sh | sh

# 运行模型
ollama run llama3

# 启动服务 (默认监听 11434)
# Ollama 默认已在后台运行
```

---

## 第三部分：配置 Cloudflare Tunnel

我们不需要在 GCP 防火墙开放 8000 端口，而是通过 Tunnel 穿透出去。

### 步骤 3.1：安装 cloudflared (Debian/Ubuntu)

```bash
# 添加 GPG key
curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | sudo tee /usr/share/keyrings/cloudflare-main.gpg >/dev/null

# 添加源
echo 'deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared jammy main' | sudo tee /etc/apt/sources.list.d/cloudflared.list

# 安装
sudo apt-get update && sudo apt-get install cloudflared
```

### 步骤 3.2：创建并运行 Tunnel

1. 登录 [Cloudflare Zero Trust Dashboard](https://one.dash.cloudflare.com)。
2. **Networks** > **Tunnels** > **Create a tunnel**。
3. 命名为 `gcp-gpu-server`。
4. 复制安装命令 (包含 Token)，在 GCP VM 上执行：
   ```bash
   sudo cloudflared service install <YOUR_TOKEN>
   ```

### 步骤 3.3：配置 Public Hostname

1. 在 Tunnel 设置页面的 **Public Hostname** 标签。
2. **Add a public hostname**。
3. **Subdomain**: `llm-api` (例如)。
4. **Domain**: `yourdomain.com`。
5. **Service**:
   - Type: `HTTP`
   - URL: `localhost:8000` (如果是 vLLM) 或 `localhost:11434` (如果是 Ollama)。
6. 保存。

现在，你的模型 API 可以通过 `https://llm-api.yourdomain.com` 访问。

---

## 第四部分：安全防护 (关键)

GPU 资源昂贵，必须防止 API 被未授权访问。

### 步骤 4.1：配置 Cloudflare Access

1. **Zero Trust Dashboard** > **Access** > **Applications**。
2. **Add an application** > **Self-hosted**。
3. **Application domain**: `llm-api.yourdomain.com`。
4. **Policy**:
   - Rule type: **Service Token** (如果是给程序调用) 或 **Email** (如果是人工访问)。
   - **推荐 (API 调用)**: 创建一个 Service Token。
     - 在 Access > Service Auth > Create Service Token。
     - 生成 `Client ID` 和 `Client Secret`。
     - 在 Policy 中选择 "Include" -> "Service Token" -> 选择刚创建的 Token。

### 步骤 4.2：客户端调用

在使用 API 时，需要在 Header 中带上认证信息：

```python
import openai

client = openai.OpenAI(
    base_url="https://llm-api.yourdomain.com/v1",
    api_key="EMPTY",
    default_headers={
        "CF-Access-Client-Id": "your-client-id",
        "CF-Access-Client-Secret": "your-client-secret"
    }
)

completion = client.chat.completions.create(
    model="Qwen/Qwen2-7B-Instruct",
    messages=[{"role": "user", "content": "Hello!"}]
)
print(completion.choices[0].message.content)
```

---

## 第五部分：成本管理

**重要提醒**：
Google Cloud 的 GPU 实例按秒/按小时计费。不使用时请务必停止实例！

```bash
# 停止实例 (停止计费，但保留磁盘数据)
gcloud compute instances stop instance-name --zone=us-central1-a
```

建议配合 Spot 实例 (Preemptible) 使用，价格可降低 60%-90%，但随时可能被回收。

---

## 常用命令速查

| 任务 | 命令 |
|------|------|
| 监控 GPU 状态 | `watch -n 1 nvidia-smi` |
| 查看 Docker 容器 | `sudo docker ps` |
| 查看 Docker 日志 | `sudo docker logs -f <container_id>` |
| 重启 Cloudflared | `sudo systemctl restart cloudflared` |
| 停止 VM | `sudo poweroff` (或通过控制台停止) |
