# Clipline

<img src="assets/Clipline.png" width="128" alt="Clipline icon">

**Text and images, hanging side by side on your Mac.**

[简体中文](README.zh-CN.md) · [Changes](CHANGELOG.md) · [Contributing](CONTRIBUTING.md) · [License](LICENSE)

Clipline is an independent, MIT-licensed derivative of [Tendedero](https://github.com/alejandrobujan/tendedero), based on commit [`71b54fd`](https://github.com/alejandrobujan/tendedero/commit/71b54fd8c571c5ea8c514b56103dfa6bf08a8e74). **Its main addition is hanging copied text alongside screenshots and images**, extending the original screenshot clothesline into a dual-mode clipboard workspace.

The original clothesline, clips and floating-card interaction come from Tendedero. Clipline adds text capture, reading, search and local history, with a separate name and generated icon. It is not affiliated with or endorsed by the upstream author.

## Highlights

- **Two independently enabled modes:** hang copied text, copied images, or both. Screenshot handling remains available separately.
- **Two lanes:** text on the left, images on the right. The newest item in each group sits beside the centre; older items extend outward.
- **Readable text cards:** a larger heading and multiple paragraphs fill the thumbnail. Overflow stays in the full-text hover preview.
- **Full-text workflow:** hover to read and scroll, click to copy, or search text history beyond the visible thumbnail. Original whitespace, newlines and Unicode are retained.
- **Calmer appearance:** pale oatmeal text frames, mist-blue image frames, lighter clips and shadows, and matching frame dimensions. Images fit proportionally without changing their source files.
- **Independent browsing:** each lane scrolls separately using the same input convention. After browsing, leaving the interaction area gently returns both lanes to their latest items.
- **Local history:** duplicate text moves to the latest position; clicking a card to copy does not create another entry. History survives app restarts.

```text
older text ← 6 5 4 3 2 1  |  1 2 3 4 5 6 → older images
                        newest
```

## Requirements

| Item | Requirement |
| --- | --- |
| Operating system | macOS 14 Sonoma or newer; Windows and Linux are not supported |
| Processor | Apple silicon or Intel; universal app build |
| Source build | Apple Swift 5.9+ and a macOS 14+ SDK, supplied by a compatible Xcode or Command Line Tools installation |
| Additional runtime | No Python, Node.js or Homebrew required |
| Distribution | Source ZIP and a locally signed universal DMG; not Apple-notarized |
| Verified | 15 tests and universal build passed on GitHub's macOS 14 runner; local Apple silicon build/install also passed |

Intel compilation has passed; Intel hardware runtime testing and broader UI testing remain outstanding.

## Install from DMG

1. Download `Clipline-0.2.0.dmg` from [Releases](https://github.com/soroyue/Clipline/releases/latest).
2. Quit any running Clipline before replacing it. Open the DMG and drag Clipline to Applications.
3. Eject the disk image, then open Clipline from Applications and enable the desired capture switches in its menu.

The DMG does not require developer tools to run. It is ad hoc signed, not Developer ID signed or Apple-notarized, so macOS may block first launch. Do not disable system security protections; build from source if your policy does not permit this distribution. Users of the source installer should keep one installation location (it uses `~/Applications`) to avoid duplicate copies.

To make a DMG from source: `bash scripts/make-dmg.sh`. The volume includes the app, Applications shortcut, LICENSE and NOTICE.

## Build and install

### First-time setup

In Terminal, install Apple's development tools if needed:

```bash
xcode-select --install
```

Complete the system installer before continuing. If the tools are already installed, skip this step. Verify availability:

```bash
xcrun swift --version
xcrun --sdk macosx --show-sdk-path
```

### Option A: download the source ZIP

1. Open [Releases](https://github.com/soroyue/Clipline/releases/latest) and download the named `Clipline-…-source.zip` asset.
2. Extract it in Finder. A source ZIP is not an application; it must be compiled.
3. In Terminal, type `cd ` (including the space), drag the extracted `Clipline` folder into the window, and press Return.
4. Run:

```bash
bash Install-and-Test-on-Mac.command
```

The installation needs no `sudo`. Keep the Terminal window open until it prints `Installed:`. Build time depends on your Mac.

### Option B: clone with Git


Requires macOS 14 or newer and Apple's Swift toolchain (Xcode or Command Line Tools). Universal builds target Apple silicon and Intel. Source and a locally signed DMG are available. The DMG is not Apple-notarized.

```bash
git clone https://github.com/soroyue/Clipline.git
cd Clipline
bash Install-and-Test-on-Mac.command
```

The script runs tests and localization checks, builds and verifies the app, backs up an existing Clipline installation, installs to `~/Applications/Clipline.app`, and opens it. Without a Developer ID signing identity it uses ad hoc signing. It does not change system security settings.

The installer adapts to two toolchain gaps on its own. Command Line Tools for macOS 27 use an SDK whose SwiftUI needs a macro plugin those tools do not ship, so it builds against the newest installed macOS 26 SDK instead. Those tools also omit XCTest, so the automated tests are skipped with a message and CI still runs them on every push. To run them locally, install the full Xcode or point `DEVELOPER_DIR` at it:

```bash
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer bash Install-and-Test-on-Mac.command
```

To build without installing:

```bash
swift test
swift scripts/check-strings.swift
bash scripts/build-app.sh release
```

## Troubleshooting and updates

- **No window after launch:** this is a menu-bar app. Open `~/Applications/Clipline.app` in Finder and look for its menu-bar icon.
- **No text cards:** enable **Hang copied text**, then copy fresh non-empty text. Content copied before enabling capture is skipped.
- **Missing Swift or SDK:** finish installing Command Line Tools and rerun the verification commands above. A newer SDK may need a matching newer toolchain.
- **Tests are skipped during installation:** the active toolchain has no XCTest, which is the case for Command Line Tools on their own. The build and install still continue, and CI runs the tests on every push. To run them locally, install the full Xcode or set `DEVELOPER_DIR` to it as shown above.
- **`SwiftUIMacros.StateMacro could not be found`:** the default SDK's SwiftUI needs a macro plugin this toolchain lacks. The installer switches to the newest installed macOS 26 SDK by itself; a manual `swift test` outside the scripts may still need `SDKROOT` set to a macOS 26 SDK.
- **Permission prompt for a watched folder:** grant access only to the folder you want Clipline to monitor, or choose another folder.
- **macOS blocks a downloaded build:** this project does not provide notarization. Prefer building the published source yourself; do not disable Gatekeeper globally.
- **Build/test fails:** installation stops. Logs are under `build/logs/`; review and redact personal paths before sharing relevant error lines in an issue.
- **Update:** download a newer source release and rerun the installer, or run `git pull --ff-only` in a clean clone and rerun it. Existing Clipline is backed up in `build/backups/`; local history is retained.
- **Uninstall:** turn off **Open at login**, quit Clipline, and move `~/Applications/Clipline.app` to Trash. This leaves local history in place; remove history separately only if you intend to erase it.

## Display modes

Choose **Display mode** in the menu: **Images only**, **Text only**, or **Text + images (grouped)**. Single-type modes use the original centred clothesline and scrolling layout, without the split-lane return animation. Grouped mode uses our left-text/right-image layout. Switching modes preserves all history; capture switches remain independent so you can choose what to record separately from what to display.

## New in 0.2.0

- **Browse history…** groups all retained cards into All / Text / Images. Search text contents or image filenames, copy records, open original images, or remove individual cards. Image search does not perform OCR.
- **Pause recording / Resume recording** pauses new clipboard and screenshot cards without deleting history. A pause icon indicates the state, which persists across restarts. System screenshots are still saved to their configured folder; pause is not a system screenshot blocker. Resuming skips the current clipboard.
- **Interaction settings…** adjusts top-edge dwell, ordinary hide time (including animation), return animation and new-content preview hold. Changes persist immediately; Restore defaults returns to 0.5 / 1.2 / 1.4 / 2.5 seconds. The browse-return pause is 0.7 seconds; hiding waits for the return animation to finish.

## Use

1. Open Clipline from Applications. It lives in the menu bar, without a conventional main window.
2. Enable **Hang copied text** and/or **Hang copied images** in its menu. Enable screenshot handling separately if desired.
3. Copy new content. Existing clipboard content is not imported when monitoring starts.
4. Rest the pointer in the menu bar for about 0.5 seconds to reveal the line. Browse text on the left and images on the right.
5. Hover over a text card for its full preview, click to copy, or use **Browse history…**.

Ordinary pointer departure starts hiding after approximately 0.98 seconds, followed by a 0.22-second animation. After scrolling history, departure allows a 0.7-second pause and a 1.4-second return animation before hiding at about 2.5 seconds. Reading a preview or interacting with a card keeps the line visible. New-content peeks use a separate 2.5-second hold. Timing is approximate.

Text and images share the retention limit (25, 50, 100, or what fits on screen). Text deletions and capacity eviction permanently remove their local text files. Image deletion behavior depends on whether Clipline owns the source file.

## Privacy

Clipboard history is local and **not encrypted**. Text files are stored beneath `~/Library/Application Support/Clipline/Text`, with owner-only permissions when created. Avoid copying sensitive material while capture is enabled.

The text watcher skips blank text, file-copy payloads, text over 1 MiB, and entries carrying recognized concealed, transient or autogenerated clipboard markers. These markers depend on the source app; they are not a guarantee that all sensitive content is detected. The application does not implement cloud sync or clipboard upload. There is no in-app update check; download updates manually from GitHub Releases.

The published source archive excludes clipboard history, screenshots, local logs, build products, backups and development-session files. See [SECURITY.md](SECURITY.md) before reporting an issue involving sensitive data.

## Verification and limitations

Fifteen automated tests cover text fidelity, persistence and permissions, deduplication, copying, deletion, capacity, filtering, image capture and split-lane scrolling. Local macOS tests and universal builds have passed. GitHub Actions runs the checks on pushes and pull requests.

Visual behavior, multi-monitor positioning, full-screen behavior and gesture feel still need broader manual testing. A passing test suite is not a claim of complete UI acceptance. Intel is a build target; runtime validation on Intel hardware has not been performed.

## Attribution and license

Source code is distributed under the [MIT License](LICENSE), retaining **Copyright (c) 2026 Alejandro Buján** and the original permission notice. Tendedero's name and original icon are not granted by that license. Clipline uses its own application name and generated icon; internal Swift module names retain `Tendedero` for compatibility. See [NOTICE](NOTICE) for provenance and the scope of changes.
