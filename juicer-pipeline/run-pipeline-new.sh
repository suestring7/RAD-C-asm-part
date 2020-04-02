#!/bin/sh
#$ -q bio,adl,abio,free64
#$ -m beas
#$ -pe openmp 32
#$ -ckpt blcr
module load enthought_python
module load gnu_parallel/20170622
module load coreutils/8.27
module load gawk/4.1.4

# the absolute path to 3d-dna
3d-dna="/data/users/ytao7/software/3d-dna/"
# the parameter that serves as a cut-off considering contigs
threshold=10000

current=0
usage(){ echo "Usage: $0 [-i threshold] [-r round] <raw_assembly> <mnd>" 1>&2; exit 1;}
while getopts 'i:r:n:' opt; do
        case $opt in
                i)      threshold="$OPTARG"
                        [[ -n ${threshold//[0-9]/} ]]&&usage
                        ;;
                r)      step="$OPTARG"
                        [[ $((step)) != $step ]]&&usage
                        ;;
                n)      current="$OPTARG"
                        [[ -n ${current//[0-9]/} ]]&&usage
                        ;;
                *)      usage;;
        esac
done
shift $(( OPTIND-1 ))

raw_asm=$1
mnd=$2

bash $3d-dna/run-asm-pipeline.sh -m haploid -i $threshold -r $step $raw_asm $mnd

# I did something to continue from accidently stopped run, but normally we don't need that
#bash /data/users/ytao7/software/3d-dna/run-asm-pipeline.sh -m haploid -i $threshold -n $current -r $step $raw_asm $mnd
