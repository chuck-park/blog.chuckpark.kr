#!/usr/bin/env bash
set -euo pipefail

bundle exec jekyll build >/tmp/skip-link-structure-check.log 2>&1

html_file="_site/index.html"
css_file="_site/assets/css/main.css"

test -f "$html_file"
test -f "$css_file"

if ! rg -q '<nav class="skip-link">' "$html_file"; then
  echo "skip link nav should use the styled class name"
  exit 1
fi

if ! rg -q '\.skip-link' "$css_file"; then
  echo "compiled CSS should include skip link styles"
  exit 1
fi

echo "skip link structure check passed"
