#!/usr/bin/env bash
# Usage: conda activate giraffe_vg && ./scripts/run_giraffe.sh [cores]
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CFG="$ROOT/config/config.yaml"

yaml() { grep "^${1}:" "$CFG" | sed 's/.*: *"\?\([^"]*\)"\?.*/\1/' | head -1; }

command -v snakemake >/dev/null || { echo "Activate env: conda activate giraffe_vg"; exit 1; }
command -v vg >/dev/null || { echo "Activate env: conda activate giraffe_vg"; exit 1; }

PGD="$(yaml pangenome_results_dir)"
REFS="$(yaml linear_ref_dir)"
FASTQ="$(yaml fastq_dir)"
[[ -d "$PGD" ]] || { echo "Missing: $PGD"; exit 1; }
[[ -d "$REFS" ]] || { echo "Missing: $REFS"; exit 1; }

while IFS=, read -r sample r1 r2; do
  [[ "$sample" == "sample_id" || -z "$sample" ]] && continue
  [[ "$r1" != /* ]] && r1="$FASTQ/$r1"
  [[ "$r2" != /* ]] && r2="$FASTQ/$r2"
  [[ -f "$r1" && -f "$r2" ]] || { echo "Missing FASTQs for $sample"; exit 1; }
done < "$ROOT/resources/samples.csv"

cd "$ROOT"
exec snakemake -s workflow/Snakefile --directory workflow --cores "${1:-4}" -p
