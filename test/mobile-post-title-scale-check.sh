#!/usr/bin/env bash
set -euo pipefail

bundle exec jekyll build >/tmp/mobile-post-title-scale-check.log 2>&1

python3 - <<'PY'
from pathlib import Path

css = Path("_site/assets/css/main.css").read_text(encoding="utf-8").replace("\n", "")

if ".post-layout__title{width:100%;max-width:100%;font-size:clamp(1.75rem, 7.6vw, 2.65rem);line-height:1.12;letter-spacing:-0.025em}" not in css:
    raise SystemExit("mobile post title should be full width with a smaller responsive font size")

if ".post-layout__title a{display:block;width:100%;color:inherit;text-decoration:none}" not in css:
    raise SystemExit("post title link should fill the full title width")
PY

echo "mobile post title scale check passed"
