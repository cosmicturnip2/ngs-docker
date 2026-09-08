#!/usr/bin/env bash
# Example pipeline: quality-check, trim, and re-check a single-end FASTQ file.
# Run this inside the container (see README for how to start one).

set -euo pipefail

INPUT="/data/sample.fastq.gz"
TRIMMED="/data/sample_trimmed.fastq.gz"
FASTQC_OUT="/data/fastqc_output"

mkdir -p "$FASTQC_OUT"

echo "Running FastQC on raw reads..."
fastqc "$INPUT" -o "$FASTQC_OUT"

echo "Trimming low-quality trailing bases..."
trimmomatic SE -threads 4 -phred33 "$INPUT" "$TRIMMED" TRAILING:10

echo "Running FastQC on trimmed reads..."
fastqc "$TRIMMED" -o "$FASTQC_OUT"

echo "Done. Reports are in $FASTQC_OUT"
