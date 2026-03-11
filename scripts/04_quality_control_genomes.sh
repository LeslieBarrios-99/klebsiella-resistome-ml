#!/bin/bash

echo -e "Genome\tGenome_Size\tNum_Contigs\tN50" > genome_quality_metrics.tsv

for file in *.fna
do
    genome=$(basename "$file" .fna)

    # Tamaño total del genoma
    genome_size=$(grep -v "^>" "$file" | tr -d '\n' | wc -c)

    # Número de contigs
    num_contigs=$(grep -c "^>" "$file")

    # Longitudes de contigs
    lengths=$(awk '/^>/ {if (seq) print length(seq); seq=""; next} {seq=seq$0} END {print length(seq)}' "$file" | sort -nr)

    total=$(echo "$lengths" | awk '{sum+=$1} END {print sum}')
    half=$((total / 2))

    cumulative=0
    N50=0

    for len in $lengths
    do
        cumulative=$((cumulative + len))
        if [ "$cumulative" -ge "$half" ]; then
            N50=$len
            break
        fi
    done

    echo -e "$genome\t$genome_size\t$num_contigs\t$N50" >> genome_quality_metrics.tsv
done


