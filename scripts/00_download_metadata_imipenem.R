# =========================================================
# Limpieza fenotipo imipenem
# =========================================================

source("scripts/00_config.R")

pheno_raw <- read.csv("data/raw/imipenem_raw.csv")

pheno_clean <- pheno_raw %>%
  filter(Antibiotic == "imipenem") %>%
  select(`Genome.ID`, `Resistant.Phenotype`) %>%
  distinct()

write.table(
  pheno_clean,
  "data/processed/imipenem_phenotype_clean.tsv",
  sep="\t",
  quote=FALSE,
  row.names=FALSE
)

cat("Fenotipo imipenem limpio guardado\n")
