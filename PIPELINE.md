# Analysis Pipeline

## 1 Phenotype data retrieval

Phenotypic antimicrobial susceptibility data were obtained from the BV-BRC database.

Search criteria:

Organism: Klebsiella pneumoniae

Antibiotics:
- Meropenem
- Imipenem

Filters applied:

- Resistance phenotype: Resistant or Susceptible
- Evidence: Laboratory method  

Initial dataset size (Meropenem):

- 4328 phenotype records
- 4269 unique strains

Output:

data/raw/meropenem_tablageneral.csv

---

## 2 Genome download

scripts/01_download_genomes.sh

Output:

data/raw/genomes/

---

## 3 ORF prediction

scripts/02_predict_orfs_prodigal.sh

Tool: Prodigal

Output:

data/raw/proteins/

---

## 4 AMR gene identification

scripts/03_run_rgi.sh

Tool: RGI (CARD database)

Output:

results/rgi/

---

## 5 Genome quality control

scripts/04_quality_control_genomes.sh

Criteria:

Genome size: 5–6.5 Mb  
Contigs < 300  
N50 > 20000

Output:

results/qc/genomes_valid.txt

---

## 6 Resistome matrix construction

scripts/05_build_resistome_matrix.R

Output:

data/processed/resistome_matrix_binary_QC.tsv

---

## 7 Exploratory analysis

scripts/06_resistome_exploration.R

Methods:

PCA  
Clustering  
Heatmaps

---

## 8 MLST typing

scripts/07_mlst_typing.sh

---

## 9 Chromosomal mutations

scripts/08_detect_chromosomal_mutations.R

Targets:

ompK35  
ompK36  
mgrB

---

## 10 Machine learning models

scripts/10_ml_models_meropenem.R  
scripts/10_ml_models_imipenem.R

Models:

- Random Forest  
- XGBoost
- Logistic Regression

Model training and tuning were performed using the `caret` framework

---

## 11 Model evaluation

scripts/11_model_evaluation.R
