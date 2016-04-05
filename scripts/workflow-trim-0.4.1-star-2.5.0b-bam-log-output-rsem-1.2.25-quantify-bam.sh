#!/bin/bash

#make directory hierachy:
rootproject="JamesTestGround"
projectname="dx-applets-test"
samplename="case_proliferative"

projectDir="$rootproject:/projects/$projectname"
workflowDir="$rootproject:/workflows"
rawDir="$projectDir/raw_files/$samplename"
resultsDir="$projectDir/results"

dx mkdir -p "$resultsDir"

log_homeDir="/home/jamtor"
log_projectDir="$log_homeDir/projects/$projectname"
logDir="$log_projectDir/scripts/logs"

mkdir -p $logDir

echo -e
echo "The rawDir is:"
echo $rawDir
echo -e
echo "The resultsDir is:"
echo $resultsDir
echo -e
echo "The logDir is:"
echo logDir

for file in `dx ls "$rawDir"/*_1.fastq.gz`;do
	echo $file
	runline="dx run "$workflowDir/workflow-trim-0.4.1-star-2.5.0b-bam-log-output-rsem-1.2.25-quantify-bam" --input 0.reads="$rawDir/$file" --input 0.reads2="$rawDir/${file%_1.fastq.gz}_2.fastq.gz" --dest "$resultsDir/${file%_1_1.fastq.gz}" --yes";
	echo $runline
	qsub -N dxworkflow_$file -wd $logDir -b y -j y -R y -pe smp 1 -V $runline
done;