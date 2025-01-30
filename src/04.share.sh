#!/bin/bash -e


tic=`pwd | grep -o '[^/]*$'`
name=`cut -f2 actions/SUBMITTER`

echo "Hi [~${name}],"
echo "The analysis is finished, you can find results here: /lustre/scratch127/cellgen/cellgeni/tickets/$tic, predictions are in pred subfolder. Several variants of prediction are available, they are combinations of following factors:"
echo "1) detection alpha 20 or 200"
echo "2) all celltypes or only celltypes with number of cells above 20 (filtered)"
echo "3) different annotation"
echo "4) different covariates"
echo 
echo "Vitalii suggest to use alpha=20 (but previous recommendation was 200)."
echo
echo "Outputs of c2l are stored as csv files, recommended estimates of cell abundances are in predmodel/q05_cell_abundance_w_sf.csv.  Alternatively you can use predmodel/sp.h5ad output."
echo "There are some summary figures in figures subfloder and QC figures in prediction subfolders."
echo
echo "Reference signatures can in found in red fubfolder"
echo
echo "Please let me know if you have any questions or requests."
