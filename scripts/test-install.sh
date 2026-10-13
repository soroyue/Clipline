#!/bin/bash
# Tests and installs a verified build for the current macOS user.
set -euo pipefail
cd "$(dirname "$0")/.."
if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "This installer must run on your Mac; this is not a macOS environment." >&2
  exit 1
fi
MAC_MAJOR="$(sw_vers -productVersion | cut -d. -f1)"
if [[ "$MAC_MAJOR" -lt 14 ]]; then
  echo "Clipline requires macOS 14 or later." >&2
  exit 1
fi
if ! xcrun --find swift >/dev/null 2>&1; then
  echo "Install Apple Command Line Tools first: xcode-select --install" >&2
  exit 1
fi
mkdir -p build/logs
STAMP="$(date +%Y%m%d-%H%M%S)"
LOG="$(pwd)/build/logs/install-$STAMP.log"
exec > >(tee "$LOG") 2>&1
echo "macOS: $(sw_vers -productVersion); architecture: $(uname -m)"
xcrun swift --version
echo "1/4 Run automated tests and translation checks"
swift test
swift scripts/check-strings.swift
echo "2/4 Build and verify the application"
bash scripts/build-app.sh debug
codesign --verify --deep --strict build/Clipline.app
plutil -lint build/Clipline.app/Contents/Info.plist
echo "3/4 Install for the current user"
DESTINATION="$HOME/Applications/Clipline.app"
mkdir -p "$HOME/Applications"
if [[ -L "$DESTINATION" ]]; then
  echo "Destination is a symlink; refusing to replace it." >&2
  exit 1
fi
if [[ -e "$DESTINATION" ]]; then
  BUNDLE_ID="$(/usr/libexec/PlistBuddy -c 'Print CFBundleIdentifier' "$DESTINATION/Contents/Info.plist")"
  if [[ "$BUNDLE_ID" != "local.clipline.app" ]]; then
    echo "An unrelated application occupies $DESTINATION; leaving it unchanged." >&2
    exit 1
  fi
fi
STAGING="$(mktemp -d "$HOME/Applications/Clipline-install.XXXXXX")"
trap 'rm -rf "$STAGING"' EXIT
ditto build/Clipline.app "$STAGING/Clipline.app"
codesign --verify --deep --strict "$STAGING/Clipline.app"
if pgrep -f "$DESTINATION/Contents/MacOS/Tendedero" >/dev/null; then
  osascript -e 'tell application id "local.clipline.app" to quit'
  for attempt in {1..20}; do
    if ! pgrep -f "$DESTINATION/Contents/MacOS/Tendedero" >/dev/null; then break; fi
    sleep 0.2
  done
  if pgrep -f "$DESTINATION/Contents/MacOS/Tendedero" >/dev/null; then
    echo "Clipline has not quit; leaving the installed version unchanged." >&2
    exit 1
  fi
fi
BACKUP=""
if [[ -e "$DESTINATION" ]]; then
  mkdir -p build/backups
  BACKUP="$(pwd)/build/backups/Clipline-$STAMP.app"
  mv "$DESTINATION" "$BACKUP"
fi
if ! mv "$STAGING/Clipline.app" "$DESTINATION"; then
  if [[ -n "$BACKUP" ]]; then mv "$BACKUP" "$DESTINATION"; fi
  echo "Installation failed; the previous version was restored." >&2
  exit 1
fi
echo "4/4 Launch for visual testing"
open "$DESTINATION"
echo "Installed: $DESTINATION"
echo "Log: $LOG"
if [[ -n "$BACKUP" ]]; then echo "Previous version: $BACKUP"; fi
echo "Enable Hang copied text in Clipline's menu, then follow the local test checklist."
echo "Launch alone does not verify clipboard or visual behavior."
