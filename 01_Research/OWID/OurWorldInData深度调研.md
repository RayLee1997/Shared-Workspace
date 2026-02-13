# Our World in Data (OWID) 数据集深度调研计划

## 📋 项目概述

**项目名称**: Our World in Data 数据生态系统全面调研  
**调研人员**: Ray  
**最后更新**: 2026-02-09

---

## 🎯 任务目标

### 主目标

1. **整体调研**: 了解 OWID 的基本情况，包括其历史、使命、愿景、价值观、组织架构、资金来源、合作伙伴、主要数据来源、数据处理流程、技术栈、社区生态等
2. **数据目录调研**: 深度调研 OWID 数据目录，梳理所有可通过 API 访问的数据集及其简介
3. **API 能力调研**: 全面调研 OWID Python API 的功能特性和使用方法
4. **技术生态调研**: 了解 OWID 的数据处理流程、工具链和最佳实践

### 交付物

- [ ] OWID 数据集分类目录（Markdown 格式）
- [ ] Python API 完整使用手册（含代码示例）
- [ ] 数据访问技术选型建议
- [ ] 实战应用案例集（3-5个）

---

## 📊 调研任务分解

### Phase 1: 数据目录全面梳理 (Day 1-3)

#### 1.1 数据集分类统计

**目标**: 了解 OWID 数据的广度和深度

- [ ] **按主题分类**
  - [ ] 健康与医疗 (Health)
  - [ ] 人口与人口统计 (Population & Demography)
  - [ ] 经济与发展 (Economy & Development)
  - [ ] 能源与环境 (Energy & Environment)
  - [ ] 教育与知识 (Education & Knowledge)
  - [ ] 科技与创新 (Technology & Innovation)
  - [ ] 政治与治理 (Politics & Governance)
  - [ ] 暴力与冲突 (Violence & Conflict)
  - [ ] 食品与农业 (Food & Agriculture)
  - [ ] 其他主题
  
- [ ] **按数据源分类**
  - [ ] 国际组织 (WHO, UN, World Bank, IMF, OECD 等)
  - [ ] 学术机构 (IHME, OWID 自有数据等)
  - [ ] 政府机构 (各国统计局等)
  - [ ] 其他来源
  
- [ ] **按更新频率分类**
  - [ ] 实时更新
  - [ ] 年度更新
  - [ ] 季度更新
  - [ ] 历史数据（不再更新）
  
- [ ] **按数据粒度分类**
  - [ ] 国家级别
  - [ ] 地区/省级别
  - [ ] 全球汇总
  - [ ] 其他粒度

**方法**:

```python
# 使用 owid-catalog 获取完整数据集列表
from owid.catalog import Client
client = Client()

# 1. 遍历所有 namespace
# 2. 统计每个 channel 的数据集数量
# 3. 记录数据集元数据
```

**输出**: `owid_datasets_catalog.md`

---

#### 1.2 热门数据集详细调研

**目标**: 深入了解最常用的数据集

优先调研清单（Top 20-30）:

- [ ] COVID-19 数据集
- [ ] 人口数据 (UN Population)
- [ ] GDP 数据 (World Bank, Maddison)
- [ ] 预期寿命 (Life Expectancy)
- [ ] 气候变化 (Climate Change)
- [ ] 能源消耗 (Energy Consumption)
- [ ] CO2 排放 (CO2 Emissions)
- [ ] 教育数据 (Education)
- [ ] 贫困与不平等 (Poverty & Inequality)
- [ ] 疾病负担 (Global Burden of Disease)
- [ ] 可再生能源 (Renewable Energy)
- [ ] 儿童死亡率 (Child Mortality)
- [ ] 饥饿与营养不良 (Hunger & Malnutrition)
- [ ] 民主指数 (Democracy Index)
- [ ] 战争与冲突 (War & Conflict)
- [ ] 互联网使用 (Internet Usage)
- [ ] 疫苗接种 (Vaccination)
- [ ] 森林覆盖 (Forest Coverage)
- [ ] 水资源 (Water Resources)
- [ ] 性别平等 (Gender Equality)

**每个数据集记录**:

```markdown
### [数据集名称]
- **namespace**: xxx
- **dataset**: xxx
- **表数量**: N 个
- **时间范围**: YYYY-YYYY
- **地理覆盖**: 国家数量
- **更新频率**: 
- **主要指标**: 列出 5-10 个关键指标
- **数据质量**: 完整性/准确性评估
- **典型用例**: 
- **API 访问路径**: 
- **相关图表**: OWID 网站链接
```

**方法**:

```python
# 对每个数据集:
# 1. 加载数据查看 schema
# 2. 统计行数、列数、时间范围
# 3. 检查元数据完整性
# 4. 查看相关图表
```

**输出**: `owid_top_datasets_details.md`

---

#### 1.3 数据集依赖关系图

**目标**: 理解 OWID ETL 数据流

- [ ] **Channel 层级关系**
  - `meadow` (原始数据) → `garden` (清洗数据) → `grapher` (图表数据)
  - 绘制数据流转图
  
