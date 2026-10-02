# 蓝图字段和证据模式

data/blueprints.csv 每行是一篇论文的入口，至少包含 blueprint_id、title、doi、year、organism、tissue、modalities、primary_language、status、primary_data、external_data 和 code_repo。

正文必须把下列层次分开：

1. paper fact：原文或原作者代码明确写出的事实；
2. reusable recommendation：为了迁移到新项目而增加的建议；
3. inference：从结果推导出的解释；
4. open question：数据或方法不能解决的问题。

## 证据等级

| 等级 | 例子 | 推荐措辞 |
| --- | --- | --- |
| descriptive | marker、cluster、module score | 呈现、富集、相似 |
| association | 表达相关、疾病组差异 | 相关、伴随 |
| trajectory | velocity、PAGA、pseudotime | 模型支持潜在方向 |
| external_replication | 独立 donor、队列或模态复现 | 在外部数据中复现关联 |
| perturbation | 过表达、敲低、药理或功能实验 | 支持功能/因果方向，并说明边界 |

每个蓝图要明确最终检验单位。单细胞图可以按 cell 绘制，但疾病或 donor 比较优先使用 donor、pseudobulk 或 mixed model；若论文使用 cell-level Wilcoxon，需要在限制和改进中说明。

