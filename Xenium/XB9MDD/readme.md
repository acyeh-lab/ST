# XB9MDD — Xenium run, 5/16/2025

Custom 10x Xenium panel run on GI biopsies from **6 patients** (mix of GVHD
and control). The pilot's primary scientific question was whether **lysozyme
pretreatment** of FFPE sections meaningfully increases bacterial-probe signal
without inflating negative-control probe background. Each patient was
sectioned twice and run under matched conditions:

- **Lysozyme pretreatment** (slide-prefix `0050412`) — file IDs `001001`–`001006`
- **No lysozyme** (slide-prefix `0050413`) — file IDs `001011`–`001016`

The matched-pair convention is **sample N (lysozyme) ↔ sample N+10
(no lysozyme)**; the pair is the unit of comparison throughout. Pilot
finding (per `python/Control_probes.ipynb`): lysozyme pretreatment increases
bacterial-probe counts substantially while `NegControlProbe_*` background
is comparable across the two conditions — the extra signal is real, not
nonspecific.

- **Instrument run date**: 2025-05-16
- **Slides**: `0050412` (lysozyme), `0050413` (no lysozyme)
- **Panel**: human Colon + XB9MDD Custom Bacterial (`XB9MDD_hColon_100g`)
- **Panel designer**: Albert Yeh (`acyeh85@gmail.com`), 2025-04-18
- **Project root (in our deployment)**: `/fh/fast/hill_g/Albert/scSeq_ST_Analyses/Xenium_XB9MDD_2025/`

## Sample table

| Run Name         | File ID | Original Label   | Patient   | Condition    | Panel                                  |
|------------------|---------|------------------|-----------|--------------|----------------------------------------|
| XB9MDD 5/16/2025 | 001001  | 50412_3035-4     | 3035-4    | Lysozyme     | human Colon + XB9MDD Custom Bacterial  |
| XB9MDD 5/16/2025 | 001002  | 50412_3045       | 3045      | Lysozyme     | human Colon + XB9MDD Custom Bacterial  |
| XB9MDD 5/16/2025 | 001003  | 50412_P-2026-1   | P-2026-1  | Lysozyme     | human Colon + XB9MDD Custom Bacterial  |
| XB9MDD 5/16/2025 | 001004  | 50412_3056       | 3056      | Lysozyme     | human Colon + XB9MDD Custom Bacterial  |
| XB9MDD 5/16/2025 | 001005  | 50412_3056-2     | 3056      | Lysozyme     | human Colon + XB9MDD Custom Bacterial  |
| XB9MDD 5/16/2025 | 001006  | 50412_3061       | 3061      | Lysozyme     | human Colon + XB9MDD Custom Bacterial  |
| XB9MDD 5/16/2025 | 001011  | 50413_3035-4     | 3035-4    | No Lysozyme  | human Colon + XB9MDD Custom Bacterial  |
| XB9MDD 5/16/2025 | 001012  | 50413_3045       | 3045      | No Lysozyme  | human Colon + XB9MDD Custom Bacterial  |
| XB9MDD 5/16/2025 | 001013  | 50413_P-2026-1   | P-2026-1  | No Lysozyme  | human Colon + XB9MDD Custom Bacterial  |
| XB9MDD 5/16/2025 | 001014  | 50413_3056       | 3056      | No Lysozyme  | human Colon + XB9MDD Custom Bacterial  |
| XB9MDD 5/16/2025 | 001015  | 50413_3056-2     | 3056      | No Lysozyme  | human Colon + XB9MDD Custom Bacterial  |
| XB9MDD 5/16/2025 | 001016  | 50413_3061       | 3061      | No Lysozyme  | human Colon + XB9MDD Custom Bacterial  |

> Patients 3056 and 3056-2 are two different sections from patient 3056; both
> are paired against their no-lysozyme partner.

## Panel composition (XB9MDD_hColon_100g)

