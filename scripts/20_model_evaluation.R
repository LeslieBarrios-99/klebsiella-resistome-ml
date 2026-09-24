# ===========================================================
# 20_model_evaluation.R
# Model evaluation and visualization
# ===========================================================

source("scripts/00_config.R")

# =========================================================
# Load saved machine learning results
# =========================================================
## -------------------------
## Random Forest
## -------------------------
rf_mero_model <- readRDS(file.path(ml_models_dir,
    "random_forest_meropenem.rds"))
rf_mero_metrics <- readRDS(file.path(ml_models_dir,
    "random_forest_meropenem_metrics.rds"))
rf_mero_predictions <- readRDS(file.path(ml_models_dir,
    "random_forest_meropenem_predictions.rds"))
rf_mero_roc <- readRDS(file.path(ml_models_dir,
    "random_forest_meropenem_roc.rds"))
rf_imi_model <- readRDS(file.path(ml_models_dir,
    "random_forest_imipenem.rds"))
rf_imi_metrics <- readRDS(file.path(ml_models_dir,
    "random_forest_imipenem_metrics.rds"))
rf_imi_predictions <- readRDS(file.path(ml_models_dir,
    "random_forest_imipenem_predictions.rds"))
rf_imi_roc <- readRDS(file.path(ml_models_dir,
    "random_forest_imipenem_roc.rds"))

## -------------------------
## XGBoost
## -------------------------

xgb_mero_model <- readRDS(file.path(ml_models_dir,
    "xgboost_meropenem.rds"))
xgb_mero_metrics <- readRDS(file.path(ml_models_dir,
    "xgboost_meropenem_metrics.rds"))
xgb_mero_predictions <- readRDS(file.path(ml_models_dir,
    "xgboost_meropenem_predictions.rds"))
xgb_mero_roc <- readRDS(file.path(ml_models_dir,
    "xgboost_meropenem_roc.rds"))
xgb_imi_model <- readRDS(file.path(ml_models_dir,
    "xgboost_imipenem.rds"))
xgb_imi_metrics <- readRDS(file.path(ml_models_dir,
    "xgboost_imipenem_metrics.rds"))
xgb_imi_predictions <- readRDS(file.path(ml_models_dir,
    "xgboost_imipenem_predictions.rds"))
xgb_imi_roc <- readRDS(file.path(ml_models_dir,
    "xgboost_imipenem_roc.rds"))

cat("\n====================================\n")
cat("Machine learning results loaded\n")
cat("====================================\n")

cat("\nRandom Forest\n")
cat("- Meropenem\n")
cat("- Imipenem\n")

cat("\nXGBoost\n")
cat("- Meropenem\n")
cat("- Imipenem\n")

# =========================================================
# Create model performance table
# =========================================================

model_performance <- tibble(

  Antibiotic = c(
    "Meropenem",
    "Meropenem",
    "Imipenem",
    "Imipenem"
  ),

  Model = c(
    "Random Forest",
    "XGBoost",
    "Random Forest",
    "XGBoost"
  ),

  Accuracy = c(
    rf_mero_metrics$Accuracy,
    xgb_mero_metrics$Accuracy,
    rf_imi_metrics$Accuracy,
    xgb_imi_metrics$Accuracy
  ),

  Balanced_Accuracy = c(
    rf_mero_metrics$Balanced_Accuracy,
    xgb_mero_metrics$Balanced_Accuracy,
    rf_imi_metrics$Balanced_Accuracy,
    xgb_imi_metrics$Balanced_Accuracy
  ),

  Sensitivity = c(
    rf_mero_metrics$Sensitivity,
    xgb_mero_metrics$Sensitivity,
    rf_imi_metrics$Sensitivity,
    xgb_imi_metrics$Sensitivity
  ),

  Specificity = c(
    rf_mero_metrics$Specificity,
    xgb_mero_metrics$Specificity,
    rf_imi_metrics$Specificity,
    xgb_imi_metrics$Specificity
  ),

  Precision = c(
    rf_mero_metrics$Precision,
    xgb_mero_metrics$Precision,
    rf_imi_metrics$Precision,
    xgb_imi_metrics$Precision
  ),

  F1 = c(
    rf_mero_metrics$F1,
    xgb_mero_metrics$F1,
    rf_imi_metrics$F1,
    xgb_imi_metrics$F1
  ),

  Kappa = c(
    rf_mero_metrics$Kappa,
    xgb_mero_metrics$Kappa,
    rf_imi_metrics$Kappa,
    xgb_imi_metrics$Kappa
  ),

  AUC = c(
    rf_mero_metrics$AUC,
    xgb_mero_metrics$AUC,
    rf_imi_metrics$AUC,
    xgb_imi_metrics$AUC
  )
)

