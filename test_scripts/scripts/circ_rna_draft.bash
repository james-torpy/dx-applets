#!/bin/bash

###CircRNA###

module load pethum/bowtie2/prebuilt/2.2.6
module load gi/samtools/1.2
module load kevyin/python/2.7.2

big_numcores=16
small_numcores=3

projectname="dx-applets"
samplename="test_scripts"
genomename="hg38_ercc"

#make directory hierachy:
homeDir="/home/jamtor"
projectDir="$homeDir/projects/$projectname/$samplename"
resultsDir="$projectDir/results"
genomeDir="$homeDir/genomes/$genomename"
chrDir="$homeDir/genomes/$genomename/split"

#find_circ location:
circDir="/home/jamtor/local/bin/find_circ"

#input/outputs:
genomeFile="$genomeDir/$genomename"
inExt=".fq"
outExt=".circ_rna"

inDir="$projectDir/raw_files"

#scripts/logs directory
scriptsPath="$projectDir/scripts"
logDir="$scriptsPath/logs"

mkdir -p $logDir

echo -e
echo This is the genomeFile:
echo $genomeFile
echo -e
echo This is the chrDir:
echo $chrDir
echo -e
echo This is the inDir:
echo $inDir
echo -e
echo This is the logDir:
echo $logDir

#fetch file names of all projects and put into an array:
i=0
files=( $(ls $inDir/*$inExt))

for file in ${files[@]} ;do
	echo -e
	echo The file used is: $file
	filesTotal[i]=$file
	let i++
done;

#fetch the inFiles and create an outDir based on their uniqueID:
j=0

echo Total files = ${#filesTotal[@]}

while [ $j -lt ${#filesTotal[@]} ]; do
	inFile1=${filesTotal[$j]}
	inFile2=${filesTotal[$(($j+1))]}
	uniqueID=`basename $inFile1 | sed s/_R1$inExt//`
	outDir="$resultsDir/$uniqueID$outExt"
			
	mkdir -p $outDir

	echo -e
	echo This is the uniqueID:
	echo $uniqueID
	echo -e
	echo This is the outDir:
	echo $outDir

	#map samples with Bowtie2:
	bowtie_line="bowtie2 -p 16 --very-sensitive --mm -M20 --score-min=C,-15,0 -x \
	$genomeFile -q -1 $inFile1 -2 \
	$inFile2 -S $outDir/$uniqueID.sam"

	echo -e
	echo This is the bowtie_line:
	echo $bowtie_line

	#qsub -N bw2$uniqueID -wd $logDir -b y -j y -P GenomeInformatics -pe smp \
	#$big_numcores -V $bowtie_line

	samtools_line="samtools view -hbuS $outDir/$uniqueID.sam | samtools sort - \
	'$outDir/$uniqueID'"

	echo -e
	echo This is the samtools_line:
	echo $samtools_line

	#qsub -N st$uniqueID -hold_jid bw2$uniqueID -wd $logDir -b y -j y -P GenomeInformatics \
	#-pe smp $small_numcores -V $samtools_line

	#extract the unmapped reads:
	samtools_view_line="samtools view -hf 4 '$outDir/$uniqueID.bam' \
	| samtools view -Sb - > '$outDir/unmapped_$uniqueID.bam'"

	echo -e
	echo This is the samtools_view_line:
	echo $samtools_view_line

	#qsub -N view$uniqueID -hold_jid st$uniqueID -wd $logDir -b y -j y -P GenomeInformatics \
	#-pe smp $small_numcores -V $samtools_view_line

	#split unmapped reads onto anchors for independent mapping:
	split_line="python $circDir/unmapped2anchors.py $outDir/unmapped_$uniqueID.bam \
	| gzip > $outDir/${uniqueID}_anchors.qfa.gz"
	
	echo -e
	echo This is the split_line:
	echo $split_line

	#qsub -N spl$uniqueID -hold_jid view$uniqueID -wd $logDir -b y -j y -P GenomeInformatics \
	#-pe smp $small_numcores -V $split_line

	#screen for spliced reads:
	screen_line="bowtie2 -p 16 --reorder --mm -M20 --score-min=C,-15,0 -q -x $genomeFile \
	-U $outDir/${uniqueID}_anchors.qfa.gz -S $outDir/${uniqueID}_anchors.sam"

	echo -e
	echo This is the screen_line:
	echo $screen_line

	#qsub -N scr$uniqueID -hold_jid spl$uniqueID -wd $logDir -b y -j y -P GenomeInformatics \
	-pe smp $big_numcores -V $screen_line

	cat_line="cat $outDir/${uniqueID}_anchors.sam | python $circDir/find_circ.py -G \
	$chrDir -p $uniqueID -s $outDir/sites.log"

	echo -e
	echo This is the cat_line:
	echo $cat_line

	#qsub -N cat$uniqueID -hold_jid scr$uniqueID -wd $logDir -b y -j y -P GenomeInformatics -pe \
	#smp $small_numcores -e $outDir/sites.reads -o $outDir/sites.bed -V $cat_line

	#filter the output:
	grep_line="grep circ '$outDir/sites.bed'| grep -v chrM | python \
	$circDir/sum.py -2,3 | python $circDir/scorethresh.py -16 1 | python \
	$circDir/scorethresh.py -15 2 | python $circDir/scorethresh.py -14 2 | python \
	$circDir/scorethresh.py 7 2 | python $circDir/scorethresh.py 8,9 35 | python \
	$circDir/scorethresh.py -17 100000 > $outDir/circ_candidates.bed"

	echo -e
	echo This is the grep_line:
	echo $grep_line

	#qsub -N grep$uniqueID -hold_jid cat$uniqueID -wd $logDir -b y -j y -P GenomeInformatics -pe \
	#smp 1 -V $grep_line
	j=$(($j+2))
done;

###what does following mean?###
#to get a reasonable set of circRNA candidates try:;done

