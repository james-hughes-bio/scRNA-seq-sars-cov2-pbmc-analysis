# Process-local configuration. Shared libraries remain read-only.
configure_project <- function(root) {
  local_lib <- file.path(root, ".r-library")
  if (dir.exists(local_lib)) .libPaths(c(normalizePath(local_lib), .libPaths()))
  Sys.setenv(R_USER_CACHE_DIR = file.path(root, ".cache"))
  # Discover standard installations without storing a workstation-specific path.
  candidates <- c(Sys.getenv("RSTUDIO_PANDOC"), dirname(Sys.which("pandoc")),
    file.path(Sys.getenv("ProgramFiles"), "RStudio/resources/app/bin/quarto/bin/tools"))
  for (candidate in candidates[nzchar(candidates)]) {
    if (file.exists(file.path(candidate, if (.Platform$OS.type == "windows") "pandoc.exe" else "pandoc"))) {
      Sys.setenv(RSTUDIO_PANDOC = candidate)
      break
    }
  }
  invisible(root)
}

check_project_environment <- function(root, require_pandoc = TRUE) {
  recorded <- read.csv(file.path(root, "provenance/package_versions.csv"))
  files <- c(list.files(file.path(root, "analysis"), pattern = "\\.Rmd$", full.names = TRUE),
             list.files(file.path(root, "R"), pattern = "\\.R$", full.names = TRUE))
  txt <- paste(unlist(lapply(files, readLines, warn = FALSE)), collapse = "\n")
  calls <- regmatches(txt, gregexpr("library\\([A-Za-z0-9.]+\\)", txt))[[1]]
  namespaces <- regmatches(txt, gregexpr("[A-Za-z][A-Za-z0-9.]*::", txt))[[1]]
  pkgs <- sort(unique(c(recorded$package, gsub("library\\(|\\)", "", calls),
                       sub("::$", "", namespaces))))
  # BiocManager appears only in historical installation guidance, not execution.
  pkgs <- setdiff(pkgs, "BiocManager")
  failures <- character()
  for (pkg in pkgs) {
    tryCatch(loadNamespace(pkg), error = function(e) {
      failures <<- c(failures, paste0(pkg, ": ", conditionMessage(e)))
    })
  }
  if (length(failures)) stop(paste(failures, collapse = "\n"))
  versions <- data.frame(package = pkgs,
    version = vapply(pkgs, function(p) as.character(packageVersion(p)), character(1)),
    R_version = as.character(getRversion()))
  actual <- versions$version[match(recorded$package, versions$package)]
  if (any(actual != recorded$version))
    warning("Versions differ from the historical record: ",
      paste(recorded$package[actual != recorded$version], collapse = ", "))
  if (require_pandoc && !rmarkdown::pandoc_available())
    stop("Pandoc is unavailable. Put it on PATH or set RSTUDIO_PANDOC for this process.")
  cat("PASS:", length(pkgs), "required namespaces load; historical version record preserved.\n")
  if (require_pandoc) cat("Pandoc:", as.character(rmarkdown::pandoc_version()), "\n")
  versions
}

# CSV cannot encode list columns; serialization affects exports only.
csv_ready <- function(x) {
  for (name in names(x)[vapply(x, is.list, logical(1))])
    x[[name]] <- vapply(x[[name]], paste, collapse = ";", FUN.VALUE = character(1))
  x
}

require_new_run <- function(run_dir) {
  if (dir.exists(run_dir) && length(list.files(run_dir, all.files = TRUE, no.. = TRUE)))
    stop("Existing run preserved at ", run_dir,
         ". Archive it outside the run directory before a deliberate new render.")
}
