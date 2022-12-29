#!/usr/bin/awk -f

BEGIN {
	OFS = "\t"
	print "chrom", "pos", "ref", "alt", "aa", "da", "Altai", "Denisova3", "Chagyrskaya", "Vindija", "Africa"
}

$5 == $6 {		# chimp matches gorilla
	
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
