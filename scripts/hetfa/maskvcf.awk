# bioawk -c fastx '$name < 23 {split($seq, nucs, ""); for (n in nucs) print nucs[n]}' SGDP/B_Mandenka-3.ccompmask.fa.rz

function usage()
{
	print "usage: maskvcf.awk in.vcf mask" > "/dev/stderr"
	exit 1
}

BEGIN {
	OFS = "\t"

	## args
	if (ARGC != 3) # indexing starts at 0
		usage()

	VCF = ARGV[1]
	MASK = ARGV[2]
	ARGV[1] = ARGV[2] = "" # don't let awk use them as files

	## vcf reader
	if (VCF ~ /\.gz$/) {
		vcfread = "zcat "VCF
	} else {
		vcfread = "cat "VCF
	}

	## mask reader
	#maskread = "bioawk -c fastx '$name < 23 {split($seq, nucs, ""); for (n in nucs) print nucs[n]}' "MASK

	## read VCF
	while ((vcfread | getline) > 0) {
		## print VCF header
		if ($0 ~ /#/) {
			print
			continue
		}
		## mask sites
		if ($0 !~ /#/) {
			getline mask < MASK
			#maskread | getline mask
			if (mask ~ /[N0]/) {
				$10 = "./."
				#$7 = "masked"
				print $0 #, mask
			} else {
				print $0 #, mask
			}
		}
	}
}

###### working prototype ######
# ## print VCF header
# /#/ {
# 	print; next
# }
# ## mask sites
# !/#/ {
# 	getline mask < "B_Mandenka-3_chr21.mask"
# 	#print $0, mask
# 	if (mask ~ /[N0]/) {
# 		$10 = "./."
# 		#$7 = "masked"
# 		print $0 #, mask
# 	} else {
# 		print $0 #, mask
# 	}
# }
