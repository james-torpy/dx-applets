#!/bin/bash

### Genome index ###
# This script indexes a genome by chromosome sequence, marked by >chrx, and
# calls the genome_split script to split the genome by chromosome

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

# index the genomeFile:
index_line="samtools faidx $genomeFile"

echo -e
echo "This is the index_line"
echo $index_line

# submit indexing to the cluster:
#qsub -N index$genomename -wd $logDir -b y -j y -P GenomeInformatics \
#-pe smp 3 -V $index_line

# call the genome_split script:
qsub -N callsplit -hold_jid index$genomename -wd $logDir -b y -j y \
-P GenomeInformatics -pe smp 1 -V $scriptsPath/genome_split.bash