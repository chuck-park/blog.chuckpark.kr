#!/usr/bin/env bash
set -euo pipefail

css_source="_sass/custom.scss"
test -f "$css_source"

python3 - <<'PY'
from pathlib import Path
text = Path("_sass/custom.scss").read_text(encoding="utf-8")

checks = {
    "archive h1 should use the reference desktop scale": ".archive-page__title {\n  margin: 0;\n  color: #f8f4ed;\n  max-width: 13ch;\n  font-size: clamp(1.85rem, calc(1.375rem + 1.5vw), 2.5rem);",
    "page h1 should use the reference desktop scale": ".page__title {\n  margin: 0;\n  max-width: 14ch;\n  color: #f8f4ed;\n  font-size: clamp(1.85rem, calc(1.375rem + 1.5vw), 2.5rem);",
    "post h1 should use the reduced desktop scale": ".post-layout__title {\n  margin: 0;\n  color: #f8f4ed;\n  max-width: 14ch;\n  font-size: clamp(2.15rem, 4.1vw, 3.8rem);",
    "post h2 should use the reduced desktop scale": ".post-layout__content h2 {\n  font-size: clamp(1.8rem, 2.6vw, 2.3rem);",
    "post h3 should use the reduced desktop scale": ".post-layout__content h3 {\n  font-size: clamp(1.3rem, 1.7vw, 1.65rem);",
}

for message, needle in checks.items():
    if needle not in text:
        raise SystemExit(message)
PY

echo "desktop heading scale check passed"
