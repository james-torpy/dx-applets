#!/bin/bash


##### Login to DNAnexus #####

source /home/jamtor/local/lib/dnanexus/dx-toolkit/environment
dx login

##### Upload the raw files #####

raw_file_dir="/home/jamtor/projects/dx-applets_test/raw_files"

outDir="JamesTestGround:/dx-applets_test/raw_files"
dx mkdir -p $outDir
dx cd $outDir
#make raw file directory on the DNAnexus side
for file in `ls -d $raw_file_dir/*`; do
	dx upload $file
done;
