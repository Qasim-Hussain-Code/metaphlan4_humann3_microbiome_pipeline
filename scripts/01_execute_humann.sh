#!/usr/bin/env bash
# ==============================================================================
# 01_execute_humann.sh — Download demo data, run HUMAnN 3 in three modes,
#                         and perform basic post-processing.
#
# Usage:
#   ./01_execute_humann.sh              # runs bypass modes only (no 33GB DB)
#   ./01_execute_humann.sh --full       # runs all modes (requires MetaPhlAn DB)
# ==============================================================================

set -eo pipefail

# ── Parse arguments ──────────────────────────────────────────────────────────
FULL_RUN=false
if [[ "${1:-}" == "--full" ]]; then
    FULL_RUN=true
fi

# ── Project root (one level above scripts/) ──────────────────────────────────
PROJ_DIR="$(cd "$(dirname "$0")/.." && pwd)"

RAW_DIR="${PROJ_DIR}/data/raw_reads"
RESULTS_DIR="${PROJ_DIR}/results"
DB_DIR="${PROJ_DIR}/scripts/humann_dbs"
METAPHLAN_DB="${DB_DIR}/metaphlan_db"

# ── Activate conda environment ───────────────────────────────────────────────
eval "$(conda shell.bash hook)"
set +u                       # work around binutils activation bug (ADDR2LINE)
conda activate humann_3
set -u

# ── 1. Fetch HUMAnN demo databases ──────────────────────────────────────────
echo "=== Downloading HUMAnN demo databases ==="
humann_databases --download chocophlan DEMO "${DB_DIR}"
humann_databases --download uniref DEMO_diamond "${DB_DIR}"

# ── 1b. MetaPhlAn database (only for --full mode, ~33 GB) ───────────────────
if [[ "${FULL_RUN}" == true ]]; then
    echo ""
    echo "=== Installing MetaPhlAn database (~33 GB — this will take a while) ==="
    mkdir -p "${METAPHLAN_DB}"
    metaphlan --install --force_download --db_dir "${METAPHLAN_DB}"
fi

# ── 2. Download demo input files ─────────────────────────────────────────────
echo ""
echo "=== Downloading demo input files ==="
mkdir -p "${RAW_DIR}"

for f in demo.fastq.gz demo.sam demo.m8; do
    if [[ ! -f "${RAW_DIR}/${f}" ]]; then
        wget -q -P "${RAW_DIR}" \
            "https://github.com/biobakery/humann/raw/master/examples/${f}"
        echo "  Downloaded ${f}"
    else
        echo "  ${f} already exists — skipping"
    fi
done

# ── 3A. Full metagenomic run — requires MetaPhlAn DB ────────────────────────
if [[ "${FULL_RUN}" == true ]]; then
    echo ""
    echo "=== Run A: full metagenomic run (demo.fastq.gz) ==="
    humann --input "${RAW_DIR}/demo.fastq.gz" \
           --output "${RESULTS_DIR}/" \
           --nucleotide-database "${DB_DIR}/chocophlan" \
           --protein-database "${DB_DIR}/uniref" \
           --metaphlan-options "--db_dir ${METAPHLAN_DB}" \
           --threads 4
else
    echo ""
    echo "=== Skipping Run A (requires 33 GB MetaPhlAn DB; use --full to enable) ==="
fi

# ── 3B. Bypassing nucleotide alignment (from SAM) ────────────────────────────
echo ""
echo "=== Run B: bypass nucleotide alignment (demo.sam) ==="
humann --input "${RAW_DIR}/demo.sam" \
       --output "${RESULTS_DIR}/" \
       --bypass-prescreen \
       --bypass-nucleotide-search \
       --protein-database "${DB_DIR}/uniref" \
       --threads 4

# ── 3C. Bypassing all alignment steps (from m8) ──────────────────────────────
echo ""
echo "=== Run C: bypass all alignment (demo.m8) ==="
humann --input "${RAW_DIR}/demo.m8" \
       --output "${RESULTS_DIR}/" \
       --bypass-prescreen \
       --bypass-nucleotide-search \
       --bypass-translated-search

# ── 4. Post-processing & matrix engineering ──────────────────────────────────
echo ""
echo "=== Post-processing ==="

# 4a. Relative-abundance normalisation
mkdir -p "${RESULTS_DIR}/gene_families"
humann_renorm_table --input "${RESULTS_DIR}/demo_genefamilies.tsv" \
                    --output "${RESULTS_DIR}/gene_families/demo_genefamilies_relab.tsv" \
                    --units relab

# 4b. Consolidate multi-sample cohort (pathway abundance)
mkdir -p "${RESULTS_DIR}/pathways"
humann_join_tables --input "${RESULTS_DIR}/" \
                   --output "${RESULTS_DIR}/pathways/cohort_pathway_abundance.tsv" \
                   --file_name pathabundance

echo ""
echo "=== Done! Results are in ${RESULTS_DIR}/ ==="
