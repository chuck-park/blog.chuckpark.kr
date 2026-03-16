#!/usr/bin/env bash
set -euo pipefail

bundle exec jekyll build >/tmp/mobile-menu-position-check.log 2>&1

css="_site/assets/css/main.css"
js="_site/index.html"

test -f "$css"
test -f "$js"

if ! rg -q '\.menu-main\{[^}]*position:fixed;[^}]*right:0;[^}]*width:min\(48vw, 280px\);[^}]*height:100dvh;[^}]*transform:translateX\(100%\);' "$css"; then
  echo "mobile menu should be a fixed right-side panel in compiled CSS"
  exit 1
fi

if ! rg -q "document.addEventListener\\('click'" "$js"; then
  echo "mobile menu should close when clicking outside the panel"
  exit 1
fi

echo "mobile menu position check passed"
