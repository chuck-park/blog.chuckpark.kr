#!/usr/bin/env bash
set -euo pipefail

bundle exec jekyll build >/tmp/mobile-related-layout-check.log 2>&1

css="_site/assets/css/main.css"

test -f "$css"

if ! rg -q '\.post-feed__list--related\{grid-template-columns:1fr;[^}]*gap:0\.9rem' "$css"; then
  echo "mobile related cards should stack in a single column"
  exit 1
fi

echo "mobile related layout check passed"
