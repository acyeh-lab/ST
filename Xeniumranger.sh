#!/bin/bash
#SBATCH --job-name=xeniumranger
#SBATCH --output=xeniumranger_%j.log
#SBATCH --error=xeniumranger_%j.err
#SBATCH --time=01:00:00
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --partition=campus-new

# ----------------------
# Usage: sbatch xeniumranger.sh <xenium_output_dir> <Run name>
# Example:
# sbatch xeniumranger.sh /fh/fast/hill_g/Albert/.../output-XETG00049... RUN1
# ----------------------

# Check for command-line argument
if [ -z "$1" ]; then
    echo "Usage: sbatch run_import_segmentation.slurm <xenium_output_dir>"
    exit 1
fi

# Assign working directory from argument
wd="$1"

# Check if directory exists
if [ ! -d "$wd" ]; then
    echo "Directory does not exist: $wd"
    exit 1
fi

# Change to working directory
cd "$wd" || { echo "Failed to cd to $wd"; exit 1; }

# Load the required module
module load XeniumRanger/3.1.0

# Run import-segmentation
xeniumranger import-segmentation \
    --id "$2" \
    --xenium-bundle="$wd" \
    --viz-polygons baysor-cell-polygons.geojson \
    --transcript-assignment baysor-transcript-metadata.csv \
    --units microns \
    --jobmode=slurm

