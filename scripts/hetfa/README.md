# Readme
I wrote these scripts to convert [HETFA](https://reichdata.hms.harvard.edu/pub/datasets/sgdp/) files (FASTA with IUPAC heterozygous bases) to VCF format, for merging with my other data. The data I have in HETFA format are low-coverage and hence do not actually contain heterozygous bases. Thus my scripts only deal with homozygous bases, which are much simpler to encode.

The standard tools for the job are [ctools](https://github.com/DReichLab/cTools), but they require extra files in formats I did not have, plus they only convert to eigenstrat format, which I would have to convert further (most likely to plink and only then to VCF, taking care of properly handling REF and ALT alleles along the way). That was already way more work than I considered necessary, so I wrote my own scripts.

## Workflow

There are three scripts:

1. `fasta2tsv.r`
2. `tsv2vcf.1sample.awk`
3. `tsv2vcf.2apes.awk`

First, the `R` script takes FASTA file and a TSV file as arguments and produces an updated version of the TSV file (with name based on the FASTA name). The input TSV file has two columns with positions of SNPs to be extracted from the FASTA. It can be produced e.g. as follows:

```
bcftools query -f '%CHROM\t%POS\n' input.vcf > input.tsv
```

The `R` script then adds a new column to this TSV with genotypes extracted from the FASTA.

This script should be run on each sample separately, and also on the hg19 genome assembly. The TSV of hg19 is later used to properly handle REF alleles during conversion to VCFs. To do this, it needs to be merged with each sample, e.g. like this:

```
paste hg19.tsv Mezmaiskaya1.tsv | cut -f 1-3,6 > Mezmaiskaya1_hg19.tsv
```

This gives us a TSV file with four columns: CHROM, POS, REF, GT. This is the input for the second `awk` script, which will convert it to a VCF file. It needs to be run on each sample separately (so I don't have to care about tracking multiple ALT alleles) and all samples are then merged with `bcftools merge`.

The 3rd script is specific to apes, as we needed to consider both chimp and gorilla variants together. In particular, we needed to mask LQ bases (encoded as lowercase letters), but only if the two apes do not match. The script again expects a TSV file as input, but this time it should have five columns: CHROM, POS, REF, chimp.GT, gorilla.GT.

## Performance notes
The scripts run quite fast even on whole-genome scale data. However, note that the `R` script loads all data into memory and the FASTA can take a few GB of RAM. The `awk` script on the other hand reads files line-by-line and has negligible RAM comsumption.
