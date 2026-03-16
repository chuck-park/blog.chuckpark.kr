#!/usr/bin/env bash
set -euo pipefail

bundle exec jekyll build >/tmp/archive-card-thumbnails-check.log 2>&1

for page in "_site/index.html" "_site/categories/index.html" "_site/year-archive/index.html"; do
  if rg -q 'post-card__placeholder' "$page"; then
    echo "archive card placeholder found in $page"
    exit 1
  fi
done

echo "archive card thumbnails check passed"
