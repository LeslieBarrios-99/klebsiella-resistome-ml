# =========================================================
# PCA del resistoma coloreado por fenotipo
# =========================================================

source("scripts/00_config.R")

library(tidyverse)

# -------------------------------
# Resistome matrix
# -------------------------------

resistome <- read_tsv("data/processed/resistome_matrix_binary_QC.tsv")

genome_ids <- resistome$Genome

X <- resistome %>%
  select(-Genome)

# -------------------------------
# Eliminar genes sin variación
# -------------------------------

X_var <- X[, apply(X, 2, var) != 0]

cat("Genes antes del filtro:", ncol(X), "\n")
cat("Genes con variación:", ncol(X_var), "\n")

# -------------------------------
# PCA
# -------------------------------

pca <- prcomp(X_var, scale. = TRUE)

pca_df <- as.data.frame(pca$x)
pca_df$Genome <- genome_ids
pca_df$Genome <- as.character(pca_df$Genome)

variance <- summary(pca)$importance[2,]

# -------------------------------
# Cargar metadata con assembly
# -------------------------------

mer_meta <- read_tsv("data/processed/meropenem_with_assembly.tsv")
imi_meta <- read_tsv("data/processed/imipenem_with_assembly.tsv")

pheno <- bind_rows(mer_meta, imi_meta) %>%
  select(`Assembly Accession`, `Resistant.Phenotype`) %>%
  rename(
    Genome = `Assembly Accession`,
    Phenotype = `Resistant.Phenotype`
  )

# asegurar mismo tipo
pheno$Genome <- as.character(pheno$Genome)  

# -------------------------------
# Unir PCA + fenotipo
# -------------------------------

pca_df <- left_join(pca_df, pheno, by = "Genome")

# -------------------------------
# Plot PCA
# -------------------------------

p <- ggplot(pca_df, aes(PC1, PC2, color = Phenotype)) +
  geom_point(size = 2.5, alpha = 0.8) +
  theme_classic() +
  labs(
    title = expression(
      "Resistome variation in " * italic(Klebsiella~pneumoniae)
    ),
    x = paste0("PC1 (", round(variance[1]*100,2), "%)"),
    y = paste0("PC2 (", round(variance[2]*100,2), "%)")
  ) +
  scale_color_manual(
    values = c(
      "Resistant" = "#d73027",
      "Susceptible" = "#4575b4"
    )
  ) +
  theme(
    plot.title = element_text(hjust = 0.5, size = 14),
    legend.title = element_text(size = 11),
    legend.text = element_text(size = 10)
  )

# Mostrar la figura en RStudio

print (p)

# Guardar en PNG

ggsave(
  "figures/resistome_pca_by_phenotype.png",
  p,
  width = 10,
  height = 6,
  dpi = 300
)

cat("PCA phenotype figure saved\n")
