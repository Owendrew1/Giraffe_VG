#!/usr/bin/env bash
# Giraffe map + surject + optional vg call for one sample.
# Called by workflow/Snakefile rule giraffe_sample.
set -euo pipefail

GBZ="$1" DIST="$2" MIN="$3" R1="$4" R2="$5" REF="$6" OUTDIR="$7" SAMPLE="$8"
CORES_G="$9" CORES_S="${10}" READ_GROUP="${11}" EXTRA="${12:-}"
RUN_VG="${13}" PACK_QUAL="${14}" CORES_V="${15}" LOG="${16}"

GAM="$OUTDIR/${SAMPLE}.gam"
GAF="$OUTDIR/${SAMPLE}.gaf.gz"
BAM="$OUTDIR/${SAMPLE}.surject.bam"
VG_VCF="$OUTDIR/${SAMPLE}.vg_call.vcf.gz"

mkdir -p "$OUTDIR" "$(dirname "$LOG")"
exec > >(tee -a "$LOG") 2>&1

vg giraffe -Z "$GBZ" -d "$DIST" -m "$MIN" -f "$R1" -f "$R2" -t "$CORES_G" $EXTRA -o "$GAM"
vg view -a "$GAM" | gzip -c > "$GAF"

vg surject -t "$CORES_S" -i "$GAM" -x "$REF" -b "$BAM" -R "$READ_GROUP"
samtools index -@ "$CORES_S" "$BAM"

if [[ "$RUN_VG" == "True" || "$RUN_VG" == "true" ]]; then
  WRK="$OUTDIR/vg_call_work"
  mkdir -p "$WRK"
  vg snarls "$GBZ" > "$WRK/snarls.snarls"
  vg pack -x "$GBZ" -g "$GAM" -Q "$PACK_QUAL" -o "$WRK/pack.gz"
  vg call "$WRK/pack.gz" -k "$WRK/snarls.snarls" -a -r "$REF" -t "$CORES_V" \
    | bgzip -c > "$VG_VCF"
  tabix -f -p vcf "$VG_VCF"
else
  echo '##fileformat=VCFv4.2' | bgzip -c > "$VG_VCF"
  tabix -f -p vcf "$VG_VCF"
fi

echo "Wrote $GAM $BAM $VG_VCF"
