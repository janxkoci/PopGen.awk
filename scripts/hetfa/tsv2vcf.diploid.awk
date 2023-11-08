#!/usr/bin/awk -f

## PROCESS diploid SGDP samples
## reads file with 4 columns:
## chrom pos hg19.REF SGDP-sample.GT
BEGIN {
	OFS = "\t"

	iupac["W"] = "AT"
	iupac["S"] = "CG"
	iupac["M"] = "AC"
	iupac["K"] = "GT"
	iupac["R"] = "AG"
	iupac["Y"] = "CT"
}

## VCF COLUMNS
NR == 1 {
	## VCF HEADER
	print "##fileformat=VCFv4.2"
	print "##source=tsv2vcf.diploid.awk"
	print "##INFO=<ID=HG,Number=0,Type=Flag,Description=\"REF allele based on hg19 genome assembly. Repeats are lowercase.\">"
	print "##FORMAT=<ID=GT,Number=1,Type=String,Description=\"Genotype\">"
	# TODO "getline FILENAME" to extract contig names
	# actually bcftools merge will do it for you, so don't bother

	print "#CHROM", "POS", "ID", "REF", "ALT", "QUAL", "FILTER", "INFO", "FORMAT", $4
	next
}

## just in case
$4 == $3 {
	gt = "0/0"
	alt = "."
}

$4 != $3 {
	## Q means Href
	if ($4 == "Q") {
		gt = "0/0"
		alt = "."
	## missing data
	} else if ($4 ~ /[nN-]/) {
		gt = "./."
		alt = "."
	## alt homozygous
	} else if ($4 ~ /[ACGT]/) {
		gt = "1/1"
		alt = $4
	## heterozygous
	} else if ($4 in iupac) {
		gt = iupac[$4]
		if (gt ~ $3) {
			alt = gt
			sub($3, "", alt)
			gt = "0/1"
		} else {
			split(gt, alts, "")
			alt = alts[1]","alts[2]
			gt = "1/2"
		}
	}
}

## PRINT VCF-like format
# CHROM POS ID REF ALT QUAL FILTER INFO FORMAT
NR > 1 {
	print $1, $2, ".", $3, alt, ".", ".", "HG", "GT", gt
}
