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

test -f packages/cursor/.cursor-plugin/plugin.json
test -d packages/cursor/.cursor/rules
test -d shared/skills
test -f shared/mcp/clara.mcp.json

# Output is a .cursor/ directory that drops into project root
rsync -a packages/cursor/.cursor/ dist/build/cursor/.cursor/
rsync -a shared/skills/ dist/build/cursor/.cursor/skills/
cp shared/mcp/clara.mcp.json dist/build/cursor/.cursor/mcp.json
rsync -a packages/cursor/.cursor-plugin/ dist/build/cursor/.cursor-plugin/

python3 - <<EOF
import json
from pathlib import Path

version = "${VERSION}"
path = Path("dist/build/cursor/.cursor-plugin/plugin.json")
data = json.loads(path.read_text())
data["version"] = version
path.write_text(json.dumps(data, indent="\t") + "\n")
EOF

OUT="dist/clara-cursor-plugin-v${VERSION}.zip"
rm -f "$OUT"
(
	cd dist/build/cursor
	zip -r "../../$OUT" . -x "*.DS_Store"
)

echo "Created $OUT"
