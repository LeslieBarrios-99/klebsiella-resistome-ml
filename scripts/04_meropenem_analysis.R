# =========================================================
# 04_meropenem_analysis.R
# PCA y exploración del resistoma asociado a meropenem
# =========================================================

source("scripts/00_config.R")

library(tidyverse)

# ---------------------------------------------------------
# 1. Cargar matriz resistoma
# ---------------------------------------------------------

resistome <- read_tsv("data/processed/resistome_matrix_binary_QC.tsv")

# ---------------------------------------------------------
# 2. Cargar fenotipo meropenem
# ---------------------------------------------------------

phenotype <- read_tsv("data/raw/meropenem_tablageneral.csv")

phenotype_clean <- phenotype %>%
  select(Assembly_Accession, Resistant_Phenotype) %>%
  distinct()

# ---------------------------------------------------------
# 3. Unir resistoma con fenotipo
# ---------------------------------------------------------

data <- resistome %>%
  left_join(phenotype_clean, by = "Assembly_Accession")

# Filtrar genomas con fenotipo disponible
data_pheno <- data %>%
  filter(!is.na(Resistant_Phenotype))

# ---------------------------------------------------------
# 4. PCA
# ---------------------------------------------------------

matrix <- data_pheno %>%
  select(-Assembly_Accession, -Resistant_Phenotype)

pca <- prcomp(matrix, scale. = TRUE)

pca_df <- as.data.frame(pca$x)
pca_df$Phenotype <- data_pheno$Resistant_Phenotype

# ---------------------------------------------------------
# 5. Visualización
# ---------------------------------------------------------

library(ggplot2)

ggplot(pca_df, aes(PC1, PC2, color = Phenotype)) +
  geom_point(size = 2, alpha = 0.8) +
  theme_minimal() +
  labs(
    title = "PCA del resistoma asociado a meropenem",
    x = "PC1",
    y = "PC2"
  )
