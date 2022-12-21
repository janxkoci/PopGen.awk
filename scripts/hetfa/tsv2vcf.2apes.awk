#!/usr/bin/awk -f

## PROCESS apes
## reads file with 5 columns:
## chrom pos hg19.REF chimp.GT gorilla.GT
BEGIN {
	OFS = "\t"

	## VCF HEADER
	print "##fileformat=VCFv4.2"
	print "##source=tsv2vcf.2apes.awk"
	print "##INFO=<ID=HG,Number=0,Type=Flag,Description=\"REF allele based on hg19 genome assembly. Repeats are lowercase.\">"
	print "##FORMAT=<ID=GT,Number=1,Type=String,Description=\"Genotype\">"
	# TODO "getline FILENAME" to extract contig names
	# actually bcftools merge will do it for you, so don't bother
}

## VCF COLUMNS
NR == 1 {
	print "#CHROM", "POS", "ID", "REF", "ALT", "QUAL", "FILTER", "INFO", "FORMAT", $4, $5
	next
}

## MASK MISSING bases with "."
NR > 1 {
	for (i = 4; i <= NF; i++) {
		sub(/[n-]/, ".", $i)
	}
}

## MASK LQ bases with "."
## but only at mismatch sites
toupper($4) != toupper($5) {
	for (i = 4; i <= NF; i++) {
		sub(/[acgt]/, ".", $i)
	}
}

## CONVERT GTs to VCF style format
## matching GTs
toupper($4) == toupper($5) {
	gts = toupper($4$5)
	if (gts ~ /\./) {
		chimp = "./."
		gorilla = "./."
		alt = "."
	} else if (gts ~ toupper($3)) {
		chimp = "0/0"
		gorilla = "0/0"
		alt = "."
	} else {
		chimp = "1/1"
		gorilla = "1/1"
		alt = toupper($4)
	}
}

## non-matching GTs
toupper($4) != toupper($5) {
	gts = toupper($4$5)
	if (gts ~ /\./ && gts ~ toupper($3)) {
		for (i = 4; i <= 5; i++) {
			sub(/\./, "./.", $i)
			sub(/[a-zA-Z]/, "0/0", $i)
		}
		chimp = $4
		gorilla = $5
		alt = "."
	} else if (gts ~ /\./ && gts !~ toupper($3)) {
		for (i = 4; i <= 5; i++) {
			sub(/\./, "./.", $i)
			sub(/[a-zA-Z]/, "1/1", $i)
		}
		chimp = $4
		gorilla = $5
		alt = gensub(/\./, "", 1, gts)
	} else if (gts ~ toupper($3)) {
		for (i = 4; i <= 5; i++) {
			sub(toupper($3), "0/0", $i)
			alt = gensub(toupper($3), "", 1, gts)
			sub(alt, "1/1", $i)
		}
		chimp = $4
		gorilla = $5
		#alt = gensub(toupper($3), "", 1, gts)
	} else {
		chimp = "1/1"
		gorilla = "2/2"
		alt = $4","$5
	}
}

## PRINT VCF-like format
# CHROM POS ID REF ALT QUAL FILTER INFO FORMAT
NR > 1 {
	print $1, $2, ".", $3, alt, ".", ".", "HG", "GT", chimp, gorilla
}
