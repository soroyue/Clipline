#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
bash scripts/build-app.sh release
VERSION=$(/usr/libexec/PlistBuddy -c 'Print CFBundleShortVersionString' build/Clipline.app/Contents/Info.plist)
STAGE="$(mktemp -d)"
trap 'rm -rf "$STAGE"' EXIT
ditto build/Clipline.app "$STAGE/Clipline.app"
cp LICENSE NOTICE "$STAGE/"
ln -s /Applications "$STAGE/Applications"
codesign --verify --deep --strict "$STAGE/Clipline.app"
hdiutil create -volname "Clipline $VERSION" -srcfolder "$STAGE" -ov -format UDZO "build/Clipline-$VERSION.dmg"
hdiutil verify "build/Clipline-$VERSION.dmg"
echo "Built build/Clipline-$VERSION.dmg (not notarized)"
