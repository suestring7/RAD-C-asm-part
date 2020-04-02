#!/bin/bash
#$ -m beas
#$ -q bio,adl,sf,pub64,free64 
#$ -ckpt restart

module load bwa/0.7.8
ref=$1
REF=$2
workDir=$3
splitDir=$workDir/split-$REF
dataDir=$workDir/data
trimDir=$workDir/trim

# the absolute place to script
script=/data/users/ytao7/software/mytools/juicer-pipeline/

[ -d $splitDir ] || mkdir -p $splitDir
[ -d $dataDir ] || mkdir -p $dataDir
[ -d $trimDir ] || mkdir -p $trimDir

mv $workDir/*READ* $dataDir   # edit the files to READ
[ -f $1.amb ] && [ -f $1.ann ] && [ -f $1.bwt ] && [ -f $1.pac ] && [ -f $1.sa ]|| bwa index $1
for reads in $(ls $dataDir/*READ*)
do
	name=${reads##*/}
	qsub -N trim_$workDir $script/trimming.sh $reads $trimDir/${name%.txt.gz}.trim.txt.gz
done

for reads in $(ls $trimDir/*READ*)
do
	qsub -N bwa_$workDir-$REF -hold_jid trim_$workDir $scripts/BWA.sh -r $ref -n 1 -o $splitDir $reads 
done

qsub -N mnd_$workDir-$REF -hold_jid bwa_$workDir-$REF $script/run-mnd.sh $workDir $REF

