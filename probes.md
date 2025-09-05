# Loading Probe Data

## Why Use DuckDB for Transcript Queries

Working with Xenium `transcripts.parquet` files can involve **tens of millions of rows**.  
Instead of loading the entire dataset into memory with pandas, you can use **DuckDB** to query only what you need.

### Example

```python
import duckdb

transcripts = duckdb.sql(
    f"""
    SELECT (row_number() OVER ()) - 1 AS transcript_id,
           feature_name,
           x_location AS x,
           y_location AS y
    FROM '{transcripts_file}'
    WHERE feature_name ~ '..._...\\d'
    """
).to_df()
```
- transcripts_file should be a parquet file generated AFTER Xeniumranger is applied (not before)
- Note the regex '..._...\\d' works because our custom bacterial probes are in the format XXX_XXXX.


# Kernel Density Estimation (KDE) Overview

## What is KDE?
Kernel Density Estimation (KDE) is a **non-parametric method** to estimate the underlying distribution of data points.  
Instead of assuming a specific distribution (e.g., Gaussian, Poisson), KDE places a small "bump" (a *kernel function*) at each data point and sums them to create a smooth estimate.

Think of KDE as a **smooth version of a histogram**:
- Histogram → counts in discrete bins (depends heavily on bin size).
- KDE → continuous curve controlled by a *bandwidth* parameter.

---

## Mathematical Idea
For data points \(x_1, x_2, \dots, x_n\), the KDE at location \(x\) is:

\[
\hat{f}(x) = \frac{1}{n h} \sum_{i=1}^{n} K\!\left(\frac{x - x_i}{h}\right)
\]

- \(K\): kernel function (often Gaussian).
- \(h\): bandwidth (controls smoothness).
- Intuition: each point contributes a little Gaussian bump → add them all → get a continuous density estimate.

---

## KDE in 2D
For tissue coordinates (X,Y):
- Place a Gaussian bump around each transcript or cell.
- Add them up across the dataset.
- Result = a smooth **intensity map** of where transcripts or cells are concentrated.

**Clinical analogy**:
- PET imaging: each emission gets blurred → summed into a continuous intensity image.
- Pathology heatmaps: showing immune hotspots in a biopsy.

---

## The `KernelIntensity` Wrapper

```python
class KernelIntensity:
    """
    Thin wrapper scaling KernelDensity to give positional intensities.
    """
    def __init__(self, bandwidth: float=1.0, kernel: str="gaussian"):
        self.n = 0
        self.kde = KernelDensity(bandwidth=bandwidth, kernel=kernel)

    def fit(self, xys: np.ndarray):
        self.n = xys.shape[0]
        self.kde.fit(xys)

    def log_intensities(self, xys: np.ndarray):
        return self.kde.score_samples(xys) + np.log(self.n)
