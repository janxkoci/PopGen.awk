#!/usr/bin/awk -f

## usage: while ((vcfreader(filename) | getline) > 0)

function vcfreader(filename,    command)
{
    ## VCF.GZ
    if (filename ~ /\.gz$/) {
		command = "zcat "filename
	## BCF
	} else if (filename ~ /\.bcf$/) {
		command = "bcftools view "filename
	## VCF
	} else {
	    command = "cat "filename
	}
    return command
}

function getsamples(line,    s)
{
	if (line ~ /#CHROM/) {
		for (s = 10; s <= NF; s++) return $s
	}
}
