# Spatial Transcriptomics
Tips on how to run / analyze ST.  Thanks to Julie Boiko MD, PhD for initial tips!

## Tissue Analysis Software
1) Tissue Faxsviewer (open source)
https://tissuegnostics.com/products/scanning-and-viewing-software/tissuefaxs-viewer

# Xenium Pipeline

## (1) Download data from Cirro
Download the data from Cirro to your fast folder. The files are huge and you don't want to download these locally! I temporarily changed my download location in Chrome to my desired subfolder in fast. This will download a zipped folder which you can then unzip.
a.	Change chrome download to: X:\fast\hill_g\Albert\Collaboration-Spatial_Seq_Biopsy_Samples\Xenium Imaging\Run1_XB9MDD_5_19_25

## (2) Custom segmentation with Proseg
### A. Install Proseg locally on your machine per https://github.com/dcjones/proseg. (it will have you clone the github repository and then run something in cargo to install Proseg)
  - I made this folder: /fh/fast/hill_g/Albert/Collaboration-Spatial_Seq_Biopsy_Samples/proseg
  - ```git clone https://github.com/dcjones/proseg```
  - ```ml Rust/1.83.0-GCCcore-13.3.0```
  - ```cargo install proseg```
  - ```echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> ~/.bashrc```  (just type this once when starting shell we have everything else setup)
  - Now can run proseg below!
### B. Generate Proseg polygons and metadata
  - Run "Proseg_init.sh" (see included files).
  - e.g. ```sbatch Proseg_init.sh /fh/fast/hill_g/Albert/Collaboration-Spatial_Seq_Biopsy_Samples/Xenium/Run1_XB9MDD_5_19_25/output-XETG00049__0050413__XE054_50413_3035-4-F-S-A__20250516__213842```
  - This will generate the following files in the directory specified:
    1.	cell-metadata.csv.gz
    2.	cell-polygon.geojson.gz
    3.	cell-polygons-layers.geojson.gz
    4.	expected-counts.csv.gz
    5.	transcript-metadata.csv.gz
  - Slurm output files will be located in proseg_run_XXXXX.err and .log
  - **Takes about 30 min to 1 hr to run**
### C. Convert to Baysor for Xenium Import
  - From dcjones github: It is possible to use proseg segmentation with Xenium Explorer, but requires a little work. The xeniumranger tool has a command to import segmentation from Baysor. To use this, we must first convert Proseg output to Baysor-compatible formatting.
  - Run "Proseg_to_Bayor.sh" (see included files).
  - e.g. ```sbatch Proseg_to_Baysor.sh /fh/fast/hill_g/Albert/Collaboration-Spatial_Seq_Biopsy_Samples/Xenium/Run1_XB9MDD_5_19_25/output-XETG00049__0050413__XE054_50413_3035-4-F-S-A__20250516__213842```
  - This gives you the following new files in the folder:
    1.	baysor-cell-polygons.geojson
    2.	baysor-transcript-metadata.csv
  - Slurm output files will be located in proseg_to_baysor_XXXXX.err and .log
  - **Takes about 2 min**

## (3) Run Xeniumranger
  - Run "Xeniumranger.sh" (see included files).
  - e.g. ```sbatch Xeniumranger.sh /fh/fast/hill_g/Albert/Collaboration-Spatial_Seq_Biopsy_Samples/Xenium/Run1_XB9MDD_5_19_25/output-XETG00049__0050413__XE054_50413_3035-4-F-S-A__20250516__213842 RUN1``` Note that there are 2 input variables (file directory and name of run).
  - **Make sure name of run is a unique folder that doesn't already exist, otherwise will get error !**
  - Slurm output files will be located in xeniumranger_XXXXX.err and .log
  - **Takes about X min**
    
## (4) Analyze Data with Python
  - In data directory, include the following for our python analysis:
    1. "proseg"
    2. "hne"
    3. "anndata"
  


