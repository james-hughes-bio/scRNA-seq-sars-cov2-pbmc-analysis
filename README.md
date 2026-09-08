# Single-cell RNA-seq analysis of SARS-CoV-2 PBMC samples

The primary source is [analysis/pbmc_analysis.Rmd](analysis/pbmc_analysis.Rmd): QC, library-specific doublet detection, normalization, PCA, clustering, marker discovery, annotation review, and descriptive library composition.

GSE149689 has 20 libraries: 11 COVID-19, five influenza, and four healthy controls. The primary paper reports **eight COVID-19 patients**, three sampled twice. Barcode suffixes identify libraries, not independent donors.

## Status and scope

The historical exports describe 53,380 singlets and 12 clusters; their internal consistency was checked against cell metadata. Both notebooks pass R parsing and input/annotation guard tests. Every sparse input entry passed streaming structural validation. **The refactored primary PBMC workflow was rerun successfully end-to-end on 2026-09-06. The completed run passed manifest verification for all 14 inputs and all 55 generated outputs. The atlas sensitivity screen has not yet been rerun.** Historical images and tables remain explicitly labeled under reference/.

The primary source retains six PCs, resolution 0.3, original QC thresholds, and marker parameters. RNG kind is now set before seeding. Saved markers are not reused. Historical annotations transfer only after exact full-partition comparison, allowing cluster-number permutations. Changed partitions remain unannotated pending marker review.

Library composition is descriptive. Original Kruskal-Wallis results are retained only as historical evidence and are not regenerated or interpreted as donor-independent disease tests. A validated donor/time-point crosswalk is needed before disease comparisons.

## Run and validate

Use R 4.5.2, Pandoc, and the packages in [provenance/package_versions.csv](provenance/package_versions.csv). This is a historical dependency record, not a locked environment. R entry points prefer an existing repository-local `.r-library/`; shared libraries are read only. See [dependency and runtime guidance](docs/VALIDATION.md#runtime-and-dependencies).

Python validation requires Python 3.11 or newer (standard library only).

From this repository:

~~~sh
Rscript --vanilla scripts/validate.R
python scripts/validate_repository.py
Rscript --vanilla tests/test_render.R
Rscript --vanilla scripts/check_environment.R
python scripts/validate_raw.py data/raw --full
Rscript --vanilla scripts/render.R data/raw --preflight
Rscript --vanilla scripts/render.R data/raw
~~~

The default input directory is `data/raw/`. You may pass a different existing input directory; relative arguments resolve from the caller's working directory. Rendering requires `matrix.mtx.gz`, `features.tsv.gz`, and `barcodes.tsv.gz`. The streaming validator also accepts plain equivalents. Original compressed/plain pairs were previously verified identical after decompression.

For an independent checkout, download the three [GEO supplementary files](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE149689) into data/raw/ and remove the GSE149689_ filename prefix. Do not commit the raw matrix. The original local hashes are recorded in the workspace manifest; upstream binary identity has not been independently established by this cleanup.

Refresh metadata with:

~~~sh
python scripts/refresh_geo_metadata.py --check  # offline comparison; changes nothing
python scripts/refresh_geo_metadata.py          # explicit online refresh
~~~

This derives groups from GEO characteristics and verifies barcode suffixes against GEO's explicit mapping. It never guesses donor IDs from age, sex, or barcode.

The optional [atlas sensitivity source](analysis/atlas_sensitivity.Rmd) retains the separate 15–25-PC/resolution screen. Run it with:

~~~sh
Rscript --vanilla scripts/render.R data/raw atlas --preflight
Rscript --vanilla scripts/render.R data/raw atlas
~~~

Its default anchor and heuristic labels are provisional, not an established optimum or validated replacement for the primary analysis.

## Outputs and provenance

New runs write only to outputs/pbmc/ or outputs/atlas_sensitivity/, including reports, figures, tables, objects, sessions, and SHA-256 manifests. Generated outputs, raw inputs, local libraries, and caches are ignored by Git. A nonempty run directory is preserved: deliberately archive it before requesting a new render. Input manifests use `repository` or `data_dir` scopes with relative paths. Only the primary workflow lists the historical membership file as an annotation input. `--preflight` checks dependencies and input availability without executing analysis.

[docs/AUDIT.md](docs/AUDIT.md) records the audit. [docs/VALIDATION.md](docs/VALIDATION.md) distinguishes completed checks from remaining validation. [reference/](reference/) contains historical exports, including the original composition-test table whose independence assumption is unresolved. Older 14-cluster markers, screenshots, session files, and render caches remain solely in the untouched original workspace.

The 127-million-entry matrix requires substantial memory when loaded into R. Streaming validation uses much less memory and does not establish analytical reproducibility.

## Sources

- [GSE149689 at GEO](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE149689)
- [Lee et al. primary study](https://pmc.ncbi.nlm.nih.gov/articles/PMC7402635/)

The exact maintenance file list and original branch state are recorded in [docs/MAINTENANCE.md](docs/MAINTENANCE.md).

Author: James Hughes
