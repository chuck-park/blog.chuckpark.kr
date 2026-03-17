#!/usr/bin/env bash
set -euo pipefail

bundle exec jekyll build >/tmp/listing-main-padding-check.log 2>&1

python3 - <<'PY'
from pathlib import Path

css = Path("_site/assets/css/main.css").read_text(encoding="utf-8").replace("\n", "")

if ".site-main--listing{padding:0}" not in css:
    raise SystemExit("site-main--listing should remove inherited main padding")
PY

echo "listing main padding check passed"
