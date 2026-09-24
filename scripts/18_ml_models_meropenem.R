# ===========================================================
# 18_ml_models_meropenem.R
# Machine learning models for meropenem resistance prediction
# ===========================================================

source("scripts/00_config.R")

# ---------------------------------------------------------
# Load Machine Learning dataset
# ---------------------------------------------------------

dataset <- read_tsv(
  "data/processed/ml_dataset_meropenem.tsv",
  show_col_types = FALSE
)

dataset$Phenotype <- factor(
  dataset$Phenotype,
  levels = c("Resistant", "Susceptible")
)

cat("\n========== DATASET ==========\n")
cat("Genomes:", nrow(dataset), "\n")
cat("Predictive variables:", ncol(dataset)-3, "\n")

# =========================================================
# Prepare predictor matrix
# =========================================================

ml_data <- dataset %>%
  dplyr::select(-Genome, -ST)

X <- ml_data %>%
  dplyr::select(-Phenotype)

y <- ml_data$Phenotype

# Verify class order
stopifnot(
  identical(
    levels(y),
    c("Resistant", "Susceptible")
  )
)

# =========================================================
# Train-test split
# =========================================================

set.seed(123)

train_index <- createDataPartition(
  y,
  p = 0.70,
  list = FALSE
)

X_train <- X[train_index, ]
X_test  <- X[-train_index, ]

y_train <- y[train_index]
y_test  <- y[-train_index]

cat("\nTraining set\n")
print(table(y_train))

cat("\nTesting set\n")
print(table(y_test))


# =========================================================
# Random Forest
# =========================================================
# ---------------------------------------------------------
# Cross-validation settings
# ---------------------------------------------------------
ctrl <- trainControl(
  method = "cv",
  number = 5,
  classProbs = TRUE,
  savePredictions = "final"
)
# ---------------------------------------------------------
# Train model
# ---------------------------------------------------------
rf_model <- train(
  x = X_train,
  y = y_train,
  method = "rf",
  trControl = ctrl,
  importance = TRUE,
  ntree = 500
)
# ---------------------------------------------------------
# Predictions
# ---------------------------------------------------------
rf_pred <- predict(rf_model, X_test)
rf_prob <- predict(rf_model, X_test, type = "prob")[, "Resistant"]
# ---------------------------------------------------------
# Model evaluation
# ---------------------------------------------------------
rf_cm <- confusionMatrix(rf_pred, y_test)
rf_precision <- rf_cm$byClass["Pos Pred Value"]
rf_recall    <- rf_cm$byClass["Sensitivity"]
rf_f1 <- 2 * (rf_precision * rf_recall) / (rf_precision + rf_recall)
rf_roc <- roc(
  response = y_test,
  predictor = rf_prob,
  levels = c("Susceptible", "Resistant")
)

rf_auc <- as.numeric(auc(rf_roc))

# ---------------------------------------------------------
# Save evaluation metrics
# ---------------------------------------------------------
rf_metrics <- list(

  Accuracy = unname(rf_cm$overall["Accuracy"]),
  Balanced_Accuracy = unname(rf_cm$byClass["Balanced Accuracy"]),
  Sensitivity = unname(rf_cm$byClass["Sensitivity"]),
  Specificity = unname(rf_cm$byClass["Specificity"]),
  Precision = unname(rf_cm$byClass["Pos Pred Value"]),
  F1 = unname(rf_f1),
  Kappa = unname(rf_cm$overall["Kappa"]),
  AUC = unname(rf_auc)
)
# ---------------------------------------------------------
# Save predictions
# ---------------------------------------------------------
rf_predictions <- list(
  truth = y_test,
  predicted = rf_pred,
  probability = rf_prob
)
# ---------------------------------------------------------
# Console output
# ---------------------------------------------------------

print(rf_model)
print(rf_cm)
print(rf_metrics)
# =========================================================
# XGBoost
# =========================================================
# ---------------------------------------------------------
# Prepare DMatrix
# ---------------------------------------------------------
train_matrix <- xgb.DMatrix(
  data = as.matrix(X_train),
  label = as.numeric(y_train) - 1
)

test_matrix <- xgb.DMatrix(
  data = as.matrix(X_test),
  label = as.numeric(y_test) - 1
)
# ---------------------------------------------------------
# Cross-validation
# ---------------------------------------------------------
params <- list(
  objective = "binary:logistic",
  eta = 0.3,
  max_depth = 6,
  subsample = 0.8,
  colsample_bytree = 0.8,
  eval_metric = "logloss"
)

cv_model <- xgb.cv(
  params = params,
  data = train_matrix,
  nrounds = 500,
  nfold = 5,
  early_stopping_rounds = 20,
  verbose = 0
)

best_nrounds <- cv_model$early_stop$best_iteration

cat("\nBest number of boosting rounds:", best_nrounds, "\n")

