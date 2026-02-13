---
title: Claude’s C Compiler vs. GCC
author: unchar1
published: 2026-02-09 04:30:38
link: https://harshanu.space/en/tech/ccc-vs-gcc/
guid: https://news.ycombinator.com/item?id=46941603
tags: [AI, Compiler, C, Linux, Performance, Benchmark]
---

# Claude’s C Compiler vs. GCC

**Author:** unchar1
**Published:** Mon, 09 Feb 2026 04:30:38 +0000
**Link:** https://harshanu.space/en/tech/ccc-vs-gcc/

---

## 摘要 (Summary)

这是一篇关于 **Claude's C Compiler (CCC)** 与行业标准 **GCC** 进行对比的深度技术评测文章。CCC 是由 Anthropic 的 Claude Opus 4.6 模型完全独立编写的 C 语言编译器。作者通过编译 Linux 内核和 SQLite 对其进行了严格测试。

**核心结论**：
*   **正确性惊人**：CCC 成功编译了 Linux 内核的所有 C 源码文件（无报错），并且编译出的 SQLite 功能完全正确。
*   **性能极差**：CCC 编译出的 SQLite 二进制文件运行速度比 GCC 慢 **737 倍到 158,000 倍**。
*   **不可用于生产**：生成的代码缺乏优化，存在严重的寄存器溢出问题，无法生成可引导的内核镜像。

---

## 详细内容 (Detailed Content)

### 1. 技术背景
*   **CCC 架构**：完全由 Rust 编写，支持 x86-64 等架构。它实现了从 SSA 中间表示到汇编生成的全过程。
*   **测试目标**：编译 **Linux 6.9 内核** 和 **SQLite 3.46**，对比 CCC 与 GCC 在编译速度、代码质量、运行效率和正确性上的差异。

### 2. 基准测试结果 (Benchmarks)

#### A. Linux 内核 (Kernel 6.9) 编译
*   **编译阶段**：CCC 成功编译了内核中所有 **2,844 个 C 文件**，且没有产生任何编译器错误（只有警告）。这对 AI 生成的编译器来说是一个巨大的成就。
*   **链接阶段**：**失败**。产生了约 40,784 个未定义引用错误。原因在于 CCC 生成的 `__jump_table` 重定位条目和 `__ksymtab` 符号表条目格式不正确，无法被链接器正确处理。
*   **资源消耗**：CCC 的内存峰值占用是 GCC 的 **2.3 倍** (1.9GB vs 0.8GB)。

#### B. SQLite 3.46 编译与运行
这是最能体现性能差异的测试：
*   **编译时间**：CCC (87秒) vs GCC -O0 (65秒)。
*   **二进制大小**：CCC 生成的文件大小是 GCC 的 **2.7 到 3 倍** (4.27MB vs 1.55MB)。
*   **运行时间 (Runtime)**：
    *   GCC -O2: **6.1 秒**
    *   CCC: **2 小时 06 分 (7560 秒)**
    *   **差距**：CCC 比 GCC -O2 慢了 **1,242 倍**。
*   **复杂查询性能**：在涉及子查询和连接的复杂 SQL 操作中，CCC 甚至比 GCC 慢了 **158,000 倍**。

### 3. 性能低下的根本原因 (Root Cause Analysis)

作者深入分析了汇编代码，找出了 CCC 生成代码极其缓慢的五大原因：

1.  **灾难级的寄存器分配 (Register Spilling)**：
    *   CCC 几乎不利用寄存器保存变量，而是频繁地将变量写入栈内存（RAM），再读回寄存器进行单次操作，然后立即写回栈。
    *   **微基准测试**：仅这一项缺陷就导致简单代码慢 40 倍以上。

2.  **虚假的优化选项**：
    *   CCC 无论使用 `-O0`, `-O2` 还是 `-O3`，生成的汇编代码是**字节级完全相同**的。所谓的优化参数被完全忽略了。

3.  **代码膨胀 (Code Bloat)**：
    *   由于无效的内存读写指令过多，CCC 生成的二进制文件体积庞大，导致 CPU 指令缓存（Instruction Cache）命中率极低。

### 4. 作者结论 (Author's Conclusions)

*   **技术展示成功**：Claude 能够编写出一个能正确解析并编译数千个复杂 Linux 内核文件、且生成的 SQLite 功能完全正确的编译器，这本身就是 AI 编程能力的非凡展示。
*   **不可用于生产**：由于缺乏有效的寄存器分配算法和优化传递，生成的代码效率低到无法接受。
*   **关于“编译内核”的声明**：虽然它编译了 C 代码，但无法生成可引导的内核镜像（链接失败），因此 Anthropic 的声明需要打个折扣。