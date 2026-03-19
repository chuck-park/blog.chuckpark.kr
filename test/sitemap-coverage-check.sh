#!/usr/bin/env bash
set -euo pipefail

build_dir="$(mktemp -d /tmp/sitemap-coverage-check.XXXXXX)"
trap 'rm -rf "$build_dir"' EXIT

bundle exec jekyll build --destination "$build_dir" >/tmp/sitemap-coverage-check.log 2>&1

BUILD_DIR="$build_dir" python3 - <<'PY'
from pathlib import Path
import os

xml = Path(os.environ["BUILD_DIR"]) / "sitemap.xml"
xml = xml.read_text(encoding="utf-8")

required_urls = [
    "https://blog.chuckpark.kr/",
    "https://blog.chuckpark.kr/about/",
    "https://blog.chuckpark.kr/categories/",
    "https://blog.chuckpark.kr/tags/",
]

for url in required_urls:
    if f"<loc>{url}</loc>" not in xml:
        raise SystemExit(f"missing sitemap url: {url}")
PY

echo "sitemap coverage check passed"
