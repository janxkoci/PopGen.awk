# Scripts

## derived.gawk
Takes a popfile and genotype table (produced with `bcftools query`, see below), and produces a new table with per-population derived allele counts, as defined in a popfile, using "outgroup" to define ancestral and derived alleles ("outgroup" **must be** one of the populations in the popfile).

Basic usage:

    gawk -f derived.gawk popfile.tsv genotypes.tsv > dac.tsv

Removal of missing data with `grep`:

    grep -vF './.' genotypes.tsv | gawk -f derived.gawk popfile.tsv - > dac.tsv

(Note the `-` in the second command, which stands for the `stdin` coming from `grep`.)

### Input files
The script needs two files to work - a popfile and a genotype file. Note that the file order is important - the popfile _must_ be listed before the genotype file. (I may implement handling named arguments (with `getopts`) but with only two arguments it's not a priority.)

#### popfile
A file with two columns (separated by whitespace, without header), with first column listing individuals and second column defining populations. Can be made in a speadsheet and exported as TSV, or e.g. from an eigenstrat `ind` file:

    awk '{print $1, $3}' data.eigenstrat.ind > popfile.tsv


#### genotype file
A whitespace-delimited file with four leading columns (CHROM, POS, REF, ALT), followed by variable number of columns with genotypes (GT) for each sample in the popfile (for now the number of samples in both files have to match). The genotype file can be produced using `bcftools query`:

    bcftools query -Hf '%CHROM\t%POS\t%REF\t%ALT[\t%GT]\n' input.vcf | sed '1s/# //' > genotypes.tsv

(Note that the `sed` command is necessary to fix the table header, which has `# ` at the beginning, producing extra column in the eyes of most tools, most notably `awk`!)

### Output postprocessing
The file can then be loaded into `R` to produce site pattern counts:

```R
library(tidyverse)

snps <- read_tsv("dac.tsv")

full <- snps %>% 
    group_by(Altai,Denisova3,Chagyrskaya,Vindija,Africa) %>% 
    summarise(count = n())
```
To filter only positions with G/C or A/T polymorphisms, we can use the following:

```R
filtered <- snps %>% 
    mutate(aa = toupper(aa), da = toupper(da), gt = paste0(aa, da)) %>% 
    subset(grepl("AT|TA|CG|GC", .$gt)) %>% 
    group_by(Altai,Denisova3,Chagyrskaya,Vindija,Africa) %>% 
    summarise(at_gc = n())
```

Finally, we can merge the two tables:

```R
final <- merge(full, filtered, all.x = TRUE)
write_tsv(final, "dac_tabulated.tsv")
```

## eigenstrat2vcf.awk
Converts files in EIGENSTRAT format to a GT-only VCF, preserving any polarization by outgroup, such as chimp. The EIGENSTRAT format is produced e.g. by `ctools`, a package of tools to manipulate the SGDP-lite dataset. This format consists of three files:

 - a genotype matrix (`.geno`),
 - a list of sites (`.snp`),
 - and a list of samples (`.ind`).

The three-file format typically uses a shared name **prefix**, which is provided to the `awk` script as a parameter:

    awk -f eigenstrat2vcf.awk -v prefix="SGDP.v2" | bgzip --threads 4 > SGDP.v2.vcf.gz

The script is POSIX compliant, so `mawk` can be used for extra speed. The output is a minimal-but-valid VCF (e.g. `bcftools` accepts it and so can be used to add missing annotations, if need be).

