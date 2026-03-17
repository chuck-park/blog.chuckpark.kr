#!/usr/bin/env bash
set -euo pipefail

python3 - <<'PY'
from pathlib import Path
text = Path("_sass/custom.scss").read_text(encoding="utf-8")

checks = [
    ".section {\n  width: 100%;",
    ".container {\n  box-sizing: border-box;\n  width: 100%;\n  max-width: 1280px;\n  margin: 0 auto;\n  padding-inline: 15px;",
    ".site-container {\n  box-sizing: border-box;\n  width: 100%;\n  max-width: 1280px;\n  margin: 0 auto;\n  padding-inline: 15px;",
]

for needle in checks:
    if needle not in text:
        raise SystemExit("container and section should use the reference full-width structure")
PY

echo "container width check passed"
