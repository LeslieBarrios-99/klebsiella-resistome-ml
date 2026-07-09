# =========================================================
# 14_resistome_pcoa.R
# Principal Coordinates Analysis (PCoA) of the resistome
# =========================================================

source("scripts/00_config.R")

library(tidyverse)
library(vegan)
library(dplyr)

# Load binary resistome matrix
resistome <- read_tsv("data/processed/resistome_matrix_clean.tsv")

genomes <- resistome$Genome
genes <- resistome %>% 
  select(-Genome) %>% 
  mutate(across(everything(), as.numeric))

# Jaccard distance
dist_jaccard <- vegdist(genes, method = "jaccard")

# PCoA
pcoa <- cmdscale(dist_jaccard, eig = TRUE, k = 2)

pcoa_df <- data.frame(
  Genome = genomes,
  Axis1 = pcoa$points[,1],
  Axis2 = pcoa$points[,2]
)

# Explained variance
var1 <- round(pcoa$eig[1] / sum(pcoa$eig) * 100, 2)
var2 <- round(pcoa$eig[2] / sum(pcoa$eig) * 100, 2)

# Group identical resistome profiles
pcoa_counts <- pcoa_df %>%
    mutate(
        Axis1 = round(Axis1, 6),
        Axis2 = round(Axis2, 6)
    ) %>%
    group_by(Axis1, Axis2) %>%
    summarise(
        n = n(),
        .groups = "drop"
    )

# -------------------------------
# Plot PCoA 
# -------------------------------
p <- ggplot(pcoa_counts, aes(Axis1, Axis2)) +
  geom_point(aes(size = n), alpha = 0.9, shape = 21, fill = "#F77F00", color = "black", stroke = 0.4) +
  theme_classic(base_size = 14) +
  scale_size(range = c(3,10), name = "Number of genomes") +
  labs(
    title = expression("Principal Coordinate Analysis of resistome profiles in "*italic(Klebsiella~pneumoniae)),
    x = paste0("PCoA1 (", var1, "%)"),
    y = paste0("PCoA2 (", var2, "%)")
  ) +
  theme(plot.title = element_text(hjust = 0.5, size = 16, face = "bold"),
        panel.border = element_rect(colour = "black", fill = NA, linewidth = 0.8),
  	axis.title = element_text(size = 14),
    	axis.text = element_text(size = 12),
	legend.title = element_text(size = 12),
  	legend.text = element_text(size = 11),
    	panel.grid = element_blank()
  )

print(p)

ggsave(
  "figures/resistome_PCoA.png",
  p,
  width = 8,
  height = 6,
  dpi = 300
)

cat("PCoA figure saved\n")

