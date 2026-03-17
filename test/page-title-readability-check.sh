#!/usr/bin/env bash
set -euo pipefail

bundle exec jekyll build >/tmp/page-title-readability-check.log 2>&1

css_file="_site/assets/css/main.css"
test -f "$css_file"

if ! rg -q '\.archive-page__title[^}]*max-width' "$css_file"; then
  echo "archive page title should constrain line width"
  exit 1
fi

if ! rg -q '\.post-layout__title[^}]*text-wrap:balance' "$css_file"; then
  echo "post title should balance wrapped lines"
  exit 1
fi

if ! rg -q '\.page__title[^}]*line-height' "$css_file"; then
  echo "generic page title should define readable line-height"
  exit 1
fi

echo "page title readability check passed"
