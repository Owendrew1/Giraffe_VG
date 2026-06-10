# STATUS — read before running or citing this repo

**This pipeline is NOT production-ready.**

It is scaffold / proof-of-concept code until real inputs are wired in on Nepenthes.

## What is missing (do not expect a full run yet)

| Input | Status |
|-------|--------|
| Short-read FASTQs | **Not on server** — `resources/samples.csv` is intentionally empty |
| SV coordinates | **Not set** — `config/regions.txt` has no active loci |
| Small-variant caller | **Stub only** — `scripts/run_small_variant_caller.sh` is TODO (DeepVariant/GATK) |

## What works today

- Repo structure and Snakemake workflow (5 rules)
- Points at existing Trep_pangenome graph (`trifolium_repens.d2.gbz`)
- Index step can test graph staging + dist/min rebuild (needs conda `vg` env)

## Safe commands before samples exist

```bash
bash scripts/validate_paths.sh
cd workflow && snakemake -n --cores 1 --use-conda
snakemake --cores 4 --use-conda \
  /scratch/odrew060/Giraffe_vg/results/trifolium_repens/index/index.done
```

## Before first real mapping run

1. Add FASTQs to Nepenthes (e.g. `/scratch/odrew060/fastq/`)
2. Add rows to `resources/samples.csv`
3. Add SV loci to `config/regions.txt` when available
4. Re-run `validate_paths.sh` until no ❌

**Until then: commits here are sample/scaffold code, not validated results.**
