required <- c("Seurat", "Matrix", "yaml")
optional <- c("SoupX", "DoubletFinder", "escape", "monocle3", "Signac")
cat("R:", R.version.string, "\n")
for (pkg in c(required, optional)) {
  ok <- requireNamespace(pkg, quietly = TRUE)
  version <- if (ok) as.character(utils::packageVersion(pkg)) else "not installed"
  cat(sprintf("%-16s %s\n", pkg, version))
}
missing <- required[!vapply(required, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing) > 0) stop("Install required packages: ", paste(missing, collapse = ", "))
cat("Required packages are available.\n")

