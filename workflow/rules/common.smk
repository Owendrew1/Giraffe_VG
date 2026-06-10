import csv
from pathlib import Path


def load_samples(path):
    with open(path, newline="") as f:
        rows = list(csv.DictReader(f))
    for r in rows:
        for k in list(r.keys()):
            r[k] = (r[k] or "").strip()
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

OUT = Path(config["output_dir"])
PGD = Path(config["pangenome_results_dir"])
REFS = config["linear_ref_dir"]
LOG = f"{OUT}/giraffe_logs"
DONE = f"{OUT}/giraffe.done"
RES = OUT / "results"

PANGENOME_DONE = config["pangenome_done_flag"]
INDEX_DONE = config["index_done_flag"]
USE_HAP_SUBDIR = config["linear_ref_use_haplotype_subdir"]
FASTQ_DIR = config["fastq_dir"]
REGIONS_FILE = REPO / "config" / "regions.txt"

CORES = config["cores"]
MEM_MB = config["mem_mb"]
READ_GROUP = config["read_group"]

GRAPHS = load_samples(config["graphs_csv"])
SAMPLES = [r for r in load_samples(config["samples_csv"]) if r["sample_id"]]
GRAPH_BY_ID = {g["graph_id"]: g for g in GRAPHS}
SAMPLE_BY_ID = {s["sample_id"]: s for s in SAMPLES}
GRAPH_IDS = [g["graph_id"] for g in GRAPHS]
SAMPLE_IDS = [s["sample_id"] for s in SAMPLES]


def graph_row(wc):
    return GRAPH_BY_ID[wc.graph_id]


def sample_row(wc):
    return SAMPLE_BY_ID[wc.sample_id]


def ref_path_for_graph(wc):
    return str(linear_ref_path(graph_row(wc), REFS, USE_HAP_SUBDIR))


def fastq_path(sample, field):
    return str(resolve_fastq(sample[field], FASTQ_DIR))


def surject_read_group(wc):
    return READ_GROUP.format(sample=wc.sample_id)


def sample_out(wc):
    return f"{RES}/{wc.graph_id}/{wc.sample_id}"


def index_out(wc):
    return f"{RES}/{wc.graph_id}/index"
