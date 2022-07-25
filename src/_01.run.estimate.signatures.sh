#! /bin/bash
#BSUB -G cellgeni
#BSUB -J c2l.ref[1-2]
#BSUB -o %J.%I.c2l.ref.log
#BSUB -e %J.%I.c2l.ref.err
#BSUB -n 2
#BSUB -M32000
#BSUB -R "span[hosts=1] select[mem>32000] rusage[mem=32000]"
#BSUB -q gpu-normal
#BSUB -gpu "mode=shared:j_exclusive=yes:gmem=32000:num=1"

source activate c2l220518
export PYTORCH_KERNEL_CACHE_PATH=/lustre/scratch117/cellgen/cellgeni/pasham/tmp/pytorch_cache

tic=tic-1575

cd /lustre/scratch117/cellgen/cellgeni/pasham/data/2202.c2l.service/${tic}
c2lref=/nfs/cellgeni/pasham/projects/2202.c2l.service/src/${tic}/c2l/py/01.estimate.signatures.py



ref=(ref)

$c2lref \
 --batch_key .... \
 --categorical_covariate_key .... \
 ${ref[$LSB_JOBINDEX-1]}.h5ad \
 ref/${ref[$LSB_JOBINDEX-1]} \
 .....
 
