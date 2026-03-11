# =========================================================
# Exploratory analysis of phenotype datasets
# =========================================================

source("scripts/00_config.R")

library(tidyverse)

mer <- read_tsv("data/processed/meropenem_phenotype_clean.tsv")
imi <- read_tsv("data/processed/imipenem_phenotype_clean.tsv")

# -----------------------------------
# phenotype distribution
# -----------------------------------

mer_plot <- mer %>%
  count(Resistant.Phenotype) %>%
  mutate(
    percentage = round(n/sum(n)*100,1),
    label = paste0(n," (",percentage,"%)")
  )

p1 <- ggplot(mer_plot, aes(x=Resistant.Phenotype, y=n, fill=Resistant.Phenotype)) +
  geom_bar(stat="identity", width=0.6) +
  geom_text(aes(label=label), vjust=-0.3, size=5) +
  scale_fill_manual(values=c("#D55E00","#0072B2")) +
  labs(
    title="Meropenem phenotype distribution",
    x="Phenotype",
    y="Number of isolates"
  ) +
  theme_minimal(base_size=14) +
  theme(
    plot.title = element_text(hjust=0.5, face="bold"),
    legend.position="none"
  )

ggsave(
"figures/phenotype_distribution_meropenem_raw.png",
p1,
width=6,
height=5,
dpi=300
)

# -----------------------------------

imi_plot <- imi %>%
  count(Resistant.Phenotype) %>%
  mutate(
    percentage = round(n/sum(n)*100,1),
    label = paste0(n," (",percentage,"%)")
  )

p2 <- ggplot(imi_plot, aes(x=Resistant.Phenotype, y=n, fill=Resistant.Phenotype)) +
  geom_bar(stat="identity", width=0.6) +
  geom_text(aes(label=label), vjust=-0.3, size=5) +
  scale_fill_manual(values=c("#D55E00","#0072B2")) +
  labs(
    title="Imipenem phenotype distribution",
    x="Phenotype",
    y="Number of isolates"
  ) +
  theme_minimal(base_size=14) +
  theme(
    plot.title = element_text(hjust=0.5, face="bold"),
    legend.position="none"
  )

ggsave(
"figures/phenotype_distribution_imipenem_raw.png",
p2,
width=6,
height=5,
dpi=300
)
