# Raw Reads Directory

This folder stores the raw metagenomic sequence data (such as .fastq.gz, .sam, and .m8 files) used as input for the HUMAnN pipeline.

## Git-Ignored Notice
All sequence data files in this directory are git-ignored to keep the repository lightweight and prevent large files from being tracked in version control.

## Demo Files
The pipeline scripts automatically fetch the following demo files from the bioBakery repository if they are not already present:
* `demo.fastq.gz`: Raw metagenomic reads
* `demo.sam`: Pre-aligned SAM alignments (nucleotide search bypass)
* `demo.m8`: Pre-aligned BLAST/DIAMOND m8 alignments (translated search bypass)
