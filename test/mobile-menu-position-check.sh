#!/usr/bin/env bash
set -euo pipefail

bundle exec jekyll build >/tmp/mobile-menu-position-check.log 2>&1

css="_site/assets/css/main.css"

test -f "$css"

if ! rg -q '\.menu-main\{[^}]*position:fixed;[^}]*right:0;[^}]*height:100dvh;[^}]*transform:translateX\(100%\);' "$css"; then
  echo "mobile menu should be a fixed right-side panel in compiled CSS"
  exit 1
fi

echo "mobile menu position check passed"
