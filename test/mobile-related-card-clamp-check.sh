#!/usr/bin/env bash
set -euo pipefail

bundle exec jekyll build >/tmp/mobile-related-card-clamp-check.log 2>&1

css="_site/assets/css/main.css"

test -f "$css"

if ! rg -q '\.post-feed__list--related \.post-card__title\{[^}]*display:-webkit-box;[^}]*-webkit-line-clamp:2' "$css"; then
  echo "mobile related card title should be clamped to 2 lines"
  exit 1
fi

if ! rg -q '\.post-feed__list--related \.post-card__excerpt\{[^}]*display:-webkit-box;[^}]*-webkit-line-clamp:3' "$css"; then
  echo "mobile related card excerpt should be clamped to 3 lines"
  exit 1
fi

echo "mobile related card clamp check passed"
