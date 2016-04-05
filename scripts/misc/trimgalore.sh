#make directory hierachy:

rootproject="JamesTestGround"
projectname="dx-applets_test"
appName="1.trim-galore-0.4.1"
inExt=".fastq"
outType="trimgalore"

projectDir="$rootproject:/projects/$projectname"
resultsDir="$projectDir/results"
appDir="$projectDir/applets"

applet="$appDir/$appName"
inDir="$projectDir/raw_files"
outDir="$resultsDir.$outType"

dx mkdir -p $outDir

echo -e
echo The applet is:
echo $applet
echo -e
echo The inDir is:
echo $inDir
echo -e
echo The outDir is:
echo $outDir


inExt=".fastq"
for file in `dx ls $inDir/*_R1$inExt | grep -v Undetermined`;do
	inFile1=$inDir/$file
	inFile2=$inDir/${file%1$inExt}2$inExt
	
	echo -e
	echo The inFile1 is: $inFile1
	echo -e
	echo The inFile2 is: $inFile2

	dx run $applet --dest $outDir -ireads=$inFile1 -ireads2=$inFile2 --yes;
done
