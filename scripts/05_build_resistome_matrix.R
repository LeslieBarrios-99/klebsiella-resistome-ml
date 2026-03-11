# =========================================================
# 05_build_resistome_matrix.R
# Construcción de matriz binaria de resistoma a partir de RGI 
# =========================================================

library(tidyverse)
library(stringr)

# ---------------------------------------------------------
# 1. Definir rutas del proyecto
# ---------------------------------------------------------

rgi_path <- "results/rgi/rgi_results"
qc_path <- "results/qc/quality_control/genomes_valid.txt"
output_path <- "data/processed"

# Crear carpeta de salida
dir.create(output_path, showWarnings = FALSE, recursive = TRUE)

# --------------------------------------------------------
# 2. Listar archivos RGI .txt
# --------------------------------------------------------

rgi_files <- list.files(rgi_path, 
                        pattern = "\\.txt$", 
                        full.names = TRUE)

cat("Número de archivos RGI encontrados:", length(rgi_files), "\n")

# --------------------------------------------------------
# 3. Función para leer cada archivo RGI
# --------------------------------------------------------
# - Extrae Assembly ID desde el nombre del archivo
# - Conserva únicamente el gen detectado (Best_Hit_ARO)
# - Devuelve tabla larga Genome–Gene

read_rgi_file <- function(file) {
  
  df <- read.delim(file, header = TRUE, sep = "\t", stringsAsFactors = FALSE)
  
  # Extraer Assembly ID (GCA_XXXXXX.X o GCF_XXXXXX.X)
  genome_id <- str_extract(basename(file), "G(CA|CF)_\\d+\\.\\d+")
  
  # Si no hay hits, devolver NULL
  if (nrow(df) == 0) return(NULL)
  
  df %>%
    select(ARO, Best_Hit_ARO) %>%
    mutate(
      Genome = genome_id,
      Gene = Best_Hit_ARO
    ) %>%
    select(Genome, Gene)
}

# ---------------------------------------------------------
# 4. Leer todos los archivos y construir tabla larga
# ---------------------------------------------------------

resistome_long <- map_dfr(rgi_files, read_rgi_file)

cat("Total detecciones AMR:", nrow(resistome_long), "\n")

# ---------------------------------------------------------
# 5. Limpieza: eliminar posibles NA en Genome
# ---------------------------------------------------------

resistome_long <- resistome_long %>%
  filter(!is.na(Genome))

cat("Genomas únicos con al menos 1 gen detectado:",
    length(unique(resistome_long$Genome)), "\n")

# --------------------------------------------------------
# 6. Construcción de matriz binaria (presencia/ausencia)
# --------------------------------------------------------

resistome_matrix <- resistome_long %>%
  mutate(Presence = 1) %>%
  distinct() %>%
  pivot_wider(
    names_from = Gene,
    values_from = Presence,
    values_fill = 0
  )

cat("Dimensiones matriz sin filtrar QC:", dim(resistome_matrix), "\n")

# ---------------------------------------------------------
# 7. Filtrar por control de calidad (QC)
# ---------------------------------------------------------

qc_genomes <- readLines(qc_path)

# Extraer Assembly ID desde nombres largos del QC
qc_assembly <- str_extract(qc_genomes,
                           "G(CA|CF)_\\d+\\.\\d+")

# Filtrar matriz
resistome_matrix_qc <- resistome_matrix %>%
  filter(Genome %in% qc_assembly)

cat("Genomas que pasan QC y tienen genes AMR:",
    nrow(resistome_matrix_qc), "\n")

# ---------------------------------------------------------
# 8. Guardar resultados
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

cat("Matrices guardadas correctamente.\n")

# =========================================================
# FIN DEL SCRIPT
# =========================================================


matriz_qc <- read.delim("data/processed/resistome_matrix_binary_QC.tsv")
dim(matriz_qc)
