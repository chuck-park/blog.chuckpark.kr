#!/usr/bin/env bash
set -euo pipefail

bundle exec jekyll build >/tmp/mobile-post-title-scale-check.log 2>&1

python3 - <<'PY'
from pathlib import Path

css = Path("_site/assets/css/main.css").read_text(encoding="utf-8").replace("\n", "")

if ".post-layout__title{max-width:100%;font-size:clamp(1.75rem, 7.6vw, 2.65rem);line-height:1.12;letter-spacing:-0.025em}" not in css:
    raise SystemExit("mobile post title should use a smaller responsive font size")
PY

echo "mobile post title scale check passed"
