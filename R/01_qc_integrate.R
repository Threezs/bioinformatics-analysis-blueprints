args <- commandArgs(trailingOnly = TRUE)
get_arg <- function(flag, default = NULL) {
  hit <- which(args == flag)
  if (length(hit) == 0 || hit == length(args)) return(default)
  args[[hit + 1]]
}
input_dir <- get_arg("--input")
sample_sheet_path <- get_arg("--sample-sheet")
config_path <- get_arg("--config", "config/smoc1.yml")
out_dir <- get_arg("--out", "results/qc_integrated")
if (is.null(input_dir) || is.null(sample_sheet_path)) {
  stop("Usage: Rscript R/01_qc_integrate.R --input <10x_dir> --sample-sheet <tsv> [--config file] [--out dir]")
}
if (!dir.exists(input_dir)) stop("Input directory does not exist: ", input_dir)
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
suppressPackageStartupMessages({ library(Seurat); library(Matrix); library(yaml) })
cfg <- yaml::read_yaml(config_path)
sheet <- read.delim(sample_sheet_path, stringsAsFactors = FALSE, check.names = FALSE)
required_sheet <- c("sample_id", "donor_id", "condition", "modality")
if (!all(required_sheet %in% names(sheet))) stop("sample sheet must contain: ", paste(required_sheet, collapse = ", "))
read_matrix <- function(path) {
  x <- Read10X(path)
  if (is.list(x)) if ("Gene Expression" %in% names(x)) x <- x[["Gene Expression"]] else x <- x[[1]]
  x
}
make_object <- function(row) {
  path <- file.path(input_dir, row$sample_id)
  if (!dir.exists(path)) stop("Missing 10x directory: ", path)
  obj <- CreateSeuratObject(counts = read_matrix(path), min.cells = 3, min.features = 200, project = row$sample_id)
  obj$sample_id <- row$sample_id
  obj$donor_id <- row$donor_id
  obj$condition <- row$condition
  obj$modality <- row$modality
  obj$log10GenesPerUMI <- log10(obj$nFeature_RNA) / log10(obj$nCount_RNA)
  obj$percent.mt <- PercentageFeatureSet(obj, pattern = "^MT-")
  obj
}
objects <- lapply(seq_len(nrow(sheet)), function(i) make_object(sheet[i, , drop = FALSE]))
names(objects) <- sheet$sample_id
qc <- function(obj) subset(obj, subset = nCount_RNA >= cfg$seurat$min_counts & nFeature_RNA >= cfg$seurat$min_features & log10GenesPerUMI > cfg$seurat$min_log10_genes_per_umi & percent.mt / 100 < cfg$seurat$max_mito_fraction)
objects <- lapply(objects, qc)
if (requireNamespace("SoupX", quietly = TRUE) && isTRUE(cfg$soupX$enabled)) message("SoupX is installed; apply donor-specific estimates when raw droplets are available.")
if (requireNamespace("DoubletFinder", quietly = TRUE) && isTRUE(cfg$doubletFinder$enabled)) message("DoubletFinder is installed; run per sample after PCA/SCT and record pK.")
objects <- lapply(objects, SCTransform, verbose = FALSE)
features <- SelectIntegrationFeatures(object.list = objects, nfeatures = cfg$seurat$sct_nfeatures)
objects <- PrepSCTIntegration(object.list = objects, anchor.features = features, verbose = FALSE)
anchors <- FindIntegrationAnchors(object.list = objects, normalization.method = "SCT", anchor.features = features, verbose = FALSE)
integrated <- IntegrateData(anchorset = anchors, normalization.method = "SCT", verbose = FALSE)
DefaultAssay(integrated) <- "integrated"
integrated <- RunPCA(integrated, npcs = 50, verbose = FALSE)
integrated <- FindNeighbors(integrated, dims = 1:30, verbose = FALSE)
integrated <- FindClusters(integrated, resolution = cfg$seurat$louvain_resolution, verbose = FALSE)
integrated <- RunUMAP(integrated, dims = 1:30, verbose = FALSE)
saveRDS(integrated, file.path(out_dir, "integrated.rds"))
write.table(integrated[[]], file.path(out_dir, "qc_metadata.tsv"), sep = "\t", quote = FALSE, row.names = TRUE)
writeLines(capture.output(sessionInfo()), file.path(out_dir, "sessionInfo.txt"))
message("Wrote ", file.path(out_dir, "integrated.rds"))

