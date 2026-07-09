# =========================================================
# 09_build_resistome_matrix.R
# Construction of a binary resistome matrix from RGI 
# =========================================================

library(tidyverse)
library(stringr)

# ---------------------------------------------------------
# Project pathways
# ---------------------------------------------------------

rgi_path <- "results/rgi/rgi_results"
qc_file <- "results/qc/quality_control/genomes_valid.txt"
output_path <- "data/processed"

# Define output
dir.create(output_path, showWarnings = FALSE, recursive = TRUE)

# --------------------------------------------------------
# List RGI .txt files
# --------------------------------------------------------

rgi_files <- list.files(rgi_path, 
                        pattern = "\\.txt$", 
                        full.names = TRUE)

cat("Number of RGI files:", length(rgi_files), "\n")

# --------------------------------------------------------
# Función para leer cada archivo RGI
# --------------------------------------------------------
# - Extracts Assembly ID from the filename
# - Retains only the detected gene (Best_Hit_ARO)
# - Returns a long-format Genome–Gene table

read_rgi_file <- function(file) {
  
  df <- read.delim(file, header = TRUE, sep = "\t", stringsAsFactors = FALSE)
  
  # Extract Assembly ID (GCA_XXXXXX.X o GCF_XXXXXX.X)
  genome_id <- str_extract(basename(file), "G(CA|CF)_\\d+\\.\\d+")
  
  # If there are no hits, return NULL
  if (nrow(df) == 0) return(NULL)
  
  df %>%
    select(Best_Hit_ARO) %>%
    mutate(
      Genome = genome_id,
      Gene = Best_Hit_ARO
    ) %>%
    select(Genome, Gene)
}

# ---------------------------------------------------------
# Read all files and build a long table
# ---------------------------------------------------------

resistome_long <- map_dfr(rgi_files, read_rgi_file)

cat("Total AMR detections:", nrow(resistome_long), "\n")

# ---------------------------------------------------------
# Cleaning: remove potential NAs in Genome
# ---------------------------------------------------------

resistome_long <- resistome_long %>%
  filter(!is.na(Genome))

cat("Genomes with AMR:",
    length(unique(resistome_long$Genome)), "\n")

# --------------------------------------------------------
# Build binary presence/absence resistome matrix
# --------------------------------------------------------

resistome_matrix <- resistome_long %>%
  mutate(Presence = 1) %>%
  distinct() %>%
  pivot_wider(
    names_from = Gene,
    values_from = Presence,
    values_fill = 0
  )

cat("Matrix dimensions before QC filtering:", dim(resistome_matrix), "\n")

# ---------------------------------------------------------
# Filter by Quality Control (QC)
# ---------------------------------------------------------

qc_genomes <- readLines(qc_path)

# Extract Assembly ID from long QC names
qc_assembly <- str_extract(qc_genomes,
                           "G(CA|CF)_\\d+\\.\\d+")

# Filter matrix
resistome_matrix_qc <- resistome_matrix %>%
  filter(Genome %in% qc_assembly)

cat("Genomes that pass QC and contain AMR genes
:", nrow(resistome_matrix_qc), "\n")

# ---------------------------------------------------------
# Save results
# ---------------------------------------------------------

write.table(resistome_long,
            file = file.path(output_path,
                             "resistome_long.tsv"),
            sep = "\t",
            quote = FALSE,
            row.names = FALSE)

write.table(resistome_matrix,
            file = file.path(output_path,
                             "resistome_matrix_binary_raw.tsv"),
            sep = "\t",
            quote = FALSE,
            row.names = FALSE)

write.table(resistome_matrix_qc,
            file = file.path(output_path,
                             "resistome_matrix_binary_QC.tsv"),
            sep = "\t",
            quote = FALSE,
            row.names = FALSE)

cat("Matrices saved successfully.\n")
