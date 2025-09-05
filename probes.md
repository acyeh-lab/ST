

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
