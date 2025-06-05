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
Install Proseg locally on your machine per https://github.com/dcjones/proseg. (it will have you clone the github repository and then run something in cargo to install Proseg)
	- I made this folder: /fh/fast/hill_g/Albert/Collaboration-Spatial_Seq_Biopsy_Samples/proseg
	- git clone https://github.com/dcjones/proseg
	```ml Rust/1.83.0-GCCcore-13.3.0```
	```cargo install proseg```
 ```echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> ~/.bashrc```  (just type this once when starting shell we have everything else setup)
  - Now can run proseg below!
