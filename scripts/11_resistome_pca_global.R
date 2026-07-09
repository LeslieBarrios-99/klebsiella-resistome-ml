# =========================================================
# 11_resistome_pca_global.R
# Global PCA of the resistome (all genomes)
# =========================================================

source("scripts/00_config.R")

library(tidyverse)

# ==========================================================
# Load CLEAN matrix
# ==========================================================
resistome <- read_tsv("data/processed/resistome_matrix_clean.tsv")
genome_ids <- resistome$Genome
X <- resistome %>%
  select(-Genome)

# ==========================================================
# Remove genes with no variation
# ==========================================================
X_var <- X[, apply(X, 2, var) != 0, drop = FALSE]

cat("Genes before:", ncol(X), "\n")
cat("Genes with variation:", ncol(X_var), "\n")

# Verification
if (ncol(X_var) < 2) {
  stop("There are not enough variable genes for PCA")
}

# ==========================================================
# PCA
# ==========================================================
pca <- prcomp(X_var, scale. = TRUE)

pca_df <- as.data.frame(pca$x)
pca_df$Genome <- genome_ids

variance <- summary(pca)$importance[2,]

pca_counts <- pca_df %>%
  group_by(PC1, PC2) %>%
  summarise(n = n(), .groups = "drop")
# ==========================================================
# Plot (without phenotype)
# ==========================================================
p <- ggplot(pca_counts,
            aes(PC1,
                PC2,
                size = n)) +
  geom_point(
    shape = 21,
    fill = "#0072B2",
    colour = "black",
    alpha = 0.8
  ) +
  theme_classic(base_size = 14) +
  labs(
    title = expression(
      "Global resistome variation in " * italic(Klebsiella~pneumoniae)
    ),
    x = paste0("PC1 (", round(variance[1]*100,2), "%)"),
    y = paste0("PC2 (", round(variance[2]*100,2), "%)")
  ) +
  scale_size(
    name = "Shared genomes",
    range = c(2, 10)
  ) +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold"),
    axis.title = element_text(size = 13),
    axis.text = element_text(size = 11),
    panel.border = element_rect(colour = "black", fill = NA, linewidth = 0.8)
  )

print(p)

# ==========================================================
# Save figure
# ==========================================================
ggsave(
  "figures/resistome_global_pca.png",
  p,
  width = 8,
  height = 6,
  dpi = 300
)

cat("Global PCA saved\n")
cat("Number of genomes:", nrow(pca_df), "\n")
