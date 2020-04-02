#!/bin/bash
#$ -m beas
#$ -q bio,adl,abio128,abio,sf,pub*,free*
#$ -ckpt restart

# The absolute path to the pipeline folder
script="/data/users/ytao7/software/mytools/juicer-pipeline"
# The absolute path to the reference file [ the draft assembly ]
ref="/dfs3/long-lab/ytao7/RADC/koreanmudskipper/cns_p_ctg.fasta"
# The name to call the reference file
REF="draft"
# The species name
sp="kr-ms"  # korean mudskiper, a fish

# run the preparation step
bash $script/run-prep.sh $ref $REF $sp

# Pick a proper round number according to the size and complexity of the genome
round=3
# Expected chromosome number 
chr=21
dir=$sp/N$REF-$round
[ -d $dir ] || mkdir -p $dir
cd $dir
qsub -N Nasm-${sp}-$REF-$round -hold_jid mnd_$sp-$REF $script/run-pipeline-new.sh -i 10000 -r $round $ref ../output-$REF/merged_nodups.txt
