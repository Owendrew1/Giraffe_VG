# STATUS

Index validated on Nepenthes. Full run needs FASTQs in `resources/samples.csv`.

## Edit when data arrives

| What | File |
|------|------|
| FASTQs | `resources/samples.csv` |
| SV loci | `config/regions.txt` (`contig:start-end`, full contig name) |
| vg call | `workflow/Snakefile` → `giraffe_sample` TODO |
| Small variants | `workflow/Snakefile` → `small_variant_call` TODO + `environment.yaml` |

## Run

```bash
conda activate giraffe_vg
./scripts/run_giraffe.sh 4
ls /scratch/odrew060/Giraffe_vg/giraffe.done
ls /scratch/odrew060/Giraffe_vg/results/trifolium_repens/index/
```
