#!/usr/bin/env bash
set -euo pipefail

build_dir="$(mktemp -d /tmp/archive-index-signal-check.XXXXXX)"
trap 'rm -rf "$build_dir"' EXIT

bundle exec jekyll build --destination "$build_dir" >/tmp/archive-index-signal-check.log 2>&1

BUILD_DIR="$build_dir" python3 - <<'PY'
from pathlib import Path
import os

build_dir = Path(os.environ["BUILD_DIR"])

category_html = (build_dir / "categories" / "dev" / "index.html").read_text(encoding="utf-8")
tag_html = (build_dir / "tags" / "github" / "index.html").read_text(encoding="utf-8")
year_html = (build_dir / "year-archive" / "2026" / "index.html").read_text(encoding="utf-8")
year_root_html = (build_dir / "year-archive" / "index.html").read_text(encoding="utf-8")
sitemap_xml = (build_dir / "sitemap.xml").read_text(encoding="utf-8")

noindex_meta = '<meta name="robots" content="noindex, follow">'

if noindex_meta in category_html:
    raise SystemExit("category detail pages should remain indexable")

if noindex_meta not in tag_html:
    raise SystemExit("tag detail pages should be noindex,follow")

if noindex_meta not in year_html:
    raise SystemExit("year detail pages should be noindex,follow")

if noindex_meta not in year_root_html:
    raise SystemExit("year archive root should be noindex,follow")

if "<loc>https://blog.chuckpark.kr/categories/dev/</loc>" not in sitemap_xml:
    raise SystemExit("category detail page should remain in sitemap")

if "<loc>https://blog.chuckpark.kr/tags/github/</loc>" in sitemap_xml:
    raise SystemExit("tag detail page should be removed from sitemap")

if "<loc>https://blog.chuckpark.kr/year-archive/2026/</loc>" in sitemap_xml:
    raise SystemExit("year detail page should be removed from sitemap")

if "<loc>https://blog.chuckpark.kr/year-archive/</loc>" in sitemap_xml:
    raise SystemExit("year archive root should be removed from sitemap")
PY

echo "archive index signal check passed"
