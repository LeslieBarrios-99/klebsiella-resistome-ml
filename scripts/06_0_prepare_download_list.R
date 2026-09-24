# =========================================================
# 06_0_Prepare assembly list for genome download
# Prefer RefSeq (GCF) over GenBank (GCA)
# =========================================================

library(readr)
library(dplyr)

mer <- read_tsv("data/processed/meropenem_filtered_genomes.tsv")
imi <- read_tsv("data/processed/imipenem_filtered_genomes.tsv")

# Function to prioritize GCF

select_refseq <- function(df) {

  df %>%
    mutate(
      accession_base = gsub("\\..*", "", `Assembly Accession`)
    ) %>%
    group_by(accession_base) %>%
    arrange(desc(grepl("^GCF", `Assembly Accession`))) %>%
    slice(1) %>%
    ungroup()
}

mer_clean <- select_refseq(mer)
imi_clean <- select_refseq(imi)

# -----------------------
# Save
# -----------------------

write_lines(
  mer_clean$`Assembly Accession`,
  "data/processed/meropenem_assembly_list.txt"
)

write_lines(
  imi_clean$`Assembly Accession`,
  "data/processed/imipenem_assembly_list.txt"
)
# -----------------------
# Print
# -----------------------

cat("\n===== Assembly summary =====\n")


cat("Meropenem QC:", nrow(mer), "\n")
cat("Meropenem unique:", nrow(mer_clean), "\n")
cat("Duplicates removed:", nrow(mer)-nrow(mer_clean), "\n\n")

cat("Imipenem QC:", nrow(imi), "\n")
cat("Imipenem unique:", nrow(imi_clean), "\n")
cat("Duplicates removed:", nrow(imi)-nrow(imi_clean), "\n")