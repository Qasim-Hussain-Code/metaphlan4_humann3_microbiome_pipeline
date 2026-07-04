# Metagenomic Analysis Scripts

This directory contains the core bash scripts that run the MetaPhlAn 4 and HUMAnN 3 pipeline.

## Workflow Scripts

### 1. `00_install.sh`
* **Purpose:** Provisions the Conda/Mamba virtual environment (`humann_3`) and installs core dependencies, specifically Python 3.10, MetaPhlAn 4.2.4, Bowtie2, DIAMOND, and HUMAnN 3.9 (via pip to resolve dependencies).
* **Usage:** `./00_install.sh`

### 2. `01_execute_humann.sh`
* **Purpose:** Fetches the demo databases (Chocophlan and UniRef) and executes the functional profiling.
* **Usage:** 
  * `./01_execute_humann.sh` (Runs in demo mode using SAM and m8 inputs, bypassing MetaPhlAn)
  * `./01_execute_humann.sh --full` (Runs in full mode, requiring raw reads and downloading the 33GB MetaPhlAn database)

### 3. `02_renormalize_tables.sh`
* **Purpose:** Normalizes gene families and pathway abundance matrices into Copies Per Million (CPM) and Relative Abundance (RelAb) scales.
* **Usage:** `./02_renormalize_tables.sh`

### 4. `03_consolidate_cohort.sh`
* **Purpose:** Consolidates individual sample matrices (single or multiple) into a unified, cohort-level matrix (such as CPM or Relative Abundance).
* **Usage:** `./03_consolidate_cohort.sh`
