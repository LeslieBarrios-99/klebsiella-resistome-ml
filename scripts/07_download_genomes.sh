#!/bin/bash

# =========================================================
# Download genomes from NCBI using assembly accessions
# =========================================================

ASSEMBLY_LIST="data/processed/all_assemblies.txt"
OUTPUT_DIR="data/raw/genomes"

mkdir -p $OUTPUT_DIR

cat $ASSEMBLY_LIST | parallel -j 3 '

ID={}

echo "Downloading $ID"

datasets download genome accession $ID \
  --include genome \
  --filename tmp_${ID}.zip

unzip -q tmp_${ID}.zip -d tmp_${ID}

# mover el archivo fasta correcto
FASTA=$(find tmp_${ID} -name "*genomic.fna")

if [ -f "$FASTA" ]; then
    mv "$FASTA" '"$OUTPUT_DIR"'/
else
    echo "Genome file not found for $ID"
fi

rm -rf tmp_${ID} tmp_${ID}.zip

echo "Finished $ID"

'
