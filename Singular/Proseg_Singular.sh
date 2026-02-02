#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# HOW TO USE THIS SCRIPT
#
# Purpose
# -------
# Run Proseg on a Singular Genomics SpatialData Zarr (converted via spatialdata_io.g4x)
# and write a new SpatialData Zarr containing Proseg results (cell assignments / shapes).
#
# IMPORTANT ASSUMPTIONS
# ---------------------
# • INPUT is a SpatialData-backed Zarr directory (e.g. A01.zarr), not the raw Singular folder.
# • Your input Zarr contains:
#     - Points: transcripts
#     - Shapes: nuclei_shapes (and a geometry column)
#     - A per-nucleus / per-cell identifier stored in the shapes (label column)
# • This script uses the "proseg ... --zarr <input.zarr>" mode (as in your working command).
#
# What it does
# ------------
# • Loads Rust (if needed) so the proseg binary works.
# • Ensures ~/.cargo/bin is on PATH (where cargo-installed proseg lives).
# • Runs Proseg with your provided flags:
#     - coordinate scale 0.3125
#     - uses nuclei_shapes + geometry + label as initial shapes / IDs
#     - excludes gene "gdna"
# • Writes: proseg-output.zarr inside the working directory (or wherever you run it)
#
# Invocation
# ----------
# Submit with sbatch, passing ONE argument: the input zarr path.
#
#   sbatch Proseg_Singular.sh /path/to/A01.zarr
#
# Example:
#   sbatch Proseg_Singular.sh\
#     /fh/fast/hill_g/Albert/scSeq_ST_Analyses/Singular_Pilot_2025/.../A01/A01.zarr
#
# Outputs
# -------
# By default (as written here):
#   <same_dir_as_input>/proseg-output.zarr
#
# Logs
# ----
# logs/proseg_run_<JOBID>.log
# logs/proseg_run_<JOBID>.err
#
# Notes / Tips
# ------------
# • Match threads to SLURM: set --nthreads "${SLURM_CPUS_PER_TASK}" so you use what you request.
# • If you want a different output location, edit OUT_ZARR below.
# • If your shapes are named differently (e.g. nuclei_exp_shapes), change --zarr-shape.
# -----------------------------------------------------------------------------

#SBATCH --job-name=proseg_run_singular
#SBATCH --output=logs/proseg_run_%j.log
#SBATCH --error=logs/proseg_run_%j.err
#SBATCH --time=1-00:00:00
#SBATCH --cpus-per-task=8
#SBATCH --mem=128G
#SBATCH --partition=campus-new

set -euo pipefail

mkdir -p logs

# ---- modules / environment ----
module load Rust/1.83.0-GCCcore-13.3.0

# Ensure proseg is in PATH (cargo install proseg puts it here)
export PATH="$HOME/.cargo/bin:$PATH"

command -v proseg >/dev/null 2>&1 || {
  echo "[ERROR] proseg not found in PATH. Install with: cargo install proseg" >&2
  exit 127
}

# ---- args ----
if [[ $# -ne 1 ]]; then
  echo "Usage: sbatch run_proseg_singular.slurm /path/to/input.zarr" >&2
  exit 2
fi

IN_ZARR="$1"

if [[ ! -d "$IN_ZARR" ]]; then
  echo "[ERROR] Input zarr directory not found: $IN_ZARR" >&2
  exit 2
fi

# Put output next to the input zarr (edit if you prefer)
IN_DIR="$(cd "$(dirname "$IN_ZARR")" && pwd)"
OUT_ZARR="${IN_DIR}/proseg-output.zarr"

# Threads: use what SLURM allocated (fallback to 8)
NTHREADS="${SLURM_CPUS_PER_TASK:-8}"

echo "[INFO] Host: $(hostname)" >&2
echo "[INFO] Start: $(date)" >&2
echo "[INFO] proseg: $(command -v proseg)" >&2
echo "[INFO] proseg version: $(proseg --version 2>/dev/null || true)" >&2
echo "[INFO] Input zarr:  $IN_ZARR" >&2
echo "[INFO] Output zarr: $OUT_ZARR" >&2
echo "[INFO] Threads:     $NTHREADS" >&2

# ---- run proseg (YOUR COMMAND, adapted to SLURM + paths) ----
proseg \
  --x-column x \
  --y-column y \
  --z-column z_level \
  --gene-column gene_name \
  --cell-id-column cell_id \
  --cell-id-unassigned 0 \
  --coordinate-scale 0.3125 \
  --excluded-genes gdna \
  --zarr-shape nuclei_shapes \
  --zarr-shape-geometry-column geometry \
  --zarr-shape-cell-id-column label \
  --zarr \
  --output-spatialdata "$OUT_ZARR" \
  --nthreads "$NTHREADS" \
  "$IN_ZARR"

echo "[INFO] Done: $(date)" >&2
echo "[INFO] Wrote: $OUT_ZARR" >&2
