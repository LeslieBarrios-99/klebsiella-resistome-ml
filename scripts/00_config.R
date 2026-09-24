# =========================================================
# 00_config.R
# Global project configuration
# =========================================================

# ========================================================
# Libraries
# ========================================================

library(tidyverse)
library(data.table)

library(caret)
library(randomForest)
library(xgboost)

library(pROC)
library(MLmetrics)

library(themis)

library(reshape2)

# ========================================================
# Project directory
# ========================================================

project_dir <- getwd()

# ========================================================
# Paths
# ========================================================

data_dir <- file.path(project_dir, "data")

raw_dir <- file.path(data_dir, "raw")
processed_dir <- file.path(data_dir, "processed")

genomes_dir <- file.path(raw_dir, "genomes")
proteins_dir <- file.path(raw_dir, "proteins")

results_dir <- file.path(project_dir, "results")

rgi_dir <- file.path(results_dir, "rgi")
qc_dir <- file.path(results_dir, "qc")

resistome_dir <- file.path(results_dir, "resistome")
mlst_dir      <- file.path(results_dir, "mlst")

ml_dir <- file.path(results_dir, "machine_learning")
ml_models_dir  <- file.path(ml_dir, "models")
ml_tables_dir  <- file.path(ml_dir, "tables")
ml_figures_dir <- file.path(ml_dir, "figures")


#========================================================
# Create output directories
# ========================================================

dir.create(results_dir, recursive = TRUE, showWarnings = FALSE)

dir.create(rgi_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(qc_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(resistome_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(mlst_dir, recursive = TRUE, showWarnings = FALSE)

dir.create(ml_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(ml_models_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(ml_tables_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(ml_figures_dir, recursive = TRUE, showWarnings = FALSE)


# ========================================================
# R options
# ========================================================

options(stringsAsFactors = FALSE)

message("Project configuration loaded successfully.")