- [ ] **Namespace 依赖**
  - 识别数据集之间的引用关系
  - 标注核心 upstream 数据集
  
- [ ] **版本管理**
  - 理解版本命名规则
  - 追踪主要数据集的版本历史

**输出**: `owid_data_flow.mmd` (Mermaid 图)

---

### Phase 2: Python API 深度调研 (Day 3-4)

#### 2.1 API 接口完整清单

**Charts API**

- [ ] `charts.get_data(slug)` - 获取图表数据
- [ ] `charts.get_metadata(slug)` - 获取图表配置
- [ ] 支持的图表类型
- [ ] 返回数据格式
- [ ] 性能基准测试

**Catalog API**

- [ ] `catalog.find()` - 搜索功能
  - [ ] 按 table 搜索
  - [ ] 按 dataset 搜索
  - [ ] 按 namespace 搜索
  - [ ] 正则表达式支持
  - [ ] 模糊搜索 (fuzzy)
- [ ] `catalog.load()` - 数据加载
- [ ] `RemoteCatalog` - 远程目录访问
- [ ] `LocalCatalog` - 本地缓存

**Indicators API**

- [ ] `client.indicators.search()` - 指标搜索
- [ ] 搜索参数选项
- [ ] 结果排序和过滤

**Tables API**

- [ ] `client.tables.search()` - 表搜索
- [ ] 参数说明
- [ ] 与 Catalog API 的区别

**元数据系统**

- [ ] `Table.metadata` - 表级元数据
- [ ] `Variable.metadata` - 列级元数据
- [ ] 元数据传播机制
- [ ] `@keep_metadata` 装饰器

**数据处理模块**

- [ ] `owid.catalog.processing` 模块
- [ ] 支持的操作 (merge, concat, pivot 等)
- [ ] 元数据保留策略

**输出**: `owid_api_reference.md`

---

#### 2.2 代码示例库

为每个功能编写可运行的示例:

```python
# examples/
├── 01_basic_search.py           # 基础搜索
├── 02_load_dataset.py           # 加载数据集
├── 03_charts_api.py             # Charts API 使用
├── 04_metadata_handling.py      # 元数据处理
├── 05_data_processing.py        # 数据处理
├── 06_fuzzy_search.py           # 模糊搜索
├── 07_multi_dataset_merge.py    # 多数据集合并
├── 08_export_formats.py         # 导出格式
├── 09_cache_management.py       # 缓存管理
└── 10_error_handling.py         # 错误处理
```

**输出**: `examples/` 目录

---

#### 2.3 性能测试

- [ ] **数据加载速度**
  - 小数据集 (<10MB)
  - 中等数据集 (10-100MB)
  - 大数据集 (>100MB)
  
- [ ] **搜索响应时间**
  - 精确搜索
  - 模糊搜索
  - 正则搜索
  
- [ ] **内存占用**
  - 不同大小数据集的内存消耗
  
- [ ] **缓存效果**
  - 首次加载 vs 缓存加载

**输出**: `performance_benchmark.md`

---

### Phase 3: 数据访问技术对比 (Day 4-5)

#### 3.1 多种访问方式对比

| 方式 | 优势 | 劣势 | 适用场景 |
|------|------|------|----------|
| **owid-catalog (Python)** | | | |
| **Charts API** | | | |
| **DuckDB (SQL)** | | | |
| **Datasette (Web UI)** | | | |
| **GitHub (CSV下载)** | | | |
| **Grapher JSON API** | | | |

**对比维度**:

- 易用性
- 性能
- 数据完整性
- 元数据支持
- 离线支持
- 学习曲线

**输出**: `data_access_comparison.md`

---

#### 3.2 技术选型建议

针对不同使用场景给出建议:

- **数据分析师**:
- **数据科学家**:
- **Web 开发者**:
- **研究人员**:
- **自动化脚本**:

**输出**: 整合到 `data_access_comparison.md`

---

### Phase 4: ETL 流程与工具链调研 (Day 5-6)

#### 4.1 ETL 仓库结构

- [ ] 仓库组织方式
- [ ] Snapshot 系统
- [ ] Step 定义
- [ ] DAG (有向无环图) 管理
- [ ] 数据质量检查

**输出**: `owid_etl_architecture.md`

---

#### 4.2 开发者工具

- [ ] `etl` CLI 工具
- [ ] `wizards` 自动化工具
- [ ] 本地开发环境搭建
- [ ] 贡献数据集的流程

**输出**: `developer_guide.md`

---

### Phase 5: 实战应用案例 (Day 6-7)

#### 5.1 案例设计

**案例 1: 全球健康趋势分析**

- 数据: 预期寿命、儿童死亡率、疫苗接种率
- 技术: Catalog API + pandas + matplotlib
- 输出: Jupyter Notebook

**案例 2: 气候变化可视化仪表板**

- 数据: CO2 排放、温度变化、可再生能源
- 技术: Charts API + Streamlit
- 输出: Web 应用

**案例 3: 经济发展对比分析**

- 数据: GDP、贫困率、教育水平
- 技术: DuckDB + SQL 查询
- 输出: 分析报告

