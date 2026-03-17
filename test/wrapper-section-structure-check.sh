#!/usr/bin/env bash
set -euo pipefail

bundle exec jekyll build >/tmp/wrapper-section-structure-check.log 2>&1

python3 - <<'PY'
from pathlib import Path

html = Path("_site/index.html").read_text(encoding="utf-8")

wrapper = '<div id="wrapper" class="wrapper">'
if wrapper not in html:
    raise SystemExit("wrapper should wrap the page content")

after = html.split(wrapper, 1)[1]
section_count = after.count('<div class="section')
if section_count < 2:
    raise SystemExit("wrapper should contain multiple section blocks")

required = [
    '<div class="title">',
    '<div class="title-heading">',
    '<div class="row align-items-center">',
]

for needle in required:
    if needle not in after:
        raise SystemExit(f"missing expected archive title structure: {needle}")
PY

echo "wrapper section structure check passed"
