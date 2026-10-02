#!/usr/bin/env python3
"""Run a transparent scVelo/PAGA bridge from a GRCh38 loom and Seurat metadata."""
from __future__ import annotations
import argparse
from pathlib import Path
import matplotlib.pyplot as plt
import pandas as pd
import scanpy as sc
import scvelo as scv

def main() -> None:
    p = argparse.ArgumentParser()
    p.add_argument("--loom", required=True)
    p.add_argument("--metadata", required=True)
    p.add_argument("--out", default="results/velocity")
    args = p.parse_args()
    out = Path(args.out)
    out.mkdir(parents=True, exist_ok=True)
    meta = pd.read_csv(args.metadata, sep="\t")
    required = {"cell_id", "UMAP_1", "UMAP_2", "cell_state"}
    missing = required.difference(meta.columns)
    if missing:
        raise SystemExit(f"metadata is missing columns: {sorted(missing)}")
    if meta["cell_id"].duplicated().any():
        raise SystemExit("metadata cell_id values are not unique")
    adata = scv.read(args.loom, cache=True)
    adata.var_names_make_unique()
    common = adata.obs_names.intersection(meta["cell_id"])
    if len(common) < 100:
        raise SystemExit(f"Only {len(common)} barcodes overlap; fix prefixes before velocity.")
    adata = adata[common].copy()
    meta = meta.set_index("cell_id").loc[common]
    adata.obs = adata.obs.join(meta[["cell_state"]], how="left")
    adata.obsm["X_umap"] = meta[["UMAP_1", "UMAP_2"]].to_numpy()
    adata.obs["cell_state"] = adata.obs["cell_state"].astype("category")
    scv.pp.filter_and_normalize(adata, min_shared_counts=20, n_top_genes=3000)
    scv.pp.moments(adata, n_pcs=30, n_neighbors=30)
    scv.tl.velocity(adata, mode="stochastic")
    scv.tl.velocity_graph(adata)
    scv.tl.velocity_confidence(adata)
    sc.tl.paga(adata, groups="cell_state")
    scv.tl.paga(adata, groups="cell_state")
    adata.uns["blueprint"] = {"model": "stochastic", "reference_genome": "GRCh38", "n_cells": int(adata.n_obs)}
    adata.write(out / "velocity_paga.h5ad")
    adata.obs[["velocity_confidence"]].to_csv(out / "velocity_confidence.tsv", sep="\t")
    scv.pl.velocity_embedding_stream(adata, basis="umap", color="cell_state", legend_loc="right", show=False)
    plt.savefig(out / "velocity_stream.png", dpi=200, bbox_inches="tight")
    plt.close()
    scv.pl.paga(adata, basis="umap", color="cell_state", show=False)
    plt.savefig(out / "paga.png", dpi=200, bbox_inches="tight")
    plt.close()

if __name__ == "__main__":
    main()

