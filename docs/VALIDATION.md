# Validation record

Maintenance date: 2026-09-06. Scope: engineering only. Existing analysis designs, thresholds, classification rules, source data and interpretations were retained.

## Results and rendering status

- Original library/annotation-partition and historical export tests: PASS.
- Saved GEO snapshot and all 20 metadata rows: PASS, unchanged.
- All 30 reference-file hashes and all 83 original-file hashes: PASS.
- Streaming validation inspected all 127,119,627 entries: PASS; 33,538 features and 85,144 barcodes, with all 20 suffixes matching GEO.
- Existing local `rlang` 1.3.0 repair retained. All 23 required namespaces load, including `celldex`, `scDblFinder` and `Seurat`. Historical direct dependency versions match. The shared `rlang` remains 1.1.7.
- Primary and atlas render preflights and the R Markdown integration render: PASS.
- Both Rmds parse. Regression tests cover exact historical partition transfer, list-column CSV serialization, and preserving existing run directories.

The full primary PBMC analysis was rerun successfully end-to-end on 2026-09-06 using the original read-only 10x inputs. An initial full-run attempt reached marker identification but failed because the Windows multisession marker step could not allocate a serialization buffer. Marker discovery was therefore changed from future::plan(multisession) to future::plan(sequential), without changing the marker test, thresholds, clustering parameters, source data, or biological interpretation. The subsequent primary workflow completed successfully.

The completed run produced a rendered HTML report and finished with run_status.txt = complete. scripts/verify_run.py verified all 14 recorded input hashes and all 55 output hashes against the completed run.

The atlas sensitivity analysis has not yet been rerun. Full atlas visual QA therefore remains unverified.
```sh
python scripts/validate_raw.py path/to/10x_directory --full
Rscript --vanilla scripts/render.R path/to/10x_directory --preflight
Rscript --vanilla scripts/render.R path/to/10x_directory atlas --preflight
```

These commands used the existing read-only original 10x inputs. Relative data arguments were checked from the workspace parent. After a future completed run, verify its manifests with:

```sh
python scripts/verify_run.py outputs/pbmc --data-dir path/to/10x_directory
```

## Unresolved reproducibility limits

The SingleR reference is fetched by the existing `celldex::HumanPrimaryCellAtlasData()` call. Its downloaded reference contents are not included in the current raw-input manifest or pinned to a retained reference artifact. The new runner redirects future R-user caches locally, but does not establish a reproducible offline reference download. Network availability and reference identity remain prerequisites to document when a full run is feasible.

Independent raw-download identity, a donor/time-point crosswalk, full transitive dependency locking and independent-machine reproduction remain unverified. PDF rendering was not attempted. Full primary PBMC report rendering is now complete; atlas report visual QA remains unverified. No scientific changes were made to resolve these limitations.

## Executed validation commands

From the repository root, using the installed R 4.5.2 executable for `Rscript`:

```sh
Rscript --vanilla scripts/validate.R
python scripts/validate_repository.py
python scripts/refresh_geo_metadata.py --check
python scripts/verify_originals.py
Rscript --vanilla scripts/check_environment.R
Rscript --vanilla tests/test_render.R
```

The R suite includes the original tests, R/Rmd parsing, chunk-label checks, and a regression test protecting prior run directories. The integration test generates a small HTML report with evaluated inline R and an embedded plot beneath ignored `outputs/validation/`. It does not execute the biological analysis. The Python suite checks manifests, offline metadata derivation, syntax, local documentation links, source paths and ignore rules. Commands were also tested with the caller outside the repository.
## Runtime and dependencies

`Rscript` must select R 4.5.2. Python scripts require Python 3.11 or newer because hashing uses `hashlib.file_digest`; no third-party Python dependencies are needed. If it is not on PATH, invoke the installed executable by its discovered path; no global PATH or package changes are required. Pandoc 3.6.3 was discovered in the standard RStudio installation. Runners check `RSTUDIO_PANDOC`, PATH, and that standard installation in order. Other installations can supply `RSTUDIO_PANDOC` for the child process.

The historical `provenance/package_versions.csv` is never rewritten by environment checks. Current direct dependency versions are printed; a completed future run records them under its output directory. Version drift is reported. This is a local overlay on shared libraries, not a fully isolated or transitively pinned environment. An independent-machine restoration has not been established.

If a dependency needs repair, install only the selected, verified package archive into this repository's `.r-library/`, using `install.packages(archive, repos = NULL, lib = file.path(repo_root, ".r-library"), type = "win.binary")` for a compatible Windows binary. Create that local directory first. Source archives require a suitable compiler and `type = "source"`. Do not run a broad package upgrade. Re-run `scripts/check_environment.R` in a fresh R process afterward. No installer was run during this maintenance.

`R_USER_CACHE_DIR` is set only in the R process to this repository's ignored `.cache/`; no shared cache is moved or modified. Runners load local packages before dependent namespaces. R startup emitted four warnings because the inherited `C.UTF-8` locale is unsupported on this Windows installation. Global locale settings were not changed.

## Provenance and Git checks

Offline GEO checks reproduce CSV serialization from the existing compressed snapshots, including blank fields for characteristics absent in individual samples. No metadata or input values were changed. The reference manifest must cover every reference file exactly; original and disposition manifests must agree. Historical CSV/data bytes are protected from Git line-ending conversion through `.gitattributes`. Source code and Markdown use LF.

The original workspace manifest deliberately covers both original loose datasets and the out-of-scope document. It is historical lineage, not a dependency on the other Git checkout. `python scripts/verify_originals.py path/to/original-workspace` verifies the entire original inventory; its default is the checkout's parent directory. An independent checkout need not have that historical workspace to run its own analysis.

`outputs/`, `.r-library/`, `.cache/`, raw inputs, session objects and local environment files are ignored. Prior tracked bulk exports remain recoverable through Git history and their exact reference copies. Both main refs and all remote refs were left unchanged; no push or merge was performed.

## Checkout validation

A disposable export of the staged Git index reproduced every working source, metadata and reference file byte-for-byte (43 files in the bulk checkout, 59 in the single-cell checkout). The original R test suites and offline metadata checks also passed from that export, invoked from the workspace parent. This validates checkout portability of the tracked artifacts, not a fresh dependency installation or full analytical reproduction. The export remains under ignored `outputs/maintenance-20260906/`.
