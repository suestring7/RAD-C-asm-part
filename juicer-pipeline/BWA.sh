#! /bin/bash
#$ -N BWA
#$ -q bio,adl,abio,pub*,free*
#$ -pe openmp 16
#$ -m beas
#$ -ckpt blcr
#$ -R y

usage(){ echo "Usage: $0 [-r <referenceFile>] [-n 1|2] [-o <outputDir>] [-f sam|bam] <read1> <read2>" 1>&2; exit 1;}
module load bwa/0.7.8
module load samtools
number=1
outDir="."
format='sam'
while getopts 'r:n:f:o:' opt; do
	case $opt in
		r) 	ref="$OPTARG";;
		n) 	number="$OPTARG"
			((number==1||number==2))||usage
			;;
		o)	outDir="$OPTARG";;
		f)	format="$OPTARG"
			[ $format == 'bam' ]||[ $format == 'sam' ]||usage
			;;
		*) 	usage;;
	esac
done
shift $(( OPTIND-1 ))
name=$(basename ${1%%[.]*})
#name=$(basename ${1%%[.-]*})

echo "number=$number"
echo "ref=$ref"
echo "name=$name"
echo "$outDir/$name.align2ref.sam"

if [ $number -eq 1 ]
then
	if [ $format == 'bam' ]
	then
		[ -f $outDir/$name.2.bam ] && echo "File "$outDir/$name.2.bam" already exist! Please delete it to restart!"
                [ -f $outDir/$name.2.bam ] || bwa mem -t $CORES -M $ref $1 | samtools sort -@$CORES -O BAM -o $outDir/$name.2.bam
	else
		[ -f $outDir/$name.align2ref.sam ] && echo "File "$outDir/$name.align2ref.sam" already exist! Please delete it to restart!"
		[ -f $outDir/$name.align2ref.sam ] || bwa mem -t $CORES -M $ref $1 > $outDir/$name.align2ref.sam
	fi
else
	if [ $format == 'bam' ]
	then
		echo "I am bug!"
		[ -f $outDir/$name.22.bam ] && echo "File "$outDir/$name.22.bam" already exist! Please delete it to restart!"
		[ -f $outDir/$name.22.bam ] || bwa mem -t $CORES -M $ref $1 $2 | samtools sort -@$CORES -O BAM -o $outDir/$name.22.bam
	else
		[ -f $outDir/$name.align22ref.sam ] && echo "File "$outDir/$name.align22ref.sam" already exist! Please delete it to restart!" 
		[ -f $outDir/$name.align22ref.sam ] || bwa mem -t $CORES -M $ref $1 $2 > $outDir/$name.align22ref.sam
	fi	
fi

