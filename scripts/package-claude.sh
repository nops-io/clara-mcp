#!/usr/bin/env bash
set -euo pipefail

VERSION="$(./scripts/current-version.sh)"
OUT="dist/clara-claude-plugin-v${VERSION}.zip"

mkdir -p dist
rm -f "$OUT"

cd packages/claude
zip -r "../../$OUT" . -x "*.DS_Store"

echo "Created $OUT"
