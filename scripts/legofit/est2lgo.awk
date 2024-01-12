#!/usr/bin/awk -f

## USAGE
## awk -f est2lgo.awk model_est.txt model.lgo

BEGIN {OFS="\t"}

# read EST file and save param values into array
# note: array includes also header, but that won't match, so nobody cares
NR==FNR {a[$1]=$2; next}

# read LGO file and apply param values
$2=="free" {
	# rewrite name of current free param into $3
	sub(/=[0-9].*/,"",$3) # POSIX
	# take value for current param from the array and assign formatted value to $3
	val=a[$3]
	$3=$3"="val
}1 # print non-matching lines too