model_performance <- model_performance %>%
  mutate(
    across(
      where(is.numeric),
      ~ round(.x, 4)
    )
  )
print(model_performance)
# =========================================================
# Save performance table
# =========================================================

write_tsv(
  model_performance,
  file.path(
    ml_tables_dir,
    "model_performance.tsv"))


cat("\nPerformance table saved:\n")
cat(file.path(ml_tables_dir,"model_performance.tsv"),"\n")

# =========================================================
# Plot ROC curves
# =========================================================
# ---------------------------------------------------------
# Prepare ROC data
# ---------------------------------------------------------
## Meropenem

roc_mero <- bind_rows(

  tibble(
    False_Positive_Rate = 1 - rf_mero_roc$specificities,
    True_Positive_Rate = rf_mero_roc$sensitivities,
    Model = "Random Forest"
  ),
  tibble(
    False_Positive_Rate = 1 - xgb_mero_roc$specificities,
    True_Positive_Rate = xgb_mero_roc$sensitivities,
    Model = "XGBoost"
  )
) %>%
  mutate(
    Antibiotic = "Meropenem"
  )

## Imipenem

roc_imi <- bind_rows(

  tibble(
    False_Positive_Rate = 1 - rf_imi_roc$specificities,
    True_Positive_Rate = rf_imi_roc$sensitivities,
    Model = "Random Forest"
  ),
  tibble(
    False_Positive_Rate = 1 - xgb_imi_roc$specificities,
    True_Positive_Rate = xgb_imi_roc$sensitivities,
    Model = "XGBoost"
  )
) %>%
  mutate(
    Antibiotic = "Imipenem"
  )

## Combine both antibiotics

roc_data <- bind_rows(
  roc_mero,
  roc_imi
)

print(head(roc_data))
# =========================================================
# Figure theme
# =========================================================

theme_tfm <- theme_bw(base_size = 12) +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold", size = 14),
    axis.title = element_text(face = "bold"),
    axis.text = element_text(colour = "black"),
    panel.border = element_rect(colour = "black", fill = NA, linewidth = 0.8),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    strip.background = element_rect(colour = "black", fill = "white"),
    strip.text = element_text(face = "bold"),
    legend.position = "bottom",
    legend.title = element_text(face = "bold")
  )

## Panel order
roc_data$Antibiotic <- factor(
  roc_data$Antibiotic,
  levels = c("Meropenem","Imipenem")
)

## ROC plot
roc_plot <- ggplot(
  roc_data,
  aes(
    x = False_Positive_Rate,
    y = True_Positive_Rate,
    colour = Model)
) +
  geom_line(linewidth = 1.2) +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed",  colour = "grey70") +
  facet_wrap(~ Antibiotic, nrow = 1) +
  scale_colour_manual(
    values = c(
      "Random Forest" = "#1F77B4",
      "XGBoost" = "#D55E00")
  ) +
  labs(
    title = "ROC curves for antimicrobial resistance prediction",
    x = "False Positive Rate (1 - Specificity)",
    y = "True Positive Rate (Sensitivity)",
    colour = NULL
  ) +
  coord_equal() +
  theme_tfm

print (roc_plot)

ggsave(
  filename = file.path(
    ml_figures_dir,
    "roc_curves.png"
  ),
  plot = roc_plot,
  width = 10,
  height = 5,
  dpi = 300
)
# =========================================================
# Variable importance
# =========================================================
# ---------------------------------------------------------
# RANDOM FOREST MEROPENEM
# ---------------------------------------------------------

# Extract importance

rf_mero_importance <- varImp(rf_mero_model)
print(rf_mero_importance)

# Convert to dataframe

rf_mero_importance <- rf_mero_importance$importance %>%
  rownames_to_column("Variable") %>%
  as_tibble()

# ---------------------------------------------------------
# Keep a single importance column.
# For this binary classification model, caret::varImp()
# returns identical importance values for both classes.
# Therefore, only one column is retained for plotting.
# ---------------------------------------------------------

rf_mero_importance <- rf_mero_importance %>%
  select(Variable, Importance = Resistant)

# Order variables by importance

rf_mero_importance <- rf_mero_importance %>%
  arrange(desc(Importance))
print(rf_mero_importance)

# Plot
rf_mero_plot <- ggplot(
  rf_mero_importance,
  aes(x = reorder(Variable, Importance), y = Importance)) +
  geom_col(fill = "#1F77B4") +
  coord_flip() +
  scale_x_discrete(limits = rev) +
  labs(
    title = "Random Forest variable importance for meropenem",
    x = NULL,
    y = "Importance"
  ) +
  theme_tfm