- **442 total targets** = 422 gene probes + 20 `NegControlProbe_*`
- **342 base targets** from 10x's `hColon_v1` (Xenium Human Colon Gene Expression panel)
- **100 custom targets** added under `design_id = XB9MDD`, split into two halves:
  - **~50 human immune / T-cell genes** (Th1/Th2/Th17 TFs, gut-homing
    integrins, exhaustion markers, chemokine axes): AHR, BCL6, CCL17/22/25,
    CCR1/2/4/6/9, CD19/27/28/33/44/69, CLEC10A, CLEC4A, CSF2, CX3CR1,
    CXCL10/13, CXCR3/6, FCGR3A, GATA3, HAVCR2, HLA-DRA, IFNG,
    IL4/6/10/12A/17A/18, ITGA2/4/AE/AM, ITGB7, LAG3, NCAM1, PDCD1, PRDM1,
    SDC1, TBX21, TGFB1, TNF, ZNF683.
  - **~50 bacterial / SCFA probes** (custom 40-nt binders against 16S regions
    or SCFA-pathway transcripts; not in Ensembl):

    | Prefix    | Species / function                      | # probes |
    |-----------|-----------------------------------------|----------|
    | `AKK_MUC` | *Akkermansia muciniphila*               | 2        |
    | `BAC_FRA` | *Bacteroides fragilis*                  | 2        |
    | `BAC_OVA` | *Bacteroides ovatus*                    | **4**    |
    | `BAC_THE` | *Bacteroides thetaiotaomicron*          | 2        |
    | `BIF_BRE` | *Bifidobacterium breve*                 | 2        |
    | `BIF_LON` | *Bifidobacterium longum*                | 2        |
    | `BLA_HYD` | *Blautia hydrogenotrophica*             | 2        |
    | `BLA_LUT` | *Blautia luti*                          | 2        |
    | `BLA_WEX` | *Blautia wexlerae*                      | 2        |
    | `BLA_HAN` | *Blautia hansenii*                      | 2        |
    | `BLA_PRO` | *Blautia producta*                      | 2        |
    | `COL_AER` | *Collinsella aerofaciens*               | 2        |
    | `ENT_FAS` | *Enterococcus faecalis*                 | 2        |
    | `ENT_FAM` | *Enterococcus faecium*                  | 2        |
    | `ESC_COL` | *Escherichia coli*                      | 2        |
    | `FAE_PRA` | *Faecalibacterium prausnitzii*          | 2        |
    | `STR_ANG` | *Streptococcus anginosus*               | 2        |
    | `STR_MUT` | *Streptococcus mutans*                  | 2        |
    | `STR_SAL` | *Streptococcus salivarius*              | 2        |
    | `BUK1..9` | butyrate-kinase functional probes       | 9        |
    | `BUT`     | butyryl-CoA-related functional probe    | 1        |

Total bacterial = 50 (19 species × pairs + 2 extra `BAC_OVA` probes + 10
SCFA-pathway probes). Paired probes (`<PREFIX>1` vs `<PREFIX>2`) are the
basis for the concordancy filter used in downstream notebooks; `BUK*` + `BUT`
are functional (SCFA-production pathway) rather than taxonomic — interpret
per-cell counts of those accordingly.

Panel sources: `XB9MDD_hColon_100g_panel.json`,
`XB9MDD_hColon_100g_gene_list.csv`,
`XB9MDD_hColon_100g_custom_sequences.csv` (the 40-nt binders), and
`XB9MDD_hColon_100g_web_summary.html`.

## Pipeline overview

```
1. Xenium imaging         -> external (10x), raw outputs land in Xenium/raw/
2. Cell re-segmentation   -> sbatch ../../Proseg_init.sh <wd>
3. Baysor-format export   -> sbatch wrapper around `proseg-to-baysor`
4. Per-sample analysis    -> python/AY_00100X.ipynb (one per lysozyme sample)
5. Pilot-level figures    -> python/Control_probes.ipynb (lys vs no-lys QC)
6. Bacterial KDE          -> python/bacterial-density.py (marimo prototype)
```

Steps 2–3 are batch operations across all 12 samples and are the focus of
this README. Steps 4–6 live as notebooks in the project tree, not in this
repo.

## Step 1 — Xenium imaging (external)

Performed on a 10x Xenium instrument with the XB9MDD panel on 2025-05-16.
Raw outputs from the instrument live (in our deployment) at:

