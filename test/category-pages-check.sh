#!/usr/bin/env bash
set -euo pipefail

bundle exec jekyll build >/tmp/category-pages-check.log 2>&1

test -f "_site/categories/index.html"
test -f "_site/categories/product/index.html"
test -f "_site/year-archive/index.html"
test -f "_site/year-archive/2026/index.html"

if ! rg -q 'entries-list|post-card' "_site/categories/index.html"; then
  echo "categories index should render the default category posts"
  exit 1
fi

if ! rg -q '>All<' "_site/categories/index.html"; then
  echo "categories index should include the All option"
  exit 1
fi

if ! rg -q '/categories/product/' "_site/categories/index.html"; then
  echo "categories index should link to category detail pages"
  exit 1
fi

if ! rg -q '>All<' "_site/year-archive/index.html"; then
  echo "year archive index should include the All option"
  exit 1
fi

if ! rg -q '/year-archive/2026/' "_site/year-archive/index.html"; then
  echo "year archive index should link to year detail pages"
  exit 1
fi

if ! rg -q 'entries-list|post-card' "_site/year-archive/index.html"; then
  echo "year archive index should render the default all posts"
  exit 1
fi

echo "category pages check passed"
