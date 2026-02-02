#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# HOW TO USE
#
# Purpose
#   Read a Singular Genomics G4x region directory with spatialdata_io.g4x()
#   and (if the loader writes/caches a Zarr store) materialize the Zarr store.
#
# Usage
#   sbatch singular_zarr.sbatch.sh /path/to/<REGION_DIR>
#
# Example
#   sbatch singular_zarr.sbatch.sh \
#     /fh/fast/hill_g/Albert/scSeq_ST_Analyses/Singular_Pilot_2025/data/Run1_raw/Gut/\
#     g4-012-054-FC2-L001_5WtNECt2qiMdhgeK/customer_output/A01
#
# Notes
#   - This script treats the input directory as READ-ONLY.
#   - We do NOT call "micromamba activate". We run Python directly from an env prefix,
#     just like your working BLAST wrapper.
#   - If g4x() creates <REGION>/<REGION>.zarr, we print the path at the end.
# -----------------------------------------------------------------------------

#SBATCH --job-name=g4x_to_zarr
#SBATCH --partition=campus-new
#SBATCH --cpus-per-task=4
#SBATCH --mem=128G
#SBATCH --time=2:00:00
#SBATCH --output=logs/%x-%j.out
#SBATCH --error=logs/%x-%j.err

set -euo pipefail

mkdir -p logs

usage() {
  cat <<'EOF'
Usage:
  sbatch singular_zarr.sbatch.sh <INPUT_FOLDER>

Example:
  sbatch singular_zarr.sbatch.sh /path/to/customer_output/A01
EOF
}

if [[ $# -ne 1 ]]; then
  usage
  exit 2
fi

INPUT_DIR="$1"
[[ -d "$INPUT_DIR" ]] || { echo "[ERROR] Input folder does not exist: $INPUT_DIR" >&2; exit 2; }

# ---- Point directly at the micromamba env prefix (no activation needed) ----
# Set this to the env that has spatialdata + spatialdata-io with g4x support.
ENV_PREFIX="/home/ayeh/micromamba/envs/spatial-singular"

# Threading: many libs will try to use all cores; keep it reasonable / predictable.
export OMP_NUM_THREADS=${SLURM_CPUS_PER_TASK:-4}
export OPENBLAS_NUM_THREADS=1
export MKL_NUM_THREADS=1
export NUMEXPR_NUM_THREADS=1
export PYTHONUNBUFFERED=1

# Make sure env python exists
[[ -x "$ENV_PREFIX/bin/python" ]] || { echo "[ERROR] Missing $ENV_PREFIX/bin/python" >&2; exit 127; }

echo "[INFO] Host: $(hostname)" >&2
echo "[INFO] Start: $(date)" >&2
echo "[INFO] INPUT_DIR: $INPUT_DIR" >&2
echo "[INFO] ENV_PREFIX: $ENV_PREFIX" >&2
echo "[INFO] Using python: $ENV_PREFIX/bin/python" >&2
"$ENV_PREFIX/bin/python" -V >&2

# Optional sanity check: show which spatialdata_io we’re using
"$ENV_PREFIX/bin/python" - <<'PY'
import spatialdata_io as sio
print("[python] spatialdata_io version:", getattr(sio, "__version__", "unknown"))
print("[python] has g4x:", hasattr(sio, "g4x"))
PY

# Run ingestion
"$ENV_PREFIX/bin/python" - <<PY
import os, sys
from pathlib import Path
from spatialdata_io import g4x

input_dir = Path(r"$INPUT_DIR")

print(f"[python] Reading: {input_dir}", file=sys.stderr)
sdata = g4x(input_dir)

# Try to infer the Zarr path in the most common pattern:
# <input_dir>/<basename>.zarr (e.g., A01/A01.zarr)
zarr_guess = input_dir / (input_dir.name + ".zarr")
if zarr_guess.exists():
    print(f"[python] Zarr store exists: {zarr_guess}", file=sys.stderr)
else:
    print(f"[python] Zarr store not found at expected path: {zarr_guess}", file=sys.stderr)
    print("[python] (This may be normal depending on spatialdata_io version / lazy materialization.)", file=sys.stderr)

print("[python] Done.", file=sys.stderr)
PY

echo "[INFO] End: $(date)" >&2
