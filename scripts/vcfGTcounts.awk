#!/usr/bin/gawk -f

BEGIN {
    OFS = "\t"
}

/##/ {
    next
}

/#CHROM/ {
    ## number of columns
    ncol = NF
    ## collect sample names
    for (col = 10; col <= NF; col++) {
        samples[col] = $col ## samples[10] = "Href"
    }
}

!/#/ {
    ## parse genotypes
    for (col = 10; col <= NF; col++) {
        ## split sample data to array (GT is first per VCF spec)
        split($col, gt, ":")
        ## save per-sample GT counts
        #gts[col, gt[1]]++ ## gts[10, "0/0"] += 1
        gts[col][gt[1]]++ ## gawk
    }
}

END {
    ## header
    print "sample", "gt", "count"
    ## loop over samples
    for (col = 10; col <= NF; col++) {
        ## loop over genotypes
        for (g in gts[col]) {
            ## print sample, GT, count
            print samples[col], g, gts[col][g]
        }
    }
}