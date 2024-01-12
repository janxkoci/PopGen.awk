#!/usr/bin/awk -f

function usage()
{
	print "Convert legofit model with estimates to slendr simulation script." > "/dev/stderr"
	print "usage: estlgo2slendr.awk model.lgo" > "/dev/stderr"
	err_exit = 1
	exit 1
}

BEGIN {
	if (ARGC != 2) # indexing starts at 0
		usage()

	print "library(slendr)"
	print "init_env()"
	print ""
	print "gentime <- 29"
	print "popsize <- 1000"
	print ""
	## create ancestor and outgroup
	print "anc <- population(name = \"anc\", N = popsize, time = 6.5e6/gentime, map = F)"
	print "chimp <- population(name = \"chimp\", N = popsize, time = (6.5e6/gentime)-1, parent = anc, map = F)"
}

## collect params
$1 == "time" {split($3, par, "="); tparams["t="par[1]] = par[2]}
$1 == "twoN" {split($3, par, "="); sparams["twoN="par[1]] = par[2]}
$1 == "mixFrac" {split($3, par, "="); mparams[par[1]] = par[2]}

## combine population segments
$1 == "segment" {if ($3 in tparams || $4 in sparams) {segments[$2] = "time = "tparams[$3]+1", N = "sparams[$4]/2}}
$1 == "segment" && $5 ~ /samples/ {samples[$2] = tparams[$3]}

## print populations with parents
$1 ~ /^derive|^mix$/ {if ($2 in segments) {print $2, "<- population(name = \""$2"\", "segments[$2]", parent = "$4", map = F)"; seen[$2]++}}

## gene flows
$1 == "mix" {msegs[$6] = $6" <- gene_flow(from = "$8", to = "$4", rate = "mparams[$6]", start = "tparams["t=T"$6]-1", end = "tparams["t=T"$6]-11")"}

## print gene flow info
#END {print ""; print "## admix", "generations", "proportion"; for (m in mparams) print "# "m, tparams["t=T"m], mparams[m]}
END {
	if (err_exit)
		exit 1
	## add the last parental population
	for (s in segments) {
		if (!(s in seen)) {print s " <- population(name = \""s"\", "segments[s]", parent = anc, map = F)"}
	}
	
	print ""
	## list of gene flows
	for (m in msegs) {
		print msegs[m]
		gflist = gflist sep m; sep = ", "
	}

	## list of populations
	sep = ""
	for (s in segments) {
		poplist = poplist sep s; sep = ", "
	}

	## sampling schedule
	sep = ""
	for (s in samples) {
		time = time sep samples[s]
		pop = pop sep "\""s"\""
		if (samples[s] == 0) {
			n = n sep 20	# modern samples
		} else {
			n = n sep 1	# archaic samples
		}
		sep = ", "
	}

	print ""
	print "sampling <- data.frame("
	print "\ttime = c(0, "time"),"
	print "\tpop = c(\"chimp\", "pop"),"
	print "\tn = c(1, "n"),"
	print "\tx = NA, y = NA, x_orig = NA, y_orig = NA"
	print ")"

	## model
	print ""
	print "model <- compile_model("
	print "\tpopulations = list(anc, chimp, "poplist"),"
	print "\tgene_flow = list("gflist"), generation_time = 1"
	print ")"
	print ""
	print "plot_model(model)"
	print ""
	print "#ts <- msprime(model, sequence_length = 10e6, recombination_rate = 1e-8, samples = sampling)"
	print ""
}
