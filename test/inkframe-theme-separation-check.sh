#!/usr/bin/env bash
set -euo pipefail

python3 - <<'PY'
from pathlib import Path
import re

config = Path("_config.yml").read_text(encoding="utf-8")
main_scss = Path("assets/css/main.scss").read_text(encoding="utf-8")
package_json = Path("package.json").read_text(encoding="utf-8")

if re.search(r"(?m)^\s*remote_theme\s*:", config):
    raise SystemExit("remote_theme should be removed once Inkframe is activated")

if 'theme_snapshot_path    : "vendor/minimal-mistakes-4.24.0"' not in config:
    raise SystemExit("config should point to the vendored Minimal Mistakes snapshot")

if '@import "inkframe/skins/' not in main_scss or '@import "inkframe";' not in main_scss:
    raise SystemExit("main.scss should import Inkframe instead of Minimal Mistakes")

if '"build:inkframe-js"' not in package_json:
    raise SystemExit("package.json should define an Inkframe JS build script")

if not Path("vendor/minimal-mistakes-4.24.0").is_dir():
    raise SystemExit("vendor snapshot should exist")
PY

echo "inkframe theme separation check passed"
