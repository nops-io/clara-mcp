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

test -f packages/claude/.claude-plugin/plugin.json
test -d packages/cursor/.cursor/rules
test -d shared/skills
test -f shared/mcp/clara.mcp.json

# Claude package: merge shared skills and MCP config
rsync -a \
	--exclude "skills" \
	--exclude ".mcp.json" \
	packages/claude/ \
	dist/build/claude/

mkdir -p dist/build/claude/skills
rsync -a shared/skills/ dist/build/claude/skills/
cp shared/mcp/clara.mcp.json dist/build/claude/.mcp.json

# Cursor package: output is a .cursor/ directory that drops into project root
rsync -a packages/cursor/.cursor/ dist/build/cursor/.cursor/
rsync -a shared/skills/ dist/build/cursor/.cursor/skills/
cp shared/mcp/clara.mcp.json dist/build/cursor/.cursor/mcp.json
rsync -a packages/cursor/.cursor-plugin/ dist/build/cursor/.cursor-plugin/

# Stamp version into plugin manifests
python3 - <<EOF
import json
from pathlib import Path

version = "${VERSION}"
for path in [
    Path("dist/build/claude/.claude-plugin/plugin.json"),
    Path("dist/build/cursor/.cursor-plugin/plugin.json"),
]:
    data = json.loads(path.read_text())
    data["version"] = version
    path.write_text(json.dumps(data, indent="\t") + "\n")
EOF

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
