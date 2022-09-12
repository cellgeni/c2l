#!/bin/bash -e
#BSUB -G cellgeni
#BSUB -J c2l.pred[1-2]
#BSUB -o %J.%I.c2l.pred.log
#BSUB -e %J.%I.c2l.pred.err
#BSUB -n 2
#BSUB -M64000
#BSUB -R "span[hosts=1] select[mem>64000] rusage[mem=64000]"
#BSUB -q gpu-normal
#BSUB -gpu "mode=shared:j_exclusive=yes:gmem=32000:num=1"


source activate c2l220518
export PYTORCH_KERNEL_CACHE_PATH=/lustre/scratch117/cellgen/cellgeni/pasham/tmp/pytorch_cache

# edit here

refs=(ref)
alphas=(20 200)

c2lpred=actions/c2l/src/py/02.predict.cell.abundancies.py

# edit below
i=$(($LSB_JOBINDEX-1))
ref=${refs[$((i % ${#refs[@]}))]}
alp=${alphas[$((i / ${#refs[@]}))]}

# normally you do not need to change the code below
$c2lpred \
 --batch_key library_id \
 --detection_alpha ${alp} \
 --N_cells_per_location 30 \
 --max_epochs 50000 \
 viss.h5ad \
 ref/${ref}/rsignatures/inf_aver.csv \
 pred/${ref}.${alp}

