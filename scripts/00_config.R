# =========================================================
# 00_config.R
# Configuración global del proyecto
# =========================================================

# =========================
# Librerías
# =========================

library(tidyverse)
library(data.table)

library(caret)
library(randomForest)
library(xgboost)

library(pROC)
library(MLmetrics)

library(themis)

library(reshape2)

# =========================
# Directorio del proyecto
# =========================

project_dir <- "~/Bioinformatica/TFM_Leslie"

# =========================
# Rutas
# =========================

data_dir <- file.path(project_dir, "data")

raw_dir <- file.path(data_dir, "raw")
processed_dir <- file.path(data_dir, "processed")

genomes_dir <- file.path(raw_dir, "genomes")
proteins_dir <- file.path(raw_dir, "proteins")

results_dir <- file.path(project_dir, "results")
figures_dir <- file.path(project_dir, "figures")

rgi_dir <- file.path(results_dir, "rgi")
qc_dir <- file.path(results_dir, "qc")
models_dir <- file.path(results_dir, "models")

# =========================
# Opciones R
# =========================

options(stringsAsFactors = FALSE)

message("Configuración del proyecto cargada correctamente")
