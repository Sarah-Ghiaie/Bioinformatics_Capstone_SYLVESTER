#!/usr/bin/env Rscript
# =============================================================================
# Bacterial Genome Assembly QC Script
# Usage:
#   Rscript genome_qc.R /path/to/fasta/dir
#   Rscript genome_qc.R /path/to/file1.fna /path/to/file2.fna ...
#   Rscript genome_qc.R          # uses current working directory
# =============================================================================

required_packages <- c("ggplot2", "knitr")
optional_packages <- c("rmarkdown", "gridExtra", "scales")

install_if_missing <- function(pkgs) {
  missing <- pkgs[!sapply(pkgs, requireNamespace, quietly = TRUE)]
  if (length(missing) > 0) {
    message("Installing missing packages: ", paste(missing, collapse = ", "))
    install.packages(missing, repos = "https://cloud.r-project.org", quiet = TRUE)
  }
}

install_if_missing(required_packages)
install_if_missing(optional_packages)
library(ggplot2)

args <- commandArgs(trailingOnly = TRUE)
fna_files <- c()

if (length(args) == 0) {
  fna_files <- list.files(".", pattern = "\\.fn[a]$|\\.fasta$|\\.fa$", full.names = TRUE)
  if (length(fna_files) == 0) stop("No .fna/.fasta/.fa files found in current directory.")
} else if (length(args) == 1 && dir.exists(args[1])) {
  fna_files <- list.files(args[1], pattern = "\\.fn[a]$|\\.fasta$|\\.fa$", full.names = TRUE)
  if (length(fna_files) == 0) stop("No .fna/.fasta/.fa files found in: ", args[1])
} else {
  fna_files <- args[file.exists(args)]
}

message("Found ", length(fna_files), " genome file(s) to process.\n")

read_fasta <- function(filepath) {
  lines <- readLines(filepath, warn = FALSE)
  header_idx <- grep("^>", lines)
  starts <- header_idx
  ends <- c(header_idx[-1] - 1, length(lines))
  mapply(function(s, e, h) {
    list(header = sub("^>", "", lines[h]), seq = paste(lines[(h + 1):e], collapse = ""))
  }, starts, ends, header_idx, SIMPLIFY = FALSE)
}

compute_n50 <- function(lengths) {
  sorted <- sort(lengths, decreasing = TRUE)
  cumsum_len <- cumsum(sorted)
  total <- sum(sorted)
  idx <- which(cumsum_len >= total / 2)[1]
  list(N50 = sorted[idx], L50 = idx)
}

compute_n90 <- function(lengths) {
  sorted <- sort(lengths, decreasing = TRUE)
  cumsum_len <- cumsum(sorted)
  total <- sum(sorted)
  idx <- which(cumsum_len >= total * 0.9)[1]
  list(N90 = sorted[idx], L90 = idx)
}

qc_genome <- function(filepath) {
  filename <- basename(filepath)
  accession <- sub("_genomic\\.fn[a]?$", "", filename)
  accession <- sub("^[0-9]+_", "", accession)
  message("  Processing: ", accession)
  seqs <- tryCatch(read_fasta(filepath), error = function(e) NULL)
  if (is.null(seqs)) return(NULL)
  sequences <- sapply(seqs, `[[`, "seq")
  headers <- sapply(seqs, `[[`, "header")
  lengths <- nchar(sequences)
  total_length <- sum(lengths)
  is_plasmid <- grepl("plasmid", headers, ignore.case = TRUE)
  chr_lengths <- lengths[!is_plasmid]
  if (length(chr_lengths) == 0) chr_lengths <- lengths
  n50_res <- compute_n50(chr_lengths)
  n90_res <- compute_n90(chr_lengths)
  all_seq <- paste(sequences, collapse = "")
  total_bases <- nchar(all_seq)
  g_count <- nchar(gsub("[^Gg]", "", all_seq))
  c_count <- nchar(gsub("[^Cc]", "", all_seq))
  a_count <- nchar(gsub("[^Aa]", "", all_seq))
  t_count <- nchar(gsub("[^Tt]", "", all_seq))
  n_count <- nchar(gsub("[^Nn]", "", all_seq))
  other_count <- total_bases - g_count - c_count - a_count - t_count - n_count
  gc_content <- (g_count + c_count) / (total_bases - n_count) * 100
  n_percent <- n_count / total_bases * 100
  gaps <- unlist(regmatches(all_seq, gregexpr("N{10,}", all_seq, ignore.case = TRUE)))
  num_gaps <- length(gaps)
  total_gap_bp <- if (num_gaps > 0) sum(nchar(gaps)) else 0
  data.frame(
    Accession = accession, File = filename,
    Total_Length_bp = total_length, Num_Sequences = length(lengths),
    Num_Chromosomes = sum(!is_plasmid), Num_Plasmids = sum(is_plasmid),
    Largest_Seq_bp = max(lengths), Smallest_Seq_bp = min(lengths),
    Mean_Seq_bp = round(mean(lengths), 1), Median_Seq_bp = round(median(lengths), 1),
    N50_bp = n50_res$N50, L50 = n50_res$L50,
    N90_bp = n90_res$N90, L90 = n90_res$L90,
    GC_Percent = round(gc_content, 2), N_Bases = n_count,
    N_Percent = round(n_percent, 4), Num_Gaps_ge10bp = num_gaps,
    Total_Gap_bp = total_gap_bp, A_count = a_count, T_count = t_count,
    G_count = g_count, C_count = c_count, Other_bases = other_count,
    Seqs_ge_1kb = sum(lengths >= 1000), Seqs_ge_10kb = sum(lengths >= 10000),
    Seqs_ge_1Mb = sum(lengths >= 1e6), stringsAsFactors = FALSE
  )
}

message("Running QC...\n")
results_list <- lapply(fna_files, qc_genome)
results_list <- Filter(Negate(is.null), results_list)
results <- do.call(rbind, results_list)

write.table(results, "genome_qc_results.tsv", sep = "\t", row.names = FALSE, quote = FALSE)
message("Results written to: genome_qc_results.tsv")

results$Label <- sub("GCF_[0-9]+_[0-9]+_", "", results$Accession)
theme_qc <- theme_bw(base_size = 11) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 8),
        plot.title = element_text(face = "bold", size = 12))

ggsave("plot_genome_size.png",
  ggplot(results, aes(x = Label, y = Total_Length_bp / 1e6, fill = Label)) +
    geom_col(show.legend = FALSE) + labs(title = "Genome Size", x = NULL, y = "Total Length (Mb)") + theme_qc,
  width = 8, height = 5, dpi = 150)

ggsave("plot_gc_content.png",
  ggplot(results, aes(x = Label, y = GC_Percent, fill = Label)) +
    geom_col(show.legend = FALSE) + labs(title = "GC Content (%)", x = NULL, y = "GC %") + theme_qc,
  width = 8, height = 5, dpi = 150)

ggsave("plot_n50.png",
  ggplot(results, aes(x = Label, y = N50_bp / 1e6, fill = Label)) +
    geom_col(show.legend = FALSE) + labs(title = "N50", x = NULL, y = "N50 (Mb)") + theme_qc,
  width = 8, height = 5, dpi = 150)

message("Done.")
