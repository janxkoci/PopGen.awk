#!/usr/bin/awk -f

## TODO
## define functions uniq, arr2str, dac, daf, aac, aaf
## it will make input clear, so i know how to get it

## arr2str
# see https://stackoverflow.com/a/60157991/5184574
function arr2str(arr,    str, sep, i)
{
    for (i = 1; i in arr; i++) {
        str = str sep arr[i]; sep = "\t" #sprintf(" %s:\"%s\"", i, arr[i])
    }
    return str
}

# get unique values from array
function uniq(arr,    unique, seen, i)
{
	for (i=1; i in arr; i++) {
		if ( !seen[arr[i]]++ ) {
			unique[++j] = arr[i]
		}
	}
	return unique # I think it cannot return array like this!
}

## not good
function getalleles(outgroups,    alleles)
{
	#for (i in outgroups) {
		if ($outgroups[1] ~ /\./) {
			next
		} else if ($outgroups[1] ~ /0/) {
			alleles[aa] = $3 # REF is ancestral
			alleles[da] = $4 # ALT is derived
		} else if ($outgroups[1] ~ /1/) {
			alleles[da] = $3 # REF is derived
			alleles[aa] = $4 # ALT is ancestral
		} else {
			print "Error: unknown genotype in outgroups!"
			exit 1
		}
	#}
	return alleles
}

function message(text)
{
	print text > "/dev/stderr"
}
