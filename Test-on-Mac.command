#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"
if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "Please run this on your Mac (macOS 14 or later)."
  exit 1
fi
if ! xcrun --find swift >/dev/null 2>&1; then
  echo "Install Apple's Command Line Tools first: xcode-select --install"
  exit 1
fi
source scripts/toolchain.sh
if ! has_xctest; then
  echo "This toolchain does not include XCTest, so the tests cannot run here."
  echo "Install the full Xcode, or set DEVELOPER_DIR to it, then try again."
  exit 1
fi
ensure_swiftui_compatible_sdk
echo "Running clipboard tests…"
swift test
echo "Building Clipline for Apple silicon and Intel…"
bash scripts/build-app.sh debug
open build/Clipline.app
echo "In Clipline's menu, enable Hang copied text, then copy some text."
