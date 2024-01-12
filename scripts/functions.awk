#!/usr/bin/awk -f

## print message to stderr
function message(text)
{
	print text > "/dev/stderr"
}

## arr2str
## see https://stackoverflow.com/a/60157991/5184574
function arr2str(arr,    str, sep, i)
{
    for (i = 1; i in arr; i++) {
        str = str sep arr[i]; sep = OFS #sprintf(" %s:\"%s\"", i, arr[i])
    }
    return str
}

## get unique values from array
## FIXME
function uniq(arr,    unique, seen, i)
{
	## default separator
	#sep = sep == "" ? OFS : sep
	for (i=1; i in arr; i++) {
		if ( !seen[arr[i]]++ ) {
			unique[++j] = arr[i]
		}
	}
	return arr2str(unique)
	#return unique # I think it cannot return array like this!
}

## PROGRESS
## usage: {progress(NR)}
function progress(nr, step)
{
	## default step
	step = step == "" ? 1000 : step
	## print progress at step
	if (!(nr % step)) {
		printf "%d sites processed\r", nr > "/dev/stderr"
	}
}

## VCFREADER
## usage: {while ((vcfreader(filename) | getline) > 0)}
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

## FIXME
function getsamples(line,    s)
{
	if (line ~ /#CHROM/) {
		for (s = 10; s <= NF; s++) return $s
	}
}

## TODO
## define functions uniq, arr2str, dac, daf, aac, aaf
## it will make input clear, so i know how to get it

## FIXME
function getalleles(outgroups,    alleles)
{
	#for (i in outgroups) {
		if ($outgroups[1] ~ /\./) {
			next
		} else if ($outgroups[1] ~ /0/) {
			alleles[aa] = $3 # REF is ancestral
			alleles[da] = $4 # ALT is derived
		} else if ($outgroups[1] ~ /1/) {
			alleles[da] = $3 # REF is derived
			alleles[aa] = $4 # ALT is ancestral
		} else {
			print "Error: unknown genotype in outgroups!"
			exit 1
		}
	#}
	return alleles
}
