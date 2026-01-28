# Spatial Transcriptomics
Tips on how to run / analyze ST using the Singular Platform.  This is bootstrapped by myself.

## PHysical Slide
Singular slides come in 2 formats: the 32 slot format (4x8 4mm squares) or the 10 slot (2x5 1cm squares).

## File Format
We download the file format via secure FTP, with each row (e.g. for the 4x8 slots, each folder contain a row of 8) getting a separate file name.
Gut samples we got 4 rows (from 1 48x slide):
g4-012-054-FC2-L001_5WtNECt2qiMdhgeK -> customer_output -> A01-H01

Each folder contains the following:
 - diagnostics
 - g4x_viewer
 - h_and_e
 - metrics
 - protein
 - rna
 - segmentation
 - single_cell_data


