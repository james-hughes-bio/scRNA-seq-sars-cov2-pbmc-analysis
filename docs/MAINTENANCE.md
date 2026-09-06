# Engineering maintenance record

Date: 2026-09-06. Branch: `cleanup/pbmc-only-refactor`. Main at start: `b9eb73839795b5dcac94c771728e3d2a77b921b3`.

## Incoming local state

All staged and unstaged diffs were inspected before modification. Large deleted CSVs and binary figures were compared byte-for-byte with reference copies. The deleted misplaced notebook and HTML were inspected as the prior cross-repository source/report. Complete binary patches, a per-file hash inventory and copies of all incoming source/reference files are preserved locally under `outputs/maintenance-20260906/`. No original loose workspace file or prior generated output was overwritten.

```text
 M README.md
?? .gitattributes
?? .gitignore
?? R/validation.R
?? analysis/atlas_sensitivity.Rmd
?? analysis/pbmc_analysis.Rmd
?? data/metadata/geo_samples.csv
?? docs/AUDIT.md
?? provenance/GSE149689_series_matrix.txt.gz
?? provenance/dataset.json
?? provenance/geo_source.json
?? provenance/original_workspace_manifest.csv
?? provenance/package_versions.csv
?? provenance/reference_manifest.csv
?? provenance/workspace_disposition.csv
?? reference/figures/annotated_umap.png
?? reference/figures/canonical_marker_dotplot.png
?? reference/figures/cluster_composition_by_group.png
?? reference/figures/elbow_plot.png
?? reference/figures/marker_heatmap.png
?? reference/figures/pca_plot_grouped.png
?? reference/figures/pca_plot_sample.png
?? reference/figures/qc_by_group.png
?? reference/figures/qc_scatter_counts_features.png
?? reference/figures/qc_scatter_counts_mito.png
?? reference/figures/qc_violin.png
?? reference/figures/representative_marker_featureplots.png
?? reference/figures/singler_umap.png
?? reference/figures/umap_clusters.png
?? reference/figures/umap_group.png
?? reference/figures/variable_features.png
?? reference/tables/all_markers.csv
?? reference/tables/annotation_vs_singler_labels.csv
?? reference/tables/cell_metadata_with_annotations.csv
?? reference/tables/cluster_annotation_table.csv
?? reference/tables/cluster_composition_by_group.csv
?? reference/tables/cluster_composition_by_sample.csv
?? reference/tables/cluster_composition_kruskal_tests.csv
?? reference/tables/cluster_sizes.csv
?? reference/tables/doublet_by_sample.csv
?? reference/tables/doublet_calls.csv
?? reference/tables/doublet_summary.csv
?? reference/tables/singleR_labels.csv
?? reference/tables/top10_markers_by_cluster.csv
?? reference/tables/top5_markers_by_cluster.csv
?? scripts/check_environment.R
?? scripts/refresh_geo_metadata.py
?? scripts/render.R
?? scripts/validate.R
?? scripts/validate_raw.py
?? scripts/verify_originals.py
?? tests/test_validation.R
```

## Engineering changes

- Added repository-local runtime initialization: local library precedence, local R-user cache location and Pandoc discovery without a user-specific path.
- Environment checks load all statically referenced and recorded dependencies and preserve the historical version record. Existing dependencies were reused; shared package installation was not modified.
- Specialized the metadata parser and render entry point to this dataset. Offline `--check` uses the saved GEO snapshot without changing it.
- Render inputs have relative paths with explicit scopes. New manifests include source helpers, metadata derivation inputs and historical dependency records. Existing/nonempty runs are refused to prevent stale output manifests; failed renders receive an explicit status.
- Added exact-byte reference/disposition checks, portable original-workspace arguments, run-manifest verification, output-preservation regression tests and a small rendering integration test.
- Protected data and historical reference bytes from line-ending conversion; kept generated outputs, local caches and local libraries ignored. Added missing validation documentation and corrected README commands. Removed only trailing whitespace from existing notebook lines.
- Single-cell notebook edits are limited to generated figure paths, CSV serialization of an atlas list column and export-directory documentation. The primary/atlas computational code and classification logic were preserved.

