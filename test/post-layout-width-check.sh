#!/usr/bin/env bash
set -euo pipefail

bundle exec jekyll build >/tmp/post-layout-width-check.log 2>&1

python3 - <<'PY'
from pathlib import Path

css = Path("_site/assets/css/main.css").read_text(encoding="utf-8").replace("\n", "")

if ".site-container--narrow{width:100%;max-width:1040px;padding-inline:24px}" not in css:
    raise SystemExit("site-container--narrow should use a wider max width")

if ".post-layout__title.p-name{max-width:100%}" not in css:
    raise SystemExit("post-layout title should use the full available width")

if ".post-layout__title a{display:block;width:100%;max-width:100%;color:inherit;text-decoration:none}" not in css:
    raise SystemExit("post-layout title link should use the full available width")
PY

echo "post layout width check passed"
