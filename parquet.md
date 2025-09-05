# Transcript File Conversion in Xenium Workflows

## Why convert `transcripts.parquet` → `transcripts.csv.gz`?

Xenium outputs transcript data in **Parquet format** by default. While Parquet is efficient for storage and fast for modern Python libraries, many downstream tools in bioinformatics expect text-based formats like `.csv.gz`.

### 1. Format Compatibility
- **`transcripts.parquet`**: columnar, binary format optimized for Python/Arrow/Spark.
- **`transcripts.csv.gz`**: plain text + compressed, broadly accepted by:
  - R/Seurat (`ReadXenium()`)
  - Scanpy workflows
  - Command-line and legacy genomics tools

### 2. Interoperability
- Not all collaborators or repositories (e.g., GEO, ArrayExpress) support `.parquet`.
- `.csv.gz` is the *lingua franca* across R, Python, and Unix pipelines.

### 3. Compression & Size Management
- Transcript-level files can be huge (millions of rows).
- `.csv.gz` compresses by ~5–10×.
- Parquet is already compressed, but not all downstream tools can read it.

---

## Example Conversion (Python)

```python
import pyarrow.parquet as pq

# Read Parquet into Pandas DataFrame
df = pq.read_table("transcripts.parquet").to_pandas()

# Save as compressed CSV
df.to_csv("transcripts.csv.gz", index=False, compression="gzip")
