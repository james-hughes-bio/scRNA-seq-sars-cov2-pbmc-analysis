"""Offline repository checks: provenance, exact reference bytes, paths and documentation."""
from pathlib import Path
import ast
import csv
import hashlib
import re
import subprocess
import sys
from urllib.parse import unquote

ROOT = Path(__file__).resolve().parents[1]


def sha256(path):
    with path.open("rb") as handle:
        return hashlib.file_digest(handle, "sha256").hexdigest()


def rows(path):
    with path.open(newline="", encoding="utf-8-sig") as handle:
        return list(csv.DictReader(handle))


def main():
    refs = rows(ROOT / "provenance/reference_manifest.csv")
    expected = {r["path"] for r in refs}
    actual = {p.relative_to(ROOT).as_posix() for p in (ROOT / "reference").rglob("*") if p.is_file()}
    if len(expected) != len(refs) or expected != actual:
        raise ValueError("Reference manifest has duplicate, missing or extra files")
    for row in refs:
        if sha256(ROOT / row["path"]) != row["sha256"]:
            raise ValueError(f"Reference hash mismatch: {row['path']}")
    original = rows(ROOT / "provenance/original_workspace_manifest.csv")
    disposition = rows(ROOT / "provenance/workspace_disposition.csv")
    a = {r["workspace_relative_path"]: r["sha256"] for r in original}
    b = {r["original"]: r["sha256"] for r in disposition}
    if len(a) != len(original) or len(b) != len(disposition) or a != b:
        raise ValueError("Original and disposition manifests disagree")
    subprocess.run([sys.executable, str(ROOT / "scripts/refresh_geo_metadata.py"), "--check"], check=True)
    for file in (ROOT / "scripts").glob("*.py"):
        ast.parse(file.read_text(encoding="utf-8"), filename=str(file))
    for file in [ROOT / "README.md", *(ROOT / "docs").glob("*.md")]:
        for link in re.findall(r"\[[^\]]*\]\(([^)]+)\)", file.read_text(encoding="utf-8")):
            if re.match(r"[a-z]+:|#", link):
                continue
            target = unquote(link.split("#", 1)[0].strip("<>"))
            if target and not (file.parent / target).exists():
                raise ValueError(f"Broken local link in {file.name}: {target}")
    for directory in ("analysis", "R", "scripts"):
        for file in (ROOT / directory).glob("*"):
            if file.suffix not in {".R", ".Rmd", ".py"}:
                continue
            if re.search(r"[A-Za-z]:[/\\]Users[/\\]|/home/[A-Za-z]+/|/mnt/[a-z]/Users/", file.read_text(encoding="utf-8")):
                raise ValueError(f"Machine-specific path: {file.relative_to(ROOT)}")
    probe = ["outputs/example.html", ".r-library/example/DESCRIPTION", ".cache/example", "data/raw/matrix.mtx.gz"]
    ignored = subprocess.run(["git", "check-ignore", "--stdin", "-z"], input=("\0".join(probe)+"\0").encode(), cwd=ROOT, capture_output=True, check=True)
    if set(ignored.stdout.decode().rstrip("\0").split("\0")) != set(probe):
        raise ValueError("Generated outputs, local libraries, caches or raw inputs are not ignored")
    print(f"PASS: {len(refs)} exact reference hashes, {len(original)} disposition records, offline metadata, Python syntax, documentation links, source paths and ignore rules.")


if __name__ == "__main__":
    main()
