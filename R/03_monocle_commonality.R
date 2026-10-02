args <- commandArgs(trailingOnly = TRUE)
get_arg <- function(flag, default = NULL) {
  hit <- which(args == flag)
  if (length(hit) == 0 || hit == length(args)) return(default)
  args[[hit + 1]]
}
rds_path <- get_arg("--rds")
velocity_path <- get_arg("--velocity")
out_dir <- get_arg("--out", "results/commonality")
if (is.null(rds_path) || is.null(velocity_path)) stop("Usage: Rscript R/03_monocle_commonality.R --rds reference.rds --velocity velocity_metadata.tsv [--out dir]")
if (!requireNamespace("monocle3", quietly = TRUE)) stop("Install monocle3 for graph_test.")
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
suppressPackageStartupMessages({ library(Seurat); library(monocle3); library(Matrix) })
obj <- readRDS(rds_path)
meta <- read.delim(velocity_path, stringsAsFactors = FALSE, check.names = FALSE)
meta <- meta[match(colnames(obj), meta$cell_id), , drop = FALSE]
if (anyNA(meta$cell_id)) stop("Velocity metadata does not cover every Seurat barcode.")
rownames(meta) <- meta$cell_id
counts <- GetAssayData(obj, assay = "RNA", slot = "counts")
cds <- new_cell_data_set(counts, cell_metadata = meta, gene_metadata = data.frame(gene_short_name = rownames(counts), row.names = rownames(counts)))
cds <- preprocess_cds(cds, num_dim = 50)
cds <- reduce_dimension(cds, reduction_method = "UMAP")
cds <- cluster_cells(cds)
root_state <- "AB"
root_cells <- colnames(cds)[colData(cds)$cell_state == root_state]
if (length(root_cells) < 10) stop("Fewer than 10 cells have root state: ", root_state)
cds <- learn_graph(cds)
cds <- order_cells(cds, root_cells = root_cells)
tests <- graph_test(cds, neighbor_graph = "principal_graph", cores = 1)
tests$gene_id <- rownames(tests)
write.table(as.data.frame(tests), file.path(out_dir, "monocle_graph_test.tsv"), sep = "\t", quote = FALSE, row.names = FALSE)
write.table(as.data.frame(colData(cds)), file.path(out_dir, "pseudotime_metadata.tsv"), sep = "\t", quote = FALSE, row.names = FALSE)
saveRDS(cds, file.path(out_dir, "monocle3_cds.rds"))
message("Graph test complete; compute intersections only after donor-aware sensitivity checks.")
