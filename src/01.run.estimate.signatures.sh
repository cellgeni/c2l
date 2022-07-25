#! /bin/bash
#BSUB -G cellgeni
#BSUB -J c2l.ref[1]
#BSUB -o %J.%I.c2l.ref.log
#BSUB -e %J.%I.c2l.ref.err
#BSUB -n 2
#BSUB -M64000
#BSUB -R "span[hosts=1] select[mem>64000] rusage[mem=64000]"
#BSUB -q gpu-normal
#BSUB -gpu "mode=shared:j_exclusive=yes:gmem=32000:num=1"

source activate c2l220518
export PYTORCH_KERNEL_CACHE_PATH=/lustre/scratch117/cellgen/cellgeni/pasham/tmp/pytorch_cache

#cd /lustre/scratch117/cellgen/cellgeni/TIC-misc/tic-....

c2lref=./actions/py/01.estimate.signatures.py

# edit here
ref=(ref)

$c2lref \
 --batch_key .... \
 --categorical_covariate_key .... \
 ${ref[$LSB_JOBINDEX-1]}.h5ad \
 ref/${ref[$LSB_JOBINDEX-1]} \
 ....
 
