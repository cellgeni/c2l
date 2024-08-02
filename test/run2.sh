#! /bin/bash -e
IMAGE=/nfs/cellgeni/singularity/images/c2l_v0.1.3p_240701.sif
c2lpred=../src/py/02.predict.cell.abundancies.py

OUT=pred/$1
VISIN=vis_HCA_sCTCL13787191.h5ad
REF=ref/farm22-gpu0203/rsignatures/inf_aver.csv


singularity exec --nv --bind /lustre,/nfs $IMAGE /bin/bash -c "nvidia-smi; \
 $c2lpred \
  --batch_key library_id \
  --detection_alpha 20 \
  --N_cells_per_location 30 \
  --max_epochs 10000 \
  $VISIN \
  $REF \
  $OUT"