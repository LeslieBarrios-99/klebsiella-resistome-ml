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

Output:

```
data/raw/
```

Scripts:

```
01_download_metadata_meropenem.R
02_download_metadata_imipenem.R
```

---

## 2. Genome ID extraction

Unique Genome IDs were extracted from each phenotype dataset.

Script:

```
03_extract_genome_ids.R
```

Output:

```
meropenem_genome_ids.txt
imipenem_genome_ids.txt
```

---

## 3. Assembly mapping

Genome IDs were mapped to Assembly Accessions using the BV-BRC genome metadata.

Script:

```
04_map_genome_to_assembly.R
```

Output:

```
meropenem_with_assembly.tsv
imipenem_with_assembly.tsv
```

---

## 4. Genome quality filtering

Assemblies were filtered according to assembly quality.

Criteria

- Genome size: 5.0–6.5 Mb
- Contigs < 300
- N50 > 20,000 bp

Script

```
05_filter_genomes_before_download.R
```

---

## 5. Assembly selection

Duplicated assemblies were removed.

When both RefSeq (GCF) and GenBank (GCA) versions were available, RefSeq assemblies were preferentially retained.

Scripts

```
06_0_prepare_download_list.R
06_1_merge_download_lists.sh
```

Output

```
all_assemblies.txt
```

---

## 6. Genome download

Genomes were downloaded from NCBI using NCBI Datasets.

Script

```
07_download_genomes.sh
```

Output

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

Script

```
08_run_rgi.sh
```

Output

```
results/rgi/
```

---

## 8. Resistome construction

A binary presence/absence resistome matrix was generated from the RGI output.

Script

```
09_build_resistome_matrix.R
```

---

## 9. Resistome curation

Gene annotations were harmonized.
Duplicated annotations were merged.
Invariant genes were removed.

Script

```
10_clean_resistome_matrix.R
```

Output

```
resistome_matrix_clean.tsv
```

---

## 10. Exploratory resistome analysis

Scripts

```
11_resistome_pca_global.R
12_resistome_pca_by_phenotype.R
13_resistome_amr_gene_freq.R
14_resistome_pcoa.R
15_resistome_heatmap_clustering.R
```

Analyses

- Global PCA
- PCA by phenotype
- AMR gene frequency
- PCoA
- Hierarchical clustering
- Heatmap

---

## 11. MLST typing

Scripts

```
16_0_mlst_typing.sh
16_1_mlst_frequency.R
```

Output

- Sequence Types
- MLST frequency distribution

---

## 12. Machine Learning dataset preparation

Phenotype + Curated resistome + MLST -> Final datasets

Scripts

```
17_prepare_ml_dataset.R
```

Outputs

```
ml_dataset_meropenem.tsv
ml_dataset_imipenem.tsv
```

---

## 13. Machine Learning

Independent models were developed for each carbapenem.

Scripts

```
18_ml_models_meropenem.R
19_ml_models_imipenem.R
```

Algorithms

- Random Forest
- XGBoost

---

## 14. Model evaluation

Script

```
20_model_evaluation.R
```

Evaluation metrics

- Confusion Matrix
- ROC
- AUC
- Precision
- Recall
- F1-score
- MCC
- Feature importance

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

Following this order reproduces the complete bioinformatic workflow from raw phenotype data to machine learning model evaluation.
