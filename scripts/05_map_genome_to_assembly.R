# =========================================================
# Map Genome.ID to Assembly Accession
# =========================================================

source("scripts/00_config.R")

library(tidyverse)

# -----------------------------
# cargar datasets fenotipo
# -----------------------------

mer <- read_tsv("data/processed/meropenem_phenotype_clean.tsv")
imi <- read_tsv("data/processed/imipenem_phenotype_clean.tsv")

# -----------------------------
# cargar metadata genomas
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

cat("Meropenem genomes with assembly:",
nrow(mer_map), "\n")

# -----------------------------
# IMIPENEM
# -----------------------------

imi_map <- imi %>%
  left_join(meta, by=c("Genome.ID"="Genome ID")) %>%
  filter(!is.na(`Assembly Accession`))

write_tsv(
  imi_map,
  "data/processed/imipenem_with_assembly.tsv"
)

cat("Imipenem genomes with assembly:",
nrow(imi_map), "\n")
