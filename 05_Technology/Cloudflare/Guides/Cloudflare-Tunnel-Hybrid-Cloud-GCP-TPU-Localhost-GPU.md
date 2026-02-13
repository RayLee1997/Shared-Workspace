# Cloudflare Tunnel 整合混合云架构：GCP TPU + Localhost GPU 完全指南

## 概述

本指南详细介绍如何使用 Cloudflare Tunnel 构建一个混合云 AI 推理架构，将 **Google Cloud TPU/GPU 实例** 与 **本地家庭 GPU 服务器** 统一暴露为公网 API 服务，并通过智能路由实现负载均衡和故障转移。

**架构目标**：
- 云端 (GCP)：租赁按需 GPU/TPU 处理大模型推理任务
- 本地 (Home Server)：利用闲置硬件处理轻量级请求或作为备用节点
- 统一入口：通过 Cloudflare 提供单一 API 端点，自动路由到最优后端
- 零信任安全：所有流量经过 Cloudflare Access 认证

```text

                                   ┌─────────────────────────────────┐
                                   │   Cloudflare Edge Network       │
                                   │                                 │
                                   │  ┌───────────────────────────┐  │
     用户请求                       │  │   Cloudflare Access       │  │
  ────────────────────────────────►│  │   (Service Token / OTP)   │  │
  https://llm.yourdomain.com       │  └───────────────────────────┘  │
                                   │              │                  │
                                   │      ┌───────┴───────┐          │
                                   │      ▼               ▼          │
                                   │  ┌───────┐      ┌───────┐       │
                                   │  │Tunnel │      │Tunnel │       │
                                   │  │ gcp   │      │ home  │       │
                                   │  └───┬───┘      └───┬───┘       │
                                   └──────┼──────────────┼───────────┘
                                          │              │
                    ┌─────────────────────┘              └─────────────────────┐
                    ▼                                                          ▼
     ┌──────────────────────────────┐                       ┌──────────────────────────────┐
     │   Google Cloud Platform      │                       │   家庭服务器 (CentOS 9)       │
     │                              │                       │                              │
     │  ┌────────────────────────┐  │                       │  ┌────────────────────────┐  │
     │  │  VM with GPU/TPU       │  │                       │  │  Localhost GPU         │  │
     │  │  - vLLM (Qwen3-72B)    │  │                       │  │  - vLLM (Gemma3-27B)   │  │
     │  │  - Port 8000           │  │                       │  │  - Port 11434          │  │
     │  └────────────────────────┘  │                       │  └────────────────────────┘  │
     │                              │                       │                              │
     │  cloudflared → Tunnel gcp    │                       │  cloudflared → Tunnel home   │
     └──────────────────────────────┘                       └──────────────────────────────┘
```

---

## 第一部分：前置准备

### 1.1 资源清单

| 资源 | 用途 | 备注 |
|------|------|------|
| Cloudflare 账号 | 管理 Tunnel 和 Access | 免费版即可 |
| 托管域名 | 提供公网访问入口 | 需将 NS 指向 Cloudflare |
| GCP 账号 | 租赁云端 GPU/TPU | 新用户有 $300 赠金 |
| 家庭服务器 | 本地 GPU 推理节点 | CentOS 9 / Ubuntu |

### 1.2 Cloudflare 账号与域名配置

