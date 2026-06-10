#!/usr/bin/env bash
# List FASTQs under fastq_dir from config. Usage: bash scripts/list_fastqs.sh
set -euo pipefail
source "$(dirname "$0")/config_paths.sh"

echo "fastq_dir: $FASTQ_DIR"
[[ -d "$FASTQ_DIR" ]] || { echo "Directory not found." >&2; exit 1; }
find "$FASTQ_DIR" -maxdepth 3 \( -name '*.fq.gz' -o -name '*.fastq.gz' \) 2>/dev/null | head -40
