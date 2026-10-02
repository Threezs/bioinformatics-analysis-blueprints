cran <- c("Seurat", "Matrix", "yaml", "ggplot2", "dplyr", "patchwork")
bioc <- c("SoupX", "SingleCellExperiment")
if (!requireNamespace("BiocManager", quietly = TRUE)) install.packages("BiocManager")
for (pkg in cran) if (!requireNamespace(pkg, quietly = TRUE)) install.packages(pkg, repos = "https://cloud.r-project.org")
for (pkg in bioc) if (!requireNamespace(pkg, quietly = TRUE)) BiocManager::install(pkg, ask = FALSE, update = FALSE)
message("Core packages installed. Install DoubletFinder, escape, monocle3 and Signac according to their upstream instructions.")

