#!/usr/bin/awk -f

## awk -f eigenstrat2vcf.awk SGDP/SGDP.v2

function usage()
{
	print "Please provide prefix for eigenstrat files." > "/dev/stderr"
	print "usage: eigenstrat2vcf prefix" > "/dev/stderr"
	exit 1
}

BEGIN {
	OFS = "\t"

	## args
	if (ARGC != 2) # indexing starts at 0
		usage()

	prefix = ARGV[1]
	ARGV[1] = "" # don't let awk use it as file

	## input prefix
	#prefix = prefix == "" ? "SGDP/SGDP.v2" : prefix # default prefix
	indfile = prefix".ind"
	snpfile = prefix".snp"
	genofile = prefix".geno"

	## read ind file
	idx = 1
	while ((getline line < indfile) > 0) {
		split(line, fields, FS)
		samples[idx] = fields[3]"_"fields[1] # TODO look in VCF spec for more useful separator
		idx++
	}
	close(indfile)
	## concat sample names into a string
	allinds = ""; sep = ""
	for (i = 1;  i in samples; i++) {allinds = allinds sep samples[i]; sep = "\t"}

	## VCF HEADER
	print "##fileformat=VCFv4.2"
	print "##source=eigenstrat2vcf.awk"
	print "##INFO=<ID=CH,Number=0,Type=Flag,Description=\"REF allele polarized by chimp (panTro6) aligned to hg19. Repeats are lowercase.\">"
	print "##FORMAT=<ID=GT,Number=1,Type=String,Description=\"Genotype\">"
	print "#CHROM", "POS", "ID", "REF", "ALT", "QUAL", "FILTER", "INFO", "FORMAT", allinds

	## VCF BODY
	## genotypes dict
	gtcodes[9] = "./." ## missing
	gtcodes[2] = "0/0" ## ref homozygous
	gtcodes[1] = "0/1" ## heterozygous
	gtcodes[0] = "1/1" ## alt homozygous

	## read snp file
	while ((getline < snpfile) > 0) { ## columns 1..6 are available with $1..$6
		## read geno file
		getline genotypes < genofile
		## split to array
		split(genotypes, gts, "")
		## scan genotypes
		for(i = 1; i in gts; i++) {
			if (gts[i] in gtcodes) {
				gts[i] = gtcodes[gts[i]]
				continue
			}
			#printf gts[i]
		}
		## concat array elements into string
		allgts = ""; sep = ""
		for (i = 1;  i in gts; i++) {allgts = allgts sep gts[i]; sep = "\t"}

		## print chrom, pos, id, ref, alt, etc..
		print $2, $4, $1, $5, $6, ".", ".", "CH", "GT", allgts #gts[1], gts[2]
	}
}
