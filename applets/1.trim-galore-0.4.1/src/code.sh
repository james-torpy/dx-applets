#!/bin/bash

# The following line causes bash to exit at any point if there is any error
# and to output each line as it is executed -- useful for debugging
set -e -x -o pipefail

#
# Download the reads
#
dx-download-all-inputs --parallel

#
# Run trim_galore
#

# Requires fastqc and cutadapt in the path
PATH="/FastQC/:$HOME/.local/bin:$PATH"

mkdir results
trim_galore --length 25 ./in/reads/* ./in/reads2/* $extra_options -o results

#
# Upload results
#
name="$reads_prefix"
name="${name%_1}"
name="${name%_R1}"
if [ "$sample_name" != "" ]; then
  name="$sample_name"
fi

mkdir -p ~/out/reads/trimgalore ~/out/reads2/trimgalore ~/out/others/trimgalore/other_files
mv results/*_val_1.fq.gz ~/out/reads/trimgalore/"$name"_1.fq.gz
mv results/*_val_2.fq.gz ~/out/reads2/trimgalore/"$name"_2.fq.gz
mv results/* ~/out/others/trimgalore/other_files

dx-upload-all-outputs --parallel
