# =========================================================
# 16_1_mlst_frequency.R
# Sequence Types Frequency (MLST)
# =========================================================

source("scripts/00_config.R")

library(tidyverse)
library(forcats)

# ---------------------------------------------------------
# Read MLST results
# ---------------------------------------------------------

mlst <- read_tsv(
  "results/mlst/mlst_results.tsv",
  col_names = FALSE,
  show_col_types = FALSE
)

colnames(mlst) <- c(
  "Genome",
  "Species",
  "ST",
  "gapA",
  "infB",
  "mdh",
  "pgi",
  "phoE",
  "rpoB",
  "tonB"
)

# ---------------------------------------------------------
# Extract Assembly Accession from MLST file paths
# ---------------------------------------------------------

mlst <- mlst %>%
  mutate(
    Genome = str_extract(
      Genome,
      "G(CA|CF)_\\d+\\.\\d+"
    )
  )

# ---------------------------------------------------------
# Filter MLST results according to the final resistome
# collection
# ---------------------------------------------------------

final_genomes <- read_tsv(
  "data/processed/resistome_matrix_clean.tsv",
  show_col_types = FALSE
) %>%
  select(Genome) %>%
  distinct()

mlst_final <- mlst %>%
  inner_join(
    final_genomes,
    by = "Genome"
  )
cat("Final collection genomes:", nrow(final_genomes), "\n")
cat("Genomes with MLST results:", sum(mlst_final$ST != "-"), "\n")
cat("Distinct STs:", n_distinct(mlst_final$ST[mlst_final$ST != "-"]), "\n")

# ---------------------------------------------------------
# ST frequency
# ---------------------------------------------------------

st_freq <- mlst_final %>%
  filter(ST != "-") %>%
  count(ST, sort = TRUE)

# Total number of STs
cat("Total number of STs:", n_distinct(st_freq$ST), "\n")

# Top 15 STs
st_top <- st_freq %>%
  slice_max(n, n = 15)

# Percentage
st_top <- st_top %>%
  mutate(
    Percent = round(n / sum(st_freq$n) * 100, 1)
  )

# ---------------------------------------------------------
# Chart order
# ---------------------------------------------------------

st_top <- st_top %>%
  mutate(
    ST = fct_reorder(
      paste0("ST", ST),
      n
    )
  )

# ---------------------------------------------------------
# Plot
# ---------------------------------------------------------

p <- ggplot(
  st_top,
  aes(x = ST, y = n)
) +
  geom_col(
    fill = "#F77F00",
    width = 0.7
  ) +
  geom_text(
    aes(
      label = paste0(
        n,
        " (",
        Percent,
        "%)"
      )
    ),
    hjust = -0.15,
    size = 4  
  ) +
  coord_flip() +
  theme_classic(base_size = 14) +
  labs(
    title = expression(
      "Frequency of MLST sequence types in " *
      italic(Klebsiella~pneumoniae)
    ),
    x = "Sequence Type",
    y = "Number of genomes"
  ) +
  expand_limits(
    y = max(st_top$n) * 1.15
  ) +
  theme(
    plot.title = element_text(
      hjust = 0.5,
      face = "bold"
    ),
    panel.border = element_rect(
      colour = "black",
      fill = NA,
      linewidth = 0.8
    )
  )

print(p)

ggsave(
  "results/resistome/mlst_frequency.png",
  p,
  width = 8,
  height = 6,
  dpi = 300
)

cat("MLST frequency figure saved\n")
