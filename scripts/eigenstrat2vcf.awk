#!/usr/bin/awk -f

## awk -f eigenfiles2vcf.awk -v prefix="SGDP/SGDP.v2"

BEGIN {
	OFS = "\t"

	## VCF HEADER
	print "##fileformat=VCFv4.2"
	print "##source=eigenfiles2vcf.awk"
	print "##INFO=<ID=CH,Number=0,Type=Flag,Description=\"REF allele polarized by chimp (panTro6) aligned to hg19. Repeats are lowercase.\">"
	print "##FORMAT=<ID=GT,Number=1,Type=String,Description=\"Genotype\">"
	# TODO "getline FILENAME" to extract contig names
	# actually bcftools merge will do it for you, so don't bother

	## input prefix
	prefix ==""?"SGDP/SGDP.v2":prefix # doesn't seem to work - provide '-v prefix=' 
	indfile = prefix".ind"
	snpfile = prefix".snp"
	genofile = prefix".geno"

	## read ind file
	idx = 1
	while ((getline line < indfile) > 0) {
		split(line, fields, FS)
		samples[idx] = fields[3]"_"fields[1]
		idx++
	}
	## concat sample names into a string
	allinds = ""; sep = ""
	for (i = 1;  i <= length(samples); i++) {allinds = allinds sep samples[i]; sep = "\t"}
	## print VCF colnames
	print "#CHROM", "POS", "ID", "REF", "ALT", "QUAL", "FILTER", "INFO", "FORMAT", allinds

	## read snp file
	while ((getline < snpfile) > 0) { ## columns 1..6 are available with $1..$6
		## read geno file
		getline genotypes < genofile
		## split to array
		split(genotypes, gts, "")
		## scan genotypes
		for(i = 1; i <= length(gts); i++) { ## for(i=5;i<=NF;i++) gsub(/0/,$3,$i) gsub(/1/,$4,$i); print
			gtcodes[9] = "./."
			gtcodes[2] = "0/0"
			gtcodes[1] = "0/1"
			gtcodes[0] = "1/1"
			
			if (gts[i] in gtcodes) {
				gts[i] = gtcodes[gts[i]]
				continue
			}
			#printf gts[i]
		}
		## concat array elements into string
		allgts = ""; sep = ""
		for (i = 1;  i <= length(gts); i++) {allgts = allgts sep gts[i]; sep = "\t"}

		## print chrom, pos, id, ref, alt, etc..
		print $2, $4, $1, $5, $6, ".", ".", "CH", "GT", allgts #gts[1], gts[2]
	}
}
