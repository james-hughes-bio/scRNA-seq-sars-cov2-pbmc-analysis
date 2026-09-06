source("R/validation.R")
expect_error <- function(expr) {
  stopifnot(inherits(tryCatch({force(expr); NULL}, error = identity), "error"))
}
m <- data.frame(sample = c("1","2"), group = c("Normal","COVID"),
                geo_accession = c("GSM1","GSM2"))
stopifnot(identical(map_library_metadata(c("AA-2","BB-1"),m)$group, c("COVID","Normal")))
expect_error(map_library_metadata("AA-3",m))
expect_error(map_library_metadata(c("AA-1","AA-1"),m))
expect_error(map_library_metadata("AA",m))
ref <- data.frame(Cell=c("a","b","c","d"), cluster_id=c("0","0","1","1"),
                  annotation=c("T","T","B","B"), annotation_confidence="Reviewed")
stopifnot(!is.null(reviewed_cluster_lookup(ref$Cell,c("7","7","8","8"),ref)),
          is.null(reviewed_cluster_lookup(ref$Cell,c("0","1","0","1"),ref)),
          is.null(reviewed_cluster_lookup(c("a","b","c","e"),ref$cluster_id,ref)))
cells <- read.csv("reference/tables/cell_metadata_with_annotations.csv",row.names=1)
cells$Cell <- rownames(cells)
labels <- read.csv("reference/tables/singleR_labels.csv")
stopifnot(setequal(labels$Cell, cells$Cell))
labels <- labels[match(cells$Cell, labels$Cell), ]
stopifnot(all(labels$Annotation == cells$annotation),
          all(labels$SingleR_label == cells$SingleR_main))
geo <- read.csv("data/metadata/geo_samples.csv")
mapped <- map_library_metadata(cells$Cell,geo)
stopifnot(all(mapped$group==cells$group), all(mapped$sample==cells$sample),
          !is.null(reviewed_cluster_lookup(cells$Cell,cells$cluster_id,cells)),
          all(cells$doublet_status=="singlet"))
sizes <- read.csv("reference/tables/cluster_sizes.csv")
obs <- table(cells$annotation)
stopifnot(all(as.integer(obs[sizes$Cluster])==sizes$Cells))
comp <- read.csv("reference/tables/cluster_composition_by_sample.csv")
counts <- as.data.frame(table(sample=cells$sample, annotation=cells$annotation))
key <- function(x) paste(x$sample,x$annotation,sep="|")
stopifnot(all(comp$cells_in_annotation==counts$Freq[match(key(comp),key(counts))]),
          all(abs(tapply(comp$prop,comp$sample,sum)-1)<1e-10))
calls <- read.csv("reference/tables/doublet_calls.csv")
stopifnot(setequal(calls$Cell[calls$doublet_status=="singlet"],cells$Cell),
          nrow(cells)==53380L, sum(calls$doublet_status=="doublet")==3086L)
markers <- read.csv("reference/tables/all_markers.csv")
stopifnot(all(markers$p_val_adj<.05), setequal(markers$cluster,cells$cluster_id))
for (n in c(5L,10L)) {
  top <- read.csv(paste0("reference/tables/top",n,"_markers_by_cluster.csv"))
  stopifnot(all(paste(top$cluster,top$gene) %in% paste(markers$cluster,markers$gene)),
            all(table(top$cluster)==n))
}
cat("PASS: GEO library mapping, unknown suffix rejection, full partition annotation guard, historical cell/doublet/cluster/composition/marker consistency.\n")
