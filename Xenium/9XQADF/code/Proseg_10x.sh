#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# Proseg_10x.sh — run ProSeg on a 10x Xenium output bundle
# -----------------------------------------------------------------------------
#
# Purpose
# -------
# Re-segment a 10x Xenium run with ProSeg (Daniel Jones' Bayesian segmenter)
# starting from `transcripts.parquet`. Outputs are written to
#   <run_root>/proseg/<SAMPLE_ID>/
# so the AY_001*.ipynb analysis notebooks pick them up via
#   prosegDir = data/<run>/proseg ; <SAMPLE_ID>/cell-metadata.csv.gz, etc.
#
# What this script does
# ---------------------
# • Loads Rust (so the proseg binary works) and ensures ~/.cargo/bin is on PATH.
# • Runs ProSeg with the `--xenium` preset (correct column parsing for the
#   Xenium transcripts.parquet format).
# • Writes both the modern SpatialData zarr (canonical v3 output) AND the
#   legacy per-table outputs that downstream notebooks consume directly.
#
# IMPORTANT ASSUMPTIONS
# ---------------------
# • ProSeg v3.x is installed via `cargo install proseg`.
#       which proseg     -> ~/.cargo/bin/proseg
#       proseg --version -> 3.x.y
# • IN_DIR is a 10x Xenium output bundle directory containing
#   transcripts.parquet (typical name:
#   output-XETG00049__<slide>__XE075_<slide_last4>_<sample>__<date>__<time>).
# • Initial cell IDs come from Xenium's nucleus segmentation embedded in
#   transcripts.parquet — no need for the `--zarr-shape` flow used in the
#   Singular Genomics script.
#
# Heads-up on file formats (proseg v3 breaking change)
# ----------------------------------------------------
# In proseg v3, count matrices write as **matrix-market** (`.mtx.gz`), not
# `.csv.gz` as in earlier versions. The XB9MDD analysis notebooks currently
# load with:
#       sc.read_csv(".../expected-counts.csv.gz")
# That call WILL FAIL on the new outputs. Either:
#   (a) Update the notebooks to load via scipy.io.mmread (recommended), or
#   (b) Add a one-shot post-processing step here to convert mtx.gz -> csv.gz.
#
# Outputs (under <run_root>/proseg/<SAMPLE_ID>/)
# ----------------------------------------------
#   proseg-output.zarr/              SpatialData zarr (transcripts, polygons,
#                                    AnnData with counts + metadata)
#   expected-counts.mtx.gz           cell × gene expected (non-integer) counts
#   cell-metadata.csv.gz             cell_id, centroid_x, centroid_y, volume…
#   transcript-metadata.csv.gz       per-transcript revised positions + assign.
#   cell-polygons.geojson.gz         2D consensus cell boundaries
#
# Logs
# ----
# logs/proseg_10x_<JOBID>.log   stdout
# logs/proseg_10x_<JOBID>.err   stderr
#
# Invocation
# ----------
# Single sample (sbatch one bundle):
#   sbatch shell/Proseg_10x.sh \
#     /fh/fast/.../data/xenium_9xqadf_2026/raw/output-XETG00049__0063672__XE075_63672_3022__20260408__203547
#
# All 12 bundles in this run (fan out as separate jobs):
#   for d in data/xenium_9xqadf_2026/raw/output-XETG*; do
#     sbatch shell/Proseg_10x.sh "$d"
#   done
#
# Notes / Tips
# ------------
# • Threads: --nthreads "${SLURM_CPUS_PER_TASK}" so we use what SLURM gave us.
# • Memory: full-tissue Xenium sections often need 64–128 GB; bump --mem if
#   the job OOMs. Reduce by raising --voxel-size or passing --no-diffusion.
# • Time: each section can take several hours; bump --time on big tissue.
# • To inspect results in Xenium Explorer, post-process with `proseg-to-baysor`
#   on proseg-output.zarr, then `xeniumranger import-segmentation`.
# • ProSeg is non-deterministic across runs (results are interpretively close).
# -----------------------------------------------------------------------------

