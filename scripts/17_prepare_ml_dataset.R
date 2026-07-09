# =========================================================
# 17_prepare_ml_dataset.R
# Construction of curated Machine Learning datasets
# for meropenem and imipenem prediction
# =========================================================

source("scripts/00_config.R")

library(tidyverse)
library(data.table)
library(stringr)

# =========================================================
# File paths
# =========================================================

resistome_file <- "data/processed/resistome_matrix_clean.tsv"
meropenem_file <- "data/processed/meropenem_with_assembly.tsv"
imipenem_file <- "data/processed/imipenem_with_assembly.tsv"
mlst_file <- "results/mlst_results.tsv"
output_dir <- "data/processed"

# =========================================================
# Load curated resistome matrix
# =========================================================

resistome <- read_tsv(resistome_file)

cat("\n========== RESISTOME ==========\n")
cat("Genomes:", nrow(resistome), "\n")
cat("Predictors:", ncol(resistome)-1, "\n")

# =========================================================
# Load phenotype metadata
# =========================================================

mer_raw <- read_tsv(meropenem_file)
imi_raw <- read_tsv(imipenem_file)

cat("\n========== PHENOTYPES ==========\n")
cat("Meropenem records:", nrow(mer_raw), "\n")
cat("Imipenem records:", nrow(imi_raw), "\n")

# =========================================================
# Load MLST results
# =========================================================

mlst <- read_tsv(
  mlst_file,
  col_names = FALSE,
  show_col_types = FALSE
)

# Keep only genome and ST
mlst <- mlst %>%
  transmute(
    Genome = str_extract(X1, "G(CA|CF)_\\d+\\.\\d+"),
    ST = X3
  ) %>%
  distinct()

cat("\n========== MLST ==========\n")
cat("Genomes with MLST:", nrow(mlst), "\n")
cat("Unique STs:", length(unique(mlst$ST)), "\n")

# =========================================================
# Function to prepare phenotype tables
# =========================================================

prepare_phenotype <- function(df){
  
  # Detect conflicting phenotypes
  conflicts <- df %>%
    select(
      `Assembly Accession`,
      Resistant.Phenotype
    ) %>%
    group_by(`Assembly Accession`) %>%
    summarise(
      n_pheno = n_distinct(Resistant.Phenotype),
      .groups = "drop"
    ) %>%
    filter(n_pheno > 1)
  
  cat("Conflicting genomes removed:", nrow(conflicts), "\n")
  
  if(nrow(conflicts) > 0){
    cat("Genome IDs:\n")
    print(conflicts)
  }
  
  # Build clean phenotype table
  df %>%
    select(
      `Assembly Accession`,
      Resistant.Phenotype
    ) %>%
    rename(
      Genome = `Assembly Accession`,
      Phenotype = Resistant.Phenotype
    ) %>%
    group_by(Genome) %>%
    filter(n_distinct(Phenotype) == 1) %>%
    slice(1) %>%
    ungroup() %>%
    mutate(
      Genome = as.character(Genome),
      Phenotype = factor(
        Phenotype,
        levels = c(
          "Resistant",
          "Susceptible"
        )
      )
    )
  
}

# =========================================================
# Prepare phenotype tables
# =========================================================
mer <- prepare_phenotype(mer_raw)
imi <- prepare_phenotype(imi_raw)

cat("\n========== CLEAN PHENOTYPES ==========\n")
cat("Meropenem genomes:", nrow(mer), "\n")
cat("Imipenem genomes:", nrow(imi), "\n")

# =========================================================
# Build final ML dataset
# =========================================================

build_ml_dataset <- function(resistome, phenotype, mlst){
  
  dataset <- phenotype %>%
    inner_join(resistome, by = "Genome") %>%
    left_join(mlst, by = "Genome")
  
  dataset <- dataset %>%
    filter(!is.na(ST))
  
  cat("\n==============================\n")
  cat("Final Machine Learning dataset\n")
  cat("==============================\n")
  
  cat("Genomes:", nrow(dataset), "\n")
  cat("Predictors:", ncol(resistome)-1, "\n")
  
  cat("Phenotypes available:", sum(!is.na(dataset$Phenotype)), "\n")
  cat("MLST assigned:", sum(!is.na(dataset$ST)), "\n")
  
  cat("Missing phenotype:", sum(is.na(dataset$Phenotype)),"\n")
  cat("Missing MLST:", sum(is.na(dataset$ST)), "\n")
  
  return(dataset)
}

mer_dataset <- build_ml_dataset(resistome, mer, mlst)
imi_dataset <- build_ml_dataset(resistome, imi, mlst)

# =========================================================
# Save datasets
# =========================================================
# Before save
stopifnot(sum(is.na(mer_dataset)) == 0)
stopifnot(sum(is.na(imi_dataset)) == 0)

#Save
write_tsv(mer_dataset, file.path(output_dir, "ml_dataset_meropenem.tsv"))
write_tsv(imi_dataset, file.path(output_dir, "ml_dataset_imipenem.tsv"))
cat("\nDatasets successfully saved.\n")

cat("\n==============================\n")
cat("Phenotype distribution\n")
cat("==============================\n")

cat("\nMeropenem phenotype distribution\n")
print(table(mer_dataset$Phenotype))

cat("\nImipenem phenotype distribution\n")
print(table(imi_dataset$Phenotype))

cat("\n=====================================\n")
cat("Machine Learning datasets successfully generated\n")
cat("=====================================\n")