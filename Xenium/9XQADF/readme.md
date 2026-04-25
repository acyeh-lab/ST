# 9XQADF — Xenium run, 4/8/2026

Custom 10x Xenium panel (XE075) targeting human colon + a focused bacterial
probe set. This run was designed to follow up on the XB9MDD run (5/16/2025)
with a refined probe panel covering high-abundance gut organisms identified in
prior brushings, plus a bacterial-pellet positive control.

- **Instrument run ID**: `20260408__203443__XE075_Hill_04082026`
- **Slides**: `0063672`, `0063675` (two Xenium slides, 6 samples each)
- **Panel**: human Colon + 9XQADF Custom Bacterial (XE075)
- **Target organisms (custom probes)**: *A. muciniphila*, *B. fragilis*,
  *C. aerofaciens*, *E. coli*, *E. faecalis*, *S. salivarius*

## Sample table

| Slide   | Sample ID (short) | Bundle name (raw output dir)                                                  | Notes                          |
|---------|-------------------|-------------------------------------------------------------------------------|--------------------------------|
| 0063672 | 63672_3022        | `output-XETG00049__0063672__XE075_63672_3022__20260408__203547`               |                                |
| 0063672 | 63672_3027        | `output-XETG00049__0063672__XE075_63672_3027__20260408__203547`               |                                |
| 0063672 | 63672_3081        | `output-XETG00049__0063672__XE075_63672_3081__20260408__203547`               |                                |
| 0063672 | 63672_3132        | `output-XETG00049__0063672__XE075_63672_3132__20260408__203547`               |                                |
| 0063672 | 63672_3143        | `output-XETG00049__0063672__XE075_63672_3143__20260408__203547`               |                                |
| 0063672 | 63672_P2015-2     | `output-XETG00049__0063672__XE075_63672_P2015-2__20260408__203547`            |                                |
| 0063675 | 63675_3035-4      | `output-XETG00049__0063675__XE075_63675_3035-4__20260408__203547`             |                                |
| 0063675 | 63675_3045        | `output-XETG00049__0063675__XE075_63675_3045__20260408__203547`               |                                |
| 0063675 | 63675_3056        | `output-XETG00049__0063675__XE075_63675_3056__20260408__203547`               |                                |
| 0063675 | 63675_3061        | `output-XETG00049__0063675__XE075_63675_3061__20260408__203547`               |                                |
| 0063675 | 63675_P-2026-1    | `output-XETG00049__0063675__XE075_63675_P-2026-1__20260408__203547`           |                                |
| 0063675 | 63675_bac_pellets | `output-XETG00049__0063675__XE075_63675_bac_pellets__20260408__203547`        | Bacterial pellet positive ctrl |

> The "Sample ID (short)" form (`<slide_last4>_<sample>`) is what we use as the
> directory name under `proseg/` and as the key in downstream notebooks. It is
> auto-derived from the bundle name by `Proseg_10x.sh`.

## Pipeline overview

```
0. Probe design          -> code/Probe_Design.ipynb
1. Xenium imaging        -> performed by 10x; raw outputs land in data/.../raw/
2. Cell re-segmentation  -> sbatch code/Proseg_10x.sh <bundle>
3. Cell typing & QC      -> Scanpy/Squidpy notebooks (see "Step 3" below)
4. Bacterial spatial     -> KDE / density modelling (bacterial-density.py)
```

Each step is independent per sample; everything below is per-bundle except
where noted.

## Step 0 — Probe design

See `code/Probe_Design.ipynb`. Inputs are the per-organism FASTA files under
`data/xenium_9xqadf_2026/genome_Sequences/` and 16S/23S references under
`rRNA_Sequences/`. The notebook calls a k-mer overlap script
(`find_shared_regions.py`) that for each organism:

1. Builds a 35-mer index over a chosen reference sequence.
2. Counts how many input strain FASTAs contain each reference 35-mer.
3. Keeps only k-mers present in **all** strains (or `--require-at-least N`).
4. Stitches contiguous shared k-mer windows into maximal regions ≥k.
5. Emits a TSV of `(sequence, start, end)` for each conserved region.

These conserved regions are the candidate target-binding sites. The 9XQADF
final probe set (`data/xenium_9xqadf_2026/final_list/`) was built from the
regions that survived this filter for each of the six target organisms.

## Step 1 — Xenium imaging (external)

Performed on a 10x Xenium instrument with the XE075 panel on 2026-04-08. Raw
outputs from the instrument live under
`data/xenium_9xqadf_2026/raw/output-XETG00049__<slide>__XE075_<slide>_<sample>__<date>__<time>/`
and contain the standard set of files:

