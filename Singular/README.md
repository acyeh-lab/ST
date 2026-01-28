# Spatial Transcriptomics
Tips on how to run / analyze ST using the Singular Platform.  This is bootstrapped by myself.

## PHysical Slide
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
   - feature_matrix.hg


