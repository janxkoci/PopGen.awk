#!/usr/bin/env Rscript

# library(seqinr)

## ARGS
args <- commandArgs(trailingOnly=TRUE)
if (length(args) != 2) stop("Two input files must be supplied.", call.=FALSE)

## INPUT
fastafile <- grep(".fa", args, val=T) # args[1] # "mez1_chr21-22.fa"
snpfile <- grep(".tsv", args, val=T) # args[2] # "hgdp_chr21-22_pos.tsv"

if (length(fastafile) != 1) stop("Check your fastafile! [.fa|.fasta]", call.=FALSE)
if (length(snpfile) != 1) stop("Check your snpfile! [.tsv]", call.=FALSE)

fastaname <- tools::file_path_sans_ext(fastafile) # basename(fastafile)
# snpname <- tools::file_path_sans_ext(snpfile)

if(grepl(".gz", fastafile)) {
	fastaname <- tools::file_path_sans_ext(fastafile, compression = T) # basename(fastafile)
	fastafile <- gzfile(fastafile)
}
if(grepl(".gz", snpfile)) {
	snpfile <- gzfile(snpfile)
	# snpname <- tools::file_path_sans_ext(snpfile, compression = T)
}

## READ DATA
fas <- seqinr::read.fasta(fastafile, forceDNAtolower = F)
sites <- read.table(snpfile, sep="\t")

sites[,3] <- NA
colnames(sites) <- c("CHROM", "POS", basename(fastaname))

## LOOP
chroms <- unique(sites[,1])

for(chr in chroms) {
    chrs <- as.character(chr)
    pos <- sites[sites[,1]==chrs, 2]
    
    sites[which(sites[,1]==chr),3] <- fas[[chrs]][pos]
}

## MASK lowercase BASES
# sites[which(grepl("[acgtn-]", sites[,3])),] <- "N" # TEST THIS

## alternatively mask later with awk
## awk '$3~/[acgtn-]/ {$3="N"}1'

## WRITE OUTPUT
# write.csv(sites, paste0(fastaname, ".csv"))
write.table(sites, paste0(fastaname, ".tsv"), quote=F, sep="\t", row.names=F)
