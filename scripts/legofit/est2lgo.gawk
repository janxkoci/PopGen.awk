#!/usr/bin/gawk -f

## USAGE
## gawk -f est2lgo.gawk model_est.txt model.lgo

BEGIN {OFS="\t"}

# read EST file and save param values into array
# note: array includes also header, but that won't match, so nobody cares
NR==FNR {a[$1]=$2; next}

# read LGO file and apply param values
$2=="free" {
	# save name of current free param into variable par
	par=gensub(/=[0-9].*/,"",1,$3) # GAWK ONLY
	# check the par against the array and assign formatted value to $3
	if (par in a) $3=par"="a[par]
}1 # print non-matching lines too
