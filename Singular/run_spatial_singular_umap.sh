#!/usr/bin/env bash
#SBATCH --job-name=spatial_umap
#SBATCH --output=logs/spatial_umap_%j.out
#SBATCH --error=logs/spatial_umap_%j.err
#SBATCH --time=02:00:00
#SBATCH --cpus-per-task=8
#SBATCH --mem=64G
#SBATCH --partition=campus-new

# -----------------------------------------------------------------------------
# HOW TO USE
#
# Purpose
# -------
# Run Scanpy normalization + PCA + neighbors + UMAP + Leiden clustering on:
#   1) Raw Singular SpatialData Zarr (<sample>.zarr)
#   2) ProSeg SpatialData Zarr (proseg-output.zarr)
#
# Invocation
# ----------
# sbatch run_spatial_umap.sh <INPUT_DIR>
#
# Example:
# sbatch run_spatial_singular_umap.sh \
#   /fh/fast/hill_g/Albert/.../customer_output/A01
#
# Expected files in INPUT_DIR
# ---------------------------
#   A01.zarr
#   proseg-output.zarr
#
# Outputs
# -------
#   INPUT_DIR/
#     └── umap_default_vs_proseg.png
#
# Environment
# -----------
# Uses a pre-existing micromamba env directly via PATH:
#   spatial-singular
# -----------------------------------------------------------------------------

set -euo pipefail
mkdir -p logs

# -----------------------------
# CONFIG: environment prefix
# -----------------------------
ENV_PREFIX="$HOME/micromamba/envs/spatial-singular"

export PATH="$ENV_PREFIX/bin:$PATH"
export PYTHONUNBUFFERED=1
export OMP_NUM_THREADS=${SLURM_CPUS_PER_TASK:-8}
export OPENBLAS_NUM_THREADS=1
export MKL_NUM_THREADS=1
export NUMEXPR_NUM_THREADS=1

# sanity checks
[[ -x "$ENV_PREFIX/bin/python" ]] || {
  echo "[ERROR] Python not found in $ENV_PREFIX/bin" >&2
  exit 127
}

echo "[INFO] Using python: $(which python)" >&2
python -V >&2

# -----------------------------
# argument parsing
# -----------------------------
if [[ $# -ne 1 ]]; then
  echo "Usage: sbatch run_spatial_umap.sh <INPUT_DIR>" >&2
  exit 2
fi

INPUT_DIR="$1"

if [[ ! -d "$INPUT_DIR" ]]; then
  echo "[ERROR] Directory does not exist: $INPUT_DIR" >&2
  exit 2
fi

SAMPLE_ID="$(basename "$INPUT_DIR")"
RAW_ZARR="$INPUT_DIR/${SAMPLE_ID}.zarr"
PROSEG_ZARR="$INPUT_DIR/proseg-output.zarr"

[[ -d "$RAW_ZARR" ]] || { echo "[ERROR] Missing $RAW_ZARR" >&2; exit 2; }
[[ -d "$PROSEG_ZARR" ]] || { echo "[ERROR] Missing $PROSEG_ZARR" >&2; exit 2; }

# -----------------------------
# run analysis
# -----------------------------

python <<PY
import random
import numpy as np
import scanpy as sc
import matplotlib.pyplot as plt
from spatialdata import SpatialData

random.seed(1234)
np.random.seed(1234)

input_dir = r"$INPUT_DIR"
raw_zarr = r"$RAW_ZARR"
proseg_zarr = r"$PROSEG_ZARR"

print(f"[python] Reading raw: {raw_zarr}")
sdata_raw = SpatialData.read(raw_zarr)

print(f"[python] Reading proseg: {proseg_zarr}")
sdata_proseg = SpatialData.read(proseg_zarr)

# -----------------------------
# Build AnnData objects
# -----------------------------
adata_default = sdata_raw.tables["table"].copy()
adata_proseg  = sdata_proseg.tables["table"].copy()

def run_scanpy(adata):
    sc.pp.normalize_total(adata)
    sc.pp.log1p(adata)
    sc.pp.pca(adata)
    sc.pp.neighbors(adata)
    sc.tl.umap(adata)
    sc.tl.leiden(adata, resolution=0.5)
    return adata

adata_default = run_scanpy(adata_default)
adata_proseg  = run_scanpy(adata_proseg)

# -----------------------------
# Side-by-side plot
# -----------------------------
fig, axes = plt.subplots(1, 2, figsize=(11, 5))  # rectangular PNG

sc.pl.umap(
    adata_default,
    color="leiden",
    ax=axes[0],
    show=False,
    title="default",
)

sc.pl.umap(
    adata_proseg,
    color="leiden",
    ax=axes[1],
    show=False,
    title="proseg",
)

for ax in axes:
    ax.set_xlabel("UMAP1")
    ax.set_ylabel("UMAP2")

plt.tight_layout()
out_png = f"{input_dir}/umap_default_vs_proseg.png"
plt.savefig(out_png, dpi=200)
plt.close()

print(f"[python] Wrote: {out_png}")
print("[python] Done.")
PY
