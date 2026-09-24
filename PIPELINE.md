# Bioinformatic Analysis Pipeline

This document describes the complete bioinformatic workflow developed for the Master's Thesis:

**Prediction of antimicrobial resistance phenotype in *Klebsiella pneumoniae* using machine learning models based on genomic data.**

---

##  1. Phenotype data retrieval

Phenotypic antimicrobial susceptibility data were obtained from the BV-BRC database.

Search criteria:

- Organism: *Klebsiella pneumoniae*
- Antibiotics:
  - Meropenem
  - Imipenem

Filters applied:

- Resistant
- Susceptible
- Laboratory evidence

Outputs:

```
data/raw/
data/processed/
```

Scripts:

```
01_download_metadata_meropenem.R
02_download_metadata_imipenem.R
```

---

## 2. Genome ID extraction

Unique Genome IDs were extracted from the curated phenotype datasets.

Script:

```
03_extract_genome_ids.R
```

Outputs:

```
data/processed/meropenem_genome_ids.txt
data/processed/imipenem_genome_ids.txt
```

---

## 3. Assembly mapping

Genome IDs were mapped to Assembly Accessions using the BV-BRC genome metadata.

Script:

```
04_map_genome_to_assembly.R
```

Outputs:

```
data/processed/meropenem_with_assembly.tsv
data/processed/imipenem_with_assembly.tsv
```

---

## 4. Genome quality filtering

Assemblies were filtered according to predefined assembly quality criteria.

Criteria:

- Genome size: 5.0–6.5 Mb
- Contigs < 300
- N50 > 20,000 bp

Script:

```
05_filter_genomes_before_download.R
```

Outputs:

```
data/processed/meropenem_filtered_genomes.tsv
data/processed/imipenem_filtered_genomes.tsv
```
---

## 5. Assembly selection

Duplicated assemblies were removed.

When both RefSeq (GCF) and GenBank (GCA) versions were available, RefSeq assemblies were preferentially retained.

Scripts:

```
06_0_prepare_download_list.R
06_1_merge_download_lists.sh
```

Outputs:

```
data/processed/meropenem_assembly_list.txt
data/processed/imipenem_assembly_list.txt
data/processed/all_assemblies.txt
```

---

## 6. Genome download

Genomes were downloaded from NCBI using NCBI Datasets.

Script:

```
07_download_genomes.sh
```

Output:

```
data/raw/genomes/
```

---

## 7. ORF prediction and AMR detection

Protein coding sequences were predicted using Prodigal.
AMR determinants were identified using:

- RGI
- CARD database
- DIAMOND

Script:

```
08_run_rgi.sh
```

Output:

```
data/raw/proteins/
results/rgi/rgi_results/
```

---

## 8. Resistome construction

A binary presence/absence resistome matrix was generated from the RGI output.

Script:

```
09_build_resistome_matrix.R
```
Output:

```
data/processed/resistome_matrix_binary_QC.tsv
```

---

## 9. Resistome curation

Gene annotations were harmonized.
Duplicated annotations were merged.
Invariant genes were removed.

Script:

```
10_clean_resistome_matrix.R
```

Output:

```
data/processed/resistome_matrix_clean.tsv
```

---

## 10. Exploratory resistome analysis

The curated resistome matrix was used for exploratory multivariate and clustering analyses.

Scripts:

```
11_resistome_pca_global.R
12_resistome_pca_by_phenotype.R
13_resistome_amr_gene_freq.R
14_resistome_pcoa.R
15_resistome_heatmap_clustering.R
```

Outputs:
```
results/resistome/
```

Main figures generated:

```
results/resistome/resistome_global_pca.png
results/resistome/resistome_pca_by_phenotype.png
results/resistome/resistome_amr_gene_frequency.png
results/resistome/resistome_PCoA.png
results/resistome/resistome_heatmap.png
```
---

## 11. MLST typing

Multilocus sequence typing was performed on the genome collection.

Scripts:

```
16_0_mlst_typing.sh
16_1_mlst_frequency.R
```

Outputs:
```
results/mlst/mlst_results.tsv
results/resistome/mlst_frequency.png
``
---

## 12. Machine Learning dataset preparation

Phenotypic data and the curated resistome matrix were integrated to generate the datasets used for Machine Learning.

Scripts:

```
17_prepare_ml_dataset.R
```

Outputs:

```
data/processed/ml_dataset_meropenem.tsv
data/processed/ml_dataset_imipenem.tsv
```

---

## 13. Machine Learning

Independent models were developed for each carbapenem.

Scripts:

```
18_ml_models_meropenem.R
19_ml_models_imipenem.R
```

Algorithms:

- Random Forest
- XGBoost

Model outputs:
```
results/machine_learning/models/
```

The directory contains trained models, model metrics, predictions and ROC objects forboth carbapenems.

---

## 14. Model evaluation

The trained models were evaluated using the saved model objects, predictions and ROC data.

Script:

```
20_model_evaluation.R
```

Evaluation metrics:

- Confusion Matrix
- Accuracy
- Balanced Accuracy
- Sensitivity
- Specificity
- Precision
- F1-score
- Kappa
- ROC AUC
- Feature importance

Outputs:
```
results/machine_learning/tables/model_performance.tsv
results/machine_learning/figures/
```

Main figures generated:
```
results/machine_learning/figures/roc_curves.png
results/machine_learning/figures/rf_variable_importance_meropenem.png
results/machine_learning/figures/rf_variable_importance_imipenem.png
results/machine_learning/figures/xgb_variable_importance_meropenem.png
results/machine_learning/figures/xgb_variable_importance_imipenem.png
```

---

## Reproducibility

All scripts were designed to be executed sequentially.

The recommended execution order is:

```
01
↓

02
↓

03

...

↓

20
```

Following this order reproduces the complete bioinformatic workflow from phenotype data processing through resistome characterization, MLST typing, Machine Learning modeldevelopment and model evaluation.
```
The repository excludes raw and processed datasets, analysis results and local databases from version control. Software requirements and installation instructions are provided in environment.md and install_packages.md.
```
