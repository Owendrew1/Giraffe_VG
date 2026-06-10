# Shared config paths for bash helpers. Source from scripts/: source "$(dirname "$0")/config_paths.sh"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CFG="$ROOT/config/config.yaml"
yaml() { grep "^${1}:" "$CFG" | sed 's/.*: *"\?\([^"]*\)"\?.*/\1/' | head -1; }

OUT="$(yaml output_dir)"
PGD="$(yaml pangenome_results_dir)"
REFS="$(yaml linear_ref_dir)"
FASTQ_DIR="$(yaml fastq_dir)"
INDEX_DONE="$(yaml index_done_flag)"
GRAPH="$(awk -F, 'NR==2 {print $1}' "$ROOT/resources/graphs.csv")"
