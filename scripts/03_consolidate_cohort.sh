#!/usr/bin/env bash
# ==============================================================================
# 03_consolidate_cohort.sh — Join individual sample tables into a unified
#                             cohort-level abundance matrix.
# ==============================================================================

set -eo pipefail

# ── Project root (one level above scripts/) ──────────────────────────────────
PROJ_DIR="$(cd "$(dirname "$0")/.." && pwd)"
RESULTS_DIR="${PROJ_DIR}/results"

# ── Activate conda environment ───────────────────────────────────────────────
eval "$(conda shell.bash hook)"
set +u                       
conda activate humann_3
set -u

echo "============================================="
echo "  Step 1: Consolidating Cohort Pathway Abundances"
echo "============================================="

# humann_join_tables joins all tables in a folder matching a filename pattern or all files.
# Since we are running the demo with a single sample, this will create a single-column matrix.
# For a real study, this merges multiple sample columns into a unified table.

mkdir -p "${RESULTS_DIR}/pathways"

echo "Joining pathway abundance tables..."
humann_join_tables --input "${RESULTS_DIR}/pathways" \
                   --output "${RESULTS_DIR}/pathways/cohort_pathway_abundance.tsv" \
                   --file_name "pathabundance"

echo "Joining pathway abundance CPM tables..."
humann_join_tables --input "${RESULTS_DIR}/pathways" \
                   --output "${RESULTS_DIR}/pathways/cohort_pathway_abundance_cpm.tsv" \
                   --file_name "pathabundance_cpm"

echo ""
echo "============================================="
echo "  Step 2: Consolidating Cohort Gene Families"
echo "============================================="
mkdir -p "${RESULTS_DIR}/gene_families"

echo "Joining gene families CPM tables..."
humann_join_tables --input "${RESULTS_DIR}/gene_families" \
                   --output "${RESULTS_DIR}/gene_families/cohort_genefamilies_cpm.tsv" \
                   --file_name "genefamilies_cpm"

echo "Joining gene families RelAb tables..."
humann_join_tables --input "${RESULTS_DIR}/gene_families" \
                   --output "${RESULTS_DIR}/gene_families/cohort_genefamilies_relab.tsv" \
                   --file_name "genefamilies_relab"

echo ""
echo "=== Done! Cohort matrices consolidated in results/ ==="
