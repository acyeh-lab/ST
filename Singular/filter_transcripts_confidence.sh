#!/usr/bin/env bash
#SBATCH --job-name=plot_confidence
#SBATCH --output=logs/filter_confidence_%j.out
#SBATCH --error=logs/filter_confidence_%j.err
#SBATCH --time=02:00:00
#SBATCH --cpus-per-task=2
#SBATCH --mem=128G
#SBATCH --partition=campus-new

# ==============================================================================
# Script: filter_transcripts_confidence.sh
#
# Purpose:
#   Filters transcript_table.csv.gz by confidence_score using Polars. Default threshold is 20.
#
# Behavior:
#   1. Renames original:
#        transcript_table.csv.gz
#        → transcript_table_original.csv.gz
#   2. Writes filtered file back to:
#        transcript_table.csv.gz
#
# Safety:
#   - Aborts if transcript_table_original.csv.gz already exists
#   - Lazy + streaming write (memory efficient)
#
# Usage:
#   sbatch filter_transcripts_confidence.sh /path/to/run_folder
#
# Optional:
#   sbatch --export=ALL,THRESH=30 filter_transcripts_confidence.sh /path/to/run
# ==============================================================================
set -euo pipefail

ENV_PREFIX="/home/ayeh/micromamba/envs/spatial-singular"

INPUT_DIR="${1:-}"

if [[ -z "$INPUT_DIR" ]]; then
    echo "[ERROR] Must provide input directory."
    echo "Usage: sbatch $0 /path/to/run_folder"
    exit 1
fi

ORIGINAL_FILE="${INPUT_DIR}/transcript_table.csv.gz"
BACKUP_FILE="${INPUT_DIR}/transcript_table_original.csv.gz"
OUTPUT_FILE="${INPUT_DIR}/transcript_table.csv.gz"

THRESH="${THRESH:-20}"

# ---- Thread control ----
export OMP_NUM_THREADS=${SLURM_CPUS_PER_TASK:-4}
export OPENBLAS_NUM_THREADS=1
export MKL_NUM_THREADS=1
export NUMEXPR_NUM_THREADS=1
export PYTHONUNBUFFERED=1
export POLARS_MAX_THREADS=${SLURM_CPUS_PER_TASK:-4}
export RAYON_NUM_THREADS=${SLURM_CPUS_PER_TASK:-4}

# ---- Checks ----
[[ -x "$ENV_PREFIX/bin/python" ]] || {
    echo "[ERROR] Missing $ENV_PREFIX/bin/python" >&2
    exit 127
}

[[ -f "$ORIGINAL_FILE" ]] || {
    echo "[ERROR] Cannot find $ORIGINAL_FILE" >&2
    exit 2
}

if [[ -f "$BACKUP_FILE" ]]; then
    echo "[ERROR] $BACKUP_FILE already exists. Aborting to prevent overwrite."
    exit 3
fi

echo "[INFO] Host: $(hostname)"
echo "[INFO] Start: $(date)"
echo "[INFO] Input directory: $INPUT_DIR"
echo "[INFO] Threshold: confidence_score >= $THRESH"

# ---- Rename original file ----
echo "[INFO] Renaming original file..."
mv "$ORIGINAL_FILE" "$BACKUP_FILE"

echo "[INFO] Original renamed to transcript_table_original.csv.gz"

# ---- Run filtering ----
INPUT="$BACKUP_FILE" OUTPUT="$OUTPUT_FILE" THRESH="$THRESH" \
"$ENV_PREFIX/bin/python" - <<'PY'
import os
import polars as pl

input_file = os.environ["INPUT"]
output_file = os.environ["OUTPUT"]
thresh = float(os.environ["THRESH"])

print(f"[python] Reading: {input_file}")
print(f"[python] Writing: {output_file}")
print(f"[python] Filter: confidence_score >= {thresh:g}")

lf = pl.scan_csv(input_file)

total = lf.select(pl.len()).collect().item()

lf_filtered = lf.filter(pl.col("confidence_score") >= thresh)
kept = lf_filtered.select(pl.len()).collect().item()

print(f"[python] Total transcripts: {total:,}")
print(f"[python] Kept: {kept:,}")
print(f"[python] Dropped: {total - kept:,}")
print(f"[python] Percent kept: {100 * kept / total:.2f}%")

lf_filtered.sink_csv(output_file, compression="gzip")

print("[python] Done.")
PY

echo "[INFO] Finished: $(date)"

# ---- Copy Slurm stdout into input directory (robust) ----
if [[ -n "${SLURM_JOB_ID:-}" ]]; then
    SUBMIT_DIR="${SLURM_SUBMIT_DIR:-$(pwd)}"
    SLURM_OUT="${SUBMIT_DIR}/logs/filter_confidence_${SLURM_JOB_ID}.out"
    if [[ -f "$SLURM_OUT" ]]; then
        cp "$SLURM_OUT" "${INPUT_DIR}/transcript_filter_${SLURM_JOB_ID}.out"
        echo "[INFO] Copied Slurm output to ${INPUT_DIR}/transcript_filter_${SLURM_JOB_ID}.out"
    else
        echo "[WARN] Slurm stdout not found at: $SLURM_OUT"
    fi
fi


