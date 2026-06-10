# Paths, config-derived constants, and helpers (aligned with Trep_pangenome).

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


REPO = Path(workflow.basedir).parent

# --- output layout ---
OUT = Path(config["output_dir"])
PGD = Path(config["pangenome_results_dir"])
REFS = config["linear_ref_dir"]
LOG = f"{OUT}/giraffe_logs"
DONE = f"{OUT}/giraffe.done"
RES = OUT / "results"

# --- upstream flags ---
PANGENOME_DONE = config["pangenome_done_flag"]
INDEX_DONE = config["index_done_flag"]
USE_HAP_SUBDIR = config.get("linear_ref_use_haplotype_subdir", False)
FASTQ_DIR = config.get("fastq_dir", "")

# --- region config ---
REGIONS_FILE = REPO / "config" / "regions.txt"
CHROM_MAP = REPO / "config" / "chrom_map.tsv"
REF_CONTIG = config.get("reference_contig", "")

# --- samples / graphs ---
GRAPHS = load_samples(config["graphs_csv"])
SAMPLES = [r for r in load_samples(config["samples_csv"]) if r["sample_id"]]
GRAPH_BY_ID = {g["graph_id"]: g for g in GRAPHS}
SAMPLE_BY_ID = {s["sample_id"]: s for s in SAMPLES}
GRAPH_IDS = [g["graph_id"] for g in GRAPHS]
SAMPLE_IDS = [s["sample_id"] for s in SAMPLES]

# --- tool settings (swap in config.yaml) ---
GF = config["giraffe"]
SURJECT = config["surject"]
VG_CALL = config.get("vg_call", {})
RUN_VG_CALL = config.get("run_vg_call", False)
CALLER = config.get("small_variant_caller", "deepvariant")

CORES_G = GF.get("cores", 16)
MEM_G = GF.get("mem_mb", 32000)
EXTRA_G = GF.get("extra_args", "")
CORES_S = SURJECT.get("cores", 8)
CORES_V = VG_CALL.get("cores", 8)
PACK_QUAL = VG_CALL.get("pack_qual", 5)
INDEX_THREADS = GF.get("index_threads", CORES_G)

READ_GROUP_TEMPLATE = SURJECT.get(
    "read_group",
    "@RG\\tID:{sample}\\tSM:{sample}\\tPL:ILLUMINA",
)

CONDA_ENV = "envs/giraffe.yaml"


def graph_row(wc):
    return GRAPH_BY_ID[wc.graph_id]


def sample_row(wc):
    return SAMPLE_BY_ID[wc.sample_id]


def ref_path_for_graph(wc):
    return str(linear_ref_path(graph_row(wc), REFS, USE_HAP_SUBDIR))


def fastq_path(sample, field):
    return str(resolve_fastq(sample[field], FASTQ_DIR))


def surject_read_group(wc):
    return READ_GROUP_TEMPLATE.format(sample=wc.sample_id)


def sample_out(wc):
    return f"{RES}/{wc.graph_id}/{wc.sample_id}"


def index_out(wc):
    return f"{RES}/{wc.graph_id}/index"