```
/fh/fast/hill_g/Albert/Collaboration-Spatial_Seq_Biopsy_Samples/Xenium/Run1_XB9MDD_5_19_25/
  output-XETG00049__0050412__XE054_50412_<patient>-F-S-A__20250516__213842/   # lysozyme
  output-XETG00049__0050413__XE054_50413_<patient>-F-S-A__20250516__213842/   # no lysozyme
```

Each folder contains the standard Xenium Ranger output: `transcripts.parquet`,
`cells.csv.gz`, `cell_feature_matrix.h5`, `morphology.ome.tif`,
`experiment.xenium`, `gene_panel.json`, `metrics_summary.csv`,
`analysis_summary.html`, etc.

We **ignore 10x's default segmentation** and re-segment with ProSeg in step 2.

## Step 2 — Re-segmentation with ProSeg

`Proseg_init.sh` (at the repo root) is the SLURM batch script that runs
[ProSeg](https://github.com/dcjones/proseg) on a single Xenium bundle. We
pin to **ProSeg v3.1.0**, installed via `cargo install proseg` (binary at
`~/.cargo/bin/proseg`, Rust toolchain `Rust/1.83.0-GCCcore-13.3.0`).

SLURM defaults in the script: `--partition=campus-new --cpus-per-task=8
--mem=32G --time=03:00:00`. Per-sample runtime in our run was 5:25–20:18
depending on transcript count.

### Patched script (commit [`e7c548b`](https://github.com/acyeh-lab/ST/commit/e7c548b))

Two changes in ProSeg ≥3.0 broke the downstream pipeline as written, so the
local `Proseg_init.sh` was patched on 2026-05-19:

1. **CSV/GeoJSON outputs are now opt-in.** ProSeg ≥3.0 writes only
   `proseg-output.zarr/` by default. The script now explicitly requests the
   legacy outputs the analysis notebooks expect:

   ```
   --output-cell-polygons cell-polygons.geojson.gz
   --output-cell-polygon-layers cell-polygons-layers.geojson.gz
   --output-union-cell-polygons union-cell-polygons.geojson.gz
   --output-transcript-metadata transcript-metadata.csv.gz
   --output-cell-metadata cell-metadata.csv.gz
   --output-expected-counts expected-counts.csv.gz
   ```

2. **`expected-counts.csv.gz` is silently written as MatrixMarket sparse**
   regardless of the filename, and ProSeg exposes no
   `--output-expected-counts-fmt` flag. The analysis notebooks use
   `sc.read_csv()` and require a dense (cells × genes) CSV with a bare
   gene-name header. The patched script adds a Python post-step that:

   - renames the MTX-format file to `expected-counts.csv.gz.mtx`,
   - reads its float posterior-mean values via `scipy.io.mmread`,
   - reads gene-name ordering from
     `proseg-output.zarr/tables/table` (`var['gene']`),
   - writes a true dense CSV back to `expected-counts.csv.gz` and removes
     the `.mtx` intermediate.

   The zarr's `X` was intentionally NOT used as the value source — it is
   `uint32` point estimates, not the float posterior means required for the
   notebooks' fractional bacterial-count statistics. Only the gene-name
   ordering comes from the zarr.

### Single-sample invocation

```bash
sbatch Proseg_init.sh /path/to/working_dir
# working_dir must contain transcripts.parquet (real or a symlink to the
# Xenium Ranger output folder's transcripts.parquet)
```

Outputs (in `working_dir`):

| File                                | Format             | Use                                                                   |
|-------------------------------------|--------------------|-----------------------------------------------------------------------|
| `proseg-output.zarr/`               | SpatialData zarr   | Canonical v3 output (transcripts + polygons + AnnData with uint32 X)  |
| `expected-counts.csv.gz`            | Dense gzipped CSV  | Cell × gene posterior-mean counts (`adata.X`) — **densified post-step** |
| `cell-metadata.csv.gz`              | CSV                | Cell centroids, volumes (`adata.obs`)                                 |
| `transcript-metadata.csv.gz`        | CSV                | Per-transcript revised positions + assignment probabilities           |
| `cell-polygons.geojson.gz`          | GeoJSON            | 2D consensus cell boundaries                                          |
| `cell-polygons-layers.geojson.gz`   | GeoJSON            | Per-z-layer boundaries                                                |
| `union-cell-polygons.geojson.gz`    | GeoJSON            | Per-cell union over layers                                            |

## Step 3 — Baysor-format export for Xenium Explorer / downstream tools

`proseg-to-baysor` (shipped with the ProSeg cargo install) converts the zarr
into Baysor-compatible GeoJSON + CSV. **The CLI changed in ProSeg 3.1.0**:
older docs (and the original `Proseg_to_Baysor.sh` in the repo) pass two
positional args (`transcript-metadata.csv.gz cell-polygons.geojson.gz`); the
new CLI takes a single positional `<PROSEG_SPATIALDATA_ZARR>` and emits both
outputs from it.

Working invocation (run via `sbatch --wrap=...` in the harmonization sweep):

```bash
proseg-to-baysor proseg-output.zarr \
  --output-transcript-metadata baysor-transcript-metadata.csv \
  --output-cell-polygons       baysor-cell-polygons.geojson
```

Outputs (uncompressed by design — Xenium Ranger expects these):
`baysor-cell-polygons.geojson`, `baysor-transcript-metadata.csv`. Runtime is
3–12 s per sample. Only `baysor-cell-polygons.geojson` is propagated into
`proseg/<file_id>/` downstream.

## 2026-05-19 publication-harmonization sweep

All 12 samples were re-segmented in a **single coherent sweep** on this date
so that the pilot's downstream cross-sample analyses (cluster harmonization,
cell-typing, bacterial-density comparisons) are based on a uniform Proseg
version and an identical script. This was prompted by the discovery that the
historic per-sample Proseg runs spanned multiple Proseg versions, including
one (older) version whose `cell-metadata.csv.gz` schema differed from
3.1.0's (see [Reproducibility & methods notes](#reproducibility--methods-notes)).

