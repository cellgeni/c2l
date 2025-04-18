#! /bin/bash -e
#BSUB -G cellgeni
#BSUB -J c2l.pred[1-2]
#BSUB -o logs/%J.%I.c2l.pred.log
#BSUB -e logs/%J.%I.c2l.pred.err
#BSUB -n 2
#BSUB -M64000
#BSUB -R "span[hosts=1] select[mem>64000] rusage[mem=64000]"

# for gpu-normal
#BSUB -q gpu-normal
#BSUB -gpu "mode=shared:j_exclusive=yes:gmem=32000:num=1"

module load cellgen/singularity

WDIR=`pwd -P`

IMAGE=/nfs/cellgeni/singularity/images/c2l_v014.sif

c2lpred=./actions/c2l/src/py/02.predict.cell.abundancies.py

# edit here
# by default script will submit array job (edit -J bsub option above) for all combinations of refs and alphas specified below
refs=(ref)
alphas=(20 200)
i=$(($LSB_JOBINDEX-1))

alp=${alphas[$((i / ${#refs[@]}))]}
ref=${refs[$((i % ${#refs[@]}))]}

# script expects reference signaatures to be stored in ref subfolder, but paths can be specified directly here
REF=ref/${ref}/rsignatures/inf_aver.csv
OUT=pred/${ref}.${alp}
VISIN=viss.h5ad # path to combined visum h5ad


# edit below if you want to change some defaults (ncells, epochs)
singularity exec --nv --bind /lustre,/nfs $IMAGE /bin/bash -c "nvidia-smi;cd ${WDIR}; \
 $c2lpred \
  --batch_key library_id \
  --detection_alpha ${alp} \
  --N_cells_per_location 30 \
  --max_epochs 50000 \
  $VISIN \
  $REF \
  $OUT"
