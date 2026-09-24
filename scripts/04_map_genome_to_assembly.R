# =========================================================
# 04_Map Genome to assembly
# Map Genome.ID to Assembly Accession
# =========================================================

source("scripts/00_config.R")

library(tidyverse)

# -----------------------------
# Low phenotype datasets
# -----------------------------

mer <- read_tsv("data/processed/meropenem_phenotype_clean.tsv")
imi <- read_tsv("data/processed/imipenem_phenotype_clean.tsv")

# -----------------------------
# Load genome metadata
# -----------------------------

meta <- read_csv("data/raw/klebsiella_genomes_metadata.csv")

# -----------------------------
# MEROPENEM
# -----------------------------

mer_map <- mer %>%
  left_join(meta, by=c("Genome.ID"="Genome ID")) %>%
  filter(!is.na(`Assembly Accession`))

write_tsv(
  mer_map,
  "data/processed/meropenem_with_assembly.tsv"
)

# -----------------------------
# IMIPENEM
# -----------------------------
cat("Imipenem before mapping:", nrow(imi), "\n")

imi_map <- imi %>%
  left_join(meta, by=c("Genome.ID"="Genome ID")) %>%
  filter(!is.na(`Assembly Accession`))

write_tsv(
  imi_map,
  "data/processed/imipenem_with_assembly.tsv"
)

# -----------------------------
# PRINT
# -----------------------------

cat("===== Meropenem =====\n")
cat("Phenotype:", nrow(mer), "\n")
cat("With Assembly:", nrow(mer_map), "\n")
cat("Unique Assembly:", length(unique(mer_map$`Assembly Accession`)), "\n")
cat("Without Assembly:", sum(is.na(
  left_join(mer, meta, by = c("Genome.ID" = "Genome ID"))$`Assembly Accession`
)), "\n\n")

cat("===== Imipenem =====\n")
cat("Phenotype:", nrow(imi), "\n")
cat("With Assembly:", nrow(imi_map), "\n")
cat("Unique Assembly:", length(unique(imi_map$`Assembly Accession`)), "\n")
cat("Without Assembly:", sum(is.na(
  left_join(imi, meta, by = c("Genome.ID" = "Genome ID"))$`Assembly Accession`
)), "\n\n")