#SBATCH --job-name=proseg_10x
#SBATCH --output=logs/proseg_10x_%j.log
#SBATCH --error=logs/proseg_10x_%j.err
#SBATCH --time=1-00:00:00
#SBATCH --cpus-per-task=8
#SBATCH --mem=128G
#SBATCH --partition=campus-new

set -euo pipefail

mkdir -p logs

# ---- modules / environment ----
module load Rust/1.83.0-GCCcore-13.3.0
export PATH="$HOME/.cargo/bin:$PATH"

command -v proseg >/dev/null 2>&1 || {
  echo "[ERROR] proseg not found in PATH. Install with: cargo install proseg" >&2
  exit 127
}

# ---- args ----
if [[ $# -ne 1 ]]; then
  echo "Usage: sbatch shell/Proseg_10x.sh /path/to/xenium/output/bundle" >&2
  echo "       (the bundle must contain transcripts.parquet)" >&2
  exit 2
fi

IN_DIR="$(cd "$1" && pwd)"
TRANSCRIPTS="$IN_DIR/transcripts.parquet"

if [[ ! -d "$IN_DIR" ]]; then
  echo "[ERROR] Input bundle directory not found: $IN_DIR" >&2
  exit 2
fi
if [[ ! -f "$TRANSCRIPTS" ]]; then
  echo "[ERROR] transcripts.parquet not found in $IN_DIR" >&2
  echo "        — is this a Xenium output bundle?" >&2
  exit 2
fi

# ---- derive SAMPLE_ID from bundle name ----
# Bundle name pattern:
#   output-XETG00049__0063672__XE075_63672_3022__20260408__203547
# We want:                         63672_3022
RAW_NAME="$(basename "$IN_DIR")"
SAMPLE_ID="$(echo "$RAW_NAME" \
  | sed -E 's/^output-XETG[0-9]+__[0-9]+__XE[0-9]+_//; s/__[0-9]+__[0-9]+$//')"
[[ -n "$SAMPLE_ID" ]] || SAMPLE_ID="$RAW_NAME"

# ---- derive output dir: <run_root>/proseg/<SAMPLE_ID> ----
RAW_DIR="$(dirname "$IN_DIR")"          # .../data/xenium_9xqadf_2026/raw
RUN_ROOT="$(dirname "$RAW_DIR")"        # .../data/xenium_9xqadf_2026
OUT_DIR="$RUN_ROOT/proseg/$SAMPLE_ID"
mkdir -p "$OUT_DIR"

OUT_ZARR="$OUT_DIR/proseg-output.zarr"

# Threads = what SLURM allocated (fallback 8)
NTHREADS="${SLURM_CPUS_PER_TASK:-8}"

echo "[INFO] Host:        $(hostname)" >&2
echo "[INFO] Start:       $(date)" >&2
echo "[INFO] proseg:      $(command -v proseg)" >&2
echo "[INFO] proseg ver:  $(proseg --version 2>/dev/null || true)" >&2
echo "[INFO] Input:       $TRANSCRIPTS" >&2
echo "[INFO] Sample ID:   $SAMPLE_ID" >&2
echo "[INFO] Output dir:  $OUT_DIR" >&2
echo "[INFO] Threads:     $NTHREADS" >&2

cd "$OUT_DIR"

# ---- run proseg ----
proseg \
  --xenium \
  --nthreads "$NTHREADS" \
  --output-spatialdata          "$OUT_ZARR" \
  --output-expected-counts      expected-counts.mtx.gz \
  --output-cell-metadata        cell-metadata.csv.gz \
  --output-transcript-metadata  transcript-metadata.csv.gz \
  --output-cell-polygons        cell-polygons.geojson.gz \
  "$TRANSCRIPTS"

echo "[INFO] Done:        $(date)" >&2
echo "[INFO] Wrote:       $OUT_DIR" >&2
