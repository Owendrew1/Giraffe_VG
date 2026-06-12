# STATUS

Index validated on Nepenthes. Test sample: `ERR14041371` in `resources/samples.csv` (download FASTQs first).

## Edit when data arrives

| What | File |
|------|------|
| FASTQs | `resources/samples.csv` |
| SV loci | `config/regions.txt` |
| Which outputs to build | `config/config.yaml` → `outputs` |
| vg call / GATK tuning | `workflow/Snakefile` → `vg_variant_call` / `small_variant_call` |

## Run (same flow as Trep_pangenome / index_Trep_refs)

```bash
conda activate snakemake
cd ~/github-repos/Giraffe_vg
./scripts/run_giraffe.sh 4
```
