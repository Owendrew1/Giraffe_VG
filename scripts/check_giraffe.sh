#!/usr/bin/env bash
# Status check. Usage: bash scripts/check_giraffe.sh
set -euo pipefail
source "$(dirname "$0")/config_paths.sh"

IDX="$OUT/results/$GRAPH/index"
SAMPLE="$(awk -F, 'NR>1 && $1!="" {print $1; exit}' "$ROOT/resources/samples.csv")"

bar() { printf '%s\n' "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"; }

bar
if [[ -f "$OUT/giraffe.done" ]]; then
  echo "  STATUS      ✅ DONE"
else
  echo "  STATUS      🔄 not finished (no giraffe.done)"
fi
bar

echo ""
echo "  INDEX:"
for f in graph.gbz graph.dist graph.min index.done; do
  [[ -f "$IDX/$f" ]] && echo "  ✅ $f" || echo "  ❌ $f"
done

if [[ -n "$SAMPLE" ]]; then
  RES="$OUT/results/$GRAPH/$SAMPLE"
  echo ""
  echo "  SAMPLE ($SAMPLE):"
  for f in "${SAMPLE}.surject.bam" "${SAMPLE}.vg_call.vcf.gz" "${SAMPLE}.sv_regions.tsv"; do
    [[ -f "$RES/$f" ]] && echo "  ✅ $f" || echo "  ❌ $f"
  done
fi

bar
