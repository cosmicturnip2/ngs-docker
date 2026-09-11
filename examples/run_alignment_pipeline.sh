#!/usr/bin/env bash
# Example pipeline: from raw FASTQ through germline variant calling.
# Run this inside the container (see README for how to start one).

set -euo pipefail

REF="/data/hg38.fa"
KNOWN_SITES="/data/hg38_v0_Homo_sapiens_assembly38.dbsnp138.vcf"
R1="/data/sample_1.fastq.gz"
R2="/data/sample_2.fastq.gz"
SAMPLE="sample"
FASTQC_OUT="/data/fastqc_output"

mkdir -p "$FASTQC_OUT"

# 1. Quality control on raw reads
fastqc "$R1" "$R2" -o "$FASTQC_OUT"

# 2. Paired-end adapter/quality trimming
trimmomatic PE -threads 4 -phred33 \
  "$R1" "$R2" \
  "${SAMPLE}_1_paired.fastq.gz" "${SAMPLE}_1_unpaired.fastq.gz" \
  "${SAMPLE}_2_paired.fastq.gz" "${SAMPLE}_2_unpaired.fastq.gz" \
  TRAILING:10

# 3. Index the reference genome (only needs to be done once)
if [ ! -f "${REF}.bwt" ]; then
  bwa index -a bwtsw "$REF"
fi

# 4. Align trimmed reads to the reference, tagging with a read group
bwa mem -R "@RG\tID:${SAMPLE}\tPL:ILLUMINA\tSM:${SAMPLE}\tLB:${SAMPLE}" \
  "$REF" \
  "${SAMPLE}_1_paired.fastq.gz" "${SAMPLE}_2_paired.fastq.gz" \
  > "${SAMPLE}_aligned.sam"

# 5. Convert SAM to BAM
samtools view -@4 -b "${SAMPLE}_aligned.sam" > "${SAMPLE}_aligned.bam"

# 6. Fix mate information: name-sort -> fixmate -> coordinate-sort
samtools sort -n -o - "${SAMPLE}_aligned.bam" \
  | samtools fixmate -m - - \
  | samtools sort -o "${SAMPLE}_final_sorted.bam" -

# 7. Mark duplicate reads
samtools markdup -S "${SAMPLE}_final_sorted.bam" "${SAMPLE}_marked_duplicates.bam"

# 8. Prepare reference companion files GATK needs (once per reference)
if [ ! -f "${REF}.fai" ]; then
  samtools faidx "$REF"
fi
if [ ! -f "${REF%.fa}.dict" ]; then
  gatk CreateSequenceDictionary -R "$REF" -O "${REF%.fa}.dict"
fi

# 9. Build the base quality score recalibration model
gatk BaseRecalibrator \
  -I "${SAMPLE}_marked_duplicates.bam" \
  -R "$REF" \
  --known-sites "$KNOWN_SITES" \
  -O "${SAMPLE}_recal_data.table"

# 10. Apply base quality score recalibration
gatk ApplyBQSR \
  -I "${SAMPLE}_marked_duplicates.bam" \
  -R "$REF" \
  --bqsr-recal-file "${SAMPLE}_recal_data.table" \
  -O "${SAMPLE}_recalibrated.bam"

# 11. Call germline variants
gatk HaplotypeCaller \
  -R "$REF" \
  -I "${SAMPLE}_recalibrated.bam" \
  -O "${SAMPLE}.vcf.gz"

echo "Done. Variant calls: ${SAMPLE}.vcf.gz"
