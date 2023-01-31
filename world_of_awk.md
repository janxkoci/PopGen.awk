# The world of ~~awe~~ AWK
The history of the AWK language goes back to the 70's, and over the years multiple implementations appeared. Some information on the internets can be outdated or confusing to beginners, so here is a quick overview, relevant for this repository.

First, when I say "AWK" I mean the language, while `awk` is a program that interprets the code written in the AWK language, and executes it. Several such interpreters exist and compatibility between them may be an issue (but it's manageable). In the past, AWK had some limitations, that were later addressed by what is called "new awk", or `nawk`. All the versions discussed here are interpreters of the "new awk".

**The POSIX standard** provides a specification of the AWK language, and all major interpreters support this standard. Thus, a "POSIX-compliant" script can be run using any of these interpreters. Moreover, most interpreters provide some **extensions** on top of this standard.

For the code in this repository, the following interpreters are the most relevant:

- **BWK AWK**, also called the "one true awk", is generally considered the baseline implementation, although it also sports a few non-standard extensions. It's maintained by Brian Kernighan, one of the original authors of AWK. It is the default AWK version on macOS.
- **`mawk`** is a _very fast_ bytecode interpreter developed by Mike Brennan. Older versions may be buggy, but the version `1.3.4` is stable, POSIX-compliant, and also provides a few extensions. It's currently maintained by Thomas Dickey. Version 2 is also in development by Mike Brennan, but is not commonly packaged by any distribution and needs to be manually compiled from Github (I failed trying). I personally avoid any version other than `1.3.4`, at least for the time being. It is the default AWK interpreter on Ubuntu Linux.
- **GNU awk**, also known as `gawk`, is the most advanced version, feature-wise. Besides its POSIX and "traditional" modes, it provides many new extensions and features, bringing the AWK language on par with other scripting languages like Perl or Python. It's also the only version supporting locales and Unicode! It is actively developed by Arnold Robbins and other collaborators. It is often the default version on many Linux versions (notably excluding Ubuntu, where `mawk` is the default). **_If in doubt, use this version._**
- **`bioawk`** is an extension of BWK AWK for biologists, developed by Heng Li. It provides support for several common bioinformatic formats (FASTA, FASTQ, SAM, BED, GFF, VCF), as well as TSV with headers (where column names can be used in place of standard numeric names). Also supports gzipped input (again, very common in bioinformatics).

Even more comprehensive list can be found in the [GNU `awk` manual](https://www.gnu.org/software/gawk/manual/html_node/Other-Versions.html).

**To summarize:** Even though `gawk` is the most comfortable to use, providing extra convenient functions, I usually try to write in POSIX, if possible, so I can use the speedy `mawk`. But sometimes `gawk` is more easy or elegant. I haven't written any scripts in `bioawk` (yet) - for now I mostly use it for one-liners.

I will do my best to make clear which AWK flavour should be used with each script. For now, I typically use the shebang and the file extension to indicate if a particular AWK flavour is _required_.

All the AWK flavours used here are easy to install with package managers like `conda` or `brew`.