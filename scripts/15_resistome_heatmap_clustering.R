# =========================================================
# 15_resistome_heatmap_clustering.R
# Hierarchical clustering of the resistome + heatmap
# =========================================================

source("scripts/00_config.R")

library(tidyverse)
library(pheatmap)

# ==========================================================
# Load data
# ==========================================================
resistome <- read_tsv("data/processed/resistome_matrix_clean.tsv")

genes <- resistome %>% 
  select(-Genome) %>% 
  as.matrix()

# ==========================================================
# Heatmap 
# ==========================================================
pheatmap(
  genes,
  color = c("#F7F7F7", "#2C7FB8"),
  clustering_distance_rows = "binary",
  clustering_distance_cols = "binary",
  clustering_method = "average",
  cluster_rows = TRUE,
  cluster_cols = TRUE,
  show_rownames = FALSE,
  show_colnames = TRUE,
  angle_col = 45,
  fontsize_col = 10,
  fontsize_row = 6,
  border_color = NA,
  main = expression("Hierarchical clustering of resistome profiles of "*italic(Klebsiella~pneumoniae)),
  filename = "figures/resistome_heatmap.png",
  width = 8,
  height = 10
)

# ==========================================================
# Logs
# ==========================================================
cat("Resistome heatmap saved\n")
cat("Genomes before:", nrow(resistome), "\n")
cat("Genomas after:", nrow(genes), "\n")
