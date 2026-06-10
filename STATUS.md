# STATUS

Index validated on Nepenthes. Full run needs FASTQs in `resources/samples.csv`.

## Edit when data arrives

| What | File |
|------|------|
| FASTQs | `resources/samples.csv` |
| SV loci | `config/regions.txt` |
| vg call | `workflow/Snakefile` → `giraffe_sample` TODO |
| Small variants | `workflow/Snakefile` → `small_variant_call` TODO + `workflow/envs/giraffe.yaml` |

## Run (same flow as Trep_pangenome / index_Trep_refs)

```bash
conda activate snakemake
cd ~/github-repos/Giraffe_vg
./scripts/run_giraffe.sh 4
bash scripts/check_giraffe.sh
```
