#!/bin/bash
# Shared toolchain helpers for the test, build and install scripts.
#
# Not every Swift toolchain can compile this package with its default SDK. The
# macOS 27 SDKs declare SwiftUI's @State as an external macro
# (#externalMacro(module: "SwiftUIMacros")), and the Command Line Tools do not
# ship that plugin, so a CLT-only Mac fails with
# "external macro implementation type 'SwiftUIMacros.StateMacro' could not be
# found". The macOS 26 SDKs use the older property wrapper, which CLT compiles
# without help, so ensure_swiftui_compatible_sdk points the build at them.
#
# The Command Line Tools also omit XCTest altogether, so `swift test` cannot run
# there at all. has_xctest lets the installer skip that one step with an
# explanation instead of refusing to install an otherwise valid build.
#
# Usage: source scripts/toolchain.sh

# The active developer directory, honouring DEVELOPER_DIR.
toolchain_developer_dir() {
  if [ -n "${DEVELOPER_DIR:-}" ]; then
    printf '%s\n' "$DEVELOPER_DIR"
  else
    xcode-select -p
  fi
}

# Prints the newest macOS 26 SDK installed for the active toolchain, or nothing.
newest_macos26_sdk() {
  local dev sdk list=""
  dev="$(toolchain_developer_dir)"
  for sdk in "$dev"/SDKs/MacOSX26*.sdk \
             "$dev"/Platforms/MacOSX.platform/Developer/SDKs/MacOSX26*.sdk; do
    if [ -d "$sdk" ]; then list="$list$sdk
"; fi
  done
  printf '%s' "$list" | sort -V | tail -1
}

# Succeeds when the active toolchain ships the SwiftUI macro plugin.
has_swiftui_macros_plugin() {
  local dev
  dev="$(toolchain_developer_dir)"
  if [ -e "$dev/usr/lib/swift/host/plugins/libSwiftUIMacros.dylib" ]; then
    return 0
  fi
  [ -e "$dev/Platforms/MacOSX.platform/Developer/usr/lib/swift/host/plugins/libSwiftUIMacros.dylib" ]
}

# Succeeds when the active toolchain can compile XCTest tests.
has_xctest() {
  local dev
  dev="$(toolchain_developer_dir)"
  if [ -e "$dev/Platforms/MacOSX.platform/Developer/Library/Frameworks/XCTest.framework" ]; then
    return 0
  fi
  [ -e "$dev/Library/Developer/Frameworks/XCTest.framework" ]
}

# Exports SDKROOT at a macOS 26 SDK when the default one cannot compile
# @State on this toolchain. Does nothing if SDKROOT is already set, if the
# toolchain has the macro plugin, or if no macOS 26 SDK is installed.
ensure_swiftui_compatible_sdk() {
  if [ -n "${SDKROOT:-}" ]; then return 0; fi
  if has_swiftui_macros_plugin; then return 0; fi
  local fallback
  fallback="$(newest_macos26_sdk)"
  if [ -z "$fallback" ]; then return 0; fi
  export SDKROOT="$fallback"
  echo "Using $fallback: the default SDK's SwiftUI needs a macro plugin this toolchain lacks." >&2
}