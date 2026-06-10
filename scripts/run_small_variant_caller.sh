#!/usr/bin/env bash
# Small-variant calling on surjected BAM (TODO: DeepVariant or GATK).
# Called by workflow/Snakefile rule small_variant_call.
set -euo pipefail

CALLER="$1" BAM="$2" REF="$3" VCF="$4" SAMPLE="$5" LOG="$6"

mkdir -p "$(dirname "$VCF")" "$(dirname "$LOG")"
exec > >(tee -a "$LOG") 2>&1

echo "caller=$CALLER sample=$SAMPLE"

case "$CALLER" in
  deepvariant)
    # TODO: run_deepvariant --ref "$REF" --reads "$BAM" --output_vcf "${VCF%.gz}" ...
    echo "TODO: DeepVariant in scripts/run_small_variant_caller.sh" >&2
    ;;
  gatk)
    # TODO: gatk HaplotypeCaller -R "$REF" -I "$BAM" -O "${VCF%.gz}" ...
    echo "TODO: GATK in scripts/run_small_variant_caller.sh" >&2
    ;;
esac

{
  echo '##fileformat=VCFv4.2'
  echo "##reference=$REF"
  echo -e '#CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tINFO'
} | bgzip -c > "$VCF"
tabix -f -p vcf "$VCF"
