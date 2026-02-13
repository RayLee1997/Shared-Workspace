# GCP 算力资源租赁最佳实践 (2026)

> 最后更新：2026年1月
> 目标受众：个人开发者、小型团队
> 聚焦场景：LLM 推理 (如 Qwen 72B)、图像/视频生成 (ComfyUI)

---

## 1. 核心原则：性价比优化三板斧

| 策略 | 节省幅度 | 适用场景 |
|------|---------|---------|
| **Spot VM (抢占式实例)** | 60-91% | 可容忍中断的推理/实验任务 |
| **CUD (承诺使用折扣)** | 20-57% | 稳定、可预测的长期工作负载 |
| **Cloud Run GPU** | 按秒计费 | 低频、突发性 API 调用 |

---

## 2. GPU 资源全景对比 (2026年最新定价)

### 2.1 主流 GPU 选型矩阵

| GPU | 显存 | On-Demand ($/hr) | Spot ($/hr) | 性价比评级 | 推荐场景 |
|-----|------|------------------|-------------|-----------|---------|
| **NVIDIA L4** | 24 GB | $0.71 | **$0.20-0.28** | S (性价比之王) | 通用推理、SDXL、ComfyUI |
| **NVIDIA T4** | 16 GB | $0.35 | $0.11 | A | 轻量推理、老模型、预算极限 |
| **NVIDIA A100 40GB** | 40 GB | $3.67 | $1.10+ | B | 中大模型训练/推理 |
| **NVIDIA A100 80GB** | 80 GB | $4.00+ | $1.50+ | C | 超大模型、显存敏感任务 |
| **NVIDIA H100** | 80 GB | ~$11/GPU-hr (A3实例) | $3.00+ | C | 最高性能训练、时间敏感任务 |
| **NVIDIA H200** | 141 GB | ~$10/GPU-hr | $3.72 | B+ | 超大模型、HBM3e加速 |
| **NVIDIA L40S** | 48 GB | ~$2.50 | ~$0.80 | A+ | 专业可视化、大模型推理 |

> **2026年趋势**：A100 价格已降至 <$1/GPU-hr (Spot)，H100 预计年中降至 $2 以下。L4 仍是性价比首选。

### 2.2 TPU 资源对比 (Google 独家)

| TPU | 性能定位 | On-Demand ($/chip-hr) | CUD 3年 ($/chip-hr) | 适用框架 |
|-----|---------|----------------------|---------------------|---------|
| **TPU v5e** | 推理优化 | $1.20 | ~$0.55 | JAX, PyTorch XLA |
| **TPU v5p** | 训练性能 | $4.20 | $1.89 | JAX, PyTorch XLA |
| **TPU v6e (Trillium)** | 推理性能 4.7x v5e | $1.375 | **$0.39** | JAX, PyTorch XLA |
| **TPU v7 (Ironwood)** | 最新旗舰 | TBD | TBD | JAX |

**TPU 优势**：
- 性价比极高 (尤其 v6e CUD 仅 $0.39/chip-hr)
- 能效比 GPU 高 60-65%
- MLPerf 推理 8/9 项领先 A100

**TPU 劣势**：
- 生态兼容性弱 (ComfyUI 等社区项目不支持)
- 需要 JAX/XLA 改造代码
- 调试复杂度高

**结论**：个人开发者首选 GPU；熟悉 JAX 的进阶用户可考虑 TPU v6e。

---

## 3. 场景化方案推荐

### 3.1 场景 A：部署 Qwen 72B (LLM 推理)

**显存需求分析**：

| 精度 | 显存需求 | 方案可行性 |
|------|---------|-----------|
| FP16 | ~144 GB | 个人不可承受 |
| Int8 | ~72 GB | 需 A100 80GB 或多卡 |
| **Int4/GPTQ** | **40-48 GB** | 双 L4 完美覆盖 |
| GGUF Q4_K_M | ~42 GB | llama.cpp 多卡 |

#### 推荐方案 A1：双 L4 策略 (性价比最优)

```
配置：g2-standard-24 + 2x NVIDIA L4
部署：Spot VM
成本：~$0.60/hr (约 ¥4.3/hr)
```

**软件栈选择**：

| 引擎 | 优势 | 劣势 | 推荐度 |
|------|------|------|-------|
| **vLLM** | 高吞吐、PagedAttention、多用户并发 35x+ | 需偶数 GPU | 多用户首选 |
| **llama.cpp** | 支持异构硬件、GGUF 格式通用 | 单流效率型 | 单用户/实验 |
| **ExLlamaV2** | 极速 (37 tok/s @72B 8bit)、内存效率高 | 部分模型不支持 | 追求速度 |

**推荐模型版本**：
- `Qwen/Qwen2.5-72B-Instruct-GPTQ-Int4`
- `Qwen/Qwen2.5-72B-Instruct-AWQ`
- GGUF: `Q4_K_M` 或 `Q5_K_M`