**Procedure (recorded for the Methods section):**

1. The patched `Proseg_init.sh` was committed to `acyeh-lab/ST` main as
   [`e7c548b`](https://github.com/acyeh-lab/ST/commit/e7c548b).

2. The 12 pre-2026-05-19 `proseg/<file_id>/` folders were moved en bloc to
   `proseg/old/<file_id>/` to preserve them.

3. For each of the 12 samples a scratch working directory was created at
   `scripts/rerun_2026_05_19/<file_id>/` containing a symlink to the
   upstream `transcripts.parquet`. All 12 ProSeg jobs were submitted in
   parallel via `sbatch Proseg_init.sh <wd>` and completed COMPLETED/exit-0
   with elapsed times 5:25–20:18 (smallest sample 001004/001014; largest
   001005 at ~30,000 cells / 147 MB transcripts.parquet).

4. After all 12 ProSeg jobs finished, 12 `proseg-to-baysor` jobs were
   submitted in parallel (3–12 s each, all COMPLETED/exit-0).

5. The three canonical files (`cell-metadata.csv.gz`,
   `expected-counts.csv.gz`, `baysor-cell-polygons.geojson`) were
   cherry-picked from each scratch dir into `proseg/<file_id>/`. The
   scratch dir retains the full ProSeg output (zarr,
   `transcript-metadata.csv.gz`, all polygon layers) for any later
   reanalysis.

## Reproducibility & methods notes

These are publication-relevant facts about this dataset that are easy to
forget; record them in the Methods section.

### ProSeg 3.1.0 has no `--seed` flag

`proseg --help` exposes no random-seed control, and source inspection
(`dcjones/proseg` v3.1.0) shows the sampler is seeded from a thread-local
RNG via `rand::rng()` (system entropy). There is no environment-variable
fallback either. Consequence: this 2026-05-19 sweep is the
**authoritative version-frozen run** of the dataset — re-running ProSeg on
the same input would produce a statistically equivalent but not bit-identical
output (see benchmark below). Future re-runs should be avoided unless
required.

### Stochasticity benchmark (measured 2026-05-19 on sample 001002)

Two independent ProSeg runs on the same `transcripts.parquet` (one this
session, one the historic run) yielded:

- **Cell-count drift**: +28 cells out of ~12,400 (+0.23 %).
- **Per-gene total transcript mass**: Pearson *r* = 0.9991,
  Spearman *r* = 0.9997 across 420 shared genes. Median per-gene
  fold-change 0.96 (5–95 % range 0.71–1.02). Global transcript-mass
  ratio = 0.94.
- **Cell-centroid stability**: median nearest-neighbor centroid distance
  between matched cells = 1.83 μm (90th percentile 5.34 μm; max 38.9 μm).
  Only **53.8 % of cells lie within 2 μm** of a same-position cell in the
  other run — the rest shift due to boundary redraw or MCMC birth/death
  moves.
- **Largest divergence is on rare bacterial probes** (top-5 |log2 FC|:
  `BIF_BRE2` −1.31, `BLA_HAN1` −1.04, `BUK5` −1.03, `AKK_MUC2` −0.98,
  `BAC_OVA2` −0.90). All are low-count probes where small-N noise dominates;
  relative ordering across taxa is preserved (Spearman 0.9997).

**Operational consequence.** Population-level outputs (Leiden clusters,
KDE, paired lys-vs-no-lys statistics, cross-sample DEG) re-emerge robustly
across re-runs. Per-cell manual labels tied to specific cell IDs do NOT
transfer; derive cell-type labels from gene-set signatures, not from cell-ID
lists.

> Caveat: the historic run for 001002 was on an older ProSeg version, so the
> numbers above mix (a) pure MCMC stochasticity and (b) some version drift.
> They slightly overstate single-version run-to-run variance.

### Cell-metadata schema diff between ProSeg versions

| Older ProSeg (pre-2026 reruns)                                | ProSeg 3.1.0 (this sweep)                                |
|---------------------------------------------------------------|----------------------------------------------------------|
| `cell, original_cell_id, centroid_x, centroid_y, centroid_z,` | `cell, original_cell_id, centroid_x, centroid_y, centroid_z,` |
| `fov, cluster, volume, scale, population`                     | `cluster, volume, surface_area, scale`                   |

ProSeg 3.1.0 **dropped** `fov` (FOV index) and `population` (ProSeg's per-cell
soft cluster assignment), and **added** `surface_area`. The current notebooks
only read `centroid_x` / `centroid_y`, so this is **non-breaking** for the
existing pipeline. Flag if any future analysis needs `fov` or `population`
— those are not in the 2026-05-19 harmonized runs and would require a
custom rerun (or referring back to `proseg/old/<file_id>/`).

### Control-probe handling in downstream notebooks

All analysis notebooks apply an inline `remove_control_probes()` filter that
drops any `var_names` starting with `Neg` or `Unassigned` before computing
statistics. This is intentional — the 20 `NegControlProbe_*` are used for QC
(per `python/Control_probes.ipynb`) but not for biological analysis.

## Output structure (per-sample)

In our deployment, the project root is
`/fh/fast/hill_g/Albert/scSeq_ST_Analyses/Xenium_XB9MDD_2025/`. The
canonical layout after the 2026-05-19 sweep is:

```
proseg/
  <file_id>/                            # harmonized 2026-05-19 outputs
    cell-metadata.csv.gz                # adata.obs (3.1.0 schema)
    expected-counts.csv.gz              # adata.X (dense cells×genes)
    baysor-cell-polygons.geojson        # cell boundaries for spatial plots
  old/
    <file_id>/                          # pre-2026-05-19 historic runs
      cell-metadata.csv.gz              # legacy schema (has fov / population)
      expected-counts.csv.gz
      baysor-cell-polygons.geojson      # only present for 001001–001006
```

Full ProSeg outputs (zarr, transcript metadata, all polygon layers, SLURM
logs) are retained at
`/fh/fast/hill_g/Albert/Collaboration-Spatial_Seq_Biopsy_Samples/scripts/rerun_2026_05_19/<file_id>/`
in case anything beyond the three cherry-picked files is needed later.

## Step 4 — Per-sample analysis (downstream)

Lives in the project tree as `python/AY_00100X.ipynb`, one notebook per
**lysozyme** sample (the no-lysozyme partner is loaded inside as `adata_2`).
Common section structure (most fleshed-out in `AY_001003.ipynb`,
`AY_001005.ipynb`, `AY_001006.ipynb`):

1. **Data Loading** — load lys + no-lys ProSeg counts as `adata` / `adata_2`,
   apply `remove_control_probes()`, attach centroids to `adata.obsm["spatial"]`,
   load matched 16S brushing data from `data/brushings/brushings.csv`.
2. **Negative Control Probe Analysis** — fraction of `NegControlProbe`
   transcripts lys vs. no-lys (lys vs. no-lys background is the key control
   for the headline finding).
3. **Brushings analysis** — bring in matched 16S relative abundances for the
   patient.
4. **Lys vs. no-lys count-type evaluation** — paired count comparisons.
5. **Labeling** — DEG → labeling → module scores → gene-set definition →
   DEG between targeted groups → dendrogram → label transfer.
6. **Bacterial transcript masks** — combined-bacterial masks, paired-probe
   concordancy scores, filter, DEG of bacteria-near vs. bacteria-far cells
   within the same cluster.
7. **Raw-transcript-level bacterial analysis** — same questions at the
   pre-segmentation transcript level.
8. **(001005/001006 only) KDE estimation** — kernel density of transcripts,
   paired-probe correlations, overlay on DAPI/ISH images. The marimo
   prototype is `python/bacterial-density.py`.

**Important: per-sample cell-type labels assigned before 2026-05-19 do not
transfer to the harmonized runs** (see [stochasticity benchmark](#stochasticity-benchmark-measured-2026-05-19-on-sample-001002)).
Re-derive labels from gene-set signatures on the new outputs. The 9XQADF
sister project will share the labeling notebook scaffold once it's written.

## Step 5 — Pilot-level lysozyme-vs-no-lysozyme figures

`python/Control_probes.ipynb` generates the paired lys-vs-no-lys figures
that report the headline finding:

- `paired_lys_vs_no_lys_paper.png` — fraction of bacterial transcripts in
  each sample's lys vs. no-lys pair (Wilcoxon paired).
- `paired_lys_vs_no_lys_paper_abs_count.png` — absolute counts version.
- `gardner_altman_lys_vs_no_lys.png`,
  `gardner_altman_neg_probe_counts.png` — estimation-plot variants.

Re-running these notebooks on the 2026-05-19 outputs is a recommended
sanity check before submission.

## Compute environment

- Fred Hutch SLURM cluster, partition `campus-new`.
- ProSeg jobs: 8 CPUs, 32 GB RAM, 5–21 min walltime per sample.
- ProSeg installed via `cargo install proseg` (built against
  `Rust/1.83.0-GCCcore-13.3.0`); binary at `~/.cargo/bin/proseg`,
  version **3.1.0**.
- Python: micromamba env `spatial-singular` (Python 3.11, scanpy, anndata,
  squidpy, spatialdata, geopandas, scikit-image, duckdb).

## Code references

| File                                 | Location                              | Purpose                                                  |
|--------------------------------------|---------------------------------------|----------------------------------------------------------|
| `Proseg_init.sh`                     | repo root                             | SLURM batch ProSeg + densify-MTX post-step               |
| `Proseg_to_Baysor.sh`                | repo root                             | Legacy 2-arg form (broken on 3.1.0 — see step 3 above)   |
| `Xeniumranger.sh`                    | repo root                             | Re-import Baysor-format segmentation into Xenium Explorer|
| `python/AY_00100X.ipynb`             | project tree (`Xenium_XB9MDD_2025/`)  | Per-sample analysis notebook (one per lysozyme sample)   |
| `python/Control_probes.ipynb`        | project tree                          | Pilot-level lys-vs-no-lys QC figures                     |
| `python/bacterial-density.py`        | project tree                          | KDE-based bacterial density (marimo prototype)           |
| `python/microbe_work.ipynb`          | project tree                          | Probe-specificity QC (BLAST hits per probe)              |
| `custom_blast.ipynb`                 | project tree (top level)              | k-mer probe-design helper, writes `kmer_matches.tsv`     |
