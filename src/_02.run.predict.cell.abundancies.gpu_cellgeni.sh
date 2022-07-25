#! /bin/bash
#BSUB -G cellgeni
#BSUB -J c2l.pred[2-8]
#BSUB -o %J.%I.c2l.pred.log
#BSUB -e %J.%I.c2l.pred.err
#BSUB -n 2
#BSUB -M64000
#BSUB -R "span[hosts=1] select[mem>64000] rusage[mem=64000]"
#BSUB -q gpu-cellgeni
#BSUB -m dgx-b11
#BSUB -gpu "mode=shared:j_exclusive=no:gmem=62000:num=1"


source activate test_pyro_cuda116
export PYTORCH_KERNEL_CACHE_PATH=/lustre/scratch117/cellgen/cellgeni/pasham/tmp/pytorch_cache


nvidia-smi

# edit here
refs=(all_normal-CG.v2.celltypes all_normal-CG.v2.subcelltypes bcc_and_normal-CG.v2.celltypes bcc_and_normal-CG.v2.subcelltypes)
alphas=(20 200)

cd /lustre/scratch117/cellgen/cellgeni/pasham/data/2202.c2l.service/2204.clarisse/v02/
c2lpred=/nfs/cellgeni/pasham/projects/2202.c2l.service/src/2204.clarisse/v02/c2l/py/02.predict.cell.abundancies.py


i=$(($LSB_JOBINDEX-1))
ref=${refs[$((i % ${#refs[@]}))]}
alp=${alphas[$((i / ${#refs[@]}))]}

# edit here
$c2lpred \
 --batch_key library_id \
 --detection_alpha ${alp} \
 --N_cells_per_location 30 \
 --max_epochs 50000 \
 viss.h5ad \
 ref/${ref}/rsignatures/inf_aver.csv \
 pred/${ref}.${alp}

