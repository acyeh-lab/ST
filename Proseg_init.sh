#!/bin/bash
#SBATCH --job-name=proseg_run
#SBATCH --output=proseg_run_%j.log
#SBATCH --error=proseg_run_%j.err
#SBATCH --time=03:00:00
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --partition=campus-new

# -----------------------------------------------------------------------------
# Proseg_init.sh -- run Proseg on a Xenium transcripts.parquet
#
# Usage: sbatch Proseg_init.sh <working_directory>
#
# <working_directory> must contain a transcripts.parquet (real or symlinked
# to a Xenium Ranger output folder). All Proseg outputs are written into
# the same directory.
#
# Reproducibility note:
#   Proseg 3.1.0 has no --seed flag and uses thread-local RNG seeded from
#   system entropy, so two runs on the same input will produce statistically
#   equivalent but not bit-identical outputs (Spearman r ~ 0.9997 on per-gene
#   totals in our tests; ~54% of cells stay within 2 um centroid distance).
#   For methodological consistency across a study, run all samples through
#   this single pinned script (Proseg 3.1.0 + identical flags + the densify
#   step below). Cite the script version in Methods.
# -----------------------------------------------------------------------------

# Load Rust toolchain (needed if proseg is recompiled from source).
module load Rust/1.83.0-GCCcore-13.3.0

# Local proseg install lives in ~/.cargo/bin
export PATH="$HOME/.cargo/bin:$PATH"

command -v proseg || { echo "ProSeg is not installed. Please run: cargo install proseg"; exit 1; }

if [ -z "$1" ]; then
  echo "Usage: sbatch Proseg_init.sh <output_directory>"
  exit 1
fi

wd="$1"
cd "$wd" || { echo "Failed to cd to $wd"; exit 1; }
pwd
proseg --version

# -----------------------------------------------------------------------------
# Step 1: run Proseg.
# Proseg >= 3.0 made outputs opt-in: only proseg-output.zarr is written by
# default. Request the legacy CSV/GeoJSON outputs the Hill Lab pipeline expects.
# -----------------------------------------------------------------------------
proseg "$wd/transcripts.parquet" \
    --xenium \
    --output-cell-polygons cell-polygons.geojson.gz \
    --output-cell-polygon-layers cell-polygons-layers.geojson.gz \
    --output-union-cell-polygons union-cell-polygons.geojson.gz \
    --output-transcript-metadata transcript-metadata.csv.gz \
    --output-cell-metadata cell-metadata.csv.gz \
    --output-expected-counts expected-counts.csv.gz

# -----------------------------------------------------------------------------
# Step 2: densify expected-counts.
# Proseg >= 3.0 always writes expected-counts as MatrixMarket (sparse, float
# values = posterior means), regardless of the filename extension; there is no
# --output-expected-counts-fmt flag. The Hill Lab notebooks load this file
# with sc.read_csv() and require a dense (cells x genes) CSV with bare
# gene-name headers (no row index).
#
# We rename the MTX-format file to expected-counts.csv.gz.mtx, then read its
# values together with the gene ordering from proseg-output.zarr's var['gene'],
# and overwrite expected-counts.csv.gz with a dense CSV.
#
# Why not use the zarr's X directly? The zarr stores integer point-estimates
# (uint32) rather than the posterior-mean float values we want. So values
# must come from the MTX; only the gene-name ordering comes from the zarr.
# -----------------------------------------------------------------------------
mv "$wd/expected-counts.csv.gz" "$wd/expected-counts.csv.gz.mtx"
micromamba run -n spatial-singular python - "$wd" <<'PY'
import gzip, sys
from pathlib import Path
import pandas as pd
import anndata as ad
from scipy.io import mmread

wd = Path(sys.argv[1])
mtx = wd / "expected-counts.csv.gz.mtx"
out = wd / "expected-counts.csv.gz"

with gzip.open(mtx, "rt") as fh:
    mat = mmread(fh).tocsr()
a = ad.read_zarr(wd / "proseg-output.zarr" / "tables" / "table")
genes = a.var["gene"].tolist() if "gene" in a.var.columns else a.var_names.tolist()
assert mat.shape == (a.shape[0], a.shape[1]), f"MTX {mat.shape} vs zarr {a.shape}"
df = pd.DataFrame(mat.toarray(), columns=genes)
df.to_csv(out, index=False, compression="gzip", float_format="%g")
print(f"[densify] wrote {out.name}: {df.shape[0]} cells x {df.shape[1]} genes, nnz={mat.nnz}")
PY
rm -f "$wd/expected-counts.csv.gz.mtx"
