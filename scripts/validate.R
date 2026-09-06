args0 <- commandArgs(FALSE)
script <- sub("^--file=", "", args0[grepl("^--file=",args0)][1])
root <- normalizePath(file.path(dirname(script),".."),mustWork=TRUE)
setwd(root)
source("tests/test_validation.R")
source("tests/test_runtime.R")
for (f in c(list.files("R", pattern="\\.R$", full.names=TRUE),
            list.files("scripts", pattern="\\.R$", full.names=TRUE))) parse(file=f)
sources <- list.files("analysis",pattern="\\.Rmd$",full.names=TRUE)
fence <- strrep(intToUtf8(96),3)
for (f in sources) {
  lines <- readLines(f,warn=FALSE)
  inside <- FALSE; code <- character(); labels <- character()
  for (line in lines) {
    if (startsWith(line,paste0(fence,"{r"))) {
      inside <- TRUE
      label <- trimws(sub("[,}].*$","",substring(line,6)))
      if (nzchar(label) && !grepl("=",label)) labels <- c(labels,label)
    } else if (inside && trimws(line)==fence) {
      parse(text=code); code <- character(); inside <- FALSE
    } else if (inside) code <- c(code,line)
  }
  stopifnot(!inside,!anyDuplicated(labels))
  cat("PARSE PASS:",f,"\n")
}
cat("Static parsing and data checks do not constitute a full analytical rerun.\n")
