#!/usr/bin/gawk -f

## USAGE
## gawk -f derived.gawk popfile.tsv input.tsv

# @include "functions.awk"

BEGIN {
	OFS = "\t"
}

## READ POPFILE
FNR == NR {
	if (NF != 2) {
		message("Error: Popfile expected to have 2 columns delimited by whitespace!")
		message("Check delimiter and/or whitespace in names.")
		exit 1
	}
	## read popfile into array (2 columns with ind and pop names)
	## bouncing ideas here...
	ind = $1
	pop = $2

	## index of chimp
	if (tolower(ind) ~ /chimp|pantro/) {
		chimp = FNR + 4
	}
	## outgroup array
	if (pop == "outgroup") {
		outgroup[++o] = FNR + 4 # num-indexed list of column idx
	} else {
		## save non-outgroup pops
		pops[pop][++i] = FNR + 4 # pop indices (gawk only)
		## unique pop names
		if (!seen[pop]++) {
			## array of unique pops
			upops[++u] = pop
			## string of unique pops
			allpops = allpops sep pop; sep = OFS
		}
	}
	nind = FNR # num of inds
	next
}

## READ DATA HEADER
FNR == 1 {
	## VALIDATIONS..
	## check if "outgroup" is present in popfile
	if (isarray(outgroup)) {
		message("outgroup OK!")
	} else {
		message("Error: No outgroup found!")
		exit 1
	}

	## check if columns match popfile
	## TODO feature: subset samples by popfile
	if (nind != NF - 4) {
		message("Error: Samples mismatch between popfile and datafile!")
		exit 1
	}

	## print header
	print "chrom", "pos", "ref", "alt", "aa", "da", allpops
}

## READ DATA
FNR > 1 {
	## PROCESS OUTGROUP
	## check if all outgroups match chimp
	for (o in outgroup) {
		sample = outgroup[o]
		if ($sample != $chimp) {
			## skip to next position if not
			next
		}
	}
	## set alleles from outgroup GT
	if ($chimp ~ /\./) {		# chimp is missing
		next
	} else if ($chimp ~ /0/) {		# chimp is ref
		anc = 0
		der = 1
		aa = $3
		da = $4
	} else if ($chimp ~ /1/) {		# chimp is alt
		anc = 1
		der = 0
		aa = $4
		da = $3
	} else {
		message("Error: Unknown genotype in chimp! The file should be biallelic.")
		exit 1
	}

	## iterate over unique pops in order
	for (p = 1; p in upops; p++) {
		## reset dac & aac
		delete dac[p]; #delete aac[p]
		## iterate over samples in pop
		for (s in pops[upops[p]]) {
			column = pops[upops[p]][s]
			## count alleles within pop
			#aac[p] += gsub(anc, "", $column)
			dac[p] += gsub(der, "", $column)
		}
	}
	## PRINT DATA
	print $1, $2, $3, $4, aa, da, arr2str(dac)
}

## FUNCTIONS
## print message to stderr
function message(text)
{
	print text > "/dev/stderr"
}

## arr2str
## see https://stackoverflow.com/a/60157991/5184574
function arr2str(arr,    str, sep, i)
{
    for (i = 1; i in arr; i++) {
        str = str sep arr[i]; sep = OFS
    }
    return str
}

## TESTING
#FNR > 10 {exit}
