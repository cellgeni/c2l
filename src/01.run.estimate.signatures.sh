#!/bin/bash -e
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


c2lref=actions/c2l/src/py/01.estimate.signatures.py

# edit below
# use --categorical_covariate_key to specify covariates
ref=(ref)


$c2lref \
 --batch_key batch \ # column in adata.obs with 10x sample identifier
 ${ref[$LSB_JOBINDEX-1]}.h5ad \ # path to reference h5ad
 ref/${ref[$LSB_JOBINDEX-1]} \ # out dir
 "cell type" # column in adata.obs with cell annotation
 
