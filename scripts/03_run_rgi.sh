#!/bin/bash

# =========================================================
# Prodigal + RGI pipeline for resistome detection
# =========================================================

GENOME_DIR="data/raw/genomes"
PROTEIN_DIR="data/raw/proteins"
RGI_DIR="results/rgi/rgi_results"

mkdir -p $PROTEIN_DIR
mkdir -p $RGI_DIR

echo "========================================="
echo "Starting Prodigal + RGI pipeline"
echo "========================================="

ls $GENOME_DIR/*.fna | parallel -j 2 '

genome={}
base=$(basename {} .fna)

protein_file='"$PROTEIN_DIR"'/${base}.faa
output_file='"$RGI_DIR"'/${base}

echo "Processing $base"

# Skip if already processed
if [ -f "${output_file}.txt" ]; then
    echo "Skipping $base (already processed)"
    exit 0
fi

# Step 1: ORF prediction with Prodigal
prodigal \
    -i $genome \
    -a $protein_file \
    -p single \
    -q

# Remove STOP codons
sed -i "s/\*//g" $protein_file

# Step 2: Run RGI
rgi main \
    --input_sequence $protein_file \
    --output_file $output_file \
    --input_type protein \
    --alignment_tool DIAMOND \
    --clean

echo "Finished $base"

'

echo "========================================="
echo "Pipeline finished"
echo "========================================="
