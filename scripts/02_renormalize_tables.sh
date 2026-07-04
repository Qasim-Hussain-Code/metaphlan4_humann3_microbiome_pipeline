# 1. Normalize Gene Families matrix
humann_renorm_table --input results/demo_genefamilies.tsv \
                    --output results/demo_genefamilies_cpm.tsv \
                    --units cpm

# 2. Normalize Pathway Abundances matrix
humann_renorm_table --input results/demo_pathabundance.tsv \
                    --output results/demo_pathabundance_cpm.tsv \
                    --units cpm