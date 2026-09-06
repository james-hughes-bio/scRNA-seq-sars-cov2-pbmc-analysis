"""Verify the full original workspace against its read-only baseline (does not modify it)."""
from pathlib import Path
import argparse
import csv
import hashlib
import sys

ROOT = Path(__file__).resolve().parents[1]
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("workspace", nargs="?", type=Path, default=ROOT.parent, help="Directory containing the original workspace folders")
workspace = parser.parse_args().workspace.resolve()
manifest = list(csv.DictReader((ROOT / "provenance/original_workspace_manifest.csv").open(encoding="utf-8-sig")))
failures = []
for row in manifest:
    path = workspace / row["workspace_relative_path"]
    if not path.is_file():
        failures.append(f"Missing: {path}")
        continue
    with path.open("rb") as f:
        digest = hashlib.file_digest(f, "sha256").hexdigest()
    if digest != row["sha256"] or path.stat().st_size != int(row["bytes"]):
        failures.append(f"Changed: {path}")
if failures:
    print("\n".join(failures))
    sys.exit(1)
print(f"PASS: all {len(manifest)} original files retain their exact baseline bytes.")