- `transcripts.parquet` — per-transcript table (used by ProSeg)
- `cells.parquet`, `nucleus_boundaries.parquet`, `cell_boundaries.parquet`
- `cell_feature_matrix.h5` / `.zarr.zip`
- `morphology.ome.tif` + `morphology_focus/`
- `experiment.xenium`, `gene_panel.json`, `metrics_summary.csv`
- `analysis/`, `analysis.zarr.zip`, `analysis_summary.html`, `aux_outputs/`

We ignore 10x's default segmentation and re-segment with ProSeg in step 2.

## Step 2 — ProSeg segmentation

`code/Proseg_10x.sh` is a SLURM batch script that runs
[ProSeg](https://github.com/dcjones/proseg) v3.x on a single Xenium bundle
and writes outputs to `data/xenium_9xqadf_2026/proseg/<SAMPLE_ID>/`.

**Requirements**: ProSeg installed via `cargo install proseg` (binary at
`~/.cargo/bin/proseg`); SLURM cluster with the `Rust/1.83.0-GCCcore-13.3.0`
module available; 8 CPU / up to 128 GB / multi-hour walltime per sample.

**Single-sample invocation** (run from the project root):

```bash
sbatch code/Proseg_10x.sh \
  data/xenium_9xqadf_2026/raw/output-XETG00049__0063672__XE075_63672_3022__20260408__203547
```

**All 12 samples (fan out as separate jobs)**:

```bash
for d in data/xenium_9xqadf_2026/raw/output-XETG*; do
  sbatch code/Proseg_10x.sh "$d"
done
```

**Outputs** (per sample, in `proseg/<SAMPLE_ID>/`):

| File                            | Format               | Use                                 |
|---------------------------------|----------------------|-------------------------------------|
| `proseg-output.zarr/`           | SpatialData zarr     | Canonical v3 output (transcripts + polygons + AnnData) |
| `expected-counts.mtx.gz`        | Matrix-market (gz)   | Cell × gene non-integer counts (used as `adata.X`) |
| `cell-metadata.csv.gz`          | CSV                  | Cell centroids, volumes (`adata.obs`) |
| `transcript-metadata.csv.gz`    | CSV                  | Per-transcript revised positions + assignment probabilities |
| `cell-polygons.geojson.gz`      | GeoJSON              | 2D consensus cell boundaries        |

> **Heads-up**: ProSeg v3 changed the count matrix from `expected-counts.csv.gz`
> (XB9MDD era) to `expected-counts.mtx.gz`. Downstream notebooks need to load
> with `scipy.io.mmread(...)` instead of `sc.read_csv(...)`.

## Step 3 — Cell typing & QC (downstream Scanpy/Squidpy)

Pattern carried over from XB9MDD. Per sample:

1. Load `expected-counts.mtx.gz` + `cell-metadata.csv.gz` into an AnnData; set
   `adata.obsm["spatial"]` from the centroid columns.
2. Drop control probes (`Neg*`, `Unassigned*`).
3. `sc.pp.filter_cells(adata, min_counts=1)` →
   `sc.pp.calculate_qc_metrics(adata, percent_top=[50,100], inplace=True)`.
4. Standard SCT / log-norm → PCA → neighbors → UMAP → Leiden.
5. DE per cluster, score for bacterial-positive vs. -negative cells, etc.

There is no analysis notebook checked in for 9XQADF yet — see the XB9MDD
`AY_001*.ipynb` notebooks in the sister run for the canonical recipe.

## Step 4 — Bacterial transcript spatial analysis

Marimo app (`bacterial-density.py` in the parent project) registers the
post-Xenium ISH image to the instrument DAPI via skimage ORB+RANSAC, fits a
kernel-density estimate of bacterial transcript positions, and compares to
16S/DAPI intensity. Reuses the same per-sample IDs as ProSeg.

## Compute environment

- Fred Hutch SLURM cluster, partition `campus-new`
- ProSeg jobs: 8 CPUs, up to 128 GB RAM, several hours walltime per sample
- Python: JupyterHub kernels `spatial_v1` (analysis: scanpy, squidpy, anndata,
  scikit-image, tifffile, duckdb) and `microbe_v1` (probe design)
- ProSeg: `cargo install proseg` (built against
  `Rust/1.83.0-GCCcore-13.3.0`)

## Code in this folder

| File                             | Purpose                                              |
|----------------------------------|------------------------------------------------------|
| `code/Probe_Design.ipynb`        | k-mer-conservation probe design for the XE075 panel  |
| `code/Proseg_10x.sh`             | SLURM batch script for ProSeg v3 segmentation        |
