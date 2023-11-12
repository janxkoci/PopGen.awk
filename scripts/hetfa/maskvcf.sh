#!/bin/bash

## vcftools supports numeric FASTA for masking a VCF

#VCF=$1
#MASK=$2

#vcftools --gzvcf $VCF --invert-mask $MASK --mask-min 1 --stdout | bgzip > $(basename -s .vcf.gz $VCF).masked.vcf.gz # --invert-mask

for f in $(cat bantu_masks.txt)
do
	MASK=$f
	NAME=$(basename -s .ccompmask.fa.rz $f)
	NEWMASK=${NAME}.mask
	VCF=${NAME}.vcf.gz
	NEWVCF=${NAME}.masked.vcf.gz

	bioawk -c fastx '$name < 23 {split($seq, nucs, ""); for (n in nucs) print nucs[n]}' $MASK > $NEWMASK

	awk -f maskvcf.awk $VCF $NEWMASK | bgzip > $NEWVCF

	bcftools index $NEWVCF

	rm $NEWMASK
done
