#!/usr/bin/gawk -f

# @include "functions.awk"

BEGIN {
	OFS = "\t"
}

# {print "FNR:", FNR, "NR:", NR > "/dev/stderr" }

## READ POPFILE
FNR == NR {
	if (NF != 2) {
		print "Error: Popfile expected to have 2 columns delimited by whitespace!" > "/dev/stderr"
		print "Check delimiter and/or whitespace in names." > "/dev/stderr"
		exit 1
	}
	## read popfile into array (2 columns with ind and pop names)
	## bouncing ideas here...
	ind = $1
	pop = $2
	ind2pop[ind] = pop # easySFS.py:536
	# pops[pop].append(ind) # python3

	inds[FNR] = $1 # num-indexed array of sample names
	pops[FNR] = $2 # num-indexed array of pop names
	#upops[$2]++ # unique pops
	#ipops[$2][++i] = FNR + 4 # pop indices

	## outgroup array
	if (pop == "outgroup") {
		outgroup[++o] = FNR + 4 # num-indexed list of column idx
	} else {
		## save non-outgroup pops
		ipops[pop][++i] = FNR + 4 # pop indices
	}
	nind = FNR # num of inds
	next
}

## READ DATA HEADER
FNR == 1 {
	## VALIDATIONS..
	## check if "outgroup" is present in popfile
	#if ("outgroup" in ipops) {
	if (outgroup) {
		print "An outgroup found, OK!" > "/dev/stderr"
	} else {
		print "Error: No outgroup found!" > "/dev/stderr"
		exit 1
	}

	## check if columns match popfile
	# print length(inds), NF > "/dev/stderr"
	if (length(inds) != NF - 4) {
		print "Error: Samples mismatch between popfile and datafile!" > "/dev/stderr"
		exit 1
	}

	## prepare header
	allpops = ""; sep = ""
	for (i = 1;  i in pops; i++) {
		if (!seen[pops[i]]++) {
			upops[++j] = pops[i] # unique pops
			allpops = allpops sep pops[i]; sep = "\t"
		}
	}
	print "chrom", "pos", "ref", "alt", "aa", "da", allpops
}

{
	## TODO
	## get outgroup GT and set aa & da

	## iterate over pops in order
	for (pop = 1; pop in upops; pop++) {
		## iterate over samples in pop
		gt = ""
		for (s in ipops) {
			## concat genotypes
			#gt = gt ipops[upops[pop]][s]
			gt[pop] += gsub(da, "", ipops[upops[pop]][s])
		}
		# dac = gsub(da, "", gt)
		# aac = gsub(aa, "", gt)
	}
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
