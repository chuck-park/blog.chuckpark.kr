#!/usr/bin/env bash
set -euo pipefail

python3 - <<'PY'
from pathlib import Path
text = Path("_sass/custom.scss").read_text(encoding="utf-8")

needle = ".site-container {\n  width: min(1280px, calc(100% - 30px));"
if needle not in text:
    raise SystemExit("site container should match the reference width")
PY

echo "container width check passed"
