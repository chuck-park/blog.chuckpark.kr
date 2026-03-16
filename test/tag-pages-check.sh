#!/usr/bin/env bash
set -euo pipefail

bundle exec jekyll build >/tmp/tag-pages-check.log 2>&1

test -f "_site/tags/index.html"
test -f "_site/tags/openclaw/index.html"

if ! rg -q '>All<' "_site/tags/index.html"; then
  echo "tags index should include the All option"
  exit 1
fi

if ! rg -q '/tags/openclaw/' "_site/tags/index.html"; then
  echo "tags index should link to tag detail pages"
  exit 1
fi

if ! rg -q 'entries-list|post-card' "_site/tags/index.html"; then
  echo "tags index should render the default all posts"
  exit 1
fi

if ! rg -q '/tags/openclaw/' "_site/product/the-final-destination-of-link-saving-openclaw/index.html"; then
  echo "post detail tags should link to tag detail pages"
  exit 1
fi

if ! rg -q 'post-card__tag' "_site/index.html"; then
  echo "archive cards should render tag chips"
  exit 1
fi

echo "tag pages check passed"
