# c2l
Set of scripts to run cell2location on farm

# Usage
There are two steps:
1. Cell type signature estimation
2. Visium deconvolution

First step needs reference h5ad file with raw counts in adata.X, all covariates and cell annotation in adata.obs. Default name for input h5ad is ./ref.h5ad.
Second step needs results of the first step and h5ad with all visium samples combined. Default name for input visium is ./viss.h5ad

Two steps are independent and have to be submited to farm one by one using srs/01 and src/02 bash scripts. Usually input data are not well formated, so some preparation is needed. In this case src/check-n-prepare.input.h5ad.ipynb can be used.

Some QCs can be plotted by src/03.plot.c2l.R.
