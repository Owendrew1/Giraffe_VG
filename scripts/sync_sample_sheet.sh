#!/usr/bin/env bash
# Download James's sample sheet onto Nepenthes (do not commit the large TSV).
set -euo pipefail
cd "$(dirname "$0")/.."
URL="https://raw.githubusercontent.com/James-S-Santangelo/align_trifolium_reads/main/resources/all_clover_samples.txt"
curl -fsSL "$URL" -o resources/all_clover_samples.txt
echo "Wrote resources/all_clover_samples.txt ($(tail -n +2 resources/all_clover_samples.txt | wc -l | tr -d ' ') samples)"
