#!/usr/bin/env bash
#SBATCH --job-name=plot_confidence
#SBATCH --output=logs/plot_confidence_%j.out
#SBATCH --error=logs/plot_confidence_%j.err
#SBATCH --time=02:00:00
#SBATCH --cpus-per-task=2
#SBATCH --mem=128G
#SBATCH --partition=campus-new

# -----------------------------------------------------------------------------
# HOW TO USE
#
# Purpose
# -------
# Create a single side-by-side PNG comparing:
#   1) Parquet meanQS histogram (log y)
#   2) CSV confidence_score histogram (log y)
# with quartile lines annotated in each panel.
#
# Input
# -----
# One argument: BASE directory that contains:
#   BASE/diagnostics/transcript_table.parquet
#   BASE/rna/transcript_table.csv.gz
#
# Output
# ------
# Writes the PNG into BASE:
#   BASE/meanQS_vs_confidence_score_histograms.png
#
# Submit
# ------
#   sbatch plot_meanQS_confidence.sh /path/to/A01
#
# Example
# -------
#   sbatch plot_meanQS_confidence.sh \
#     /fh/fast/hill_g/Albert/scSeq_ST_Analyses/Singular_Pilot_2025/data/Run1_raw/Gut/\
#     g4-012-054-FC2-L001_5WtNECt2qiMdhgeK/customer_output/A01
# -----------------------------------------------------------------------------

set -euo pipefail

mkdir -p logs

usage() {
  cat <<'EOF'
Usage:
  sbatch plot_qc_histograms.sbatch.sh <BASE_DIR>

BASE_DIR must contain:
  diagnostics/transcript_table.parquet
  rna/transcript_table.csv.gz

Output:
  <BASE_DIR>/meanQS_vs_confidence_score_histograms.png
EOF
}

if [[ $# -ne 1 ]]; then
  usage
  exit 2
fi

BASE_DIR="$1"

DIAG_DIR="${BASE_DIR%/}/diagnostics"
RNA_DIR="${BASE_DIR%/}/rna"

PARQUET="${DIAG_DIR}/transcript_table.parquet"
CSVGZ="${RNA_DIR}/transcript_table.csv.gz"
OUTPNG="${BASE_DIR%/}/meanQS_vs_confidence_score_histograms.png"

[[ -d "$BASE_DIR" ]] || { echo "[ERROR] BASE_DIR not found: $BASE_DIR" >&2; exit 2; }
[[ -f "$PARQUET" ]]  || { echo "[ERROR] Missing: $PARQUET" >&2; exit 2; }
[[ -f "$CSVGZ" ]]    || { echo "[ERROR] Missing: $CSVGZ" >&2; exit 2; }

echo "[INFO] BASE_DIR : $BASE_DIR" >&2
echo "[INFO] PARQUET  : $PARQUET" >&2
echo "[INFO] CSVGZ    : $CSVGZ" >&2
echo "[INFO] OUTPNG   : $OUTPNG" >&2

# -----------------------------------------------------------------------------
# Environment (NO activation; use direct env prefix like your working BLAST script)
# Update ENV_PREFIX to your spatial-singular micromamba env prefix.
# -----------------------------------------------------------------------------
ENV_PREFIX="/home/ayeh/micromamba/envs/spatial-singular"

export PATH="$ENV_PREFIX/bin:$PATH"
export PYTHONUNBUFFERED=1

# sanity check
[[ -x "$ENV_PREFIX/bin/python" ]] || { echo "[ERROR] Missing python at: $ENV_PREFIX/bin/python" >&2; exit 127; }

"$ENV_PREFIX/bin/python" -V >&2

# -----------------------------------------------------------------------------
# Run the plotting code
# -----------------------------------------------------------------------------
"$ENV_PREFIX/bin/python" - <<PY
import os
import polars as pl
import matplotlib.pyplot as plt
import numpy as np

base = r"$BASE_DIR"
diag_dir = os.path.join(base, "diagnostics")
rna_dir  = os.path.join(base, "rna")

parquet_path = os.path.join(diag_dir, "transcript_table.parquet")
csv_path     = os.path.join(rna_dir,  "transcript_table.csv.gz")
out_png      = os.path.join(base, "meanQS_vs_confidence_score_histograms.png")

# Load meanQS (parquet)
df_meanQS = (
    pl.scan_parquet(parquet_path)
    .select("meanQS")
    .collect()
)
meanQS = df_meanQS["meanQS"].to_numpy()
q1_m, med_m, q3_m = np.percentile(meanQS, [25, 50, 75])

# Load confidence_score (csv.gz)
df_conf = (
    pl.scan_csv(csv_path)
    .select("confidence_score")
    .collect()
)
conf = df_conf["confidence_score"].to_numpy()
q1_c, med_c, q3_c = np.percentile(conf, [25, 50, 75])

# Plot side-by-side
fig, axes = plt.subplots(1, 2, figsize=(12, 4), sharey=True)

ax = axes[0]
ax.hist(meanQS, bins=150)
ax.set_yscale("log")
ax.axvline(q1_m, linestyle="--", linewidth=1, label=f"Q1 = {q1_m:.2f}")
ax.axvline(med_m, linestyle="-",  linewidth=1.5, label=f"Median = {med_m:.2f}")
ax.axvline(q3_m, linestyle="--", linewidth=1, label=f"Q3 = {q3_m:.2f}")
ax.set_xlabel("meanQS")
ax.set_ylabel("Transcript count (log scale)")
ax.set_title("Parquet: meanQS")
ax.legend(fontsize=9)

ax = axes[1]
ax.hist(conf, bins=150)
ax.set_yscale("log")
ax.axvline(q1_c, linestyle="--", linewidth=1, label=f"Q1 = {q1_c:.2f}")
ax.axvline(med_c, linestyle="-",  linewidth=1.5, label=f"Median = {med_c:.2f}")
ax.axvline(q3_c, linestyle="--", linewidth=1, label=f"Q3 = {q3_c:.2f}")
ax.set_xlabel("confidence_score")
ax.set_title("CSV: confidence_score")
ax.legend(fontsize=9)

plt.suptitle("Transcript quality metrics comparison", fontsize=14)
plt.tight_layout(rect=[0, 0, 1, 0.95])
plt.savefig(out_png, dpi=200)
plt.close(fig)

print(f"[python] wrote: {out_png}")
PY

echo "[INFO] Done. Wrote: $OUTPNG" >&2
