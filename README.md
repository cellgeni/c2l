# c2l
Set of scripts to run cell2location on farm

# Overview
There are two steps:
1. Cell type signature estimation
2. Visium deconvolution

First step needs reference h5ad file with raw counts in adata.X, all covariates and cell annotation in adata.obs. Default name for input h5ad is ./ref.h5ad.
Second step needs results of the first step and h5ad with all visium samples combined. Default name for input visium is ./viss.h5ad

Two steps are independent and have to be submited to farm one by one using srs/01 and src/02 bash scripts. Usually input data are not well formated, so some preparation is needed. In this case src/check-n-prepare.input.h5ad.ipynb can be used.

Some QCs can be plotted by src/03.plot.c2l.R.

# Prerequisites
The pipeline uses singularity to run cell2location. Path to the image is  hardcoded in bsub scripts. 
Second step of cell2location can use a lot  of GPU memory, most likely it will not fit into gpu-normal if number of visium samples is above 15-20 (more then 20k spots). In this case `gpu-cellgeni-a100` queue can be used (comment/uncomment corresponding lines in `02.run.predict.cell.abundancies.sh`).

# Details
The pipeline is designed to be run on one or more references and single set of visiums. So prepared input consists of one or more reference h5ad and one visium h5ad files.

## Initialization
Set tic variable to ticket number and init:
```
tic=.. 
~cellgeni-su/bin/tick.sh -k $tic -c misc -t 0 -j pm19@sanger.ac.uk -y https://github.com/cellgeni/c2l
cd /lustre/scratch117/cellgen/cellgeni/TIC-misc/tic-$tic
mkdir ref pred figures
```
## Check and prepare the input
Open `actions/c2l/src/check-n-prepare.input.h5ad.ipynb` in jupiter modify paths and follow the notebook. You should get one or more reference h5ad and visium h5ad files as an output.

## Signature estimation
`actions/c2l/src/01.run.estimate.signatures.sh` submits the job to farm into gpu-normal queue. Edit the file according to the ticket: list all input reference h5ad files, specify batch, covariates and cell type annotation column of adata.obs. Internaly `01.run.estimate.signatures.sh` calls python script, so you can get detailed manual by `actions/c2l/src/py/01.estimate.signatures.py -h`. Edit file and then submit it by `bsub < actions/c2l/src/01.run.estimate.signatures.sh` from ticket directory. It runs array job, one item per reference.

## Deconvolution
The second step can be submitted only when first step was finished succesfully. Check QC plots in `ref/*` subfolders. Bsub script for second step is `actions/c2l/src/02.run.predict.cell.abundancies.sh`, that calls `actions/c2l/src/py/02.predict.cell.abundancies.py` internaly. Edit `02.run.predict.cell.abundancies.sh` to include all references, all desired alpha levels and other parameters, use `actions/c2l/src/py/02.predict.cell.abundancies.py -h` to get help. Submit job by `bsub < actions/c2l/src/02.run.predict.cell.abundancies.sh` from ticket directory. It runs array job, one item per reference/alpha combitation.

## QC
Currently there are no numeric QC metrics for cell2location performance. Cell2location produces some QC plots related to training and observed vs predicted comparison, they can be found in subfolders in `ref` and `pred`. `actions/c2l/src/03.plot.c2l.R` can be used to make for additional QC: plot UMI distribution across spots and plot predicted cell abundancies.

# Output
Resuls of pipeline are outputed into three folders:
1. `ref` contains cell2location references, they potentially can be used with other visium samples.
2. `pred` contains results of visium deconvolution: cell type abundancies in csv format. 
3. `figures` contains QC figures.

# Sharing of results
Use `actions/c2l/src/04.share.sh` to share results with customer. The script outputs template of message to be sent to the customer. Edit it accordingly to the request.
