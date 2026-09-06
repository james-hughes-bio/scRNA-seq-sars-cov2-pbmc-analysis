# Covid workspace audit

Audit date: 2026-09-05. All 83 original files were inventoried and hashed before refactoring. Original loose files are read-only.

## Initial repository state

Neither requested checkout existed in the selected workspace. Git status, remotes, and branches at the workspace root reported that it was not a repository. The GitHub connector located both repositories under james-hughes-bio. They were cloned into the requested folders after the audit plan.

| Repository | Initial main commit | Remote branches | Initial local status |
| --- | --- | --- | --- |
| bulk-rna-seq-sars-cov2-analysis | ae20644f1c6cc366fae286298dd221b00d06c165 | main only | clean |
| scRNA-seq-sars-cov2-pbmc-analysis | b9eb73839795b5dcac94c771728e3d2a77b921b3 | main only | clean |

The origin URLs are https://github.com/james-hughes-bio/ followed by the repository name and .git. The single-cell remote uses scRNA casing; the local folder uses the requested scrna casing. No applicable ancestor or repository AGENTS.md was found. No push or merge was performed.

The bulk repository contained a single-cell Rmd/HTML pair and lacked the bulk source advertised by its README. History showed deletion of the bulk Rmd at c17e5b2 and PDF at 4c7dd9c; the earlier source remains at 49e07d0. The single-cell repository contained only a README. Restoration uses the newer loose bulk source, whose baseline hash is retained.

## Original files and source lineage

The full inventory and per-file disposition are in provenance/original_workspace_manifest.csv and provenance/workspace_disposition.csv. Text sources and histories were inspected; CSV schemas and contents scanned; compressed files read through decompression; images inspected in contact sheets; DOCX text and PDF figure contents extracted. Large matrices were inspected structurally. Session files were inspected in isolated R environments.

- Bulk counts: 60,683 genes by 34 libraries, all finite nonnegative integers. Metadata align after period/hyphen normalization.
- Single-cell inputs: 33,538 features, 85,144 barcodes, 127,119,627 sparse entries. Every entry passed integer/index/range/count validation.
- Bulk counts in scRNA-seq/ exactly duplicate those in Bulk RNA-seq/.
- Four gzip/plain pairs match after decompression: bulk counts, barcodes, features, sparse matrix.
- Both small .RData files contain only .Random.seed. Neither supplies an analysis object.
- The 39 MB bulk .RDataTmp fails to load with "error reading from connection". It remains untouched.
- R histories mix prior code, settings, and annotations; they are references, not runnable sources.
- Single-cell significant_markers.csv and old screenshots describe 14 clusters. The newer all_markers.csv and metadata describe 12. They cannot be treated as one run.
- The separate atlas-rebuild notebook has no corresponding output set or saved Seurat object here. These are missing generated outputs, not missing raw inputs.
- The advertised bulk final PDF is absent. Single-cell PDFs are four figure intermediates, not final reports.
- Bonus Assignment.docx contains coursework requirements. atac-seq/ATAC-Seq.docx actually describes Illumina DNA methylation analysis. Both are out of scope.

Source copies: Bulk RNA-seq/rna_seq_analysis.Rmd becomes the bulk analysis source; scRNA-seq/scRNA_seq.Rmd becomes the primary PBMC source; scRNA-seq/scRNA_seq_global_atlas.Rmd becomes the explicitly provisional sensitivity source. Full bulk crossover sections and single-cell bulk interpretation were removed from the active reports. Older misplaced GitHub single-cell files remain recoverable at the original bulk commit.

## Scientific findings

**OBSERVED:** Historical local bulk exports contain 3,879 significant genes at padj < 0.05 and absolute shrunken log2FC > 1: 3,688 higher and 191 lower. Counts, gene membership, and top-100 order were checked against the full historical export. GitHub and local table versions remain separate.

**OBSERVED:** GEO labels S145_nCOV001_C as convalescent; the original binary model places it in Infected. Patient-like identifiers nCoV024EUHM and nCoV025EUHM appear in Draw-1/Draw-2 titles. The original cohort and condition-only model remain explicitly exploratory. Severity, sex, and timing were recovered without inventing donor IDs.

**OBSERVED:** Newer single-cell exports have 56,466 post-threshold cells: 3,086 doublets and 53,380 singlets. Cell metadata, doublet calls, cluster totals, and library-composition counts reconcile. This checks export consistency, not fresh clustering.

**SUPPORTED BY PRIMARY STUDY:** The 11 COVID libraries come from eight patients, with three sampled twice. Barcode suffixes are library IDs. Existing Kruskal-Wallis p-values therefore cannot be presented as independent-donor disease evidence. Active proportion tests were removed; descriptive proportions remain.

**NOT TESTED:** Independent-donor disease effects, cell-intrinsic regulation, formal deconvolution, absolute abundance, causal pathway activation, and optimality/stability of the separate atlas sensitivity workflow.

## Changes and execution boundaries

Edits are limited to the two Git checkouts, on cleanup/bulk-only-refactor and cleanup/pbmc-only-refactor. Main and remote refs are unchanged. Historical exports are labeled under reference/; new runs write to ignored outputs/. Removed tracked files remain in Git history.

GEO snapshots, source URLs, retrieval timestamps, derivation scripts, mapping checks, and full original hashes are included. No script installs packages. No data are uploaded, pushed, or merged.

Bulk metadata fallback was removed. Numeric/input validation rejects normalized-ID collisions, missing samples, invalid counts, and unknown groups. Symbols are used only for unambiguous mappings. GSEA retains all finite shrunken effects and records deterministic mapping selection, which changes enrichment relative to historical snapshots. Serial enrichment avoids automatic excessive process spawning.

Single-cell marker reuse based only on cluster numbers was removed. Historical annotation transfer requires an identical full barcode partition, allowing a label permutation. New partitions remain unreviewed. RNG initialization is ordered correctly. The sensitivity notebook remains provisional, with library-contribution rather than assumed donor-contribution wording.

## Remaining scientifically meaningful work

1. Resolve donor/time-point mapping and define acute versus convalescent cohort scope before revising the bulk model.
2. Establish the single-cell donor crosswalk before any repeated-measures or selected-donor disease comparison.
3. Rerun and review the full primary single-cell workflow in adequate memory; reassess labels if membership changes.
4. Run and inspect the atlas sensitivity screen before selecting or promoting a new clustering solution.
5. Use independent replication or suitable sensitivity analysis before advancing causal or mechanistic claims.

See docs/VALIDATION.md for executed checks and render status.

## Primary sources

- [GSE152418](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE152418)
- [GSE149689](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE149689)
- [Lee et al.](https://pmc.ncbi.nlm.nih.gov/articles/PMC7402635/)

The exact downloaded GEO series-matrix URL and SHA-256 are in each repository's provenance/geo_source.json.

## Engineering continuation, 2026-09-06

The prior cleanup was preserved on its existing branch. See [MAINTENANCE.md](MAINTENANCE.md) for the incoming Git state and exact engineering changes, and [VALIDATION.md](VALIDATION.md) for currently executed checks, preserved rendering evidence and unresolved warnings. This continuation made no analysis-design, threshold, classification, interpretation or source-data changes.
