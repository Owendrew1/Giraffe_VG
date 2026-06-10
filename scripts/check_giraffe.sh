#!/usr/bin/env bash
# Status check. Usage: bash scripts/check_giraffe.sh
set -euo pipefail
source "$(dirname "$0")/config_paths.sh"

bar() { printf '%s\n' "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"; }
SAMPLE="$(awk -F, 'NR==2 {print $1}' "$ROOT/resources/samples.csv")"
GRAPH="$(awk -F, 'NR==2 {print $1}' "$ROOT/resources/graphs.csv")"
RES="$OUT/results/$GRAPH/$SAMPLE"

bar
[[ -f "$OUT/giraffe.done" ]] && echo "  STATUS  ✅ DONE" || echo "  STATUS  🔄 running"
bar
for f in "${SAMPLE}.surject.bam" "${SAMPLE}.vg_call.vcf.gz" "${SAMPLE}.sv_regions.tsv"; do
  [[ -f "$RES/$f" ]] && echo "  ✅ $f" || echo "  ❌ $f"
done
bar
