#!/bin/bash

### split_genome_by_chromosome ###

module load gi/samtools/1.2

#set variables:
genomename="hg38_ercc"

#make directory hierachy:
homeDir="/home/jamtor"
genomeDir="$homeDir/genomes/$genomename"