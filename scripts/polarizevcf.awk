#!/usr/bin/awk -f

BEGIN {
	OFS="\t"
	srand() # set new random seed
}

/##/ {
	print
	next
}

/#CHROM/ {
	## find chimp
	for (i = 10; i <= NF; i++) {
		if (tolower($i) ~ /chimp|pantro/)
			chimp = i
	}
	print
}

$5 ~ /,/ {next}

$chimp == "0|1" || $chimp == "1|0" {
    if (randint(2)) { # gives 0 or 1 with uniform prob
        $chimp = "0|0"
    } else {
        $chimp = "1|1"
    }
}

$chimp ~ /^1/ {
	#$7 = "chimped"
	## swap ref and alt
	ref = $4; alt = $5
	$4 = alt; $5 = ref
	## swap genotypes
	for (i = 10; i <= NF; i++) {
		gsub(/0/, "X", $i)
		gsub(/1/, "0", $i)
		gsub(/X/, "1", $i)
	}
	#print
}

$chimp ~ /^0/ {print}

{progress(NR)}

function progress(nr)
{
	if (!(nr % 1000)) {
		printf "%d sites processed\r", nr > "/dev/stderr"
	}
}

function randint(n)
{
    return int(n * rand())
}
