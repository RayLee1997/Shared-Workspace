---
title: "调研计划：AI 时代软件商业模式巨变与价值转移"
created: 2026-02-13
status: Planning
tags: [AI, Business Model, SaaS, PaaS, IaaS, Research]
---

# 调研任务：AI时代软件商业模式巨变 (The Great Value Shift)

## 1. 研究背景与核心目标 (Background & Objective)

**背景**：Generative AI (GenAI) 正在从根本上重构软件的生产、分发与消费方式。传统 SaaS 的 "Seat-based"（按人头付费）模式正面临 "Outcome-based"（按结果付费）的挑战；PaaS 层正在被大模型 (LLMs) 和 MLOps 重定义；而 IaaS 层因算力需求的爆发而掌握了前所未有的定价权。

**核心目标**：

1. **验证价值转移假设**：量化分析价值是否真的从应用层 (SaaS) 向基础设施层 (IaaS) 和模型层 (PaaS) 转移。
2. **重定义护城河**：在 AI 时代，软件企业的核心护城河是工作流 (Workflow)、专有数据 (Proprietary Data) 还是算力 (Compute)？
3. **投资与战略启示**：识别哪些类型的软件公司将消亡，哪些将进化为新一代巨头。

## 2. 核心假设体系 (Core Hypotheses)

| 层面 | 传统模式 (Pre-AI) | AI 时代假设 (Post-AI) | 关键验证点 |
| :--- | :--- | :--- | :--- |
| **SaaS (应用层)** | **工具属性**：用户操作软件完成工作。<br>**收费**：Seat-based Subscription (ARR)。 | **代理属性 (Agentic)**：软件代替用户完成工作。<br>**收费**：Consumption/Outcome-based。<br>**风险**："Thin Wrapper" 只有极薄的价值层。 | 1. Copilot 类产品的渗透率与提价能力。<br>2. 纯工具类 SaaS 的 Churn Rate 变化。 |
| **PaaS (平台/模型层)** | **中间件/数据库**：提供开发环境与运行时。 | **MaaS (Model-as-a-Service)**：模型即平台。<br>**新生态**：Vector DB, Orchestration (LangChain)。 | 1. 推理成本 (Inference Cost) 下降曲线。<br>2. 开源 vs 闭源模型的商业化边界。 |
| **IaaS (基建/算力层)** | **公有云资源**：计算、存储、网络。竞争同质化。 | **算力垄断**：GPU/TPU 是新石油。云厂商通过 AI 栈深度绑定客户。 | 1. 资本开支 (CapEx) 占营收比例的变化。<br>2. 算力租赁的毛利率趋势。 |

## 3. 调研模块与具体内容 (Research Modules)

### 模块一：宏观趋势与经济学模型 (Macro & Economics)

- **软件边际成本的归零与推理成本的上升**：分析 AI 如何改变软件的成本结构（COGS 激增）。
- **Jevons Paradox (杰文斯悖论) 在 AI 算力中的体现**：效率提升是否导致需求爆发？
- **"The Hollow Middle" 理论**：两端（极巨头 vs 极垂直）获利，中间层塌陷。

### 模块一点五：商业模式与定价机制演变 (The Pricing Paradigm Shift)

- **核心对比**：Seat-based vs. Outcome-based vs. API-based。
  - **Seat-based (SaaS)**：传统模式，稳定 ARR，但限制了 AI 带来的效率红利（AI 做得越多，Seat 越少）。
  - **Outcome-based (Agentic)**：按解决问题的数量或价值付费（如 Klarna 客服解决一次 ticket $X）。难点在于归因与价值衡量。
  - **API-based / Token-based (PaaS/MaaS)**：按用量付费，与成本强挂钩，但缺乏经常性收入 (Recurring Revenue) 的可预测性。
  - **Royalty-based (IP/Edge)**：按设备/终端授权付费（如 QNX, Arm）。

### 模块二：分层深度分析 (Layer Analysis)

#### 2.1 IaaS & Hardware: The New Powerhouse

- **焦点企业**：NVIDIA, AWS, Azure, GCP, Oracle Cloud.
- **关键问题**：
  - 云厂商自研芯片 (AWS Trainium, Google TPU, Azure Maia) 是否会削弱 NVIDIA 的议价权？
  - 算力租赁价格趋势预测。

#### 2.2 PaaS & Model Layer: The New OS

- **焦点企业**：OpenAI, Databricks, Snowflake, MongoDB.
- **关键问题**：
  - 数据云 (Data Cloud) 如何演变为 AI Factory？
  - 向量数据库 (Vector DB) 是短期过渡特性还是长期基础设施？

#### 2.3 SaaS & Application: The Evolution or Extinction

- **焦点企业**：Salesforce (Agentforce), Adobe (Firefly), Microsoft (Copilot), Palantir.
- **关键问题**：
  - **Service-as-a-Software**：SaaS 公司是否会变成服务公司？
    - 垂直 SaaS (Vertical SaaS) 结合私有数据的防御性分析。

