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
[[ "$n" -eq 0 ]] && echo "  ℹ️  no SV coordinates yet (OK — header-only sv_regions.tsv)"

echo ""
echo "Samples:"
ns="$(awk -F, 'NR>1 && $1!="" {n++} END {print n+0}' "$ROOT/resources/samples.csv")"
if [[ "$ns" -eq 0 ]]; then
  echo "  ℹ️  no samples in resources/samples.csv yet (add rows when FASTQs are on Nepenthes)"
fi
while IFS=, read -r sample r1 r2; do
  [[ "$sample" == "sample_id" || -z "$sample" ]] && continue
  if [[ "$r1" != /* ]]; then r1="$FASTQ_DIR/$r1"; fi
  if [[ "$r2" != /* ]]; then r2="$FASTQ_DIR/$r2"; fi
  check "$r1" "$sample R1"
  check "$r2" "$sample R2"
done < "$ROOT/resources/samples.csv"

[[ "$fail" -eq 1 ]] && echo "" && echo "Fix ❌ above. For FASTQ paths try: bash scripts/list_fastqs.sh"
exit "$fail"
