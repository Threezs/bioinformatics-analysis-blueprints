#!/usr/bin/env python3
"""Dependency-light validator for the literature blueprint archive."""
from __future__ import annotations
import csv
import re
from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]
REQUIRED_INDEX = {"blueprint_id", "title", "doi", "year", "organism", "tissue", "modalities", "primary_language", "status", "primary_data", "external_data", "code_repo"}
DOI_RE = re.compile(r"^10\.\d{4,9}/\S+$")

def rows(path: Path) -> list[dict[str, str]]:
    with path.open(newline="", encoding="utf-8") as handle:
        return list(csv.DictReader(handle))

def main() -> None:
    errors: list[str] = []
    index = rows(ROOT / "data" / "blueprints.csv")
    seen: set[str] = set()
    for row in index:
        bid = row.get("blueprint_id", "?")
        missing = sorted(k for k in REQUIRED_INDEX if not row.get(k, "").strip())
        if missing:
            errors.append(f"{bid}: missing {missing}")
        if bid in seen:
            errors.append(f"duplicate blueprint_id: {bid}")
        seen.add(bid)
        if row.get("doi") and not DOI_RE.match(row["doi"]):
            errors.append(f"{bid}: malformed DOI {row['doi']}")
        if row.get("primary_language") not in {"R", "Python", "R;Python"}:
            errors.append(f"{bid}: unexpected primary_language")
        if row.get("status") not in {"draft", "active", "deprecated"}:
            errors.append(f"{bid}: unexpected status")
    claims = rows(ROOT / "data" / "evidence-claims.csv")
    allowed = {"descriptive", "association", "trajectory", "external_replication", "perturbation"}
    for claim in claims:
        if claim.get("evidence_level") not in allowed:
            errors.append(f"{claim.get('claim_id', '?')}: invalid evidence level")
        if not claim.get("source", "").strip():
            errors.append(f"{claim.get('claim_id', '?')}: source is empty")
    for required in [ROOT / "templates" / "analysis-blueprint.md", ROOT / "templates" / "method-card.yml", ROOT / "config" / "smoc1.yml", ROOT / "references" / "references.md"]:
        if not required.exists():
            errors.append(f"missing required file: {required.relative_to(ROOT)}")
    if errors:
        for error in errors:
            print(f"ERROR: {error}")
        raise SystemExit(1)
    print(f"OK: {len(index)} blueprint(s), {len(claims)} evidence claim(s)")

if __name__ == "__main__":
    main()

