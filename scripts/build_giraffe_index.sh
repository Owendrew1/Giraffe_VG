#!/usr/bin/env bash
# Stage Giraffe index (gbz/dist/min) from Trep_pangenome; rebuild dist/min if missing.
# Called by workflow/Snakefile rule giraffe_index.
set -euo pipefail

PANGENOME_DIR="$1"
GRAPH_ID="$2"
SRC_GBZ="$3"
SRC_DIST="$4"
SRC_MIN="$5"
OUTDIR="$6"
LOGFILE="$7"

mkdir -p "$OUTDIR" "$(dirname "$LOGFILE")"
exec > >(tee -a "$LOGFILE") 2>&1

echo "graph_id=$GRAPH_ID"
echo "pangenome_dir=$PANGENOME_DIR"

[[ -f "$SRC_GBZ" ]] || { echo "Missing gbz: $SRC_GBZ" >&2; exit 1; }

# Cactus sometimes leaves d2.dist/d2.min as symlinks to files that were never kept.
resolve_or_rebuild() {
  local path="$1" kind="$2"
  if [[ -e "$path" ]]; then
    echo "$path"
    return
  fi
  local base
  base="$(basename "$path")"
  local rebuilt="${PANGENOME_DIR}/${base}"
  echo "Missing $kind ($path) — rebuilding from $(basename "$SRC_GBZ")" >&2
  case "$kind" in
    min)
      vg minifier -t "${VG_INDEX_THREADS:-16}" -d 10 -o "$rebuilt" "$SRC_GBZ"
      ;;
    dist)
      vg distance -t "${VG_INDEX_THREADS:-16}" -o "$rebuilt" "$SRC_GBZ"
      ;;
  esac
  echo "$rebuilt"
}

REAL_DIST="$(resolve_or_rebuild "$SRC_DIST" dist)"
REAL_MIN="$(resolve_or_rebuild "$SRC_MIN" min)"

ln -sf "$SRC_GBZ" "$OUTDIR/graph.gbz"
ln -sf "$REAL_DIST" "$OUTDIR/graph.dist"
ln -sf "$REAL_MIN" "$OUTDIR/graph.min"

touch "$OUTDIR/index.done"
echo "Giraffe index ready under $OUTDIR"
