#!/usr/bin/env bash
# Status check. Usage: bash scripts/check_giraffe.sh
set -euo pipefail
source "$(dirname "$0")/config_paths.sh"

bar() { printf '%s\n' "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"; }
GRAPH="$(awk -F, 'NR==2 {print $1}' "$ROOT/resources/graphs.csv")"
SAMPLE="$(awk -F, 'NR>1 && $1!="" {print $1; exit}' "$ROOT/resources/samples.csv")"
IDX="$OUT/results/$GRAPH/index"

bar
[[ -f "$OUT/giraffe.done" ]] && echo "  STATUS  ✅ DONE" || echo "  STATUS  🔄 running"
bar
for f in graph.gbz graph.dist graph.min index.done; do
  [[ -f "$IDX/$f" ]] && echo "  ✅ index/$f" || echo "  ❌ index/$f"
done
if [[ -n "$SAMPLE" ]]; then
  RES="$OUT/results/$GRAPH/$SAMPLE"
  for f in "${SAMPLE}.surject.bam" "${SAMPLE}.vg_call.vcf.gz" "${SAMPLE}.sv_regions.tsv"; do
    [[ -f "$RES/$f" ]] && echo "  ✅ $f" || echo "  ❌ $f"
  done
else
  echo "  ℹ️  no samples in samples.csv yet"
fi
bar
