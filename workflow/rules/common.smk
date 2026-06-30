# Paths, sample metadata, FASTQ discovery, and helpers.

import csv
import re
import sys
from pathlib import Path

sys.path.insert(0, workflow.sourcepath("scripts"))
from discover_fastqs import discover_cohort


def load_graphs(path):
    with open(path, newline="") as f:
        rows = list(csv.DictReader(f))
    for r in rows:
        for k in list(r.keys()):
            r[k] = (r[k] or "").strip()
    return rows


def load_sample_sheet(path):
    with open(path, newline="") as f:
        rows = list(csv.DictReader(f, delimiter="\t"))
    out = []
    for i, r in enumerate(rows, 1):
        for k in list(r.keys()):
            r[k] = (r[k] or "").strip()
        if r.get("sample"):
            r["row_id"] = f"{i:04d}"
            out.append(r)
    return out


def linear_ref_path(r, refs_dir, use_hap_subdir=False):
    base = Path(refs_dir) / r["linear_ref_source"]
    if use_hap_subdir and r.get("linear_ref_subdir"):
        base = base / r["linear_ref_subdir"]
    return base / f"{r['linear_ref_assembly']}.fna"


OUT = Path(config["output_dir"])
PGD = Path(config["pangenome_results_dir"])
REFS = config["linear_ref_dir"]
LOG = f"{OUT}/giraffe_logs"
DONE = f"{OUT}/giraffe.done"
RES = OUT / "results"
REGIONS_FILE = Path(workflow.basedir).parent / "config" / "regions.txt"

PANGENOME_DONE = config["pangenome_done_flag"]
INDEX_DONE = config["index_done_flag"]
USE_HAP_SUBDIR = config["linear_ref_use_haplotype_subdir"]
FASTQ_DIR = config["fastq_dir"]
CORES = config["cores"]
MEM_MB = config["mem_mb"]
READ_GROUP = config.get("read_group", "ID:{sample} SM:{sample} PL:ILLUMINA")
SKIP_MISSING = config.get("skip_missing_fastqs", False)
CONDA = "envs/giraffe.yaml"

_OUT = config.get("outputs", {})
WANT_BAM = _OUT.get("bam", True)
WANT_GAM = _OUT.get("gam", False)
WANT_VG_VCF = _OUT.get("vg_call_vcf", True)
WANT_LINEAR_VCF = _OUT.get("linear_small_variants", False)
WANT_SV_REGIONS = _OUT.get("sv_regions", False)
WANT_QC_FLAGSTAT = _OUT.get("qc_flagstat", True)
WANT_QC_VG_STATS = _OUT.get("qc_vg_stats", True)
NEEDS_SAMPLE = (
    WANT_BAM or WANT_GAM or WANT_VG_VCF or WANT_LINEAR_VCF or WANT_SV_REGIONS
    or WANT_QC_FLAGSTAT or WANT_QC_VG_STATS
)

GRAPHS = load_graphs(config["graphs_csv"])
GRAPH_BY_ID = {g["graph_id"]: g for g in GRAPHS}
GRAPH_IDS = [g["graph_id"] for g in GRAPHS]

SAMPLE_ROWS = load_sample_sheet(config["samples_file"])
SAMPLE_IDS = [r["sample"] for r in SAMPLE_ROWS]
PROJECT = {r["sample"]: r.get("initial_project", "") for r in SAMPLE_ROWS}
COV_CAT = {r["sample"]: r.get("cov_cat", "") for r in SAMPLE_ROWS}

SAMPLE_R1, SAMPLE_R2, SAMPLE_LANES, MISSING_FASTQS = discover_cohort(
    FASTQ_DIR,
    SAMPLE_IDS,
    skip_missing=SKIP_MISSING,
)
if SKIP_MISSING:
    SAMPLE_IDS = [s for s in SAMPLE_IDS if s in SAMPLE_R1]
    SAMPLE_ROWS = [r for r in SAMPLE_ROWS if r["sample"] in SAMPLE_R1]

MULTI_LANE = [s for s in SAMPLE_IDS if len(SAMPLE_LANES[s]) > 1]
if MULTI_LANE:
    raise ValueError(
        "Multi-lane samples need per-lane mapping (next commit). Examples: "
        + ", ".join(MULTI_LANE[:5])
    )

SAMPLE_BY_ID = {r["sample"]: r for r in SAMPLE_ROWS}


def graph_row(wc):
    return GRAPH_BY_ID[wc.graph_id]


def graph_input(wc, kind):
    return str(PGD / graph_row(wc)[f"{kind}_basename"])


def sample_row(wc):
    return SAMPLE_BY_ID[wc.sample_id]


def ref_path_for_graph(wc):
    return str(linear_ref_path(graph_row(wc), REFS, USE_HAP_SUBDIR))


def sample_fastq_r1(wc):
    return SAMPLE_R1[wc.sample_id][0]


def sample_fastq_r2(wc):
    return SAMPLE_R2[wc.sample_id][0]


def surject_read_group(wc):
    return READ_GROUP.format(sample=wc.sample_id)


def ref_path_name_for_graph(wc):
    return graph_row(wc)["linear_ref_assembly"]


def sample_out(wc):
    return f"{RES}/{wc.graph_id}/{wc.sample_id}"


def index_out(wc):
    return f"{RES}/{wc.graph_id}/index"


def regions_out(wc):
    return f"{RES}/{wc.graph_id}/{wc.sample_id}/regions"


def done_inputs(wildcards):
    req = list(expand(rules.giraffe_index.output.done, graph_id=GRAPH_IDS))
    if NEEDS_SAMPLE and SAMPLE_IDS:
        if WANT_GAM:
            req.extend(expand(rules.giraffe_map.output.gam, graph_id=GRAPH_IDS, sample_id=SAMPLE_IDS))
        if WANT_BAM:
            req.extend(expand(rules.giraffe_surject.output.bam, graph_id=GRAPH_IDS, sample_id=SAMPLE_IDS))
        if WANT_VG_VCF:
            req.extend(expand(rules.vg_variant_call.output.vcf, graph_id=GRAPH_IDS, sample_id=SAMPLE_IDS))
        if WANT_LINEAR_VCF:
            req.extend(expand(rules.small_variant_call.output.vcf, graph_id=GRAPH_IDS, sample_id=SAMPLE_IDS))
        if WANT_SV_REGIONS:
            req.extend(expand(rules.sv_regions.output.tsv, graph_id=GRAPH_IDS, sample_id=SAMPLE_IDS))
        if WANT_QC_FLAGSTAT:
            req.extend(expand(rules.qc_flagstat.output, graph_id=GRAPH_IDS, sample_id=SAMPLE_IDS))
        if WANT_QC_VG_STATS:
            req.extend(expand(rules.qc_vg_stats.output, graph_id=GRAPH_IDS, sample_id=SAMPLE_IDS))
    return req


wildcard_constraints:
    graph_id="|".join(re.escape(g) for g in GRAPH_IDS),
    sample_id="|".join(re.escape(s) for s in SAMPLE_IDS),
