# Shared config paths for bash helpers.
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CFG="$ROOT/config/config.yaml"
yaml_val() { grep "^${1}:" "$CFG" | sed 's/.*: *"\?\([^"]*\)"\?.*/\1/' | head -1; }

OUT="$(yaml_val output_dir)"
PGD="$(yaml_val pangenome_results_dir)"
REFS="$(yaml_val linear_ref_dir)"
FASTQ_DIR="$(yaml_val fastq_dir)"
USE_HAP="$(yaml_val linear_ref_use_haplotype_subdir)"
INDEX_DONE="$(yaml_val index_done_flag)"
