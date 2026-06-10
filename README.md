# Giraffe_vg

Giraffe mapping on Trep_pangenome graphs → surject to UTM → variant stubs → SV region summaries.

```text
giraffe_index → giraffe_sample → small_variant_call → sv_regions → giraffe_done
```

## Setup

```bash
conda env create -f environment.yaml
conda activate giraffe_vg
```

## Run

```bash
./scripts/run_giraffe.sh 4
```

Edit before a full run: `resources/samples.csv`, `config/regions.txt`, `config/config.yaml` (paths).

Swap-in later: `workflow/Snakefile` TODO blocks for `vg call`, DeepVariant/GATK.

Done: `{output_dir}/giraffe.done`
