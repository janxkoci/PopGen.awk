#!/usr/bin/awk -f

BEGIN {
	OFS = "\t"
	print "chrom_pos", "ref", "alt", "aa", "da", "Altai", "Denisova3", "Chagyrskaya", "Vindija", "Africa"
}

$4 == $5 {		# chimp matches gorilla
	
	## concatenate African genotypes to a string (columns 10..NF)
	afr = ""
	for(i = 10; i <= NF; i++) {
		afr = afr$i
	}

	## count derived alleles per pop
	## gsub() returns number of replacements in a string
	if ($4 ~ /\./) {		# chimp no data
		
		next

	} else if ($4 ~ /0/) {		# chimp has REF

		aa = $2 # REF
		da = $3 # ALT
		altai = gsub(1, "", $6)
		denis = gsub(1, "", $7)
		chagyr = gsub(1, "", $8)
		vindija = gsub(1, "", $9)
		africa = gsub(1, "", afr)

	} else if ($4 ~ /1/) {		# chimp has ALT
		
		aa = $3 # ALT
		da = $2 # REF
		altai = gsub(0, "", $6)
		denis = gsub(0, "", $7)
		chagyr = gsub(0, "", $8)
		vindija = gsub(0, "", $9)
		africa = gsub(0, "", afr)

	}
	
	print $1,$2,$3, aa, da, altai, denis, chagyr, vindija, africa #, afr

}
