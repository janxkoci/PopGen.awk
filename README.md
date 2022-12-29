# PopGen.awk
Collection of AWK scripts for population &amp; evolutionary genomics. Maybe a library later.

**Motivation:** Even though existing tools sometimes claim to do what I need, I often find they do it [incorrectly](https://github.com/vcflib/vcflib/issues/313), or just not the way [I need](https://github.com/DReichLab/AdmixTools/tree/master/convertf). Since I like coding, I started to write my own scripts in AWK, a simple scripting language designed to process structured textual data - exactly the kind we see in genomics. As my scripts started to grow in numbers, managing them in separate gists was getting clumsy and so I've made this repository to keep the scripts in one place, and to make code reuse easier. Besides AWK, some R or Miller may show up here too.

## Dependencies
I write in several _flavours_ of the AWK language (see [here for more details](./world_of_awk.md)).

All the AWK interpreters used in this repository can be easily installed with package managers like `conda` or `brew`. For example, you can use the following conda command to install all the necessary dependencies in a new environment:

	conda create -name popgen-awk --channel conda-forge --channel bioconda gawk mawk=1.3.4 bioawk miller r-base r-seqinr r-ape
	conda activate popgen-awk
