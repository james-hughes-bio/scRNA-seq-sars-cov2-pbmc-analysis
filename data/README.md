# Data

The raw single-cell count matrix is not committed to this repository because it is large.

Download the three GSE149689 supplementary 10x files from GEO:

https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE149689

Place them in `data/raw/` and rename them to:

```text
matrix.mtx.gz
features.tsv.gz
barcodes.tsv.gz
```

`metadata/geo_samples.csv` contains the GEO-derived mapping from barcode suffix/library ID to study group.

`reference/cell_metadata_with_annotations.csv` is the reviewed historical cell-partition/annotation reference used only to transfer cluster labels when the complete barcode partition is identical up to a cluster-number permutation.

Barcode suffixes represent libraries, not independent donors. The primary study reports eight COVID-19 patients, three sampled twice.
