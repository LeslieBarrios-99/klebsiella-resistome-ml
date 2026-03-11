# =========================================================
# Extract Genome IDs from phenotype datasets
# =========================================================

source("scripts/00_config.R")

library(readr)
library(dplyr)

# ---------------------------------
# MEROPENEM
# ---------------------------------

mer <- read_tsv("data/processed/meropenem_phenotype_clean.tsv")

write_lines(
  mer$Genome.ID %>% as.character(),
  "data/processed/meropenem_genome_ids.txt"
)

cat("Meropenem Genome IDs exported\n")

# ---------------------------------
# IMIPENEM
# ---------------------------------

imi <- read_tsv("data/processed/imipenem_phenotype_clean.tsv")

write_lines(
  imi$Genome.ID %>% as.character(),
  "data/processed/imipenem_genome_ids.txt"
)

cat("Imipenem Genome IDs exported\n")
