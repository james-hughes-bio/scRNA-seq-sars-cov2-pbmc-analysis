# Small integration render: verifies R Markdown, Pandoc, root paths and image embedding.
# It does not run the analysis or change previous report outputs.
raw_args <- commandArgs(FALSE)
script <- sub("^--file=", "", raw_args[grepl("^--file=", raw_args)][1])
root <- normalizePath(file.path(dirname(script), ".."), mustWork = TRUE)
source(file.path(root, "R/runtime.R"))
configure_project(root)
parent <- file.path(root, "outputs/validation")
dir.create(parent, recursive = TRUE, showWarnings = FALSE)
out <- tempfile("render-smoke-", tmpdir = parent)
dir.create(out)
input <- file.path(out, "render_smoke.Rmd")
fence <- strrep(intToUtf8(96), 3)
writeLines(c("---", 'title: "Rendering infrastructure smoke test"',
  "output: html_document", "---", "", "Engineering validation only; no analysis results.",
  paste0(fence, "{r setup, include=FALSE}"),
  "stopifnot(file.exists('R/validation.R'))", fence,
  "", "Inline expression: `r 2 + 2`.", "", paste0(fence, "{r plot}"),
  "plot(1:3, 1:3, main='Rendering check')", fence), input)
output <- rmarkdown::render(input, output_dir = out, intermediates_dir = out,
  knit_root_dir = root, envir = new.env(parent = globalenv()), quiet = TRUE)
html <- paste(readLines(output, warn = FALSE), collapse = "\n")
stopifnot(grepl("Inline expression: 4", html, fixed = TRUE),
          grepl("data:image/png;base64,", html, fixed = TRUE),
          !grepl("## Error", html, fixed = TRUE))
cat("PASS: integration render with inline R, project-relative input and embedded PNG:", output, "\n")
