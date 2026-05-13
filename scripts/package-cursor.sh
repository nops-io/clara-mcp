#!/usr/bin/env bash
set -euo pipefail

VERSION="$(./scripts/current-version.sh)"
OUT="dist/clara-cursor-plugin-v${VERSION}.zip"

mkdir -p dist
rm -f "$OUT"

cd packages/cursor
zip -r "../../$OUT" . -x "*.DS_Store"

echo "Created $OUT"
