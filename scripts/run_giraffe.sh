#!/usr/bin/env bash
# Run Giraffe workflow. Usage: ./scripts/run_giraffe.sh [cores]
set -euo pipefail
cd "$(dirname "$0")/.."
source "$(dirname "$0")/config_paths.sh"

exec snakemake -s workflow/Snakefile --directory workflow --cores "${1:-4}" -p --use-conda
