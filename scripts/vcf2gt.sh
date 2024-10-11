#!/bin/bash

VCF=$1

bcftools query -Hf '%CHROM\t%POS\t%REF\t%ALT[\t%GT]\n' $VCF

