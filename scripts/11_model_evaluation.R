# =========================================================
# Evaluación modelo
# =========================================================

library(pROC)

roc_obj <- roc(test$Resistant_Phenotype, as.numeric(pred))

plot(roc_obj)

auc(roc_obj)
