# =========================================================
# 08_detect_chromosomal_mutations.R
# Detección de mutaciones relevantes
# =========================================================

library(tidyverse)

resistome <- read_tsv("data/processed/resistome_matrix_binary_QC.tsv")

genes_interest <- c("ompK35", "ompK36", "mgrB")

mutation_matrix <- resistome %>%
  select(Assembly_Accession, any_of(genes_interest))

write_tsv(
  mutation_matrix,
  "results/mutations/chromosomal_mutations.tsv"
)
