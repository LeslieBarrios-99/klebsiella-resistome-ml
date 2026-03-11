# Resistome Analysis of *Klebsiella pneumoniae* Associated with Carbapenem Resistance

**Master Thesis – Leslie Barrios**

## Overview

This project investigates the genomic determinants associated with resistance to carbapenems in *Klebsiella pneumoniae*, focusing on two clinically relevant antibiotics:

- **Meropenem**
- **Imipenem**

The study integrates:

- Phenotypic antimicrobial susceptibility data
- Whole genome sequences
- Resistome profiles inferred using the **CARD database**

Machine learning models are used to evaluate the predictive capacity of genomic resistance determinants for antimicrobial resistance phenotypes.

## Bioinformatic Workflow

![Pipeline workflow](figures/Pipeline_workflow.png)

## Pipeline Overview

1. Retrieval of phenotypic data from **BV-BRC**
2. Download of genomes from **NCBI**
3. ORF prediction with **Prodigal**
4. Identification of AMR genes using **RGI (CARD)**
5. Genomic quality control
6. Construction of resistome binary matrix
7. Exploratory analysis (PCA)
8. MLST lineage typing
9. Detection of chromosomal resistance mutations
10. Machine learning models
11. Model evaluation

## Project Structure

## Project Structure

```
TFM_Leslie/
│
├── scripts/        # Reproducible analysis scripts
├── data/           # Raw and processed datasets
├── databases/      # AMR reference databases
├── results/        # Analysis outputs
├── figures/        # Figures generated for the thesis
│
├── README.md
├── PIPELINE.md
├── environment.md
└── install_packages.md
```

## Reproducibility

All analyses were performed using a reproducible bioinformatic pipeline available in the **scripts/** directory.

The complete workflow is described in:

**PIPELINE.md**


## Environment

To reproduce this analysis see:

- **environment.md** → Conda environment and bioinformatics tools
- **install_packages.md** → R package installation

## Author

**Leslie Barrios**  
Master's Program in Bioinformatics
