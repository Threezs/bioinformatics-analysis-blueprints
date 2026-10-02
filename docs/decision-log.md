# BP-001 决策日志

| 决策 | 采用方案 | 原因 | 需要敏感性分析 |
| --- | --- | --- | --- |
| 环境 RNA | 论文阈值 20%，新项目优先用空液滴估计 | 胰岛激素转录本容易造成假双阳性 | SoupX 前后 GCG/INS、不同污染率 |
| 整合 | SCT anchors；保留 donor、condition、modality | 对齐技术差异，同时避免丢掉疾病信息 | 不整合、Harmony/fastMNN 或 donor-held-out |
| AB 细胞 | 不因双阳性自动删除 | 论文用 doublet、stress、multiome 多证据支持 | donor、doublet score、应激分数 |
| 速度模型 | stochastic，和 scRNA-only 对照 | 论文明确使用该模型和 velocity confidence | deterministic、不同邻居数、不同根 |
| 伪时序根 | 先由 PAGA 指定，再交给 Monocle3 | 避免任意从 UMAP 边缘选根 | AB、beta1 及替代根 |
| 疾病统计 | donor/pseudobulk 优先 | 细胞不是独立生物学重复 | cell-level 结果只作探索 |
| 候选优先级 | 多轨迹交集 + 外部队列 + multiome | 降低单轨迹过拟合 | donor bootstrap 和留一供体 |

## 文章事实和本仓库建议的分界

- 文章事实：QC 阈值、Seurat/velocyto/scVelo/PAGA/Monocle3 组合、五个 alpha 状态、十个共同基因、HPAP 的 13 ND + 13 T2D 以及 GSE accession。
- 本仓库建议：样本表契约、donor-aware 汇总、barcode 质量门、替代根节点、bootstrap/pseudobulk 敏感性分析和显式输出文件。

