#!/usr/bin/awk -f

function usage()
{
	print "Please provide outgroup TSV and output prefix." > "/dev/stderr"
	print "usage: filters.awk in.tsv outprefix" > "/dev/stderr"
	exit 1
}

BEGIN {
	## args
	if (ARGC != 3) # indexing starts at 0
		usage()

	outprefix = ARGV[2]
	ARGV[2] = "" # don't let awk use it as file

	out_atgc = outprefix "_atgc.tsv"
	out_tv = outprefix "_tv.tsv"

	## dictionaries
	atgc["AT"] = "atgc"
	atgc["TA"] = "atgc"
	atgc["GC"] = "atgc"
	atgc["CG"] = "atgc"

	tv["AT"] = "tv"
	tv["TA"] = "tv"
	tv["GC"] = "tv"
	tv["CG"] = "tv"
	tv["AC"] = "tv"
	tv["CA"] = "tv"
	tv["GT"] = "tv"
	tv["TG"] = "tv"
}

## chimp has data
!/\./ {
	chimp = $5
	## match outgroups to chimp
	for (s = 6; s <= NF; s++) {
		sample = $s
		if (sample != chimp) {
			next
		}
	}
	## concat ref & alt
	gt = $3$4 
	## selectively write sites
	if (gt in atgc) {
		#print $0, gt
		print $0 >> out_atgc
	}
	if (gt in tv) {
		print $0 >> out_tv
	}
}
