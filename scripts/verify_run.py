"""Verify a completed run's hashes without recomputing its analysis."""
from pathlib import Path
import argparse
import csv
import hashlib

ROOT = Path(__file__).resolve().parents[1]


def read_rows(path):
    with path.open(newline="", encoding="utf-8-sig") as handle:
        return list(csv.DictReader(handle))


def verify(path, digest):
    with path.open("rb") as handle:
        observed = hashlib.file_digest(handle, "sha256").hexdigest()
    if observed != digest:
        raise ValueError(f"Hash mismatch: {path}")


def within(base, name):
    path = (base / name).resolve()
    if not path.is_relative_to(base.resolve()):
        raise ValueError(f"Manifest path escapes its root: {name}")
    return path


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("run_dir", type=Path)
    parser.add_argument("--source-root", type=Path, default=ROOT,
                        help="Source snapshot used by this run; defaults to the current repository")
    parser.add_argument("--data-dir", type=Path, help="External input directory for data_dir-scope inputs")
    args = parser.parse_args()
    run = args.run_dir.resolve()
    inputs = read_rows(run / "input_manifest.csv")
    outputs = read_rows(run / "output_manifest.csv")
    if len({(r.get("scope", "repository"), r["path"]) for r in inputs}) != len(inputs):
        raise ValueError("Duplicate input manifest entries")
    for row in inputs:
        scope = row.get("scope", "repository")
        if scope not in {"repository", "data_dir"}:
            raise ValueError(f"Unknown input scope: {scope}")
        base = args.source_root if scope == "repository" else args.data_dir
        if base is None:
            raise ValueError("Supply --data-dir to verify external inputs")
        verify(within(base, row["path"]), row["sha256"])
    paths = set()
    for row in outputs:
        path = within(ROOT, row["path"])
        if not path.is_relative_to(run) or path in paths:
            raise ValueError("Output outside this run or duplicated")
        paths.add(path)
        verify(path, row["sha256"])
    actual = {p.resolve() for p in run.rglob("*") if p.is_file() and p.name != "output_manifest.csv"}
    if paths != actual:
        raise ValueError("Run contains unmanifested or missing output files")
    status = run / "run_status.txt"
    if status.exists() and status.read_text().strip() != "complete":
        raise ValueError("Run did not complete")
    print(f"PASS: {len(inputs)} input hashes and all {len(outputs)} output hashes; source root: {args.source_root}")


if __name__ == "__main__":
    main()
