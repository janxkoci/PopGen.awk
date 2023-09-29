#!/usr/bin/awk -f

## convert Href.fa
## reads file with 3 columns:
## chrom pos hg19.REF
## made with bioawk:
## bioawk -c fastx -v OFS="\t" 'NR==1 {print "chrom", "pos", FILENAME} $name < 23 {split($seq,nucs,""); for(n=1; n in nucs; n++) {print $name, n, nucs[n]}}' Href.fa > allsites_Href.tsv

BEGIN {
OFS="\t"

## VCF HEADER
print "##fileformat=VCFv4.2"
print "##source=href2vcf.awk"
print "##INFO=<ID=HG,Number=0,Type=Flag,Description=\"REF allele based on hg19 genome assembly. Repeats are lowercase.\">"
print "##FORMAT=<ID=GT,Number=1,Type=String,Description=\"Genotype\">"
# TODO "getline FILENAME" to extract contig names
# actually bcftools merge will do it for you, so don't bother
}

## VCF COLUMNS
NR==1 {print "#CHROM","POS","ID","REF","ALT","QUAL","FILTER","INFO","FORMAT",$3; next}

$3 ~ /N/ {
	ref = "N"
	alt = "."
	gt = "./."
}

$3 ~ /[ACGTMR]/ {
	ref = $3
	alt = "."
	gt = "0/0"
}

# $3 ~ /M/ {
	# ref = "C"
	# alt = "A"
	# gt = "0/1"
# }
# 
# $3 ~ /R/ {
	# ref = "A"
	# alt = "G"
	# gt = "0/1"
# }

## PRINT VCF-like format
# CHROM POS ID REF ALT QUAL FILTER INFO FORMAT
NR>1 {print $1,$2, ".", ref,alt,".",".","HG","GT",gt}
