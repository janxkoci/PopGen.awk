# PopGen.awk
Collection of awk scripts for population &amp; evolutionary genomics. Maybe a library later.

**Motivation:** Even though existing tools sometimes claim to do what I need, I often find they do it wrongly, or just not the way I need. Since I like coding, I started to write my own scripts in awk, a simple scripting language designed to process structured textual data - exactly the kind we see in genomics. I'm now arriving to the point when managing my scripts in separate gists is not efficient any more and so I'm making this repository to keep the scripts in one place and to make code reuse easier.

**Note:** Some scripts may be optimized for different _flavours_ of awk (like mawk, or bioawk). Some may _require_ a particular flavour (like gawk or bioawk). Also some R or miller may show up here. I will do my best to make clear which awk flavour should be used with each script. For now, I typically use the shebang and file extension to indicate if a particular awk flavour is required.

All the awk flavours used here are easy to install with package managers like conda or brew.