#!/bin/bash

INPUT_DIR=data/raw/genomes
OUTPUT=results/mlst/mlst_results.tsv

mkdir -p results/mlst

echo -e "Genome\tST" > $OUTPUT

for genome in $INPUT_DIR/*.fna
do
    base=$(basename $genome .fna)

    result=$(mlst $genome)

    ST=$(echo $result | awk '{print $3}')

    echo -e "$base\t$ST" >> $OUTPUT
done
