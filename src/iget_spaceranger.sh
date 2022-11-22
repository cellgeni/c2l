!/bin/bash -e

while read -r line; do
	name=`basename $line`
	echo "download $name"
	mkdir $name
	cd $name
	iget -r $line/raw_feature_bc_matrix
	iget -r $line/web_summary.html
	iget -r $line/spatial
	iget -r $line/filtered_feature_bc_matrix
	iget -r $line/filtered_feature_bc_matrix.h5
	iget -r $line/raw_feature_bc_matrix.h5
	cd ..
done
