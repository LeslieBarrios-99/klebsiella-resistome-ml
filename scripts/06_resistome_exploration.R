# =========================================================
# Exploración resistoma
# =========================================================

source("scripts/00_config.R")

matrix <- fread("data/processed/resistome_matrix_binary_QC.tsv")

mat <- matrix %>% select(-Assembly_Accession)

pca <- prcomp(mat, scale.=TRUE)

pca_df <- as.data.frame(pca$x)
pca_df$Assembly_Accession <- matrix$Assembly_Accession

var_exp <- summary(pca)$importance[2,1:2]*100

ggplot(pca_df, aes(PC1,PC2))+
  geom_point(alpha=0.6,size=1.8)+
  theme_minimal(base_size=14)+
  labs(
    title="Estructura global del resistoma en K. pneumoniae",
    x=paste0("PC1 (",round(var_exp[1],1),"%)"),
    y=paste0("PC2 (",round(var_exp[2],1),"%)")
  )

ggsave("figures/meropenem/pca_resistome.png", width=8, height=6)