print(rf_mero_plot)

# Save figure
ggsave(
  file.path(
    ml_figures_dir,
    "rf_variable_importance_meropenem.png"
  ),
  rf_mero_plot,
  width = 7,
  height = 5,
  dpi = 300
)
# ---------------------------------------------------------
# RANDOM FOREST IMIPENEM
# ---------------------------------------------------------

# Extract importance
rf_imi_importance <- varImp(rf_imi_model)
print(rf_imi_importance)

# Convert to dataframe
rf_imi_importance <- rf_imi_importance$importance %>%
  rownames_to_column("Variable") %>%
  as_tibble()

# ---------------------------------------------------------
# Keep a single importance column.
# For this binary classification model, caret::varImp()
# returns identical importance values for both classes.
# Therefore, only one column is retained for plotting.
# ---------------------------------------------------------

rf_imi_importance <- rf_imi_importance %>%
  select(Variable, Importance = Resistant)

# Order variables

rf_imi_importance <- rf_imi_importance %>%
  arrange(desc(Importance))
print(rf_imi_importance)

# Plot

rf_imi_plot <- ggplot(
  rf_imi_importance,
  aes(x = reorder(Variable, Importance), y = Importance)) +
  geom_col(fill = "#1F77B4") +
  coord_flip() +
  scale_x_discrete(limits = rev) +
  labs(
    title = "Random Forest variable importance for imipenem",
    x = NULL,
    y = "Importance"
  ) +
  theme_tfm

print(rf_imi_plot)

# Save figure
ggsave(
  filename = file.path(ml_figures_dir, "rf_variable_importance_imipenem.png"),
  plot = rf_imi_plot,
  width = 7,
  height = 5,
  dpi = 300
)

# ---------------------------------------------------------
# XGBoost MEROPENEM
# ---------------------------------------------------------

# Extract importance
xgb_mero_importance <- xgb.importance(model = xgb_mero_model)
print(xgb_mero_importance)

# ---------------------------------------------------------
# Plot
# ---------------------------------------------------------

xgb_mero_plot <- ggplot(
  xgb_mero_importance,
  aes(x = reorder(Feature, Gain), y = Gain)) +
  geom_col(fill = "#D55E00") +
  coord_flip() +
  scale_x_discrete(limits = rev) +
  labs(
    title = "XGBoost variable importance for meropenem",
    x = NULL,
    y = "Gain") +
  theme_tfm

print(xgb_mero_plot)

# Save figure
ggsave(
  filename = file.path(ml_figures_dir,"xgb_variable_importance_meropenem.png"),
  plot = xgb_mero_plot,
  width = 7,
  height = 5,
  dpi = 300
)

# ---------------------------------------------------------
# XGBoost IMIPENEM
# ---------------------------------------------------------

# Extract importance
xgb_imi_importance <- xgb.importance(model = xgb_imi_model)
print(xgb_imi_importance)

# ---------------------------------------------------------
# Plot
# ---------------------------------------------------------

xgb_imi_plot <- ggplot(
  xgb_imi_importance,
  aes(x = reorder(Feature, Gain), y = Gain)) +
  geom_col(fill = "#D55E00") +
  coord_flip() +
  scale_x_discrete(limits = rev) +
  labs(
    title = "XGBoost variable importance for imipenem",
    x = NULL,
    y = "Gain") +
  theme_tfm

print(xgb_imi_plot)

# Save figure
ggsave(
  filename = file.path(ml_figures_dir,"xgb_variable_importance_imipenem.png"),
  plot = xgb_imi_plot,
  width = 7,
  height = 5,
  dpi = 300
)

# =========================================================
# Console summary
# =========================================================

cat("\n====================================\n")
cat("Model evaluation completed\n")
cat("====================================\n")

cat("\nTables\n")
cat("-", file.path(ml_tables_dir, "model_performance.tsv"), "\n")

cat("\nFigures\n")
cat("-", file.path(ml_figures_dir, "roc_curves.png"), "\n")
cat("-", file.path(ml_figures_dir, "rf_variable_importance_meropenem.png"), "\n")
cat("-", file.path(ml_figures_dir, "rf_variable_importance_imipenem.png"), "\n")
cat("-", file.path(ml_figures_dir, "xgb_variable_importance_meropenem.png"), "\n")
cat("-", file.path(ml_figures_dir, "xgb_variable_importance_imipenem.png"), "\n")
