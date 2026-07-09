# =========================================================
# 13_resistome_amr_gene_freq.R
# AMR gene frequency analysis
# =========================================================

source("scripts/00_config.R")

library(tidyverse)
library(forcats)
# =========================
# Load resistome matrix
resistome <- read_tsv("data/processed/resistome_matrix_clean.tsv")

# Remove genome column
genes <- resistome %>%
  select(-Genome)
# =========================
# Calculate frequency
gene_freq <- colSums(genes)

gene_freq_df <- data.frame(
  Gene = names(gene_freq),
  Frequency = gene_freq
)
# =========================
# Order
gene_freq_df <- gene_freq_df %>%
  arrange(desc(Frequency))

gene_freq_df$Gene <- fct_reorder(
  gene_freq_df$Gene,
  gene_freq_df$Frequency
)

# =========================
# Percentage
n_genomes <- nrow(resistome)

gene_freq_df$Percent <- round(
  gene_freq_df$Frequency / n_genomes * 100, 1
)
# -------------------------------
# Frequency plot 
# -------------------------------
p <- ggplot(gene_freq_df, aes(x = Gene, y = Frequency)) +
  geom_bar(stat = "identity", fill = "#F77F00", color = NA) +
  geom_text(aes(label = paste0(Frequency, " (", Percent, "%)")), hjust = -0.2, size = 3.5) +
  coord_flip() +
  expand_limits(y = max(gene_freq_df$Frequency) * 1.1) +
  theme_classic(base_size = 14) +
  labs(
    title = expression("Frequency of AMR genes in "*italic(Klebsiella~pneumoniae)),
    x = "AMR gene",
    y = "Number of genomes"
  ) +
  theme(
    plot.title = element_text(hjust = 0.5),
    panel.border = element_rect(colour = "black", fill = NA, linewidth = 0.8)
  )

# Print
print(p)

# Save figure
ggsave(
  "figures/resistome_amr_gene_frequency.png",
  p,
  width = 10,
  height = 6,
  dpi = 300
)

cat("AMR gene frequency figure saved\n")
