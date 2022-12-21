#!/usr/bin/awk -f

## PROCESS LowCov ARCHAICS
## reads file with 4 columns:
## chrom pos hg19.REF archaic.GT

BEGIN {
OFS="\t"

## VCF HEADER
print "##fileformat=VCFv4.2"
print "##source=tsv2vcf.1sample.awk"
print "##INFO=<ID=HG,Number=0,Type=Flag,Description=\"REF allele based on hg19 genome assembly. Repeats are lowercase.\">"
print "##FORMAT=<ID=GT,Number=1,Type=String,Description=\"Genotype\">"
# TODO "getline FILENAME" to extract contig names
# actually bcftools merge will do it for you, so don't bother
}

## VCF COLUMNS
NR==1 {print "#CHROM","POS","ID","REF","ALT","QUAL","FILTER","INFO","FORMAT",$4}

## MASK LQ bases with "."
NR>1 {sub(/[acgtn-]/,".",$4)}

## CONVERT GTs to VCF style format
NR>1 {
	if($4==".")
		gt="./."
	else if($4==toupper($3))
		{gt="0/0"; $4="."}
	else
		gt="1/1"
}

## PRINT VCF-like format
# CHROM POS ID REF ALT QUAL FILTER INFO FORMAT
NR>1 {print $1,$2, ".", $3,$4,".",".","HG","GT",gt}
