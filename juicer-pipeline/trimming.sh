#!/bin/sh
#$ -q adl,bio,abio,free*,pub*
#$ -m beas
#$ -ckpt restart
[ -f $2 ] && echo "File "$2" already exist. Quit."
[ -f $2 ] || zcat $1 | perl ~/software/mytools/juicer-pipeline/trimreads.pl - | gzip -c - > $2

