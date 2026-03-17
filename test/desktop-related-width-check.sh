#!/usr/bin/env bash
set -euo pipefail

bundle exec jekyll build >/tmp/desktop-related-width-check.log 2>&1

python3 - <<'PY'
from pathlib import Path

css = Path("_site/assets/css/main.css").read_text(encoding="utf-8").replace("\n", "")

if ".page__related-wrap .site-container--narrow{max-width:1120px}" not in css:
    raise SystemExit("desktop related section should use a wider container")
PY

echo "desktop related width check passed"
