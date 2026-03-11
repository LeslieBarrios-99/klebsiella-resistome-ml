# =========================================================
# Preparar dataset para ML
# =========================================================

source("scripts/00_config.R")

matrix <- fread("data/processed/resistome_matrix_binary_QC.tsv")
pheno <- fread("data/processed/meropenem_phenotype_clean.tsv")

dataset <- matrix %>%
  left_join(pheno, by="Assembly_Accession")

write.table(
  dataset,
  "data/processed/ml_dataset_meropenem.tsv",
  sep="\t",
  quote=FALSE,
  row.names=FALSE
)
