# Spatial Transcriptomics
Tips on how to run / analyze ST

## Tissue Analysis Software
1) Tissue Faxsviewer (open source)
https://tissuegnostics.com/products/scanning-and-viewing-software/tissuefaxs-viewer

# Xenium Pipeline

## (1) Download data from Cirro
Download the data from Cirro to your fast folder. The files are huge and you don't want to download these locally! I temporarily changed my download location in Chrome to my desired subfolder in fast. This will download a zipped folder which you can then unzip.
a.	Change chrome download to: X:\fast\hill_g\Albert\Collaboration-Spatial_Seq_Biopsy_Samples\Xenium Imaging\Run1_XB9MDD_5_19_25

## (2) Custom segmentation with Proseg
### Install Proseg locally on your machine per https://github.com/dcjones/proseg. (it will have you clone the github repository and then run something in cargo to install Proseg)
  - I made this folder: /fh/fast/hill_g/Albert/Collaboration-Spatial_Seq_Biopsy_Samples/proseg
  - ```git clone https://github.com/dcjones/proseg```
  - ```ml Rust/1.83.0-GCCcore-13.3.0```
  - ```cargo install proseg```
  - ```echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> ~/.bashrc```  (just type this once when starting shell we have everything else setup)
  - Now can run proseg below!
### Generate Proseg polygons and metadata

I made a shell script “Proseg_init.sh” to run this segment.  So for example, run:

For example:  sbatch Proseg_init.sh /fh/fast/hill_g/Albert/Collaboration-Spatial_Seq_Biopsy_Samples/Xenium/Run1_XB9MDD_5_19_25/output-XETG00049__0050413__XE054_50413_3035-4-F-S-A__20250516__213842

Output files will be located in proseg_run_XXXXX.err and .log
**Takes about 30 min to 1 hr to run.

This gives you the following new files in the folder:
1.	cell-metadata.csv.gz
2.	cell-polygon.geojson.gz
3.	cell-polygons-layers.geojson.gz
4.	expected-counts.csv.gz
5.	transcript-metadata.csv.gz
![image](https://github.com/user-attachments/assets/1adc20c7-9b55-47e0-8fd5-9394e7e1da3b)

