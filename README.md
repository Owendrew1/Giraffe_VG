# Giraffe_vg

> **⚠️ SCAFFOLD / NOT READY FOR PRODUCTION**
>
> This repo is **sample pipeline code** until real FASTQs and SV coordinates are added on Nepenthes.
> `resources/samples.csv` is **empty on purpose**. Small-variant calling is a **TODO stub**.
>
> See **[STATUS.md](STATUS.md)** before running or pushing to GitHub.

Giraffe mapping and SV region summaries on **Trep_pangenome** graphs. Thin Snakemake (5 rules), work in bash scripts — same style as Trep_pangenome.

## Current blockers

- No short-read FASTQs on `/scratch/odrew060/` yet
- No active lines in `config/regions.txt`
- DeepVariant/GATK not wired in

## Layout

```text
Giraffe_vg/
├── STATUS.md               # what's missing / what's safe to run
├── config/config.yaml
├── config/regions.txt      # SV loci (empty until supervisor coords)
├── resources/samples.csv   # EMPTY until FASTQs exist — see samples.README
├── workflow/Snakefile
└── scripts/run_giraffe.sh
```

## Workflow (5 rules)

```text
giraffe_index → giraffe_sample → small_variant_call → sv_regions → giraffe_done
```

## Run (only after STATUS.md checklist)

```bash
conda env create -f environment.yaml && conda activate snakemake
bash scripts/validate_paths.sh
./scripts/run_giraffe.sh 4
```

**Index-only test** (no FASTQs required):

```bash
cd workflow && snakemake --cores 4 --use-conda \
  /scratch/odrew060/Giraffe_vg/results/trifolium_repens/index/index.done
```

Done flag: `{output_dir}/giraffe.done`
