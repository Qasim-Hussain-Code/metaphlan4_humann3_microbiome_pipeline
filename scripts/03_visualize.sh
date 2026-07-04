#!/bin/bash
# Automatically navigate to the repository root relative to this script
cd "$(dirname "$0")/.."

echo "=== Step 1: Generating Stratified Functional Barplot for PWY-5423 ==="
humann_barplot --input results/pathways/demo_pathabundance_cpm.tsv \
               --focal-feature PWY-5423 \
               --output results/figures/pwy5423_stratification.png

echo "=== Done! Visualization saved to results/figures/pwy5423_stratification.png ==="
