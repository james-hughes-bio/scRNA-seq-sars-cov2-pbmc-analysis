map_library_metadata <- function(barcodes, meta) {
  required <- c("sample", "group", "geo_accession")
  if (!all(required %in% names(meta))) stop("Incomplete GEO library metadata.")
  if (anyNA(barcodes) || anyDuplicated(barcodes) ||
      any(!grepl("-[0-9]+$", barcodes))) stop("Invalid or duplicate barcodes.")
  meta$sample <- as.character(meta$sample)
  if (anyNA(meta$sample) || anyDuplicated(meta$sample) ||
      anyNA(meta$group) || any(!meta$group %in% c("Normal", "Flu", "COVID")))
    stop("Invalid GEO sample mapping.")
  sample <- sub(".*-([0-9]+)$", "\\1", barcodes)
  idx <- match(sample, meta$sample)
  if (anyNA(idx)) stop("Barcode suffix missing from GEO metadata.")
  out <- meta[idx, , drop = FALSE]
  rownames(out) <- barcodes
  out
}

# Cluster numbers alone never validate reuse: require the same full barcode partition.
reviewed_cluster_lookup <- function(cells, clusters, reference) {
  required <- c("Cell", "cluster_id", "annotation", "annotation_confidence")
  if (!all(required %in% names(reference))) stop("Incomplete reference annotation.")
  if (length(cells) != length(clusters) || anyNA(cells) || anyNA(clusters) ||
      anyDuplicated(cells) || anyNA(reference$Cell) || anyDuplicated(reference$Cell))
    stop("Invalid cluster membership records.")
  if (!setequal(cells, reference$Cell)) return(NULL)
  ref <- reference[match(cells, reference$Cell), , drop = FALSE]
  # Allow a pure cluster-number permutation, but not changed cell membership.
  cross <- table(as.character(clusters), as.character(ref$cluster_id))
  if (any(rowSums(cross > 0) != 1L) || any(colSums(cross > 0) != 1L)) return(NULL)
  rows <- lapply(unique(as.character(clusters)), function(k) {
    r <- ref[as.character(clusters) == k, , drop = FALSE]
    if (length(unique(r$annotation)) != 1L ||
        length(unique(r$annotation_confidence)) != 1L) stop("Inconsistent reference label.")
    data.frame(cluster = k, annotation = r$annotation[1],
               confidence = r$annotation_confidence[1],
               annotation_note = "Historical marker review transferred after exact partition verification.")
  })
  do.call(rbind, rows)
}
