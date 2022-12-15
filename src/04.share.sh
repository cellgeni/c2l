#!/bin/bash -e


tic=`pwd | grep -o '[^/]*$'`
name=`cut -f2 actions/SUBMITTER`

cp -r pred /warehouse/cellgeni/$tic/
cp -r ref /warehouse/cellgeni/$tic/
cp -r figures /warehouse/cellgeni/$tic/

echo "data were copied to /warehouse/cellgeni/$tic"
echo "==========================="

echo "Hi [~@$name],"
echo "The analysis is finished, you can find results here: /warehouse/cellgeni/$tic, predictions are in pred subfolder. Several variants of prediction are available, they are combinations of following factors:"
echo "1) detection alpha 20 or 200"
echo "2) all celltypes or only celltypes with number of cells above 20 (filtered)"
echo "3) with or without percent_mito covariate (mt)"
echo 
echo "Vitalii suggest to use alpha=20 (but previous recommendation was 200)."
echo
echo "Outputs of c2l are stored as csv files, recommended estimates of cell abundances are in predmodel/q05_cell_abundance_w_sf.csv."
echo "There are some summary figures in figures subfloder and QC figures in prediction subfolders."
echo
echo "Please let me know if you have any questions or requests."
