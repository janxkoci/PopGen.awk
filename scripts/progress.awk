#!/usr/bin/awk -f

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
