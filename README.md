# PopGen.awk
> *Collection of AWK scripts for population &amp; evolutionary genomics. Maybe a library later.*

## Motivation
Even though existing tools sometimes claim to do what I need, I often find they do it [incorrectly](https://github.com/vcflib/vcflib/issues/313), or just not the way [I need](https://github.com/DReichLab/AdmixTools/tree/master/convertf). Since I like coding, I started to write my own scripts in AWK, a simple scripting language designed to process structured textual data - exactly the kind we see in genomics. As my scripts started to grow in numbers, managing them in separate gists was getting clumsy and so I've made this repository to keep the scripts in one place, and to make code reuse easier. Besides AWK, some R, Miller, or shell may show up here too.

## Dependencies
Most of the scripts here can be used with _any_ version of [modern `awk`](./world_of_awk.md) - if in doubt, **GNU awk (aka `gawk`)** should work well. GNU `awk` has the most features and directly supports libraries (although library support [can be coded](https://www.gnu.org/software/gawk/manual/html_node/Igawk-Program.html) with other `awk`s too).

However, some scripts may _require_ a particular interpreter (such as `gawk` or `bioawk`). In such case I note this requirement with the script shebang and file extension (e.g. `.gawk` or `.bioawk`). I also use `mawk` for speed when I can.

All the AWK interpreters used in this repository can be easily installed with package managers like `conda` or `brew`. Moreover, I often use `bcftools query` to convert raw VCF into tabular format suitable for many of the scripts.

For example, you can use the following `conda` command to install all the necessary dependencies in a new environment:

```bash
conda create --name popgen-awk --channel conda-forge --channel bioconda gawk mawk=1.3.4 bioawk bcftools miller # r-base r-seqinr r-ape
conda activate popgen-awk
```
