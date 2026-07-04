# HUMAnN and MetaPhlAn Databases

This directory stores the database indexes required for taxonomic and functional profiling.

## Git-Ignored Notice
The full databases are very large (approximately 33 GB for the full MetaPhlAn database) and are git-ignored. This directory should only contain database indexes, not code.

## Directory Structure
* `chocophlan/`: ChocoPhlAn nucleotide database (for pangenome search)
* `uniref/`: UniRef protein database (for translated search)
* `metaphlan_db/`: MetaPhlAn marker database (for taxonomic profiling, only needed for full raw read runs)
