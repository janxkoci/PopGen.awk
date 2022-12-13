# Scripts

## eigenstrat2vcf.awk
Converts files in EIGENSTRAT format to a GT-only VCF, preserving any polarization by outgroup, such as chimp. The EIGENSTRAT format is produced e.g. by `ctools`, a package of tools to manipulate the SGDP-lite dataset. This format consists of three files:

 - a genotype matrix (`.geno`),
 - a list of sites (`.snp`),
 - and a list of samples (`.ind`).

The three-file format typically uses a shared name **prefix**, which is provided to the `awk` script as a parameter:

    awk -f eigenstrat2vcf.awk -v prefix="SGDP.v2" | bgzip --threads 4 > SGDP.v2.vcf.gz

The script is POSIX compliant, so `mawk` can be used for extra speed. The output is a minimal-but-valid VCF (e.g. `bcftools` accepts it and so can be used to add missing annotations, if need be).

