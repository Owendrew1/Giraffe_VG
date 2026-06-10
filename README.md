# Giraffe_vg

> **Scaffold** — see [STATUS.md](STATUS.md) for swap-in points. Index step validated on Nepenthes; mapping needs FASTQs.

Giraffe mapping + SV summaries on **Trep_pangenome** graphs. Thin Snakemake: rules in `workflow/Snakefile`, logic in shell blocks, constants in `workflow/rules/common.smk`.

## Layout

```text
Giraffe_vg/
├── STATUS.md
├── config/config.yaml
├── config/regions.txt
├── resources/samples.csv
├── resources/graphs.csv
├── workflow/
│   ├── Snakefile           # 5 rules
│   ├── rules/common.smk    # paths, cores, helpers
│   └── envs/giraffe.yaml     # shared conda env — add tools here
└── scripts/
    ├── run_giraffe.sh
    ├── validate_paths.sh
    └── check_giraffe.sh
```

## Workflow

```text
giraffe_index → giraffe_sample → small_variant_call → sv_regions → giraffe_done
```

## Run

```bash
conda env create -f environment.yaml && conda activate snakemake
bash scripts/validate_paths.sh
./scripts/run_giraffe.sh 4
```

Done: `{output_dir}/giraffe.done`
