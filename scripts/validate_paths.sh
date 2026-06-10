#!/usr/bin/env bash
# Verify paths before launch. Usage: bash scripts/validate_paths.sh
set -euo pipefail
source "$(dirname "$0")/config_paths.sh"

fail=0
check() { [[ -e "$1" ]] && echo "  ✅ $2" || { echo "  ❌ $2"; echo "     $1"; fail=1; }; }

echo "Giraffe_vg path check"
echo ""
echo "Upstream:"
check "$PGD" "pangenome_results_dir"
check "$PGD/trifolium_repens.d2.gbz" "giraffe graph (d2.gbz)"
check "$REFS" "linear_ref_dir"
check "$ROOT/config/regions.txt" "regions_file"

n="$(awk '!/^[[:space:]]*#/ && NF {c++} END {print c+0}' "$ROOT/config/regions.txt")"
[[ "$n" -eq 0 ]] && echo "  ℹ️  no SV coordinates yet (OK for first mapping run)"

echo ""
echo "Samples:"
ns="$(awk -F, 'NR>1 && $1!="" {n++} END {print n+0}' "$ROOT/resources/samples.csv")"
if [[ "$ns" -eq 0 ]]; then
  echo "  ℹ️  no samples in resources/samples.csv yet"
  [[ -d "$FASTQ_DIR" ]] && find "$FASTQ_DIR" -maxdepth 3 \( -name '*.fq.gz' -o -name '*.fastq.gz' \) 2>/dev/null | head -10 \
    || echo "  ℹ️  fastq_dir missing or empty: $FASTQ_DIR"
else
  while IFS=, read -r sample r1 r2; do
    [[ "$sample" == "sample_id" || -z "$sample" ]] && continue
    [[ "$r1" != /* ]] && r1="$FASTQ_DIR/$r1"
    [[ "$r2" != /* ]] && r2="$FASTQ_DIR/$r2"
    check "$r1" "$sample R1"
    check "$r2" "$sample R2"
  done < "$ROOT/resources/samples.csv"
fi

[[ "$fail" -eq 1 ]] && echo "" && echo "Fix ❌ above before ./scripts/run_giraffe.sh"
exit "$fail"
