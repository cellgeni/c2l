#! /bin/bash -e
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

# edit below
# script expects all ref h5ads to be in working directory. It will submit array job (edit -J bsub option above), one instance per ref h5ad
# list here names of ref  files (without ".h5ad"). Estimated signatures will be named in the same way
ref=(ref)

# set parameters
REFOUT=ref/${ref[$LSB_JOBINDEX-1]}
REFIN=${ref[$LSB_JOBINDEX-1]}.h5ad

CELLTYPE="" # names of adata.obs column with celltype annotation
SAMPLE="" # names of adata.obs column with information about 10x sample (to be used as batch in c2l)
COV="" # names of adata.obs column with information about covariates (donor, etc) (to be used as categorical_covariate_key in c2l); add multiple "categorical_covariate_key" parameters below if you need

# usual set of parameters is defined above, but you may need to edit code below as well. See manual in py/01.estimate.signatures.py
$c2lref \
 --batch_key $SAMPLE \
 --categorical_covariate_key $COV \
 $REFIN \
 $REFOUT \
 $CELLTYPE
 
