# STATUS

**Scaffold — validated through `giraffe_index` on Nepenthes.** Full mapping waits on FASTQs.

## Swap-in points (only these change when data arrives)

| What | Where | Action |
|------|--------|--------|
| Sample FASTQs | `resources/samples.csv` | Add `sample_id,r1,r2` rows |
| SV loci | `config/regions.txt` | Add `chrom:start-end` lines (UTM haploid) |
| Variant caller | `workflow/Snakefile` → `small_variant_call` | Replace TODO block; add tool to `workflow/envs/giraffe.yaml` |
| Graph paths | `resources/graphs.csv` | Only if pangenome index names differ |
| Nepenthes paths | `config/config.yaml` | `output_dir`, `fastq_dir`, `pangenome_results_dir` |
| Tool settings | `config/config.yaml` | `giraffe.cores`, `run_vg_call`, etc. |

## Layout

```text
config/config.yaml          # paths + cores
config/regions.txt          # SV coordinates (empty OK for now)
resources/samples.csv       # FASTQ list (empty OK for now)
resources/graphs.csv        # pangenome index basenames
workflow/Snakefile          # 5 rules, shell inline
workflow/rules/common.smk   # all paths, constants, helpers
workflow/envs/giraffe.yaml    # vg/samtools/bcftools — add tools here
scripts/run_giraffe.sh        # entry point
```

## Safe to run now (no FASTQs)

```bash
bash scripts/validate_paths.sh
cd workflow && snakemake --cores 4 --use-conda \
  /scratch/odrew060/Giraffe_vg/results/trifolium_repens/index/index.done
```

## When FASTQs exist

```bash
# 1. edit resources/samples.csv
# 2. bash scripts/validate_paths.sh   # no ❌
# 3. ./scripts/run_giraffe.sh 4
# 4. bash scripts/check_giraffe.sh
```
