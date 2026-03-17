#!/usr/bin/env bash
set -euo pipefail

bundle exec jekyll build >/tmp/post-feed-width-check.log 2>&1

python3 - <<'PY'
from pathlib import Path

css = Path("_site/assets/css/main.css").read_text(encoding="utf-8").replace("\n", "")

if ".post-feed .col-lg-9{width:100%}" not in css:
    raise SystemExit("post-feed rows should expand card columns to full width")
PY

echo "post feed width check passed"
