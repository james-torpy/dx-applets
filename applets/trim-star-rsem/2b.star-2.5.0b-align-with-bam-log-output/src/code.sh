#!/bin/bash

# The following line causes bash to exit at any point if there is any error
# and to output each line as it is executed -- useful for debugging
set -e -x -o pipefail

#
# Download the reads
#
dx-download-all-inputs --except genomeindex

#
# Fetch and uncompress the genome
#
mkdir ./genomeIndex
dx cat "$genomeindex" | tar xvf - -C ./genomeIndex

STAR --runMode alignReads \
     --genomeDir ./genomeIndex/ \
     --readFilesCommand zcat \
     --outFilterType BySJout \
     --outSAMattributes NH HI AS NM MD\
     --outFilterMultimapNmax 20 \
     --outFilterMismatchNmax 999 \
     --outFilterMismatchNoverReadLmax 0.04 \
     --alignIntronMin 20 \
     --alignIntronMax 1500000 \
     --alignMatesGapMax 1500000 \
     --alignSJoverhangMin 6 \
     --alignSJDBoverhangMin 1 \
     --readFilesIn ./in/reads/* ./in/reads2/* \
     --runThreadN `nproc` \
     --quantMode TranscriptomeSAM \
     --outFilterMatchNmin 101 \
     --outSAMtype BAM SortedByCoordinate \
     --outWigType wiggle \
     --outWigNorm None \
     --limitBAMsortRAM 80000000000

#
# Upload results
#
name="$reads_prefix"
name="${name%_1}"
if [ "$sample_name" != "" ]; then
  name="$sample_name"
fi

#To do
#1. Sort out the samtools and novosort
samtools view -f 3 -u Aligned.toTranscriptome.out.bam | novosort -n -m 16G -o output.bam -
mkdir -p ~/out/transcriptome/star
mkdir -p ~/out/genome/genome
mkdir -p ~/out/bigwigs/bigwigs
mkdir -p ~/out/logs/logs

mv output.bam ~/out/transcriptome/star/"$name".transcriptome.bam
mv Aligned.sortedByCoord.out.bam ~/out/genome/genome/"$name".genome.sorted.bam
mv Log.final.out ~/out/logs/logs/"$name".log

dx-upload-all-outputs
