# =========================================================
# PCA del resistoma
# =========================================================

source("scripts/00_config.R")

library(tidyverse)

# -------------------------------
# Cargar matriz de resistoma
# -------------------------------

resistome <- read_tsv("data/processed/resistome_matrix_binary_QC.tsv")

genome_ids <- resistome$Genome

X <- resistome %>%
  select(-Genome)

# -------------------------------
# Eliminar columnas sin variación
# -------------------------------

X_var <- X[, apply(X, 2, var) != 0]

cat("Genes antes del filtro:", ncol(X), "\n")
cat("Genes con variación:", ncol(X_var), "\n")

# -------------------------------
# PCA
# -------------------------------

pca <- prcomp(X_var, scale. = TRUE)

# coordenadas PCA
pca_df <- as.data.frame(pca$x)
pca_df$Genome <- genome_ids

# -------------------------------
# Variance explained
# -------------------------------

variance <- summary(pca)$importance[2,]

cat("Variance explained PC1:", variance[1], "\n")
cat("Variance explained PC2:", variance[2], "\n")

# -------------------------------
# Plot PCA
# -------------------------------

p <- ggplot(pca_df, aes(PC1, PC2)) +
  geom_point(alpha = 0.6) +
  theme_classic() +
  labs(
    title = expression(
      "Global resistome structure in " * italic(Klebsiella~pneumoniae)
    ),
    x = paste0("PC1 (", round(variance[1]*100,2), "%)"),
    y = paste0("PC2 (", round(variance[2]*100,2), "%)")
  ) +
  theme(
    plot.title = element_text(hjust = 0.5, size = 14)
  )

# Mostrar la figura en RStudio

print (p)

# Guardar en PNG

ggsave(
  "figures/S_global_resistome_pca.png",
  p,
  width = 10,
  height = 6,
  dpi = 300
)

cat("PCA figure saved\n")
