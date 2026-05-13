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

rm -rf dist/build
mkdir -p dist/build/claude
mkdir -p dist/build/cursor
mkdir -p dist

rsync -a packages/claude/ dist/build/claude/

mkdir -p dist/build/claude/skills
rsync -a shared/skills/ dist/build/claude/skills/

rsync -a packages/cursor/ dist/build/cursor/

mkdir -p dist/build/cursor/skills
rsync -a shared/skills/ dist/build/cursor/skills/

rm -f "dist/clara-claude-plugin-v${VERSION}.zip"
(
	cd dist/build/claude
	zip -r "../../clara-claude-plugin-v${VERSION}.zip" . -x "*.DS_Store"
)

rm -f "dist/clara-cursor-plugin-v${VERSION}.zip"
(
	cd dist/build/cursor
	zip -r "../../clara-cursor-plugin-v${VERSION}.zip" . -x "*.DS_Store"
)

echo "Created dist/clara-claude-plugin-v${VERSION}.zip"
echo "Created dist/clara-cursor-plugin-v${VERSION}.zip"
