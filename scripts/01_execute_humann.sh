#!/usr/bin/env bash
# ==============================================================================
# 01_execute_humann.sh — Download demo data, run HUMAnN 3 in three modes,
#                         and perform basic post-processing.
# ==============================================================================

set -eo pipefail

# ── Project root (one level above scripts/) ──────────────────────────────────
PROJ_DIR="$(cd "$(dirname "$0")/.." && pwd)"

RAW_DIR="${PROJ_DIR}/data/raw_reads"
RESULTS_DIR="${PROJ_DIR}/results"
DB_DIR="${PROJ_DIR}/scripts/humann_dbs"

# ── Activate conda environment ───────────────────────────────────────────────
eval "$(conda shell.bash hook)"
set +u                       # work around binutils activation bug (ADDR2LINE)
conda activate humann_3
set -u

# ── 1. Fetch databases ───────────────────────────────────────────────────────
# 1a. MetaPhlAn Bowtie2 database (required — HUMAnN calls metaphlan internally)
METAPHLAN_DB="${DB_DIR}/metaphlan_db"
echo "=== Installing MetaPhlAn database (skips if already present) ==="
mkdir -p "${METAPHLAN_DB}"
metaphlan --install --db_dir "${METAPHLAN_DB}"

# 1b. HUMAnN demo databases (idempotent — skips if already present)
echo ""
echo "=== Downloading HUMAnN demo databases ==="
humann_databases --download chocophlan DEMO "${DB_DIR}"
humann_databases --download uniref DEMO_diamond "${DB_DIR}"

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

# ── 3A. Full metagenomic run (from raw reads) ────────────────────────────────
echo ""
echo "=== Run A: full metagenomic run (demo.fastq.gz) ==="
humann --input "${RAW_DIR}/demo.fastq.gz" \
       --output "${RESULTS_DIR}/" \
       --nucleotide-database "${DB_DIR}/chocophlan" \
       --protein-database "${DB_DIR}/uniref" \
       --threads 4

# ── 3B. Bypassing nucleotide alignment (from SAM) ────────────────────────────
echo ""
echo "=== Run B: bypass nucleotide alignment (demo.sam) ==="
humann --input "${RAW_DIR}/demo.sam" \
       --output "${RESULTS_DIR}/" \
       --protein-database "${DB_DIR}/uniref" \
       --threads 4

# ── 3C. Bypassing all alignment steps (from m8) ──────────────────────────────
echo ""
echo "=== Run C: bypass all alignment (demo.m8) ==="
humann --input "${RAW_DIR}/demo.m8" \
       --output "${RESULTS_DIR}/"

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
