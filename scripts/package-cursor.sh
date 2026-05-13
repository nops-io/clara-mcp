#!/usr/bin/env bash
set -euo pipefail

TAG="$(git describe --tags --exact-match 2>/dev/null || true)"

if [ -z "$TAG" ]; then
	TAG="$(git describe --tags --abbrev=0 2>/dev/null || true)"
fi

VERSION="${TAG#v}"

if [ -z "$VERSION" ]; then
	VERSION="0.0.0-dev"
fi

rm -rf dist/build/cursor
mkdir -p dist/build/cursor
mkdir -p dist

test -d packages/cursor/.cursor/rules
test -f shared/mcp/clara.mcp.json

# Output is a .cursor/ directory that drops into project root
rsync -a packages/cursor/.cursor/ dist/build/cursor/.cursor/
cp shared/mcp/clara.mcp.json dist/build/cursor/.cursor/mcp.json

OUT="dist/clara-cursor-plugin-v${VERSION}.zip"
rm -f "$OUT"
(
	cd dist/build/cursor
	zip -r "../../$OUT" . -x "*.DS_Store"
)

echo "Created $OUT"
