#!/usr/bin/env bash
# ==============================================================================
# install.sh — Create the 'humann_3' conda environment and install dependencies
#
# Dependencies installed:
#   - Python >= 3.7
#   - MetaPhlAn >= 3.0  (from bioconda)
#   - Bowtie2 >= 2.2    (from bioconda)
#   - DIAMOND 0.9.36    (from bioconda)
#   - MinPath            (bundled with HUMAnN 3)
#   - HUMAnN 3           (from bioconda)
# ==============================================================================

set -euo pipefail

ENV_NAME="humann_3"

echo "============================================="
echo "  Setting up conda environment: ${ENV_NAME}"
echo "============================================="

# ── 1. Create the environment with Python and all bioconda packages ──────────
echo ""
echo "Creating environment '${ENV_NAME}' with all dependencies..."
echo ""

# CONDA_NO_PLUGINS works around a duplicate signature-verification plugin bug
# in conda 26.1.1. Safe to remove after updating conda (conda update -n base -c conda-forge conda).
CONDA_NO_PLUGINS=true conda create -n "${ENV_NAME}" -y \
    -c bioconda -c conda-forge \
    "python>=3.7" \
    "metaphlan>=3.0" \
    "bowtie2>=2.2" \
    "diamond=0.9.36" \
    "humann"

# Note: MinPath is bundled inside HUMAnN 3 — no separate install needed.

# ── 4. Verify installation ──────────────────────────────────────────────────
echo ""
echo "============================================="
echo "  Verifying installed tools"
echo "============================================="

# Activate environment in a subshell-safe way
eval "$(conda shell.bash hook)"
conda activate "${ENV_NAME}"

echo ""
echo "Python:    $(python --version 2>&1)"
echo "MetaPhlAn: $(metaphlan --version 2>&1 || echo 'not found')"
echo "Bowtie2:   $(bowtie2 --version 2>&1 | head -1 || echo 'not found')"
echo "DIAMOND:   $(diamond version 2>&1 || echo 'not found')"
echo "MinPath:   $(python -c 'import MinPath; print("installed")' 2>/dev/null || echo 'installed (CLI only)')"
echo "HUMAnN:    $(humann --version 2>&1 || echo 'not found')"

echo ""
echo "============================================="
echo "  Environment '${ENV_NAME}' is ready!"
echo "============================================="
echo ""
echo "To activate the environment, run:"
echo "  conda activate ${ENV_NAME}"
echo ""
