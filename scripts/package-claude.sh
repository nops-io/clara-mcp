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

rm -rf dist/build/claude
mkdir -p dist/build/claude
mkdir -p dist

test -f packages/claude/.claude-plugin/plugin.json
test -d shared/skills
test -f shared/mcp/clara.mcp.json

rsync -a \
	--exclude "skills" \
	--exclude ".mcp.json" \
	packages/claude/ \
	dist/build/claude/

mkdir -p dist/build/claude/skills
rsync -a shared/skills/ dist/build/claude/skills/
cp shared/mcp/clara.mcp.json dist/build/claude/.mcp.json

python3 - <<EOF
import json
from pathlib import Path

version = "${VERSION}"
path = Path("dist/build/claude/.claude-plugin/plugin.json")
data = json.loads(path.read_text())
data["version"] = version
path.write_text(json.dumps(data, indent="\t") + "\n")
EOF

OUT="dist/clara-claude-plugin-v${VERSION}.zip"
rm -f "$OUT"
(
	cd dist/build/claude
	zip -r "../../$OUT" . -x "*.DS_Store"
)

echo "Created $OUT"
