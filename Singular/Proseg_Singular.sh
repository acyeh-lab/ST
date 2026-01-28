#!/bin/bash
#SBATCH --job-name=proseg_run_singular
#SBATCH --output=proseg_run_%j.log
#SBATCH --error=proseg_run_%j.err
#SBATCH --time=01:00:00
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --partition=campus-new

# Note that this script allows you to pass 1 variable from command line (output directory)

# Load Rust module if needed
module load Rust/1.83.0-GCCcore-13.3.0

# Ensure proseg is in PATH
export PATH="$HOME/.cargo/bin:$PATH"


# Optional: confirm that ProSeg is available
command -v proseg || { echo "ProSeg is not installed. Please run: cargo install proseg"; exit 1; }

# Check that a directory argument was provided
if [ -z "$1" ]; then
  echo "Usage: sbatch run_proseg.slurm <output_directory>"
  exit 1
fi

# Assign command-line argument to a variable
wd="$1"

# Move to the working directory
cd "$wd" || { echo "Failed to cd to $wd"; exit 1; }

# Confirm current working directory
pwd

# Run ProSeg
proseg --csv "$wd/rna/transcript_table.csv.gz" \
  --gene-column gene_name \
  --x-column x_pixel_coordinate \
  --y-column y_pixel_coordinate \
  --z-column z_level \
  --cell-id-column cell_id \
  --confidence-column confidence_score \
  --output-spatialdata proseg-output.zarr \
  --output-cell-polygons cell-polygons.geojson.gz \
  --output-transcript-metadata transcript-metadata.csv.gz \
  --nthreads 8
  
