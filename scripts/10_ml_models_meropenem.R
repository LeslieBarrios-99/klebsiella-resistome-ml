# =========================================================
# 10_ml_models_meropenem.R
# Machine learning models for resistome prediction
# =========================================================

source("scripts/00_config.R")

library(tidyverse)
library(caret)
library(randomForest)
library(xgboost)

# ---------------------------------------------------------
# Load data
# ---------------------------------------------------------

resistome <- read_tsv("data/processed/resistome_matrix_binary_QC.tsv")

phenotype <- read_tsv("data/raw/meropenem_tablageneral.csv")

dataset <- resistome %>%
  left_join(phenotype, by="Assembly_Accession") %>%
  filter(!is.na(Resistant_Phenotype))

dataset$Resistant_Phenotype <- as.factor(dataset$Resistant_Phenotype)

# ---------------------------------------------------------
# Prepare matrix
# ---------------------------------------------------------

X <- dataset %>%
  select(-Assembly_Accession, -Resistant_Phenotype)

y <- dataset$Resistant_Phenotype

# ---------------------------------------------------------
# Train test split
# ---------------------------------------------------------

set.seed(123)

trainIndex <- createDataPartition(y, p=0.8, list=FALSE)

X_train <- X[trainIndex,]
X_test <- X[-trainIndex,]

y_train <- y[trainIndex]
y_test <- y[-trainIndex]

# ---------------------------------------------------------
# Random Forest
# ---------------------------------------------------------

rf_model <- randomForest(
  x=X_train,
  y=y_train,
  ntree=500,
  importance=TRUE
)

rf_pred <- predict(rf_model, X_test)

rf_cm <- confusionMatrix(rf_pred, y_test)

print(rf_cm)

# ---------------------------------------------------------
# Logistic Regression
# ---------------------------------------------------------

glm_model <- train(
  x=X_train,
  y=y_train,
  method="glm",
  family="binomial"
)

glm_pred <- predict(glm_model, X_test)

glm_cm <- confusionMatrix(glm_pred, y_test)

print(glm_cm)

# ---------------------------------------------------------
# XGBoost
# ---------------------------------------------------------

xgb_model <- train(
  x=X_train,
  y=y_train,
  method="xgbTree",
  trControl=trainControl(method="cv",number=5)
)

xgb_pred <- predict(xgb_model, X_test)

xgb_cm <- confusionMatrix(xgb_pred, y_test)

print(xgb_cm)
