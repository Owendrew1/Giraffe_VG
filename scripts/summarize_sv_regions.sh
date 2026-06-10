#!/usr/bin/env bash
# Parse config/regions.txt; subset BAM/VCF per locus; write combined summary TSV.
# Called by workflow/Snakefile rule sv_regions.
set -euo pipefail

REGIONS="$1" CHROM_MAP="$2" REF_CONTIG="$3" BAM="$4" SMALL_VCF="$5" VG_VCF="$6"
RUN_VG="$7" OUTDIR="$8" OUT_TSV="$9" LOG="${10}"

mkdir -p "$OUTDIR" "$(dirname "$OUT_TSV")" "$(dirname "$LOG")"
exec > >(tee -a "$LOG") 2>&1

declare -A ALIAS=()
if [[ -f "$CHROM_MAP" ]]; then
  while IFS=, read -r a c; do
    [[ "$a" == "alias" || -z "$a" || "$a" == \#* ]] && continue
    ALIAS["$a"]="$c"
  done < "$CHROM_MAP"
fi

resolve_chrom() {
  local c="$1"
  [[ -n "${ALIAS[$c]:-}" ]] && { echo "${ALIAS[$c]}"; return; }
  # ASSUMPTION: chr* shorthand maps to reference_contig when no alias is defined.
  if [[ "$c" =~ ^[Cc]hr ]] && [[ -n "$REF_CONTIG" ]]; then
    echo "$REF_CONTIG"
    return
  fi
  echo "$c"
}

echo -e "region_id\tlabel\tchrom\tstart\tend\tcoords\tmean_depth\tmapped_reads\tmean_mapq\tmq_0\tmq_1_10\tmq_11_20\tmq_21_60\tmq_gt60\tsmall_variant_count\tvg_call_variant_count" > "$OUT_TSV"

while IFS= read -r line || [[ -n "$line" ]]; do
  [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
  label=""
  [[ "$line" == *$'\t'* ]] && { label="${line#*$'\t'}"; line="${line%%$'\t'*}"; }
  [[ "$line" =~ ^([^:]+):([0-9]+)-([0-9]+)$ ]] || { echo "Bad region: $line" >&2; exit 1; }

  raw_chrom="${BASH_REMATCH[1]}"
  start="${BASH_REMATCH[2]}"
  end="${BASH_REMATCH[3]}"
  chrom="$(resolve_chrom "$raw_chrom")"
  coords="${chrom}:${start}-${end}"
  region_id="${chrom}_${start}_${end}"
  region_id="${region_id//./_}"
  [[ -z "$label" ]] && label="$coords"

  locus_dir="$OUTDIR/$region_id"
  mkdir -p "$locus_dir"

  samtools view -b -r "$coords" -o "$locus_dir/${region_id}.bam" "$BAM"
  samtools index "$locus_dir/${region_id}.bam"
  bcftools view -r "$coords" -Oz -o "$locus_dir/${region_id}.small_variants.vcf.gz" "$SMALL_VCF"
  tabix -f -p vcf "$locus_dir/${region_id}.small_variants.vcf.gz"

  if [[ "$RUN_VG" == "True" || "$RUN_VG" == "true" ]]; then
    bcftools view -r "$coords" -Oz -o "$locus_dir/${region_id}.vg_call.vcf.gz" "$VG_VCF"
    tabix -f -p vcf "$locus_dir/${region_id}.vg_call.vcf.gz"
    vg_n="$(bcftools view -H -r "$coords" "$locus_dir/${region_id}.vg_call.vcf.gz" | wc -l | tr -d ' ')"
  else
    vg_n="NA"
  fi

  mean_depth="$(samtools depth -r "$coords" "$BAM" \
    | awk '{s+=$3;n++} END {if(n>0) printf "%.2f", s/n; else print "0"}')"
  read mq_stats < <(samtools view -r "$coords" "$BAM" | awk '
    { n++; s+=$5;
      if ($5==0) a++; else if ($5<=10) b++; else if ($5<=20) c++; else if ($5<=60) d++; else e++ }
    END {
      if (n>0) printf "%d\t%.2f\t%d\t%d\t%d\t%d\t%d", n, s/n, a+0, b+0, c+0, d+0, e+0;
      else print "0\t0\t0\t0\t0\t0\t0"
    }')
  mapped_reads="$(echo "$mq_stats" | awk '{print $1}')"
  mean_mapq="$(echo "$mq_stats" | awk '{print $2}')"
  mq_0="$(echo "$mq_stats" | awk '{print $3}')"
  mq_1_10="$(echo "$mq_stats" | awk '{print $4}')"
  mq_11_20="$(echo "$mq_stats" | awk '{print $5}')"
  mq_21_60="$(echo "$mq_stats" | awk '{print $6}')"
  mq_gt60="$(echo "$mq_stats" | awk '{print $7}')"
  small_n="$(bcftools view -H -r "$coords" "$locus_dir/${region_id}.small_variants.vcf.gz" | wc -l | tr -d ' ')"

  echo -e "${region_id}\t${label}\t${chrom}\t${start}\t${end}\t${coords}\t${mean_depth}\t${mapped_reads}\t${mean_mapq}\t${mq_0}\t${mq_1_10}\t${mq_11_20}\t${mq_21_60}\t${mq_gt60}\t${small_n}\t${vg_n}" >> "$OUT_TSV"
done < "$REGIONS"

if [[ "$(wc -l < "$OUT_TSV")" -le 1 ]]; then
  echo "WARN: no active regions in $REGIONS — add chrom:start-end lines" >&2
fi

echo "Wrote $OUT_TSV"
