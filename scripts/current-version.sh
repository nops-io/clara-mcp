#!/usr/bin/env bash
set -euo pipefail

TAG="$(git describe --tags --exact-match 2>/dev/null || true)"

if [ -z "$TAG" ]; then
	TAG="$(git describe --tags --abbrev=0 2>/dev/null || true)"
fi

if [ -z "$TAG" ]; then
	echo "0.0.0-dev"
	exit 0
fi

echo "${TAG#v}"
