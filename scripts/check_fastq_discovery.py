#!/usr/bin/env python3
"""Summarize FASTQ discovery for config samples_file (run on Nepenthes)."""

from __future__ import annotations

import argparse
import csv
import sys
from collections import Counter
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "workflow" / "scripts"))
from discover_fastqs import discover_cohort, discover_sample_fastqs  # noqa: E402


def parse_config(cfg_path: Path) -> dict[str, str]:
    out: dict[str, str] = {}
    for line in cfg_path.read_text().splitlines():
        line = line.strip()
        if not line or line.startswith("#") or ":" not in line:
            continue
        key, val = line.split(":", 1)
        out[key.strip()] = val.strip().strip('"')
    return out


def load_samples(path: Path) -> list[str]:
    with path.open(newline="") as f:
        return [r["sample"].strip() for r in csv.DictReader(f, delimiter="\t") if r.get("sample")]


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--config", type=Path, default=ROOT / "config" / "config.yaml")
    ap.add_argument(
        "--fastq-dir",
        help="Override fastq_dir from config (e.g. /archive/raw_data/fastq on Nepenthes)",
    )
    ap.add_argument(
        "--samples-file",
        type=Path,
        help="Override samples_file from config (e.g. resources/samples_test.tsv)",
    )
    ap.add_argument(
        "--skip-missing",
        action="store_true",
        help="Skip samples with no FASTQs instead of failing",
    )
    args = ap.parse_args()

    cfg = parse_config(args.config)
    if args.samples_file:
        samples_path = args.samples_file.resolve()
    elif "samples_file" in cfg:
        samples_path = (ROOT / cfg["samples_file"].replace("../", "")).resolve()
    else:
        print(
            "ERROR: config has no samples_file. Pass --samples-file resources/samples_test.tsv "
            "or sync config from commit 1 (feature/sample-sheet-config).",
            file=sys.stderr,
        )
        return 1
    fastq_dir = args.fastq_dir or cfg.get("fastq_dir")
    if not fastq_dir:
        print("ERROR: pass --fastq-dir /archive/raw_data/fastq", file=sys.stderr)
        return 1

    sample_ids = load_samples(samples_path)
    print(f"samples_file: {samples_path}")
    print(f"fastq_dir:    {fastq_dir}")
    print(f"samples:      {len(sample_ids)}")

    try:
        _, _, lanes, missing = discover_cohort(
            fastq_dir, sample_ids, skip_missing=args.skip_missing
        )
    except ValueError as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        return 1

    print(f"with FASTQs:  {len(lanes)}")
    if missing:
        print(f"missing:      {len(missing)}")
    lane_counts = Counter(len(v) for v in lanes.values())
    print(
        "lanes/sample: "
        + ", ".join(f"{n} lane(s): {c}" for n, c in sorted(lane_counts.items()))
    )

    multi = [s for s, ls in lanes.items() if len(ls) > 1]
    if multi:
        print(f"multi-lane:   {len(multi)} samples (e.g. {', '.join(multi[:5])})")

    for sample in sample_ids[:3]:
        if sample not in lanes:
            continue
        print(f"\n{sample} [{len(lanes[sample])} lane(s)]")
        r1s, r2s = discover_sample_fastqs(fastq_dir, sample)
        for i, (r1, r2) in enumerate(zip(r1s, r2s)):
            print(f"  lane{i}: {Path(r1).name} / {Path(r2).name}")

    return 0 if lanes else 1


if __name__ == "__main__":
    raise SystemExit(main())
