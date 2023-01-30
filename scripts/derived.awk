#!/usr/bin/gawk -f

# @include "functions.awk"

BEGIN {
	OFS = "\t"
}

# {print "FNR:", FNR, "NR:", NR > "/dev/stderr" }

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
	#ind2pop[ind] = pop # easySFS.py:536
	# pops[pop].append(ind) # python3

	#inds[FNR] = $1 # num-indexed array of sample names
	#pops[FNR] = $2 # num-indexed array of pop names
	#upops[$2]++ # unique pops
	#ipops[$2][++i] = FNR + 4 # pop indices

	## index of chimp
	if (tolower(ind) ~ /chimp|pantro/) {
		chimp = FNR + 4
	}
	## outgroup array
	if (pop == "outgroup") {
		outgroup[++o] = FNR + 4 # num-indexed list of column idx
	} else {
		## save non-outgroup pops
		pops[pop][++i] = FNR + 4 # pop indices
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
	#if ("outgroup" in pops) {
	if (isarray(outgroup)) {
		message("outgroup OK!")
	} else {
		message("Error: No outgroup found!")
		exit 1
	}

	## check if columns match popfile
	## TODO feature subset samples by popfile
	# print nind, length(inds), NF > "/dev/stderr"
	if (nind != NF - 4) {
		message("Error: Samples mismatch between popfile and datafile!")
		exit 1
	}

	## prepare header
	# allpops = ""; sep = ""
	# for (i = 1;  i in pops; i++) {
	# 	if (!seen[pops[i]]++) {
	# 		upops[++j] = pops[i] # unique pops
	# 		allpops = allpops sep pops[i]; sep = "\t"
	# 	}
	# }
	print "chrom", "pos", "ref", "alt", "aa", "da", allpops
}

FNR > 1 {
	## TODO
	## get outgroup GT and set aa & da
	for (o in outgroup) {
		sample = outgroup[o]
		if ($sample != $chimp) {
			next
		}
	}
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
		message("Unknown genotype in chimp!")
		exit 1
	}

	## iterate over unique pops in order
	for (p = 1; p in upops; p++) {
		## reset dac
		delete dac[p]
		## iterate over samples in pop
		for (s in pops[upops[p]]) {
			column = pops[upops[p]][s]
			## concat genotypes
			#gt = gt pops[upops[p]][s]
			aac[p] += gsub(anc, "", $column)
			dac[p] += gsub(der, "", $column)
		}
		# dac = gsub(da, "", gt)
		# aac = gsub(aa, "", gt)
	}
	print $1, $2, $3, $4, aa, da, arr2str(dac)
}

## TESTING
 FNR > 50 {exit}

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

## READ DATA
# FNR > 1 && $5 == $6 {		# chimp matches gorilla
	
# 	## concatenate African genotypes to a string (columns 11..NF)
# 	afr = ""
# 	for(i = 11; i <= NF; i++) {
# 		afr = afr$i
# 	}

# 	## count derived alleles per pop
# 	## gsub() returns number of replacements in a string
# 	if ($5 ~ /\./) {		# chimp no data
		
# 		next

# 	} else if ($5 ~ /0/) {		# chimp has REF

# 		aa = $3 # REF
# 		da = $4 # ALT
# 		altai = gsub(1, "", $7)
# 		denis = gsub(1, "", $8)
# 		chagyr = gsub(1, "", $9)
# 		vindija = gsub(1, "", $10)
# 		africa = gsub(1, "", afr)

# 	} else if ($5 ~ /1/) {		# chimp has ALT
		
# 		aa = $4 # ALT
# 		da = $3 # REF
# 		altai = gsub(0, "", $7)
# 		denis = gsub(0, "", $8)
# 		chagyr = gsub(0, "", $9)
# 		vindija = gsub(0, "", $10)
# 		africa = gsub(0, "", afr)

# 	}
	
# 	#print $1,$2,$3,$4, aa, da, altai, denis, chagyr, vindija, africa #, afr

# }
