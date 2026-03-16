#!/usr/bin/env bash
set -euo pipefail

bundle exec jekyll build >/tmp/mobile-menu-position-check.log 2>&1

css="_site/assets/css/main.css"

test -f "$css"

if ! rg -q '\.menu-main\{[^}]*left:auto;[^}]*right:0;[^}]*width:auto;' "$css"; then
  echo "mobile menu should be right-aligned in compiled CSS"
  exit 1
fi

echo "mobile menu position check passed"
