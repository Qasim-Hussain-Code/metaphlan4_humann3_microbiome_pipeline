#!/bin/bash
# Automatically navigate to the repository root relative to this script
cd "$(dirname "$0")/.."

echo "=== Step 1: Normalizing Gene Families to CPM ==="
humann_renorm_table --input results/demo_genefamilies.tsv \
                    --output results/demo_genefamilies_cpm.tsv \
                    --units cpm

echo "=== Step 2: Normalizing Pathway Abundances to CPM ==="
humann_renorm_table --input results/demo_pathabundance.tsv \
                    --output results/demo_pathabundance_cpm.tsv \
                    --units cpm

echo "=== Step 3: Sorting Clean Matrices into Repository Framework ==="
mv results/demo_genefamilies.tsv results/demo_genefamilies_cpm.tsv results/gene_families/
mv results/demo_pathabundance.tsv results/demo_pathabundance_cpm.tsv results/demo_pathcoverage.tsv results/pathways/

echo "=== Done! Normalized files are sorted into results/ ==="
