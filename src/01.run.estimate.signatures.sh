#! /bin/bash -e
#BSUB -G cellgeni
#BSUB -J c2l.ref[1]
#BSUB -o %J.%I.c2l.ref.log
#BSUB -e %J.%I.c2l.ref.err
#BSUB -n 2
#BSUB -M64000
#BSUB -R "span[hosts=1] select[mem>64000] rusage[mem=64000]"

# for gpu-normal
#BSUB -q gpu-normal
#BSUB -gpu "mode=shared:j_exclusive=yes:gmem=32000:num=1"

# for gpu-cellgeni-a100
##BSUB -q gpu-cellgeni-a100
##BSUB -m dgx-b11
##BSUB -gpu "mode=shared:j_exclusive=no:gmem=62000:num=1"

export PATH=/software/singularity/3.11.4/bin:$PATH


WDIR=`pwd -P`
# more recent version, probably doesnt work on farm5 due to outdated drivers, use on farm22
IMAGE=/nfs/cellgeni/singularity/images/c2l_v0.1.3p_240119.sif # or use one of /nfs/cellgeni/singularity/images/c2l_v0.1.3.sif;  c2l.jhub.221206.v0.1.sif which is based on commit 36e4f007e8fba4cb85c13b9bff47a4f6fbae9295
c2lref=./actions/c2l/src/py/01.estimate.signatures.py

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
singularity exec --nv --bind /lustre,/nfs $IMAGE /bin/bash -c "nvidia-smi;cd ${WDIR}; \
 $c2lref \
  --batch_key $SAMPLE \
  --categorical_covariate_key $COV \
  $REFIN \
  $REFOUT \
  $CELLTYPE"
