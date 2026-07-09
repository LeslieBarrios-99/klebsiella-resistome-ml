#!/bin/bash
set -e
# =========================================================
# 16_mlst_typing.sh
# MLST typing for Klebsiella pneumoniae genomes
# =========================================================

GENOMES="data/raw/genomes/*.fna"
OUTPUT="results/mlst_results.tsv"

mkdir -p results

echo "Running MLST typing"

mlst --scheme kpneumoniae --threads 3 $GENOMES > $OUTPUT

echo "MLST completed"
echo "Results saved in $OUTPUT"
