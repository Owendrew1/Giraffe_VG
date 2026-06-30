"""Recursive FASTQ discovery (align_trifolium_reads convention)."""

from __future__ import annotations

import os
import re


def run_fast_scandir(root: str, sample: str) -> list[str]:
    """Return sorted paths under root whose basename starts with `{sample}_`."""
    subfolders: list[str] = []
    files: list[str] = []
    for entry in os.scandir(root):
        if entry.is_dir():
            subfolders.append(entry.path)
        elif entry.is_file() and re.match(rf"^{re.escape(sample)}_", entry.name):
            files.append(entry.path)
    for subdir in subfolders:
        files.extend(run_fast_scandir(subdir, sample))
    return sorted(files)


def split_r1_r2(files: list[str]) -> tuple[list[str], list[str]]:
    """Illumina (_R1_/_R2_) and BGI (_1.fq.gz/_2.fq.gz) naming."""
    r1 = sorted(f for f in files if re.search(r"_R1[_.]|_1\.f(?:ast)?q\.gz$", f))
    r2 = sorted(f for f in files if re.search(r"_R2[_.]|_2\.f(?:ast)?q\.gz$", f))
    return r1, r2


def discover_sample_fastqs(fastq_dir: str, sample: str) -> tuple[list[str], list[str]]:
    files = run_fast_scandir(fastq_dir, sample)
    r1, r2 = split_r1_r2(files)
    if not r1:
        raise ValueError(f"No R1 FASTQs found for '{sample}' under '{fastq_dir}'")
    if len(r1) != len(r2):
        raise ValueError(
            f"Sample '{sample}': {len(r1)} R1 files but {len(r2)} R2 files.\n"
            f"  R1: {r1}\n  R2: {r2}"
        )
    return r1, r2


def discover_cohort(
    fastq_dir: str,
    sample_ids: list[str],
    *,
    skip_missing: bool = False,
) -> tuple[dict[str, list[str]], dict[str, list[str]], dict[str, list[str]], list[str]]:
    """Build sample → paths/lanes maps. Returns (r1, r2, lanes, missing)."""
    r1_map: dict[str, list[str]] = {}
    r2_map: dict[str, list[str]] = {}
    lane_map: dict[str, list[str]] = {}
    missing: list[str] = []

    for sample in sample_ids:
        try:
            r1s, r2s = discover_sample_fastqs(fastq_dir, sample)
        except ValueError:
            if skip_missing:
                missing.append(sample)
                continue
            raise
        r1_map[sample] = r1s
        r2_map[sample] = r2s
        lane_map[sample] = [str(i) for i in range(len(r1s))]

    if skip_missing and not r1_map:
        raise ValueError(f"No samples with FASTQs found under {fastq_dir}")

    return r1_map, r2_map, lane_map, missing
