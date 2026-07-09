# =========================================================
# 5_Filter genomes before download
# =========================================================

source("scripts/00_config.R")

library(tidyverse)

mer <- read_tsv("data/processed/meropenem_with_assembly.tsv")
imi <- read_tsv("data/processed/imipenem_with_assembly.tsv")

# -----------------------------
# Quality filters
# -----------------------------

mer_filtered <- mer %>%
  filter(
    Size >= 5000000,
    Size <= 6500000,
    Contigs < 300,
    `Contig N50` > 20000
  )

imi_filtered <- imi %>%
  filter(
    Size >= 5000000,
    Size <= 6500000,
    Contigs < 300,
    `Contig N50` > 20000
  )

# ---------------------------
# Save results
# ---------------------------

write_tsv(
  mer_filtered,
  "data/processed/meropenem_filtered_genomes.tsv"
)

write_tsv(
  imi_filtered,
  "data/processed/imipenem_filtered_genomes.tsv"
)

# ---------------------------
# Print
# ---------------------------
cat("\n===== QC Summary =====\n")

cat("Meropenem genomes before QC:", nrow(mer), "\n")
cat("Meropenem genomes after QC:", nrow(mer_filtered), "\n")
cat("Deleted:", nrow(mer)-nrow(mer_filtered), "\n\n")

cat("Imipenem genomes before QC:", nrow(imi), "\n")
cat("Imipenem genomes after QC:", nrow(imi_filtered), "\n")
cat("Deleted:", nrow(imi)-nrow(imi_filtered), "\n\n")

