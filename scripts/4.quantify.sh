#!/bin/bash

#sample="endo_1"
sample="FBS1"
#for file in `dx ls /projects/$sample/trimgalore/*_R1_001_1.fq.gz`;do 
for file in `dx ls /projects/$sample/trimgalore/*_1.fq.gz`;do
	echo $file
	dx run workflow-star-2.4.0j-quant-rsem-1.2.18 --dest /projects/$sample -istage-BZKBXGQ0qb7fQB86001Gg21v.reads=/projects/$sample/trimgalore/$file -istage-BZKBXGQ0qb7fQB86001Gg21v.reads2=/projects/$sample/trimgalore/${file%_1.fq.gz}_2.fq.gz --yes;
done;
