#!/bin/bash

# ========================================
# Predicción ORFs con Prodigal
# ========================================

GENOMES_DIR="data/raw/genomes"
PROTEINS_DIR="data/raw/proteins"

mkdir -p $PROTEINS_DIR

for genome in $GENOMES_DIR/*.fna
do
    base=$(basename $genome .fna)

    echo "Running prodigal on $base"

    prodigal \
        -i $genome \
        -a $PROTEINS_DIR/${base}.faa \
        -p single
done
