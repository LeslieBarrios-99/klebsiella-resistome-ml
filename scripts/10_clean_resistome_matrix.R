# =========================================================
# 10_clean_resistome_matrix.R
# Generation of the final resistome matrix
# =========================================================

source("scripts/00_config.R")

library(tidyverse)
library(stringr)

resistome <- read_tsv("data/processed/resistome_matrix_binary_QC.tsv")

genomes <- resistome$Genome

genes <- resistome %>%
  select(-Genome) %>%
  mutate(across(everything(), as.numeric))

# =========================
# Mapping genes
# =========================
gene_names_clean <- case_when(
  str_detect(colnames(genes), regex("gyrA", ignore_case = TRUE)) ~ "gyrA",
  str_detect(colnames(genes), regex("gyrB", ignore_case = TRUE)) ~ "gyrB",
  str_detect(colnames(genes), regex("parC", ignore_case = TRUE)) ~ "parC",
  str_detect(colnames(genes), regex("PBP3", ignore_case = TRUE)) ~ "PBP3",
  str_detect(colnames(genes), regex("PhoP", ignore_case = TRUE)) ~ "PhoP",
  str_detect(colnames(genes), regex("PhoQ", ignore_case = TRUE)) ~ "PhoQ",
  str_detect(colnames(genes), regex("ramR", ignore_case = TRUE)) ~ "ramR",
  str_detect(colnames(genes), regex("acrR", ignore_case = TRUE)) ~ "acrR",
  str_detect(colnames(genes), regex("AcrAB", ignore_case = TRUE)) ~ "AcrAB",
  str_detect(colnames(genes), regex("tetR", ignore_case = TRUE)) ~ "tetR",
  str_detect(colnames(genes), regex("rpoB", ignore_case = TRUE)) ~ "rpoB",
  TRUE ~ NA_character_
)

# =========================
# Filter valid genes
# =========================
genes <- genes[, !is.na(gene_names_clean)]
colnames(genes) <- make.unique(gene_names_clean[!is.na(gene_names_clean)])

# =========================
# Group duplicates
# =========================
genes <- genes %>%
  as.data.frame() %>%
  mutate(row_id = row_number()) %>%
  pivot_longer(-row_id, names_to = "Gene", values_to = "Value") %>%
  mutate(Gene = str_replace(Gene, "\\..*", "")) %>%
  group_by(row_id, Gene) %>%
  summarise(Value = max(Value), .groups = "drop") %>%
  pivot_wider(names_from = Gene, values_from = Value) %>%
  select(-row_id)

genes <- as.data.frame(genes)

# =========================
# Clear matrix
# =========================
genes <- genes[rowSums(genes) > 0, ]
genes[is.na(genes)] <- 0

# =========================
# Add Genomes
# =========================
genes$Genome <- genomes

# Reorder columns
genes <- genes %>% select(Genome, everything())

# =========================
# Save
# =========================
write_tsv(genes, "data/processed/resistome_matrix_clean.tsv")

cat("Resistome clean matrix saved\n")

cat("\n========== CLEAN MATRIX SUMMARY ==========\n")
cat("Original AMR annotations:", ncol(resistome)-1, "\n")
cat("Non-redundant AMR determinants:", ncol(genes)-1, "\n")
cat("Final genomes:", nrow(genes), "\n")
