#!/usr/bin/env bash
set -euo pipefail

bundle exec jekyll build >/tmp/archive-card-thumbnails-check.log 2>&1

for page in "_site/index.html" "_site/categories/index.html" "_site/year-archive/index.html"; do
  if rg -q '/assets/images/inkframe-post-placeholder.svg' "$page"; then
    echo "legacy image placeholder found in $page"
    exit 1
  fi
done

if ! rg -q 'post-card__fallback-title' "_site/index.html"; then
  echo "title fallback thumbnail should be rendered for image-less posts"
  exit 1
fi

echo "archive card thumbnails check passed"
