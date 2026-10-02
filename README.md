# Bioinformatics analysis blueprints

这是一个把论文中的生信思路拆成“证据—决策—输入—输出—质量门”的归档仓库。每条蓝图都回答：为什么做、用什么数据、按什么顺序做、什么结果才算通过、哪些结论仍然只是推断，并尽量给出 R 优先、Python 补充的可运行起点。

当前第一条完整蓝图来自：

> Kang et al. (2025), Human pancreatic alpha-cell heterogeneity and trajectory inference analyses reveal SMOC1 as a beta-cell dedifferentiation gene, Nature Communications, DOI: 10.1038/s41467-025-62670-5.

现有的 bioinformatics-literature-workbench 继续承担论文索引和阅读笔记；本仓库专门保存可以拿去规划分析的蓝图。相关仓库：

- https://github.com/Threezs/bioinformatics-literature-workbench
- https://github.com/Threezs/nature-methods-bioinformatics-catalog
- https://github.com/Threezs/bioinformatics-methods-cookbook
- https://github.com/Threezs/research-project-index

## 快速开始

~~~bash
git clone https://github.com/Threezs/bioinformatics-analysis-blueprints.git
cd bioinformatics-analysis-blueprints
python scripts/validate_blueprints.py
make validate
~~~

最小环境：R 4.3 或更高版本（Seurat、Matrix、yaml）；Python 3.10 或更高版本（scanpy、scvelo、anndata、pandas、matplotlib）。10x 数据建议先用 Cell Ranger 生成矩阵；snRNA-seq 需要把 intronic reads 纳入计数；RNA velocity 需要由 velocyto 生成 GRCh38 对应的 loom 文件。

可先运行 R/install_packages.R 安装核心 R 依赖，或用 environment.yml 创建 Python 环境。DoubletFinder、escape、monocle3、Signac 和 velocyto 建议按各自上游文档安装并把版本写入 provenance.tsv。

## 目录

| 路径 | 用途 |
| --- | --- |
| blueprints/ | 每篇论文一份可复用的分析蓝图 |
| templates/ | 新增蓝图的 Markdown 模板和方法卡字段 |
| config/ | 参数、根节点和输入输出约定 |
| R/ | R/Seurat 主流程 |
| python/ | Python/scVelo/PAGA 互操作脚本 |
| data/ | 机器可读的蓝图索引和证据声明 |
| references/ | DOI、数据集和原作者代码入口 |
| scripts/ | 结构校验 |

## 第一条蓝图的核心思路

这篇文章将非糖尿病和 T2D 人胰岛的 scRNA-seq/snRNA-seq 放到同一参考中，细分出五种 alpha 细胞状态，再把三种 beta 细胞状态纳入联合轨迹：

~~~text
Seurat 质控/整合 -> alpha/beta 亚群 -> velocyto + scVelo -> PAGA
-> Monocle3 伪时序 -> 多轨迹共同基因 -> HPAP 外部投影
-> multiome 和实验验证
~~~

可迁移价值在于：用 SoupX 和 DoubletFinder 处理环境 RNA/双细胞；用 scRNA 与 snRNA 的互补剪接信息构建 velocity；先用 PAGA 找图起点，再把起点交给 Monocle3；在多条走向目标状态的轨迹之间取共同基因；把候选基因放回独立 ND/T2D 队列后再进入多组学或扰动验证。

具体步骤、参数、数据入口、验收标准和替代路线写在 blueprints/2025-10-07-kang-smoc1.md。

## 新增蓝图的最低要求

每条蓝图至少要有 DOI 或稳定 URL、数据 accession、物种/组织/平台/供体单位、原文工具和参数、输入输出契约、质量门、失败路线、证据分级、原作者代码链接和机器可读索引。详见 docs/schema.md 和 templates/analysis-blueprint.md。

## 可复现规则

- 供体是生物学重复的基本单位；细胞级统计不能替代供体级重复。
- 任何阈值都标为文章阈值或本仓库建议阈值。
- 轨迹方向必须报告根节点、算法、模型、置信度和替代根节点。
- scRNA/snRNA、批次和疾病状态不能只靠一个 UMAP 判断可比性。
- 代码先输出 RDS/AnnData、metadata、edge table，再输出图。

## 许可证

模板和代码按 MIT 许可发布；论文内容只做带来源的事实性摘要。使用具体蓝图时请同时引用原论文、原作者代码和数据集。
