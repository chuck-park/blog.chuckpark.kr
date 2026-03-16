#!/usr/bin/env bash
set -euo pipefail

bundle exec jekyll build >/tmp/archive-link-color-check.log 2>&1

css_file="_site/assets/css/main.css"
test -f "$css_file"

if ! rg -q '\.post-card__category:visited' "$css_file"; then
  echo "archive category links should define a visited color"
  exit 1
fi

if ! rg -q '\.post-card__tag:visited' "$css_file"; then
  echo "archive tag chips should define a visited color"
  exit 1
fi

echo "archive link color check passed"