1. 注册 [Cloudflare](https://dash.cloudflare.com/sign-up) 账号
2. 添加域名，选择 Free 计划
3. 到域名注册商修改 NS 记录为 Cloudflare 提供的地址
4. 启用 Zero Trust：
   - 访问 [Zero Trust Dashboard](https://one.dash.cloudflare.com)
   - 创建 Team Name
   - 选择 Free 计划（需绑定支付方式但不扣费）

**验证**：
```bash
nslookup -type=NS yourdomain.com
# 应返回 xxx.ns.cloudflare.com
```

---

## 第二部分：GCP GPU/TPU 实例部署

### 2.1 申请 GPU/TPU 配额

新账号默认配额为 0，需先申请：

1. 登录 [Google Cloud Console](https://console.cloud.google.com/)
2. **IAM & Admin** > **Quotas**
3. 搜索目标资源：
   - GPU: `NVIDIA T4 GPUs` 或 `NVIDIA L4 GPUs`
   - TPU: `TPU v2/v3/v4 Preemptible`
4. 点击 **Edit Quotas**，申请 1 个或更多
5. 等待审批（通常几小时到 1 天）

### 2.2 创建 GPU VM 实例

1. **Compute Engine** > **VM instances** > **Create Instance**
2. 配置：
   - **Region**: `us-central1` (GPU 库存较多)
   - **Machine type**: `g2-standard-8` (配合 L4 GPU)
   - **GPU**: 添加 1x NVIDIA L4
   - **Boot disk**:
     - OS: **Deep Learning on Linux**
     - Version: **Deep Learning VM with CUDA 12.x**
     - Size: **200 GB**
   - **Firewall**: 勾选 Allow HTTP/HTTPS traffic
3. 点击 **Create**

### 2.3 部署 vLLM 推理服务

SSH 连接到 GCP VM：

```bash
# 验证 GPU
nvidia-smi

# 使用 Docker 运行 vLLM (OpenAI 兼容 API)
sudo docker run -d --name vllm \
    --runtime nvidia --gpus all \
    -v ~/.cache/huggingface:/root/.cache/huggingface \
    -p 8000:8000 \
    --ipc=host \
    --restart unless-stopped \
    vllm/vllm-openai:latest \
    --model Qwen/Qwen2-72B-Instruct-AWQ \
    --quantization awq \
    --max-model-len 8192

# 验证服务
curl http://localhost:8000/v1/models
```

### 2.4 安装 cloudflared 并创建 Tunnel

```bash
# Debian/Ubuntu
curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | sudo tee /usr/share/keyrings/cloudflare-main.gpg >/dev/null
echo 'deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared jammy main' | sudo tee /etc/apt/sources.list.d/cloudflared.list
sudo apt-get update && sudo apt-get install -y cloudflared
```

在 Zero Trust Dashboard 创建 Tunnel：
1. **Networks** > **Tunnels** > **Create a tunnel**
2. 命名为 `gcp-gpu`
3. 复制 Token 并在 VM 上执行：
   ```bash
   sudo cloudflared service install <GCP_TUNNEL_TOKEN>
   ```

配置 Public Hostname：
- Subdomain: `gcp-llm`
- Domain: `yourdomain.com`
- Service: `http://localhost:8000`

---

## 第三部分：家庭服务器 (CentOS 9) 部署

### 3.1 安装 cloudflared

```bash
# 添加仓库
sudo dnf install -y dnf-plugins-core
sudo dnf config-manager --add-repo https://pkg.cloudflare.com/cloudflared.repo

# 安装
sudo dnf install -y cloudflared

# 验证
cloudflared --version
```

### 3.2 部署 Ollama 推理服务

```bash
# 安装 Ollama
curl -fsSL https://ollama.com/install.sh | sh

# 拉取模型
ollama pull llama3:8b

# 配置为服务模式（监听所有接口）
sudo mkdir -p /etc/systemd/system/ollama.service.d
sudo tee /etc/systemd/system/ollama.service.d/override.conf <<EOF
[Service]
Environment="OLLAMA_HOST=0.0.0.0:11434"
EOF

sudo systemctl daemon-reload
sudo systemctl restart ollama

# 验证
curl http://localhost:11434/api/tags
```

### 3.3 创建 Home Tunnel

在 Zero Trust Dashboard 创建第二个 Tunnel：
1. **Networks** > **Tunnels** > **Create a tunnel**
2. 命名为 `home-gpu`
3. 复制 Token 并在家庭服务器上执行：
   ```bash
   sudo cloudflared service install <HOME_TUNNEL_TOKEN>
   ```

配置 Public Hostname：
- Subdomain: `home-llm`
- Domain: `yourdomain.com`
- Service: `http://localhost:11434`

### 3.4 配置 systemd 高可用

```bash
sudo systemctl edit cloudflared
```

添加：
```ini
[Service]
Restart=always
RestartSec=10
StartLimitIntervalSec=0
```

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now cloudflared
```

### 3.5 防火墙配置

cloudflared 只需出站连接：
```bash
# 确保出站端口可用
sudo firewall-cmd --permanent --add-port=7844/udp
sudo firewall-cmd --reload

# 验证连通性
cloudflared tunnel --edge-ip-version auto connectivity-check
```

---

## 第四部分：Cloudflare 统一入口与智能路由

### 4.1 创建统一 API 入口（Load Balancer 方式）

如果有 Cloudflare Pro 计划，可使用 Load Balancer：

1. **Traffic** > **Load Balancing** > **Create Load Balancer**
2. Hostname: `llm.yourdomain.com`
3. 添加两个 Origin Pool：
   - Pool 1: `gcp-llm.yourdomain.com` (权重: 80%)
   - Pool 2: `home-llm.yourdomain.com` (权重: 20%)
4. 配置健康检查：`GET /v1/models` 或 `/api/tags`

### 4.2 免费版替代方案：Cloudflare Workers 路由

创建 Worker 实现智能路由：

```javascript
// worker.js
export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    
    // 默认路由到 GCP
    let backend = "https://gcp-llm.yourdomain.com";
    
    // 根据路径或 header 选择后端
    if (url.pathname.startsWith("/ollama") || request.headers.get("X-Backend") === "home") {
      backend = "https://home-llm.yourdomain.com";
      url.pathname = url.pathname.replace("/ollama", "");
    }
    
    // 转发请求
    const newRequest = new Request(backend + url.pathname + url.search, {
      method: request.method,
      headers: request.headers,
      body: request.body,
    });
    
    return fetch(newRequest);
  }
};
```

部署 Worker 并绑定到 `llm.yourdomain.com`。

---

## 第五部分：安全防护 (Cloudflare Access)

### 5.1 创建 Service Token (API 调用)

1. **Zero Trust** > **Access** > **Service Auth**
2. **Create Service Token**
3. 保存 `Client ID` 和 `Client Secret`

### 5.2 配置 Access Application

1. **Access** > **Applications** > **Add an application**
2. 类型: **Self-hosted**
3. Application domain: `llm.yourdomain.com`（或 `gcp-llm` / `home-llm`）
4. Policy:
   - Action: **Allow**
   - Include: **Service Token** → 选择刚创建的 Token

### 5.3 客户端调用示例

```python
import openai

# 调用 GCP vLLM (大模型)
gcp_client = openai.OpenAI(
    base_url="https://gcp-llm.yourdomain.com/v1",
    api_key="EMPTY",
    default_headers={
        "CF-Access-Client-Id": "your-client-id",
        "CF-Access-Client-Secret": "your-client-secret"
    }
)

# 调用 Home Ollama (轻量模型)
home_client = openai.OpenAI(
    base_url="https://home-llm.yourdomain.com/v1",
    api_key="EMPTY",
    default_headers={
        "CF-Access-Client-Id": "your-client-id",
        "CF-Access-Client-Secret": "your-client-secret"
    }
)

# 根据任务复杂度选择后端
def smart_completion(prompt, complexity="low"):
    client = gcp_client if complexity == "high" else home_client
    model = "Qwen/Qwen2-72B-Instruct-AWQ" if complexity == "high" else "llama3:8b"
    
    return client.chat.completions.create(
        model=model,
        messages=[{"role": "user", "content": prompt}]
    )
```

### 5.4 邮箱 OTP 验证 (人工访问)

适用于 Web UI 或调试场景：

1. **Settings** > **Authentication** > **Add new** > **One-time PIN**
2. 在 Access Policy 中添加规则：
   - Include: **Emails** → `your-email@example.com`

---

## 第六部分：成本优化与运维

### 6.1 GCP 成本管理

```bash
# 停止 VM（停止计费，保留磁盘）
gcloud compute instances stop gcp-gpu-vm --zone=us-central1-a

# 启动 VM
gcloud compute instances start gcp-gpu-vm --zone=us-central1-a
```

**推荐策略**：
- 使用 **Spot/Preemptible** 实例，成本降低 60-90%
- 设置 **Budget Alerts**，防止超支
- 非高峰时段停止 GCP 实例，仅使用家庭服务器

### 6.2 监控与日志

**Cloudflare 侧**：
- Zero Trust Dashboard > **Logs** 查看访问记录
- **Analytics** 查看流量统计

**服务器侧**：
```bash
# cloudflared 日志
sudo journalctl -u cloudflared -f

# vLLM 日志 (GCP)
sudo docker logs -f vllm

# Ollama 日志 (Home)
sudo journalctl -u ollama -f

# GPU 监控
watch -n 1 nvidia-smi
```

### 6.3 故障转移测试

1. 停止 GCP cloudflared：`sudo systemctl stop cloudflared`
2. 验证请求自动路由到 Home 节点
3. 恢复 GCP 服务：`sudo systemctl start cloudflared`

---

## 第七部分：完整验证清单

| 检查项 | GCP 节点 | Home 节点 |
|--------|----------|-----------|
| cloudflared 运行 | `systemctl status cloudflared` | `systemctl status cloudflared` |
| 推理服务运行 | `curl localhost:8000/v1/models` | `curl localhost:11434/api/tags` |
| Tunnel 状态 | Dashboard 显示 HEALTHY | Dashboard 显示 HEALTHY |
| 公网访问 | `curl https://gcp-llm.yourdomain.com/v1/models` | `curl https://home-llm.yourdomain.com/api/tags` |
| Access 认证 | 带 Service Token Header 能访问 | 带 Service Token Header 能访问 |

---

## 常用命令速查

| 任务 | GCP (Debian/Ubuntu) | Home (CentOS 9) |
|------|---------------------|-----------------|
| 启动 Tunnel | `sudo systemctl start cloudflared` | `sudo systemctl start cloudflared` |
| 停止 Tunnel | `sudo systemctl stop cloudflared` | `sudo systemctl stop cloudflared` |
| 查看 Tunnel 日志 | `journalctl -u cloudflared -f` | `journalctl -u cloudflared -f` |
| 启动推理服务 | `docker start vllm` | `systemctl start ollama` |
| 监控 GPU | `watch nvidia-smi` | `watch nvidia-smi` |
| 更新 cloudflared | `apt update && apt upgrade cloudflared` | `dnf update cloudflared` |
| 连通性测试 | `cloudflared tunnel connectivity-check` | `cloudflared tunnel connectivity-check` |

---

## 参考资料

- [Cloudflare Tunnel 官方文档](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/)
- [Cloudflare Access 官方文档](https://developers.cloudflare.com/cloudflare-one/policies/access/)
- [vLLM GitHub](https://github.com/vllm-project/vllm)
- [Ollama 官方文档](https://ollama.com/)
- [Google Cloud GPU 定价](https://cloud.google.com/compute/gpus-pricing)

---

*文档创建日期：2026-01-26*
*适用环境：GCP Deep Learning VM + CentOS 9 Stream*
