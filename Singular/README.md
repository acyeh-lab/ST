# Spatial Transcriptomics
Tips on how to run / analyze ST using the Singular Platform.  This is bootstrapped by myself.

## Physical Slide
Singular slides come in 2 formats: the 32 slot format (4x8 4mm squares) or the 10 slot (2x5 1cm squares).

## File Format
We download the file format via secure FTP, with each row (e.g. for the 4x8 slots, each folder contain a row of 8) getting a separate file name.
Gut samples we got 4 rows (from 1 48x slide):
g4-012-054-FC2-L001_5WtNECt2qiMdhgeK -> customer_output -> A01-H01

Each folder contains the following:
 - **diagnostics**
   - transcript_table.parquet (columnar, fast-to-read version of detected RNA table, used for efficient downstream anlaytics and quick filtering compared to CSV)
 - **g4x_viewer**
   - .bin
   - .ome.tiff (standard microscopy container that supports metadata and multi-resolution)
   - .tar
   - _HE.ome.tiff
   - _nuclear.ome.tiff
   - _run_metadata.json 
 - **h_and_e** (lightweight previews)
   - h_ane_e_thumbnail.jpg
   - nulear_thumbnail.png
 - **metrics** (QC + summary stats)
   - core_metrics.csv
   - per_area_metrics.csv
   - protein_core_metrics.csv
   - transcript_core_metrics.csv
 - **protein** (usaully IF intensity renderings)
   - ATPase, CD11c, CD20, CD3, CD31, CD4, CD45, CD68, CD8, FOXP3, HLA-DR, Isotype, Ki67, PD1, PDL1, PanCK, asMA.thumbnail.jpg (these are protien level data)
 - **rna** 
   - transcript_table.csv.gz (gzip-compressed csv version of the same transcript detection table as the Parquet; maximumum compatibility but slower/bigger than Parquet)
 - **segmentation**
   - segmentation_mask.npz
 - **single_cell_data** (per-cell tables + matrices)
   - cell_by_protein.csv.gz
   - cell_by_transcript.csv.gz
   - cell_metadata.csv.gz
   - clustering_umap.csv.gz
   - dgex.csv.gz
   - feature_matrix.h5 (bundled feature matrix file, analogous to HDF5/AnnData/10x H5; also largest file)

## Creating python environment (tested 1/30/26)
```
micromamba create -n spatial-singular -c conda-forge python=3.11 -y
micromamba activate spatial-singular
micromamba install -c conda-forge \
  numpy pandas scipy \
  matplotlib seaborn \
  shapely geopandas \
  rasterio pillow \
  scanpy squidpy spatialdata \
  jupyterlab ipykernel \
  -y
python -m ipykernel install \
  --user \
  --name spatial-singular \
  --display-name "Python (spatial-singular)"
```
Now to install the PR (per Derrick / Daniel, the PR is to convert Singular raw dataset to spatialdata zarr files) for analyzing singular dataset:
https://github.com/scverse/spatialdata-io/pull/281 (last accessed 2/1/26)
```
cd /fh/fast/hill_g/Albert/Collaboration-Spatial_Seq_Biopsy_Samples
git clone https://github.com/scverse/spatialdata-io.git
cd spatialdata-io
git fetch origin pull/281/head:pr-281
git checkout pr-281
python -m pip install --no-cache-dir -e .
```
Now check if the following returns true:
```
python - << 'EOF'
import spatialdata_io as sio
print("Has g4x:", hasattr(sio, "g4x"))
print("Loaded from:", sio.__file__)
EOF
```

## Running Proseg (old)
```
ayeh@rhino02:/fh/fast/hill_g/Albert/scSeq_ST_Analyses/Singular_Pilot_2025/data/Run1_raw/Gut/g4-012-054-FC2-L001_5WtNECt2qiMdhgeK/customer_output/A01/rna$ zcat transcript_table.csv.gz | head -n 1
y_pixel_coordinate,x_pixel_coordinate,z_level,gene_name,confidence_score,cell_id
```
Thus, the Singular transcript table header is:
```
y_pixel_coordinate,
x_pixel_coordinate,
z_level,
gene_name,
confidence_score,
cell_id
```
This is close enough to Xenium format, but column names differ, so do NOT use ```--xenium```

So to run, use the following command:
```
proseg --csv rna/transcript_table.csv.gz \
  --gene-column gene_name \
  --x-column x_pixel_coordinate \
  --y-column y_pixel_coordinate \
  --z-column z_level \
  --cell-id-column cell_id \
  --confidence-column confidence_score \
  --output-spatialdata A01-proseg.zarr \
  --nthreads 16
```

to submit the job, usem for example:
```
sbatch Proseg_Singular.sh /fh/fast/hill_g/Albert/scSeq_ST_Analyses/Singular_Pilot_2025/data/Run1_raw/Gut/g4-012-054-FC2-L001_5WtNECt2qiMdhgeK/customer_output/A01
```

