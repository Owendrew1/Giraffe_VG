# STATUS

Aligned with James’s `align_trifolium_reads` pattern for the pangenome case.

## Done (matches supervisor guidance)

| Step | Status |
|------|--------|
| Find reads under `/archive/raw_data/fastq` | ✅ `discover_fastqs.py` |
| Label lane0…laneN | ✅ |
| Align per lane (Giraffe, not BWA) | ✅ |
| Merge lanes | ✅ GAMs |
| Mark duplicates | ✅ on surjected BAM |
| QC: flagstat, duplication metrics, mosdepth | ✅ |
| Pangenome QC: `vg stats` | ✅ |
| VCF + filter + `bcftools stats` | ✅ |
| Parallelize across samples (32 cores) | ✅ config |
| Sample sheet (GWAS / Toronto / GLUE / Nic) | ✅ via James TSV |

## Not yet

| Step | Notes |
|------|--------|
| Chromosome-level BAM/VCF split | Supervisor: do this once full-sample BAMs/VCFs exist |
| Full cohort run | Still on `samples_test.tsv` (2 samples) |
| `sv_regions` | Off by default; needs loci in `config/regions.txt` |
| MultiQC report | Optional later |

## Test run

```bash
conda activate snakemake
cd ~/github-repos/Giraffe_vg
python3 scripts/check_fastq_discovery.py
snakemake -s workflow/Snakefile --directory workflow --cores 4 -n -p --use-conda
./scripts/run_giraffe.sh 4
```
