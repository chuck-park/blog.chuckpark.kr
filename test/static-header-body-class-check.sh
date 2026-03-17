#!/usr/bin/env bash
set -euo pipefail

bundle exec jekyll build >/tmp/static-header-body-class-check.log 2>&1

python3 - <<'PY'
from pathlib import Path

html = Path("_site/index.html").read_text(encoding="utf-8")
css = Path("_site/assets/css/main.css").read_text(encoding="utf-8")

if '<body class="layout--home site-page site-page-blog has-static-header">' not in html:
    raise SystemExit("home page body should include site-page site-page-blog has-static-header classes")

if "body.has-static-header .header{position:relative;top:auto}" not in css.replace("\n", ""):
    raise SystemExit("static header pages should reset header positioning")

if "body.has-static-header .wrapper{padding-top:0}" not in css.replace("\n", ""):
    raise SystemExit("static header pages should remove wrapper top padding")
PY

echo "static header body class check passed"
