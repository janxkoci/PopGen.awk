#!/usr/bin/awk -f

function usage()
{
    print "usage: vcfcountgt.awk [input.vcf|stdin]" > "/dev/stderr"
    exit 1
}

BEGIN {
    OFS = "\t"

    if (ARGC != 2) # may not work with stdin
        usage()
}

/##/ {
    next
}

/#CHROM/ {
    ## check number of columns
    if (NF < 10) {
        print "VCF has no sample data!" > "/dev/stderr"
        err_exit = 1
        exit 1
    }
    ## collect sample names
    for (col = 10; col <= NF; col++) {
        samples[col] = $col ## samples[10] = "Href"
    }
}

!/#/ {
    ## check FORMAT contains genotypes (GT)
    if ($9 !~ /GT/) {
        print "VCF has no GT data at position: " $1 ":" $2 "!" > "/dev/stderr"
        err_exit = 1
        exit 1
    }
    ref = $3
    #alt = $4 ## FIXME multiallelic (use split($4, alt, ",") - num index fits alleles)
    ## parse genotypes
    for (col = 10; col <= NF; col++) {
        ## split sample data to array (GT is first per VCF spec)
        split($col, gt, ":")
        ## save per-sample GT counts
        gts[col, gt[1]]++ ## gts[10, "0/0"] += 1
        #gts[col][gt[1]]++ ## gawk

        ## WIP: translated genotypes (TGT)
        #tgt = gt[1]
        #gsub(/0/, ref, tgt)
        #gsub(/1/, alt, tgt)
        #tgts[col][tgt]++
    }
}

END {
    if (err_exit)
        exit 1
    ## header
    print "sample", "gt", "count"
    ## loop over samples
    for (g in gts) {
        split(g, idx, SUBSEP)
        ## print sample, GT, count
        print samples[idx[1]], idx[2], gts[g]
    }
}