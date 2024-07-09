#!/bin/bash -e

while read -r name line; do
	#name=`basename $line`
	echo "download $name"
	mkdir $name
	cd $name
	iget -r $line/web_summary.html
	iget -r $line/spatial
	iget -r $line/filtered_feature_bc_matrix
	iget -r $line/filtered_feature_bc_matrix.h5
	iget -r $line/raw_feature_bc_matrix
	iget -r $line/raw_feature_bc_matrix.h5
	iget -r $line/cloupe.cloupe
	iget -r $line/_cmdline
	iget -r $line/metrics_summary.csv
	cd ..
done