# ---------------------------------------------------------
# Train final model
# ---------------------------------------------------------
xgb_model <- xgb.train(
  params = params,
  data = train_matrix,
  nrounds = best_nrounds,
  verbose = 0
)
# ---------------------------------------------------------
# Predictions
# ---------------------------------------------------------
xgb_prob <- predict(xgb_model, test_matrix)

xgb_pred <- factor(
  ifelse(xgb_prob >= 0.5,
         "Susceptible",
         "Resistant"),
  levels = levels(y_test)
)
# ---------------------------------------------------------
# Model evaluation
# ---------------------------------------------------------
xgb_cm <- confusionMatrix(xgb_pred, y_test)
xgb_precision <- xgb_cm$byClass["Pos Pred Value"]
xgb_recall    <- xgb_cm$byClass["Sensitivity"]
xgb_f1 <- 2 * (xgb_precision * xgb_recall) / (xgb_precision + xgb_recall)
xgb_roc <- roc(
  response = y_test,
  predictor = xgb_prob,
  levels = c("Susceptible", "Resistant")
)

xgb_auc <- as.numeric(auc(xgb_roc))

# ---------------------------------------------------------
# Save evaluation metrics
# ---------------------------------------------------------
xgb_metrics <- list(

  Accuracy = unname(xgb_cm$overall["Accuracy"]),
  Balanced_Accuracy = unname(xgb_cm$byClass["Balanced Accuracy"]),
  Sensitivity = unname(xgb_cm$byClass["Sensitivity"]),
  Specificity = unname(xgb_cm$byClass["Specificity"]),
  Precision = unname(xgb_cm$byClass["Pos Pred Value"]),
  F1 = unname(xgb_f1),
  Kappa = unname(xgb_cm$overall["Kappa"]),
  AUC = unname(xgb_auc)
)
# ---------------------------------------------------------
# Save predictions
# ---------------------------------------------------------
xgb_predictions <- list(
  truth = y_test,
  predicted = xgb_pred,
  probability = xgb_prob
)
# ---------------------------------------------------------
# Console output
# ---------------------------------------------------------

print(xgb_model)
print(xgb_cm)
print(xgb_metrics)

# =========================================================
# Model comparison
# =========================================================

cat("\n==============================\n")
cat("Model comparison\n")
cat("==============================\n")

cat("\nRandom Forest\n")

cat("Accuracy:",
    round(rf_metrics$Accuracy, 4), "\n")
cat("Balanced Accuracy:",
    round(rf_metrics$Balanced_Accuracy, 4), "\n")
cat("Sensitivity:",
    round(rf_metrics$Sensitivity, 4), "\n")
cat("Specificity:",
    round(rf_metrics$Specificity, 4), "\n")
cat("Precision:",
    round(rf_metrics$Precision, 4), "\n")
cat("F1-score:",
    round(rf_metrics$F1, 4), "\n")
cat("AUC:",
    round(rf_metrics$AUC, 4), "\n")
cat("Kappa:",
    round(rf_metrics$Kappa, 4), "\n")

cat("\nXGBoost\n")

cat("Accuracy:",
    round(xgb_metrics$Accuracy, 4), "\n")
cat("Balanced Accuracy:",
    round(xgb_metrics$Balanced_Accuracy, 4), "\n")
cat("Sensitivity:",
    round(xgb_metrics$Sensitivity, 4), "\n")
cat("Specificity:",
    round(xgb_metrics$Specificity, 4), "\n")
cat("Precision:",
    round(xgb_metrics$Precision, 4), "\n")
cat("F1-score:",
    round(xgb_metrics$F1, 4), "\n")
cat("AUC:",
    round(xgb_metrics$AUC, 4), "\n")
cat("Kappa:",
    round(xgb_metrics$Kappa, 4), "\n")

# =========================================================
# Save results
# =========================================================

## Random Forest

saveRDS(rf_model, file.path(ml_models_dir, "random_forest_meropenem.rds"))
saveRDS(rf_metrics, file.path(ml_models_dir, "random_forest_meropenem_metrics.rds"))
saveRDS(rf_predictions, file.path(ml_models_dir, "random_forest_meropenem_predictions.rds"))
saveRDS(rf_roc, file.path(ml_models_dir, "random_forest_meropenem_roc.rds"))

## XGBoost

saveRDS(xgb_model, file.path(ml_models_dir, "xgboost_meropenem.rds"))
saveRDS(xgb_metrics, file.path(ml_models_dir,"xgboost_meropenem_metrics.rds"))
saveRDS(xgb_predictions, file.path(ml_models_dir, "xgboost_meropenem_predictions.rds"))
saveRDS(xgb_roc, file.path(ml_models_dir, "xgboost_meropenem_roc.rds"))

cat("\n=====================================\n")
cat("Meropenem machine learning completed\n")
cat("=====================================\n")
cat("\nResults saved in:\n")
cat(ml_models_dir, "\n")