The original audit is retained as prior context. Its cross-workspace inventory is intentional provenance, not an active dependency on another repository. See [VALIDATION.md](VALIDATION.md) for executed checks, numerical warnings and work that has not been reproduced.

## Exact file changes

### Files edited during this continuation

- `.gitattributes`
- `.gitignore`
- `README.md`
- `analysis/atlas_sensitivity.Rmd`
- `analysis/pbmc_analysis.Rmd`
- `docs/AUDIT.md`
- `scripts/check_environment.R`
- `scripts/refresh_geo_metadata.py`
- `scripts/render.R`
- `scripts/validate.R`
- `scripts/verify_originals.py`

### Files added during this continuation

- `R/runtime.R`
- `docs/MAINTENANCE.md`
- `docs/VALIDATION.md`
- `scripts/validate_repository.py`
- `scripts/verify_run.py`
- `tests/test_render.R`
- `tests/test_runtime.R`

### Complete cleanup change set relative to the incoming branch commit

This includes the previously uncommitted cleanup, which was preserved. `R100` denotes a byte-identical relocation.

```text
A	.gitattributes
A	.gitignore
A	R/runtime.R
A	R/validation.R
M	README.md
A	analysis/atlas_sensitivity.Rmd
A	analysis/pbmc_analysis.Rmd
A	data/metadata/geo_samples.csv
A	docs/AUDIT.md
A	docs/MAINTENANCE.md
A	docs/VALIDATION.md
A	provenance/GSE149689_series_matrix.txt.gz
A	provenance/dataset.json
A	provenance/geo_source.json
A	provenance/original_workspace_manifest.csv
A	provenance/package_versions.csv
A	provenance/reference_manifest.csv
A	provenance/workspace_disposition.csv
A	reference/figures/annotated_umap.png
A	reference/figures/canonical_marker_dotplot.png
A	reference/figures/cluster_composition_by_group.png
A	reference/figures/elbow_plot.png
A	reference/figures/marker_heatmap.png
A	reference/figures/pca_plot_grouped.png
A	reference/figures/pca_plot_sample.png
A	reference/figures/qc_by_group.png
A	reference/figures/qc_scatter_counts_features.png
A	reference/figures/qc_scatter_counts_mito.png
A	reference/figures/qc_violin.png
A	reference/figures/representative_marker_featureplots.png
A	reference/figures/singler_umap.png
A	reference/figures/umap_clusters.png
A	reference/figures/umap_group.png
A	reference/figures/variable_features.png
A	reference/tables/all_markers.csv
A	reference/tables/annotation_vs_singler_labels.csv
A	reference/tables/cell_metadata_with_annotations.csv
A	reference/tables/cluster_annotation_table.csv
A	reference/tables/cluster_composition_by_group.csv
A	reference/tables/cluster_composition_by_sample.csv
A	reference/tables/cluster_composition_kruskal_tests.csv
A	reference/tables/cluster_sizes.csv
A	reference/tables/doublet_by_sample.csv
A	reference/tables/doublet_calls.csv
A	reference/tables/doublet_summary.csv
A	reference/tables/singleR_labels.csv
A	reference/tables/top10_markers_by_cluster.csv
A	reference/tables/top5_markers_by_cluster.csv
A	scripts/check_environment.R
A	scripts/refresh_geo_metadata.py
A	scripts/render.R
A	scripts/validate.R
A	scripts/validate_raw.py
A	scripts/validate_repository.py
A	scripts/verify_originals.py
A	scripts/verify_run.py
A	tests/test_render.R
A	tests/test_runtime.R
A	tests/test_validation.R
```