**vLLM 部署命令**：
```bash
vllm serve Qwen/Qwen2.5-72B-Instruct-AWQ \
    --tensor-parallel-size 2 \
    --gpu-memory-utilization 0.9 \
    --max-model-len 32768 \
    --enable-prefix-caching \
    --port 8000
```

#### 方案 A2：Cloud Run GPU (低频调用)

```
配置：Cloud Run + 1x L4 GPU
适用：API 调用 < 2小时/天
成本：按秒计费，闲时 $0
```

优势：自动扩缩容、无需管理基础设施、85% 成本节省 (对比常驻 VM)

### 3.2 场景 B：部署 ComfyUI (SDXL / 视频生成)

#### 推荐方案 B1：单 L4 策略

```
配置：g2-standard-8 + 1x NVIDIA L4
部署：Spot VM
成本：~$0.30/hr (约 ¥2.1/hr)
```

**L4 vs T4 对比**：

| 指标 | L4 | T4 |
|------|----|----|
| 显存 | 24 GB | 16 GB |
| SDXL 速度 | 2-3x 快 | 基准 |
| 视频编解码 | 硬件加速 | 无 |
| Spot 价格 | $0.25/hr | $0.11/hr |

**结论**：L4 的性能提升远超价格差异，强烈推荐。

#### 方案 B2：L40S 策略 (高端选择)

```
配置：GPU 优化实例 + 1x L40S
显存：48 GB
成本：Spot ~$0.80/hr
适用：复杂 Workflow、多模型同时加载
```

---

## 4. 成本优化策略详解

### 4.1 Spot VM 管理最佳实践

**核心特性**：
- 折扣幅度：60-91%
- 风险：可能被随时回收 (通常 24hr+ 稳定)
- 终止通知：30秒

**自动恢复策略**：

**方法 1：Managed Instance Group (MIG)**
```bash
# 创建实例模板
gcloud compute instance-templates create qwen-template \
    --machine-type=g2-standard-24 \
    --accelerator=type=nvidia-l4,count=2 \
    --provisioning-model=SPOT \
    --maintenance-policy=TERMINATE \
    --image-family=common-cu121-ubuntu-2204 \
    --image-project=deeplearning-platform-release

# 创建托管实例组 (自动复活)
gcloud compute instance-groups managed create qwen-mig \
    --template=qwen-template \
    --size=1 \
    --zone=us-central1-a
```

**方法 2：Startup Script 自动部署**
```bash
#!/bin/bash
# /opt/startup.sh
apt-get update && apt-get install -y docker.io
docker run -d --gpus all -p 8000:8000 \
    vllm/vllm-openai:latest \
    --model Qwen/Qwen2.5-72B-Instruct-AWQ \
    --tensor-parallel-size 2
```

### 4.2 CUD (承诺使用折扣) 策略

| 承诺期限 | 折扣幅度 | 适用场景 |
|---------|---------|---------|
| 1 年 | 20-37% | 确定性工作负载 |
| 3 年 | 45-57% | 长期稳定项目 |

**2026年新变化**：
- **Multiprice CUDs**：2026年1月21日起自动生效
- **Flex CUDs**：跨机器类型、跨区域灵活使用
- **覆盖扩展**：BigQuery、Cloud Run 等也可使用 CUD

**个人开发者建议**：
- 短期实验：仅用 Spot
- 稳定项目 (>6个月)：考虑 1年 CUD 锁定核心资源

### 4.3 SUD (持续使用折扣) - 自动生效

| 使用率 | 折扣 |
|-------|------|
| 25%+ | 自动开始折扣 |
| 100% | 最高 30% |

**特点**：无需承诺，按月自动计算，适合不确定工作负载。

---

## 5. 区域选择与配额申请

### 5.1 推荐区域 (按资源丰富度)

| 区域 | GPU 供应 | Spot 稳定性 | 推荐度 |
|------|---------|------------|-------|
| us-central1 (Iowa) | 丰富 | 高 | 首选 |
| us-west1 (Oregon) | 丰富 | 高 | 首选 |
| us-east4 (Virginia) | 中等 | 中 | 备选 |
| europe-west4 (Netherlands) | 中等 | 中 | 欧洲用户 |
| asia-east1 (Taiwan) | 有限 | 低 | 亚太用户 |

### 5.2 配额申请流程

1. **进入配额页面**：IAM & Admin > Quotas
2. **搜索配额**：
   - `NVIDIA L4 GPUs`
   - `Preemptible NVIDIA L4 GPUs` (Spot 专用)
3. **选择区域**：勾选 `us-central1`
4. **申请数量**：建议 4 个 (满足双卡 + 备用)
5. **申请理由示例**：
   > Personal development for Large Language Model inference (Qwen 72B) and generative AI research using SDXL.
