# =========================================================
# 01_download metadata meropenem
# Meropenem phenotype cleanup
# =========================================================

source("scripts/00_config.R")

pheno_raw <- read.csv("data/raw/meropenem_raw.csv")

pheno_clean <- pheno_raw %>%
  filter(Antibiotic == "meropenem") %>%
  select(`Genome.ID`, `Resistant.Phenotype`) %>%
  distinct()

write.table(
  pheno_clean,
  "data/processed/meropenem_phenotype_clean.tsv",
  sep="\t",
  quote=FALSE,
  row.names=FALSE
)

cat("Meropenem phenotype cleanup saved\n")
cat("Number of genomes:", nrow(pheno_clean), "\n")
table(pheno_clean$Resistant.Phenotype)