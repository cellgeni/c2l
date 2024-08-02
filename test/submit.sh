#! /bin/bash -e
# purpose of this script is to check whether the image works on given node
# so it takes step (1 or 2), node, a as command line parameters

step=$1
node=$2



MEM=30

bsub -J c2l_ref -o logs/%J.${node}.step${step}.log -e logs/%J.${node}.step${step}.err \
 -n 2 -M${MEM}000 -R "span[hosts=1] select[mem>${MEM}000] rusage[mem=${MEM}000]" \
 -q gpu-normal \
 -gpu "mode=shared:j_exclusive=no:gmem=4000:num=1" \
 -m $node \
 ./run${step}.sh $node
