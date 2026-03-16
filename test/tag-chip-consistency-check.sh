#!/usr/bin/env bash
set -euo pipefail

bundle exec jekyll build >/tmp/tag-chip-consistency-check.log 2>&1

test -f "_site/product/the-final-destination-of-link-saving-openclaw/index.html"

if ! rg -q 'class="post-layout__tag post-card__tag"' "_site/product/the-final-destination-of-link-saving-openclaw/index.html"; then
  echo "post detail tags should reuse the shared chip class"
  exit 1
fi

echo "tag chip consistency check passed"
