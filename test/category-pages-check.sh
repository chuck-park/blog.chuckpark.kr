#!/usr/bin/env bash
set -euo pipefail

bundle exec jekyll build >/tmp/category-pages-check.log 2>&1

test -f "_site/categories/index.html"
test -f "_site/categories/product/index.html"

if rg -q 'taxonomy__section' "_site/categories/index.html"; then
  echo "categories index should not render full taxonomy sections"
  exit 1
fi

if ! rg -q '/categories/product/' "_site/categories/index.html"; then
  echo "categories index should link to category detail pages"
  exit 1
fi

echo "category pages check passed"