6. **等待时间**：通常 24-48 小时

---

## 6. 部署代码参考

### 6.1 双 L4 实例 (Qwen 72B)

```bash
gcloud compute instances create qwen-72b-server \
    --zone=us-central1-a \
    --machine-type=g2-standard-24 \
    --accelerator=type=nvidia-l4,count=2 \
    --provisioning-model=SPOT \
    --maintenance-policy=TERMINATE \
    --instance-termination-action=STOP \
    --image-family=common-cu121-ubuntu-2204 \
    --image-project=deeplearning-platform-release \
    --boot-disk-size=200GB \
    --boot-disk-type=pd-ssd \
    --metadata=startup-script='#!/bin/bash
pip install vllm
vllm serve Qwen/Qwen2.5-72B-Instruct-AWQ --tensor-parallel-size 2 --port 8000'
```

### 6.2 单 L4 实例 (ComfyUI)

```bash
gcloud compute instances create comfyui-server \
    --zone=us-central1-a \
    --machine-type=g2-standard-8 \
    --accelerator=type=nvidia-l4,count=1 \
    --provisioning-model=SPOT \
    --maintenance-policy=TERMINATE \
    --image-family=common-cu121-ubuntu-2204 \
    --image-project=deeplearning-platform-release \
    --boot-disk-size=100GB \
    --boot-disk-type=pd-ssd
```

### 6.3 Cloud Run GPU (Serverless)

```bash
# 部署 vLLM 服务
gcloud run deploy qwen-api \
    --image=vllm/vllm-openai:latest \
    --gpu=1 \
    --gpu-type=nvidia-l4 \
    --memory=32Gi \
    --cpu=8 \
    --region=us-central1 \
    --allow-unauthenticated \
    --port=8000 \
    --set-env-vars="MODEL=Qwen/Qwen2.5-7B-Instruct"
```

---

## 7. 成本计算示例

### 场景：每天使用 4 小时 Qwen 72B 推理

| 方案 | 配置 | 月成本 |
|------|------|-------|
| Spot VM (双 L4) | $0.60/hr × 4hr × 30d | **$72/月** |
| On-Demand (双 L4) | $1.52/hr × 4hr × 30d | $182/月 |
| Cloud Run | 按秒计费 + 自动缩容 | ~$50-80/月 |
| CUD 1年 (双 L4) | 30% 折扣 | ~$127/月 |

### 场景：ComfyUI 周末使用 8 小时

| 方案 | 配置 | 月成本 |
|------|------|-------|
| Spot VM (单 L4) | $0.30/hr × 8hr × 8d | **$19/月** |
| On-Demand | $0.76/hr × 8hr × 8d | $49/月 |

---

## 8. 决策流程图

```
开始
  │
  ├─ 工作负载特性？
  │   ├─ 突发/低频 (<2hr/天) → Cloud Run GPU
  │   ├─ 稳定/可预测 → CUD + 标准 VM
  │   └─ 实验/可中断 → Spot VM (推荐)
  │
  ├─ 模型规模？
  │   ├─ <7B 参数 → 单 T4/L4
  │   ├─ 7B-30B → 单 L4
  │   ├─ 30B-72B → 双 L4 或 L40S
  │   └─ >72B → 多 A100 或 H100
  │
  └─ 框架兼容性？
      ├─ ComfyUI/SD → GPU (L4)
      ├─ vLLM/llama.cpp → GPU (L4/A100)
      └─ JAX/原生支持 → 考虑 TPU v6e
```

---

## 9. 总结：2026年 GCP 算力租赁黄金法则

1. **首选 L4 GPU**：$0.25/hr (Spot) 的 24GB 显存是个人开发者甜点
2. **多卡优于大卡**：2x L4 ($0.60/hr) 完胜单 A100 ($1.50+/hr) 运行 72B 模型
3. **善用 Spot**：接受偶尔中断，换取 70-90% 成本节省
4. **Cloud Run GPU**：低频调用的终极方案，闲时成本 $0
5. **TPU 观望**：除非熟悉 JAX，否则 GPU 生态更友好
6. **区域选择**：`us-central1` 或 `us-west1` 资源最丰富

---

## 附录：实用资源

- [GCP GPU 定价计算器](https://cloud.google.com/products/calculator)
- [GPU 配额申请页面](https://console.cloud.google.com/iam-admin/quotas)
- [Cloud Run GPU 文档](https://cloud.google.com/run/docs/configuring/services/gpu)
- [vLLM 官方文档](https://docs.vllm.ai/)
- [Qwen 模型仓库](https://huggingface.co/Qwen)

---

*本文档基于 2026年1月市场数据编写，价格和政策可能变化，请以 GCP 官方定价页面为准。*
