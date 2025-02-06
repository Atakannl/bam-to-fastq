#!/bin/bash

# Exit script immediately if any command fails
set -e

# Check if a sample list file is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <sample_list.txt>"
    exit 1
fi

SAMPLE_LIST=$1

# Check if the sample list file exists and is not empty
if [ ! -s "$SAMPLE_LIST" ]; then
    echo "Error: Sample list file is missing or empty!"
    exit 1
fi

# Define the list of primary chromosomes
CHROMS="chr1 chr2 chr3 chr4 chr5 chr6 chr7 chr8 chr9 chr10 chr11 chr12 chr13 chr14 chr15 chr16 chr17 chr18 chr19 chr20 chr21 chr22 chrX chrY"

# Read the sample names from the file into an array
mapfile -t SAMPLES < "$SAMPLE_LIST"

echo "Filtering BAM files based on sample names in $SAMPLE_LIST..."

# Loop through each sample name
for sample in "${SAMPLES[@]}"; do
    echo "Processing $sample ..."

    # Find the BAM file matching the sample name
    bam=$(find . -type f -name "${sample}*.bam")

    # If no BAM file is found, exit immediately
    if [[ -z "$bam" ]]; then
        echo "Error: No BAM file found for sample: $sample"
        exit 1
    fi

    # Create a directory for the sample
    mkdir -p "$sample"
    
    # Filter for primary chromosomes
    echo "Filtering for primary chromosomes..."
    samtools view -b "$bam" $CHROMS > "$sample/${sample}_primary_filtered.bam"

    # Fix the BAM header
    echo "Fixing BAM header..."
    samtools reheader <( (samtools view -H "$sample/${sample}_primary_filtered.bam" | grep -v '^@SQ'; samtools view -H "$sample/${sample}_primary_filtered.bam" | grep -E '^@SQ.*SN:(chr([1-9]|1[0-9]|2[0-2]|X|Y))\b') ) "$sample/${sample}_primary_filtered.bam" > "$sample/${sample}_final_filtered.bam"

    # Sort the BAM file
    echo "Sorting BAM file..."
    samtools sort -o "$sample/${sample}_final_filtered.bam" "$sample/${sample}_final_filtered.bam"

    # Remove unmapped, secondary, and supplementary alignments
    echo "Removing unmapped, secondary, and supplementary alignments..."
    samtools view -b -F 4 -F 256 -F 2048 "$sample/${sample}_final_filtered.bam" > "$sample/${sample}_final_filtered.bam.tmp" && mv "$sample/${sample}_final_filtered.bam.tmp" "$sample/${sample}_final_filtered.bam"

    # Remove duplicates using Picard
    echo "Removing duplicates..."
    picard MarkDuplicates I="$sample/${sample}_final_filtered.bam" O="$sample/${sample}_filtered_noDup.bam" M="$sample/${sample}_duplication_metrics.txt" REMOVE_DUPLICATES=true

    # Index the final BAM file
    echo "Indexing BAM file..."
    samtools index "$sample/${sample}_filtered_noDup.bam"

    # Convert BAM to FASTQ
    echo "Converting BAM to FASTQ..."
    samtools bam2fq "$sample/${sample}_filtered_noDup.bam" > "$sample/${sample}_filtered.fastq"

    echo "Finished processing $sample!"
    echo "--------------------------------------------"
done

echo "All BAM files processed successfully!"
