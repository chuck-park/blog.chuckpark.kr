#!/usr/bin/env bash
set -euo pipefail

bundle exec jekyll build >/tmp/desktop-related-grid-check.log 2>&1

python3 - <<'PY'
from pathlib import Path

css = Path("_site/assets/css/main.css").read_text(encoding="utf-8").replace("\n", "")

if ".post-feed__list--related{display:grid;grid-template-columns:repeat(2, minmax(0, 1fr));gap:1.25rem}" not in css:
    raise SystemExit("desktop related content should render as a 2-column grid")
PY

echo "desktop related grid check passed"
