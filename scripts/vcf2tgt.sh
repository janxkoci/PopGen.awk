#!/bin/bash

VCF=$1

bcftools query -Hf '%CHROM\t%POS\t%REF\t%ALT[\t%TGT]\n' $VCF

