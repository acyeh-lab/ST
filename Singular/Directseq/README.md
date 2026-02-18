# Spatial Imaging with Direct Seq
Tips on how to run / analyze ST using the Singular Platform with DirectSeq. 

Overall workflow:
```
singular_zarr.sh # builds zarr file after usign g4x() pull command
  ↓
Proseg_Singular.sh # builds proseg mask
  ↓
run_spatial_singular_umap.sh # compares proseg umap vs. default umap
```

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
   - h_and_e_thumbnail.jpg
   - nulear_thumbnail.png
   - eosin_thumbnail.png
   - h_and_e.jp2
   - nuclear.jp2
   - eosin.jp2
 - **metrics** (QC + summary stats)
   - core_metrics.csv
   - per_area_metrics.csv
   - * Does not have "protein_core_metrics.csv", which standard transcript platform has
   - * Does not have "transcript_core_metrics.csv", which standard transcript platform has
 - **protein** (usaully IF intensity renderings)
   - ATPase, CD11c, CD20, CD3, CD31, CD4, CD45, CD68, CD8, FOXP3, HLA-DR, Isotype, Ki67, PD1, PDL1, PanCK, asMA.thumbnail.jpg (these are protien level data)
 - **rna** 
   - transcript_table.csv.gz (gzip-compressed csv version of the same transcript detection table as the Parquet; maximumum compatibility but slower/bigger than Parquet). This file also contains confidence scores which we can play around with to adjust cutoff.
 - **segmentation**
   - segmentation_mask.npz
 - **single_cell_data** (per-cell tables + matrices)
   - cell_by_protein.csv.gz
   - cell_by_transcript.csv.gz
   - cell_metadata.csv.gz
   - feature_matrix.h5 (bundled feature matrix file, analogous to HDF5/AnnData/10x H5; also largest file)
   - * NEW FILE "A01_dsReads.csv", which contains a matrix with x/y coordinate, sequence, cell-id, gene/probe used to generate the sequence.  Note that the reads were emultiplexed using the 10 bp sequence specific to the different J subfamilies for teh IgH or TCRb.  The actual sequence corresponds to the start of the CDR3-gap immediately downstream of a consensus J-region site selected for probe biding.  Per TUng, in-situ sequencing accuracy is ~95% over 50 cycles, there may be errors towards the end of the read.
   - * NEW FILE "A01_cell_by_genes.csv", which contains a grid of cell IDs by J probe (e.g. A01-103257; J13tcrb) along with how many times each probe hit was detected.
   - * Does not have "clustering_umap.csv.gz", which standard transcript platform has
   - * Does not have "dgex.csv.gz", which standard transcript platform has,
  