**案例 4: COVID-19 数据追踪**

- 数据: 确诊、死亡、疫苗接种
- 技术: 实时数据更新 + 自动化脚本
- 输出: 自动化报告

**案例 5: 多维度国家对比**

- 数据: 20+ 指标综合对比
- 技术: 多数据集合并 + 元数据保留
- 输出: 交互式报告

**输出**: `case_studies/` 目录

---

## 🛠️ 技术工具栈

### 必需工具

```bash
# Python 环境
python 3.11+
pip install owid-catalog --break-system-packages

# 数据分析
pip install pandas numpy matplotlib seaborn --break-system-packages

# 可视化
pip install plotly streamlit --break-system-packages

# 数据库
pip install duckdb --break-system-packages

# Jupyter
pip install jupyter notebook --break-system-packages
```

### 可选工具

```bash
# 数据导出
pip install openpyxl xlsxwriter --break-system-packages

# 高级可视化
pip install altair folium --break-system-packages

# Web 框架
pip install flask fastapi --break-system-packages
```

---

## 📁 项目文件结构

```
owid-research/
├── README.md                          # 项目说明
├── docs/                              # 调研文档
│   ├── owid_datasets_catalog.md       # 数据集目录
│   ├── owid_top_datasets_details.md   # Top 数据集详情
│   ├── owid_data_flow.mmd             # 数据流图
│   ├── owid_api_reference.md          # API 参考
│   ├── performance_benchmark.md       # 性能测试
│   ├── data_access_comparison.md      # 访问方式对比
│   ├── owid_etl_architecture.md       # ETL 架构
│   └── developer_guide.md             # 开发者指南
├── examples/                          # 代码示例
│   ├── 01_basic_search.py
│   ├── 02_load_dataset.py
│   └── ...
├── case_studies/                      # 实战案例
│   ├── 01_health_trends/
│   ├── 02_climate_dashboard/
│   ├── 03_economic_analysis/
│   ├── 04_covid_tracker/
│   └── 05_country_comparison/
├── notebooks/                         # Jupyter Notebooks
│   └── exploration.ipynb
├── scripts/                           # 自动化脚本
│   ├── fetch_all_datasets.py         # 获取所有数据集
│   ├── generate_catalog.py           # 生成目录
│   └── benchmark.py                  # 性能测试
└── data/                              # 本地数据缓存
    └── cache/
```

---

## ✅ 执行检查清单

### Day 1: 环境准备 + 数据集初探

- [ ] 创建项目目录结构
- [ ] 配置 Python 环境（需配置代理）
- [ ] 安装 owid-catalog
- [ ] 运行首个示例代码
- [ ] 获取数据集总览

### Day 2: 数据集分类统计

- [ ] 按主题统计数据集
- [ ] 按数据源统计
- [ ] 识别 Top 20 热门数据集
- [ ] 记录初步发现

### Day 3: 热门数据集详细调研

- [ ] 深入调研 Top 20 数据集
- [ ] 记录元数据
- [ ] 测试数据加载
- [ ] 开始 API 功能测试

### Day 4: API 完整调研

- [ ] 测试所有 API 接口
- [ ] 编写代码示例
- [ ] 性能基准测试
- [ ] 对比不同访问方式

### Day 5: ETL 流程调研

- [ ] 理解 ETL 架构
- [ ] 研究数据处理流程
- [ ] 探索开发者工具

### Day 6: 实战案例开发

- [ ] 完成案例 1-2
- [ ] 编写案例文档

### Day 7: 案例完善 + 文档整理

- [ ] 完成案例 3-5
- [ ] 整理所有文档
- [ ] 编写总结报告
- [ ] 准备分享材料

---

## 📈 成功标准

1. **完整性**: 覆盖至少 80% 的主要数据集类别
2. **准确性**: 所有代码示例可运行
3. **实用性**: 案例具有实际应用价值
4. **文档质量**: 清晰、结构化、易于理解
5. **可复现性**: 他人可以根据文档重现所有步骤

---

## 🚀 后续计划

调研完成后可以考虑:

- [ ] 开发 OWID 数据探索 Web 应用
- [ ] 构建自定义数据集 pipeline
- [ ] 贡献数据集到 OWID
- [ ] 开发 MCP Server for OWID
- [ ] 撰写技术博客分享经验

---

## 📝 注意事项

### 环境限制

- 当前环境网络受限，需配置代理:

  ```bash
  export https_proxy=http://127.0.0.1:7890
  export http_proxy=http://127.0.0.1:7890
  ```

### 数据使用

- OWID 数据采用 CC BY 4.0 许可
- 使用时需注明出处
- 商业使用需遵守许可条款

### 性能优化

- 首次下载数据较慢，建议使用缓存
- 大数据集考虑使用 DuckDB
- 定期清理缓存避免磁盘占满

---

## 📞 问题反馈

调研过程中遇到问题:

1. 记录在 `ISSUES.md`
2. 查阅 OWID 官方文档
3. 搜索 GitHub Issues
4. 在 OWID Slack 社区提问

---

**版本历史**:

- v1.0 (2026-02-09): 初始版本
