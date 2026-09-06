"""Stream-validate 10x inputs without loading the full matrix or writing to the input directory."""
from pathlib import Path
import argparse
import collections
import csv
import gzip
import hashlib
import json
import re

ROOT = Path(__file__).resolve().parents[1]

def input_path(directory, name):
    found = [directory / (name + suffix) for suffix in (".gz", "") if (directory / (name + suffix)).is_file()]
    if not found:
        raise ValueError(f"Missing {name}[.gz]")
    return found[0]

def open_text(path):
    return gzip.open(path, "rt") if path.suffix == ".gz" else path.open()

def validate(directory, full=False):
    paths = {n: input_path(directory, n) for n in ("barcodes.tsv", "features.tsv", "matrix.mtx")}
    with open_text(paths["barcodes.tsv"]) as f:
        barcodes = [line.strip() for line in f]
    if len(barcodes) != len(set(barcodes)) or any(not re.search(r"-\d+$", b) for b in barcodes):
        raise ValueError("Duplicate or malformed barcodes")
    suffixes = collections.Counter(b.rsplit("-", 1)[1] for b in barcodes)
    geo = list(csv.DictReader((ROOT / "data/metadata/geo_samples.csv").open()))
    if set(suffixes) != {r["sample"] for r in geo}:
        raise ValueError("Raw barcode suffixes do not match GEO libraries")
    with open_text(paths["features.tsv"]) as f:
        features = [line.rstrip("\n").split("\t") for line in f]
    if any(len(r) != 3 or r[2] != "Gene Expression" for r in features):
        raise ValueError("Expected three-column Gene Expression features")
    if len({r[0] for r in features}) != len(features):
        raise ValueError("Duplicate feature IDs")
    with open_text(paths["matrix.mtx"]) as f:
        header = next(f).strip()
        if header != "%%MatrixMarket matrix coordinate integer general":
            raise ValueError("Expected integer coordinate Matrix Market counts")
        line = next(f)
        while line.startswith("%"):
            line = next(f)
        nr, nc, nnz = map(int, line.split())
        if (nr, nc) != (len(features), len(barcodes)):
            raise ValueError("Feature/barcode counts disagree with matrix dimensions")
        entries = 0
        if full:
            for line in f:
                i, j, value = map(int, line.split())
                if not (1 <= i <= nr and 1 <= j <= nc and value >= 0):
                    raise ValueError(f"Invalid matrix entry at data row {entries + 1}")
                entries += 1
            if entries != nnz:
                raise ValueError("Matrix entry count differs from declared nnz")
    hashes = {}
    for name, p in paths.items():
        with p.open("rb") as f:
            hashes[name] = hashlib.file_digest(f, "sha256").hexdigest()
    return {"features": nr, "barcodes": nc, "declared_entries": nnz,
            "entries_checked": entries, "mode": "full" if full else "header",
            "libraries": dict(suffixes), "sha256": hashes,
            "limits": "Does not establish raw download identity, donor mapping, or analytical validity."}

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("data_dir", type=Path)
    parser.add_argument("--full", action="store_true", help="Validate every sparse entry; takes several minutes.")
    args = parser.parse_args()
    print(json.dumps(validate(args.data_dir.resolve(), args.full), indent=2))
