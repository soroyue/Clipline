#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
bash scripts/build-app.sh release
STAGE="$(mktemp -d)"
trap 'rm -rf "$STAGE"' EXIT
cp -R build/Clipline.app "$STAGE/"
ln -s /Applications "$STAGE/Applications"
hdiutil create -volname Clipline -srcfolder "$STAGE" -ov -format UDZO build/Clipline-0.1.0.dmg
echo 'Built build/Clipline-0.1.0.dmg (local test build, not notarized)'
