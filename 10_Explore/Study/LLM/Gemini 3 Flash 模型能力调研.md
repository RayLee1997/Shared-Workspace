# Gemini 3 Pro vs Gemini 3 Flash 模型能力调研

资料来源（主要）：
- https://docs.cloud.google.com/vertex-ai/generative-ai/docs/models/gemini/3-pro
- https://docs.cloud.google.com/vertex-ai/generative-ai/docs/models/gemini/3-flash
- https://docs.cloud.google.com/vertex-ai/generative-ai/docs/start/gemini-3-prompting-guide

## 1. Gemini 3 Pro 和 Gemini 3 Flash 能力差异

| 维度          | Gemini 3 Pro (Preview)                                                                                                                                | Gemini 3 Flash (Preview)                                              | 选型要点                                        |
| ----------- | ----------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------- | ------------------------------------------- |
| 官方定位        | 最先进的“推理优先”(reasoning-first) Gemini 模型，用于解决复杂问题                                                                                                        | 将 Pro 的推理能力与 Flash 线的低延迟/高效率/低成本结合，面向复杂 agentic 工作流                   | 需要更强“深推理/复杂指令遵循”优先 Pro；需要“速度/成本/吞吐”优先 Flash |
| Model ID    | `gemini-3-pro-preview`                                                                                                                                | `gemini-3-flash-preview`                                              | 目前均为 Preview                                |
| 上下文窗口       | 1,048,576 input tokens（1M）                                                                                                                            | 1,048,576 input tokens（1M）                                            | 都适合长上下文（长文档/长视频/大代码库）                       |
| 最大输出        | 65,536 output tokens                                                                                                                                  | 65,536 output tokens                                                  | 两者一致                                        |
| 输入/输出模态     | 输入：Text/Code/Images/Audio/Video/PDF；输出：Text                                                                                                           | 输入：Text/Code/Images/Audio/Video/PDF；输出：Text                           | 两者一致（注意是“理解多模态”，输出仍为文本）                     |
| thinking 控制 | `thinking_level`: `low` / `high`                                                                                                                      | `thinking_level`: `minimal` / `low` / `medium` / `high`               | Flash 额外提供 `minimal`（用于近似“零思考/极低延迟”）        |
| 多模态处理开销控制   | `media_resolution`: `low` / `medium` / `high`                                                                                                         | `media_resolution`: `low` / `medium` / `high` / `ultra high`（仅 IMAGE） | Flash 对图像额外提供更高分辨率档位；也意味着更高 token/延迟        |
| 强项（文档描述）    | 高层推理、复杂指令遵循、工具使用、agentic 用例、长上下文能力提升                                                                                                                  | 在更低延迟/更高效率/更低成本下提供接近 Pro 的推理，并面向最复杂 agentic 工作流                       | Flash 更适合“默认工作马 + 可调推理”；Pro 更适合“难题攻坚/高风险决策” |
| 已知注意点（文档描述） | 不以“音频理解”或“图像分割”作为优先优化目标；对信息密集/复杂图表可能提取错误或误读                                                                                                           | （文档未强调上述限制）                                                           | 如果任务强依赖图表精确读取/专业 OCR/图像分割，需额外评测或选专用模型       |
| 生态能力（文档列出）  | 支持：Google Search Grounding、Code execution、System instructions、Structured output、Function calling、Thinking、Context caching、RAG Engine、Chat completions | 同左                                                                    | 能力矩阵基本一致                                    |
| 不支持项（文档列出）  | Tuning、Gemini Live API                                                                                                                                | Tuning、Gemini Live API                                                | 都不适合“在线实时语音双工 Live API”场景（需选 Live API 专用模型） |

## 2. 最佳实践与更适合的场景

### 2.1 选型建议（一句话版）

- 日常/规模化/对延迟敏感：优先用 Gemini 3 Flash，并按任务复杂度调 `thinking_level`。
- 复杂推理/复杂指令遵循/高风险输出（容错低）：优先用 Gemini 3 Pro（必要时配合 `thinking_level=high`）。

### 2.2 Gemini 3 Flash 最适合的场景与用法

- 高吞吐与成本敏感：分类、抽取、改写、摘要、客服/助手对话、批量内容生产。
- 工具调用型 Agent：函数调用链路更长、交互轮次更多时，用 Flash 控制成本更划算。
- 低延迟交互：将 `thinking_level` 设为 `minimal` 或 `low`（`minimal` 约等价于 Gemini 2.5 Flash 的 `thinking_budget=0` 诉求）。
- 多模态“看图/看 PDF”但希望保持效率：默认 `media_resolution`，只有在确实读不清（小字/细节）时再逐级升高（会显著增加 token/延迟）。

### 2.3 Gemini 3 Pro 最适合的场景与用法

- 难度更高的推理与规划：多步推理、复杂约束规划、复杂代码库理解与改造方案设计。
- 复杂指令遵循与工具使用：需要更稳定地遵守多条规则/格式/边界条件的生成任务。
- 长上下文“综合理解”：整本书/长报告/整仓库级输入后进行跨段落综合分析。

注意（来自官方说明）：
- Pro 的回答倾向“简洁、直接、以解决意图为先”，信息缺失时可能会猜；对于需要严格基于证据的任务，建议在提示词中明确“只能使用给定材料进行推导，不得引入外部信息”，并配合“先验证再回答”的两步式提示。
- 对信息密集/复杂图表（graph/table/chart）可能会误读：尽量把关键数字/结论用更直白的文本/结构化方式提供给模型，或让模型先输出它“识别到的表格/数据”，再让你确认后继续推理。

### 2.4 Gemini 3 通用 Prompt/参数最佳实践（官方 prompting guide 摘要）

- `temperature`: 官方强烈建议保持默认 `1.0`；调低可能导致意外行为/循环/推理任务性能下降。
- 降低延迟：设置 `thinking_level=LOW`（Flash 也可用 `MINIMAL`），并使用 system instruction 如 `think silently`。
- 避免过度的“禁止推断”指令：不要只写 `do not infer`；改为“允许基于给定上下文做计算/逻辑推导，但不得引入外部信息”。
- 两步式验证（split-step verification）：先让模型判断是否具备信息/能力（无法验证则输出 `No Info` 并停止），再进入生成，降低“看似合理但不真实”的输出。
- 重要约束放最后：复杂提示词里，核心问题与关键的否定/格式/数量约束尽量放在最后一行，减少被忽略的概率。
- 大上下文综合：当提供长文档/代码/长视频转写等时，把问题放在数据之后，并用类似 `Based on the entire document above...` 的锚定语句提醒模型“不要只停在第一次命中”。
