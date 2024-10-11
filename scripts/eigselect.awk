#!/usr/bin/awk -f

function usage()
{
	print "usage: eigselect.awk keeplist inprefix outprefix" > "/dev/stderr"
	exit 1
}

BEGIN {
	## args
	if (ARGC != 4) # indexing starts at 0
		usage()

	keeplist = ARGV[1]
	inprefix = ARGV[2]
	outprefix = ARGV[3]
	ARGV[1] = ARGV[2] = ARGV[3] = ""

	## input
	indfile = inprefix".ind"
	snpfile = inprefix".snp" # output will stay the same
	genofile = inprefix".geno"

	## write snp file (unchanged)
	## use symlink to save disk space
	shell = "/bin/bash"
	#print "cp", snpfile, outprefix".snp" | shell
	print "ln -s", snpfile, outprefix".snp" | shell
	close(shell)

	while ((getline < keeplist) > 0) {
		keepinds[$0]++
	}
	close(keeplist)

	idx = 1
	while ((getline < indfile) > 0) {
		nind++
		if ($1 in keepinds) {
			keep[idx] = idx
			print $0 > outprefix".ind"
		}
		idx++
	}
	close(indfile)
	close(outprefix".ind")

	while ((getline genotypes < genofile) > 0) {
		split(genotypes, gts, "")
		for (i = 1; i <= nind; i++) {
			if (i in keep) {allgeno = allgeno "" gts[i]}
		}
		print allgeno > outprefix".geno"
		allgeno = ""
	}
	close(genofile)
	close(outprefix".geno")
}