#### 2.4 Edge & IoT: The Royalty Model (Terminal OS)

- **焦点企业**：BlackBerry (QNX), Qualcomm, Arm.
- **关键问题**：
  - **Royalty 模式的韧性**：在 AI 定义汽车 (SDV) 时代，底层 OS 的价值是被稀释（被上层 AI 接管）还是增强（安全与实时性要求更高）？
  - **端侧 AI (Edge AI)**：推理下沉到终端不仅降低云端成本，是否会催生新的 "AI Runtime OS" 收费模式？

## 4. 调研方法论 (Methodology)

### 4.1 定量分析 (Quantitative)

- **财务指标**：对比主要 SaaS 和 IaaS 企业的 Revenue Growth vs. CapEx Growth。
- **估值倍数**：追踪市场给予 AI-native 公司 vs. Legacy SaaS 公司的 EV/Revenue 倍数差。

### 4.2 定性分析 (Qualitative)

- **专家访谈 (Expert Network)**：查阅 Expert Calls (如 Tegus, Stream) 纪要（如有资源）。
- **产品体验**：实测 AI Agent 产品的端到端交付能力。
- **研报综合**：整合 Gartner, ARK Invest, Sequoia, Goldman Sachs 的行业观点。

### 模块四：AI 时代软件商业模式设计指南 (The Playbook & Best Practices)

- **北极星指标的变化**：从 NDR (Net Dollar Retention) 转向 "Work Delivered"。
- **成本结构的重构**：如何管理不可预测的推理成本 (Inference Cost)？
- **防御性构建**：
  - **Data Moat**：不仅仅是数据量，而是专有数据的闭环反馈 (Data Flywheel)。
  - **Workflow Intrusion**：AI不仅是 Copilot，更是 Workflow 的拥有者。
- **最佳实践检查单**：初创公司 vs. 转型巨头的商业模式转型自检表。

### 模块三：商业模式变革案例研究 (Case Studies)

1. **GitHub Copilot vs. Cursor**：IDE 的价值重构。
2. **Klarna AI 客服案例**：AI 取代人工客服对 BPO (业务流程外包) 软件的毁灭性打击。
3. **Adobe Firefly**：如何通过合规数据训练构建护城河，避免版权风险并维持高溢价。

## 5. 预期产出

| 阶段          | 任务                                                                         | 预计耗时 | 产出物                                                                                                                                                                              |
| :---------- | :------------------------------------------------------------------------- | :--- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Phase 1** | **数据收集与文献综述**<br>- 收集各大行 2024-2025 AI 软件研报。<br>- 整理 Top 20 软件公司的最新财报电话会纪要。 | 3 天  | `01_Research/Business Model/Literature_Review.md`                                                                                                                                |
| **Phase 2** | **分层专项分析**<br>- 完成 IaaS/PaaS/SaaS 三层的深度剖析。                                 | 5 天  | `01_Research/Business Model//Drafts/01_IaaS_Analysis.md`<br>`01_Research/Business Model//Drafts/02_PaaS_Analysis.md`<br>`01_Research/Business Model//Drafts/03_SaaS_Analysis.md` |
| **Phase 3** | **综合报告撰写**<br>- 整合观点，绘制价值转移趋势图 (Mermaid)。<br>- 撰写投资策略建议。                   | 3 天  | **`01_Research/Business Model/Reports/AI_Software_Business_Model_Deep_Dive.md`**                                                                                                 |

## 6. Execution Roadmap & Search Queries

### Step 1: Macro & Pricing Shift Validation

- **Search Queries**:
  - `SaaS seat-based vs outcome-based pricing transition 2024 2025`
  - `AI software value shift from SaaS to IaaS analysis`
  - `Jevons Paradox in AI compute demand`
  - `"The Hollow Middle" software market theory`

### Step 2: Layer-by-Layer Deep Dive

- **IaaS (The New Powerhouse)**:
  - `Hyperscaler capital expenditure AI infrastructure 2024 2025`
  - `AWS Trainium vs NVIDIA H100 cost performance comparison`
  - `Cloud GPU rental price trends 2024 2025`
- **PaaS (The New OS)**:
  - `Vector database market commoditization analysis`
  - `Databricks vs Snowflake AI strategy comparison`
  - `Open source model commercialization challenges`
- **SaaS (Evolution or Extinction)**:
  - `Salesforce Agentforce adoption rate and pricing`
  - `Klarna AI customer service cost reduction report`
  - `Vertical SaaS with proprietary data moat examples`

### Step 3: Synthesis & Values

- **Outputs**:
  - Quantified shift in revenue multiples (SaaS vs AI Infra).
  - Comparative analysis tables.
  - Discussion on the resilience of "Royalty" models (Edge AI).
