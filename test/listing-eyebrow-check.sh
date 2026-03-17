#!/usr/bin/env bash
set -euo pipefail

bundle exec jekyll build >/tmp/listing-eyebrow-check.log 2>&1

python3 - <<'PY'
from pathlib import Path

targets = {
    "_site/categories/index.html": "categories index",
    "_site/tags/index.html": "tags index",
    "_site/year-archive/index.html": "year archive index",
}

for path, label in targets.items():
    html = Path(path).read_text(encoding="utf-8")
    if "listing-page__eyebrow" in html or ">블로그<" in html:
        raise SystemExit(f"{label} should not render the blog eyebrow")
PY

echo "listing eyebrow check passed"
