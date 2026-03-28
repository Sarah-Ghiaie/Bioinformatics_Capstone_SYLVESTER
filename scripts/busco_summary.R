#!/usr/bin/env Rscript
# =============================================================================
# BUSCO Results Summary & Plot
# Run from your raw_data directory or set working directory in RStudio
# =============================================================================

if (!requireNamespace("ggplot2", quietly = TRUE)) install.packages("ggplot2")
library(ggplot2)

summary_files <- list.files(
  path = ".",
  pattern = "short_summary.*\\.txt",
  recursive = TRUE,
  full.names = TRUE
)

if (length(summary_files) == 0) {
  stop("No BUSCO short_summary*.txt files found.")
}

message("Found ", length(summary_files), " BUSCO summary files.")

parse_busco <- function(filepath) {
  lines <- readLines(filepath, warn = FALSE)
  sample <- basename(dirname(filepath))
  sample <- sub("^busco_", "", sample)
  sample <- sub("_genomic$", "", sample)
  sample <- sub("^[0-9]+_", "", sample)

  get_val <- function(pattern) {
    line <- grep(pattern, lines, value = TRUE)[1]
    as.integer(trimws(strsplit(line, "\t")[[1]][2]))
  }

  complete   <- get_val("Complete BUSCOs \\(C\\)")
  single     <- get_val("Complete and single-copy BUSCOs \\(S\\)")
  duplicated <- get_val("Complete and duplicated BUSCOs \\(D\\)")
  fragmented <- get_val("Fragmented BUSCOs \\(F\\)")
  missing    <- get_val("Missing BUSCOs \\(M\\)")
  total      <- get_val("Total BUSCO groups searched")

  data.frame(
    Sample         = sample,
    Complete_pct   = round(complete   / total * 100, 2),
    Single_pct     = round(single     / total * 100, 2),
    Duplicated_pct = round(duplicated / total * 100, 2),
    Fragmented_pct = round(fragmented / total * 100, 2),
    Missing_pct    = round(missing    / total * 100, 2),
    Complete_n     = complete,
    Single_n       = single,
    Duplicated_n   = duplicated,
    Fragmented_n   = fragmented,
    Missing_n      = missing,
    Total_n        = total,
    stringsAsFactors = FALSE
  )
}

results <- do.call(rbind, lapply(summary_files, parse_busco))

write.table(results, "busco_summary.tsv", sep = "\t", row.names = FALSE, quote = FALSE)
message("TSV written to: busco_summary.tsv")

plot_data <- data.frame(
  Sample   = rep(results$Sample, 4),
  Category = rep(c("Complete (Single)", "Duplicated", "Fragmented", "Missing"), each = nrow(results)),
  Percent  = c(results$Single_pct, results$Duplicated_pct, results$Fragmented_pct, results$Missing_pct)
)

plot_data$Category <- factor(plot_data$Category,
  levels = c("Missing", "Fragmented", "Duplicated", "Complete (Single)"))

plot_data$Label <- sub("GCF_[0-9]+_[0-9]+_", "", plot_data$Sample)

busco_colors <- c(
  "Complete (Single)" = "#1f78b4",
  "Duplicated"        = "#a6cee3",
  "Fragmented"        = "#f0b429",
  "Missing"           = "#e63946"
)

p <- ggplot(plot_data, aes(x = Label, y = Percent, fill = Category)) +
  geom_col(width = 0.7) +
  scale_fill_manual(values = busco_colors) +
  scale_y_continuous(limits = c(0, 100), expand = c(0, 0)) +
  labs(title = "BUSCO Genome Completeness",
       subtitle = "bacteria_odb10 | n=124 BUSCOs",
       x = NULL, y = "Percentage (%)", fill = NULL) +
  theme_bw(base_size = 12) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 8),
        plot.title = element_text(face = "bold", size = 14),
        legend.position = "bottom")

ggsave("busco_completeness.png", p, width = 10, height = 6, dpi = 150)
message("Plot saved to: busco_completeness.png")
