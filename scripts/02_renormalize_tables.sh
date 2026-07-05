#!/usr/bin/env bash
# ==============================================================================
# 02_renormalize_tables.sh — Normalize HUMAnN outputs to CPM and relative abundance
#                            and sort files into the repository structure.
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
echo "  Step 1: Normalizing Gene Families"
echo "============================================="

# Find raw gene family files (check root results directory first, then subfolders)
GENE_FAMILIES=""
if [[ -f "${RESULTS_DIR}/demo_genefamilies.tsv" ]]; then
    GENE_FAMILIES="${RESULTS_DIR}/demo_genefamilies.tsv"
elif [[ -f "${RESULTS_DIR}/gene_families/demo_genefamilies.tsv" ]]; then
    GENE_FAMILIES="${RESULTS_DIR}/gene_families/demo_genefamilies.tsv"
fi

if [[ -n "${GENE_FAMILIES}" ]]; then
    echo "Found gene families file: ${GENE_FAMILIES}"
    
    # CPM Normalization
    echo "  Normalizing to Copies Per Million (CPM)..."
    humann_renorm_table --input "${GENE_FAMILIES}" \
                        --output "${RESULTS_DIR}/demo_genefamilies_cpm.tsv" \
                        --units cpm
    
    # Relative Abundance Normalization
    echo "  Normalizing to Relative Abundance..."
    humann_renorm_table --input "${GENE_FAMILIES}" \
                        --output "${RESULTS_DIR}/demo_genefamilies_relab.tsv" \
                        --units relab
else
    echo "WARNING: No raw gene families file found. Skipping gene family normalization."
fi


echo ""
echo "============================================="
echo "  Step 2: Normalizing Pathway Abundances"
echo "============================================="

PATH_ABUNDANCE=""
if [[ -f "${RESULTS_DIR}/demo_pathabundance.tsv" ]]; then
    PATH_ABUNDANCE="${RESULTS_DIR}/demo_pathabundance.tsv"
elif [[ -f "${RESULTS_DIR}/pathways/demo_pathabundance.tsv" ]]; then
    PATH_ABUNDANCE="${RESULTS_DIR}/pathways/demo_pathabundance.tsv"
fi

if [[ -n "${PATH_ABUNDANCE}" ]]; then
    echo "Found pathway abundance file: ${PATH_ABUNDANCE}"
    
    # CPM Normalization
    echo "  Normalizing to Copies Per Million (CPM)..."
    humann_renorm_table --input "${PATH_ABUNDANCE}" \
                        --output "${RESULTS_DIR}/demo_pathabundance_cpm.tsv" \
                        --units cpm
else
    echo "WARNING: No raw pathway abundance file found. Skipping pathway normalization."
fi


echo ""
echo "============================================="
echo "  Step 3: Organizing Output Files"
echo "============================================="
mkdir -p "${RESULTS_DIR}/gene_families"
mkdir -p "${RESULTS_DIR}/pathways"

# Move gene family files
for f in demo_genefamilies.tsv demo_genefamilies_cpm.tsv demo_genefamilies_relab.tsv; do
    if [[ -f "${RESULTS_DIR}/${f}" ]]; then
        mv "${RESULTS_DIR}/${f}" "${RESULTS_DIR}/gene_families/"
        echo "  Sorted ${f} -> results/gene_families/"
    fi
done

# Move pathway files
for f in demo_pathabundance.tsv demo_pathabundance_cpm.tsv demo_pathcoverage.tsv; do
    if [[ -f "${RESULTS_DIR}/${f}" ]]; then
        mv "${RESULTS_DIR}/${f}" "${RESULTS_DIR}/pathways/"
        echo "  Sorted ${f} -> results/pathways/"
    fi
done

echo ""
echo "=== Done! Files organized in ${RESULTS_DIR}/ ==="
