#! /bin/bash -e
#BSUB -G cellgeni
#BSUB -J c2l.pred[1-2]
#BSUB -o %J.%I.c2l.pred.log
#BSUB -e %J.%I.c2l.pred.err
#BSUB -n 2
#BSUB -M64000
#BSUB -R "span[hosts=1] select[mem>64000] rusage[mem=64000]"

# comment these to use on gpu-cellgeni-a100
#BSUB -q gpu-normal
#BSUB -gpu "mode=shared:j_exclusive=yes:gmem=32000:num=1"

# uncomment these to use on gpu-cellgeni-a100
##BSUB -q gpu-cellgeni-a100
##BSUB -m dgx-b11
##BSUB -gpu "mode=shared:j_exclusive=no:gmem=62000:num=1"

nvidia-smi

# uncomment these to use on gpu-cellgeni-a1
source activate c2l220518
# uncomment these to use on gpu-cellgeni-a1
#source activate test_pyro_cuda111_a100

export PYTORCH_KERNEL_CACHE_PATH=/lustre/scratch117/cellgen/cellgeni/pasham/tmp/pytorch_cache

#cd /lustre/scratch117/cellgen/cellgeni/TIC-misc/tic-....

c2lpred=./actions/py/02.predict.cell.abundancies.py

# edit here
# by default script will submit array job (edit -J bsub option above) for all combinations of refs and alphas specified below
refs=(ref)
alphas=(20 200)
i=$(($LSB_JOBINDEX-1))

alp=${alphas[$((i / ${#refs[@]}))]}

# script expects reference signaatures to be stored in ref subfolder, but paths can be specified directly here
REF=ref/${refs[$((i % ${#refs[@]}))]}/rsignatures/inf_aver.csv
OUT=pred/${ref}.${alp}
VISIN=viss.h5ad # path to combined visum h5ad


# edit below if you want to change some defaults (ncells, epochs)
$c2lpred \
 --batch_key library_id \
 --detection_alpha ${alp} \
 --N_cells_per_location 30 \
 --max_epochs 50000 \
 $VISIN \
 $REF \
 $OUT

