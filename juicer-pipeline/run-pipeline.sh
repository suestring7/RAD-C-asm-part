#!/bin/sh
#$ -q bio,adl,abio,free64
#$ -m beas
#$ -pe openmp 32
#$ -ckpt blcr
module load enthought_python
module load gnu_parallel/20170622
module load coreutils/8.27
module load gawk/4.1.4
threshold=15000
step=7
chromosome=24

usage(){ echo "Usage: $0 [-t $threshold] [-s $step] [-c $chromosome] <raw_assembly> <mnd>" 1>&2; exit 1;}
while getopts 't:s:c:' opt; do
        case $opt in
                t)      threshold="$OPTARG"
			echo "threshold $threshold"
                        [[ -n ${threshold//[0-9]/} ]]&&usage
                        ;;
                s)      step="$OPTARG"
			echo "step $step"
                        [[ $((step)) != $step ]]&&usage
                        ;;
                c)      chromosome="$OPTARG"
			echo "chromosome $chromosome"
                        [[ $chromosome =~ ^[0-9]+$ ]]||usage
                        ;;
                *)      echo "unknown $opt"
			usage;;
        esac
done
shift $(( OPTIND-1 ))

raw_asm=$1
mnd=$2

bash /share/adl/ytao7/summer/3d-dna/3d-dna-master/run-pipeline.sh -m haploid -t $threshold -s $step -c $chromosome $raw_asm $mnd
