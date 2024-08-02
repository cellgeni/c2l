#! /bin/bash -e
IMAGE=/nfs/cellgeni/singularity/images/c2l_v0.1.3p_240701.sif
c2lref=../src/py/01.estimate.signatures.py

REFOUT=ref/$1
SAMPLE=Sanger_ID
REFIN=ref_ctcl_small100.h5ad
CELLTYPE=cell_type

singularity exec --nv --bind /lustre,/nfs $IMAGE /bin/bash -c "nvidia-smi; \
 $c2lref \
  --batch_key $SAMPLE \
  --categorical_covariate_key donor \
  $REFIN \
  $REFOUT \
  $CELLTYPE"