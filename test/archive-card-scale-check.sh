#!/usr/bin/env bash
set -euo pipefail

python3 - <<'PY'
from pathlib import Path
text = Path("_sass/custom.scss").read_text(encoding="utf-8")

checks = {
    "desktop archive thumbnail width should match reference scale": "grid-template-columns: 340px 1fr;",
    "desktop archive card gap should match reference scale": "gap: 1.875rem;",
    "desktop archive title should match reference scale": "font-size: 1.3125rem;",
    "desktop archive description should match reference scale": "font-size: 0.9375rem;",
    "mobile archive title should use reduced reference scale": "font-size: 1.1875rem;",
}

for message, needle in checks.items():
    if needle not in text:
        raise SystemExit(message)
PY

echo "archive card scale check passed"
