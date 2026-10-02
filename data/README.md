# 数据目录约定

真实矩阵和 loom 不提交到仓库。请把它们放在本地或受控存储，并把路径、下载时间、参考基因组和授权状态记录在项目自己的 provenance.tsv 中。

推荐布局：

~~~text
data/
  sample_sheet.tsv
  tenx/
    donor01_sc/
      matrix.mtx.gz
      barcodes.tsv.gz
      features.tsv.gz
  velocity/
    integrated.loom
~~~

sample_sheet.example.tsv 只用于复制字段，不是实验数据。GEO、HPAP 等公开数据的使用必须遵循各自的条款。

