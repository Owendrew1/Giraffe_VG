# Shared helpers for workflow/Snakefile (aligned with Trep_pangenome/rules/common.smk).

import csv
from pathlib import Path


def load_samples(path):
    with open(path, newline="") as f:
        rows = list(csv.DictReader(f))
    for i, r in enumerate(rows, 1):
        for k in list(r.keys()):
            r[k] = (r[k] or "").strip()
        r["row_id"] = f"{i:04d}"
    return rows


def resolve_fastq(path, fastq_dir=""):
    p = Path(path)
    if p.is_absolute():
        return p
    if fastq_dir:
        return Path(fastq_dir) / p
    return p


def linear_ref_path(r, refs_dir, use_hap_subdir=False):
    base = Path(refs_dir) / r["linear_ref_source"]
    if use_hap_subdir and r.get("linear_ref_subdir"):
        base = base / r["linear_ref_subdir"]
    return base / f"{r['linear_ref_assembly']}.fna"
