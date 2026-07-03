# Giraffe_vg

Map white clover reads to the **Trep_pangenome** graph (Giraffe), following the same overall pattern as James’s [align_trifolium_reads](https://github.com/James-S-Santangelo/align_trifolium_reads): discover FASTQs → per-lane align → merge → mark duplicates → QC → VCF.

## Layout

```text
Giraffe_vg/
├── environment.yaml
├── config/config.yaml
├── config/regions.txt          # optional SV loci (chrom:start-end)
├── resources/graphs.csv
├── resources/samples_test.tsv  # small test cohort
├── workflow/
│   ├── Snakefile
│   ├── rules/common.smk
│   ├── scripts/discover_fastqs.py
│   └── envs/giraffe.yaml
└── scripts/run_giraffe.sh
```

## Pipeline (vs James)

| James (linear BWA) | Giraffe_vg (pangenome) |
|--------------------|------------------------|
| Find reads, label lane0…N | Same (`discover_fastqs`) |
| BWA-MEM per lane | `vg giraffe` per lane |
| Merge BAMs | Merge GAMs |
| MarkDuplicates | MarkDuplicates on **surjected** BAM |
| flagstat, mosdepth | flagstat, mosdepth + `vg stats` |
| — | `vg call` → filter → `bcftools stats` |

Parallelize across **samples** at the read stage (`cores: 32`). Chromosome-level BAM/VCF split is a later step once full-sample outputs exist.

## Setup

```bash
conda activate snakemake
# edit config/config.yaml: samples_file, outputs
```

Test cohort: `resources/samples_test.tsv` (2 samples). Full cohort: `scripts/sync_sample_sheet.sh` then point `samples_file` at `all_clover_samples.txt`.

## Run

```bash
cd ~/github-repos/Giraffe_vg
./scripts/run_giraffe.sh 4
```

Dry run:

```bash
snakemake -s workflow/Snakefile --directory workflow --cores 4 -n -p --use-conda
```

## Outputs (per sample under `{output_dir}/results/{graph_id}/{sample}/`)

| File | Role |
|------|------|
| `{sample}.gam` | Merged graph alignments (if `gam: true`) |
| `{sample}.markdup.bam` | Surjected, duplicate-marked BAM |
| `{sample}.markdup.metrics.txt` | Duplication rate |
| `{sample}.flagstat.txt` | Alignment % |
| `{sample}.mosdepth.summary.txt` | Coverage |
| `{sample}.vg_stats.txt` | Pangenome-specific alignment stats |
| `{sample}.vg_call.vcf.gz` | Graph variant calls |
| `{sample}.vg_call.filtered.vcf.gz` | QUAL-filtered VCF |
| `{sample}.vg_call.filtered.bcftools_stats.txt` | VCF QC |

Done flag: `{output_dir}/giraffe.done`
