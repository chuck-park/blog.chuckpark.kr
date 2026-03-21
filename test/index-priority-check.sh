#!/usr/bin/env bash
set -euo pipefail

build_dir="$(mktemp -d /tmp/index-priority-check.XXXXXX)"
trap 'rm -rf "$build_dir"' EXIT

bundle exec jekyll build --destination "$build_dir" >/tmp/index-priority-check.log 2>&1

BUILD_DIR="$build_dir" python3 - <<'PY'
from pathlib import Path
import os

build_dir = Path(os.environ["BUILD_DIR"])
noindex_meta = '<meta name="robots" content="noindex, follow">'

page2_html = (build_dir / "page2" / "index.html").read_text(encoding="utf-8")
sitemap_page_html = (build_dir / "sitemap" / "index.html").read_text(encoding="utf-8")
page_archive_html = (build_dir / "page-archive" / "index.html").read_text(encoding="utf-8")
collection_html = (build_dir / "collection" / "index.html").read_text(encoding="utf-8")
portfolio_html = (build_dir / "portfolio" / "index.html").read_text(encoding="utf-8")
sitemap_xml = (build_dir / "sitemap.xml").read_text(encoding="utf-8")

for label, html in {
    "paginated pages": page2_html,
    "sitemap page": sitemap_page_html,
    "page archive": page_archive_html,
    "collection archive": collection_html,
    "portfolio archive": portfolio_html,
}.items():
    if noindex_meta not in html:
        raise SystemExit(f"{label} should be noindex,follow")

for url in [
    "https://blog.chuckpark.kr/page2/",
    "https://blog.chuckpark.kr/sitemap/",
    "https://blog.chuckpark.kr/page-archive/",
    "https://blog.chuckpark.kr/collection/",
    "https://blog.chuckpark.kr/portfolio/",
]:
    if f"<loc>{url}</loc>" in sitemap_xml:
        raise SystemExit(f"utility url should be removed from sitemap: {url}")
PY

echo "index priority check passed"
