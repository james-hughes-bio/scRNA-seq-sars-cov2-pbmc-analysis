# Run the portfolio PBMC single-cell workflow.
# Usage: Rscript analysis/run_analysis.R [data_dir]

args <- commandArgs(trailingOnly = TRUE)
data_dir <- if (length(args) >= 1L) args[[1]] else file.path("data", "raw")

repo_root <- normalizePath(".", winslash = "/", mustWork = TRUE)
analysis_rmd <- file.path(repo_root, "analysis", "pbmc_analysis.Rmd")
validation_src <- file.path(repo_root, "analysis", "validation.R")
annotation_src <- file.path(repo_root, "data", "reference", "cell_metadata_with_annotations.csv")

required <- c(analysis_rmd, validation_src, annotation_src)
missing_required <- required[!file.exists(required)]
if (length(missing_required)) {
  stop("Missing repository file(s): ", paste(missing_required, collapse = ", "))
}

input_dir <- normalizePath(data_dir, winslash = "/", mustWork = TRUE)
required_10x <- file.path(input_dir, c("matrix.mtx.gz", "features.tsv.gz", "barcodes.tsv.gz"))
missing_10x <- required_10x[!file.exists(required_10x)]
if (length(missing_10x)) {
  stop(
    "Missing 10x input file(s): ",
    paste(basename(missing_10x), collapse = ", "),
    ". See data/README.md for download instructions."
  )
}

if (!requireNamespace("rmarkdown", quietly = TRUE)) {
  stop("Package 'rmarkdown' is required to run the analysis.")
}

# The validated source notebook was originally developed with these two support
# locations. Materialise them only for the duration of the render so the public
# repository can retain the compact README/data/analysis/outputs layout.
temp_r_dir <- file.path(repo_root, "R")
temp_reference_dir <- file.path(repo_root, "reference")
temp_reference_tables <- file.path(temp_reference_dir, "tables")
temp_validation <- file.path(temp_r_dir, "validation.R")
temp_annotation <- file.path(temp_reference_tables, "cell_metadata_with_annotations.csv")

r_dir_existed <- dir.exists(temp_r_dir)
reference_dir_existed <- dir.exists(temp_reference_dir)
validation_existed <- file.exists(temp_validation)
annotation_existed <- file.exists(temp_annotation)

if (!dir.exists(temp_r_dir)) dir.create(temp_r_dir, recursive = TRUE)
if (!dir.exists(temp_reference_tables)) dir.create(temp_reference_tables, recursive = TRUE)

if (!file.copy(validation_src, temp_validation, overwrite = TRUE)) {
  stop("Could not stage analysis/validation.R for the render.")
}
if (!file.copy(annotation_src, temp_annotation, overwrite = TRUE)) {
  stop("Could not stage the reviewed annotation reference for the render.")
}

cleanup_support_files <- function() {
  if (!validation_existed && file.exists(temp_validation)) unlink(temp_validation)
  if (!annotation_existed && file.exists(temp_annotation)) unlink(temp_annotation)
  if (!r_dir_existed && dir.exists(temp_r_dir)) unlink(temp_r_dir, recursive = TRUE)
  if (!reference_dir_existed && dir.exists(temp_reference_dir)) unlink(temp_reference_dir, recursive = TRUE)
}
on.exit(cleanup_support_files(), add = TRUE)

outputs_dir <- file.path(repo_root, "outputs")
dir.create(outputs_dir, recursive = TRUE, showWarnings = FALSE)

rendered <- rmarkdown::render(
  input = analysis_rmd,
  output_dir = outputs_dir,
  params = list(data_dir = input_dir),
  envir = new.env(parent = globalenv()),
  quiet = FALSE
)

# The validated notebook writes run products under outputs/pbmc/. Consolidate
# figures and tables into the same compact layout used by the portfolio repo.
copy_run_outputs <- function(source_dir, destination_dir) {
  if (!dir.exists(source_dir)) return(invisible(NULL))
  dir.create(destination_dir, recursive = TRUE, showWarnings = FALSE)
  source_files <- list.files(source_dir, full.names = TRUE, recursive = FALSE, all.files = FALSE)
  if (length(source_files)) {
    ok <- file.copy(source_files, destination_dir, overwrite = TRUE, recursive = TRUE)
    if (any(!ok)) warning("Some generated outputs could not be copied into ", destination_dir)
  }
}

copy_run_outputs(file.path(outputs_dir, "pbmc", "figures"), file.path(outputs_dir, "figures"))
copy_run_outputs(file.path(outputs_dir, "pbmc", "tables"), file.path(outputs_dir, "tables"))

if (dir.exists(file.path(outputs_dir, "pbmc"))) {
  unlink(file.path(outputs_dir, "pbmc"), recursive = TRUE)
}

message("Completed PBMC scRNA-seq workflow. Report: ", normalizePath(rendered, winslash = "/", mustWork = FALSE))
