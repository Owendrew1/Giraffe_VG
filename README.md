# Giraffe_vg

Giraffe mapping on **Trep_pangenome** graphs → surject to **index_Trep_refs** UTM → SV region summaries.

## Layout

```text
Giraffe_vg/
├── environment.yaml              # Snakemake only
├── config/config.yaml            # paths + cores
├── config/regions.txt            # SV loci (chrom:start-end)
├── resources/graphs.csv
├── resources/samples.csv
├── workflow/
│   ├── Snakefile
│   ├── rules/common.smk
│   └── envs/giraffe.yaml         # vg, samtools, bcftools, gatk4
└── scripts/run_giraffe.sh
```

## Setup

```bash
conda env create -f environment.yaml
conda activate snakemake
```

Edit `config/config.yaml`: paths, `outputs` (which final files to build), `fastq_dir`.

## Run

```bash
conda activate snakemake
cd ~/github-repos/Giraffe_vg
./scripts/run_giraffe.sh 4
```

```text
giraffe_index → giraffe_map → giraffe_surject → vg_variant_call
                              → small_variant_call → sv_regions → giraffe_done
```

Done flag: `{output_dir}/giraffe.done`
