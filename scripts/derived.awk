#!/usr/bin/awk -f

BEGIN {
	OFS = "\t"
}

## READ POPFILE
FNR == NR {
	# read popfile into array (2 columns with ind and pop names)
	inds[FNR] = $1
	pops[FNR] = $2
	upops[$2]++ # unique pops
	next
}

## READ DATA HEADER
FNR == 1 {
	## check if "outgroup" is present in popfile
	if ("outgroup" in pops) {
		continue # OK?
	} else {
		print "Error: No outgroup found!"
		exit 1
	}

	## check if columns match popfile
	if (length(inds) != NF - 4) {
		print "Error: Samples mismatch between popfile and datafile!"
		exit 1
	}

	## get unique pops
	## TODO define as function
	# for (i=1; i in array; i++) {
	# 	if ( !seen[array[i]]++ ) {
	# 		unique[++j] = array[i]
	# 	}
	# }

	## print header
	allpops = ""; sep = ""
	for (i = 1;  i <= length(upops); i++) {
		# FIXME
		# upops doesn't have numeric index, and also will be unsorted!
		# see https://stackoverflow.com/a/60157991/5184574
		allpops = allpops sep upops[i]; sep = "\t"
	}
	print "chrom", "pos", "ref", "alt", "aa", "da", allpops
}

## READ DATA
FNR > 1 && $5 == $6 {		# chimp matches gorilla
	
	## concatenate African genotypes to a string (columns 11..NF)
	afr = ""
	for(i = 11; i <= NF; i++) {
		afr = afr$i
	}

	## count derived alleles per pop
	## gsub() returns number of replacements in a string
	if ($5 ~ /\./) {		# chimp no data
		
		next

	} else if ($5 ~ /0/) {		# chimp has REF

		aa = $3 # REF
		da = $4 # ALT
		altai = gsub(1, "", $7)
		denis = gsub(1, "", $8)
		chagyr = gsub(1, "", $9)
		vindija = gsub(1, "", $10)
		africa = gsub(1, "", afr)

	} else if ($5 ~ /1/) {		# chimp has ALT
		
		aa = $4 # ALT
		da = $3 # REF
		altai = gsub(0, "", $7)
		denis = gsub(0, "", $8)
		chagyr = gsub(0, "", $9)
		vindija = gsub(0, "", $10)
		africa = gsub(0, "", afr)

	}
	
	print $1,$2,$3,$4, aa, da, altai, denis, chagyr, vindija, africa #, afr

}
