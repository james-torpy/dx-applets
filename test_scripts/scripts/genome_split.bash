#!/bin/bash

### Genome split ###
# This script splits an indexed genome fasta file by chromosome sequence,
# marked by >chrx. It is called by the genome_index script.

module load gi/samtools/1.2

projectname="dx-applets"
samplename="test_scripts"
genomename="hg38_ercc"

# make directory hierachy:
homeDir="/home/jamtor"
projectDir="$homeDir/projects/$projectname/$samplename"
genomeDir="$homeDir/genomes/$genomename"

# input/outputs:
genomeFile="$genomeDir/$genomename.fa"
outDir="$genomeDir/split"

mkdir -p $outDir

# scripts/logs directory
scriptsPath="$projectDir/scripts"
logDir="$scriptsPath/logs"

mkdir -p $logDir

echo -e
echo "This is the genomeFile:"
echo $genomeFile
echo -e
echo "This is the logDir:"
echo $logDir
echo -e
echo "This is the outDir:"
echo $outDir

# create array of all chromosome labels:
chr_lab=( chr1 chr2 chr3 chr4 chr5 chr6 chr7 chr8 chr9 chr10 chr11 \
chr12 chr13 chr14 chr15 chr16 chr17 chr18 chr19 chr20 chr21 chr22 chrX chrY )

for label in ${chr_lab[@]}; do

	echo -e
	echo "The chromosome file to be created is:"
	echo $label.fa

	split_line="samtools faidx $genomeFile $label>$outDir/$label.fa"
	
	echo -e
	echo "This is the split_line"
	echo $split_line
	
	qsub -N split$genomename -wd $logDir -b y -j y -P GenomeInformatics \
	-pe smp 3 -V $split_line

done;

