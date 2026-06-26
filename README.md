# Winmac

Winmac is an open-source macOS launcher/runtime manager for Windows-only Steam games. The first goal is not to clone CrossOver; it is to build a focused tool that can discover Steam games, manage isolated Wine prefixes, apply compatibility profiles, launch games through license-compatible open-source runtimes, and produce useful diagnostics when a game fails.

## Current Status

Implementation has started with a Swift package foundation:

- `WinmacCore`: shared models and services for Steam scanning, bottle validation, launch profile planning, runtime manifests, and diagnostics.
- `winmac-cli`: a small command-line interface for proving core workflows before the native app is built.
- Documentation describing architecture, compatibility scope, and runtime licensing boundaries.

This project does not currently launch Steam games end-to-end. The first working milestone is a CLI-driven proof of life: scan Steam libraries, validate a Wine prefix, produce a launch plan, and export sanitized diagnostics.

Important: macOS Steam cannot install Windows-only games. Winmac treats native Mac Steam as a discovery source only. Future install/play support needs a Windows Steam client running inside Wine, or an advanced/manual game-file path provided by the user.

## Scope

Winmac targets single-player and non-invasive DRM Windows games first. It will not promise support for competitive multiplayer games that depend on kernel drivers, invasive anti-cheat, or platform-specific DRM. Compatibility will vary by game, macOS version, CPU architecture, GPU capability, and the available Wine/graphics translation stack.

Windows-only Steam games must be installed through a Windows-compatible Steam workflow before first play. The recommended future path is a shared Windows Steam bottle managed by Winmac; native macOS Steam is not an installation source for those titles.

## Non-Goals for the Beta

- Do not bundle CrossOver, Whisky, Porting Kit, Apple Game Porting Toolkit, Steam installers, or proprietary game assets.
- Do not redistribute proprietary runtime components.
- Do not claim broad anti-cheat support.
- Do not target the Mac App Store; this kind of app needs broad filesystem and process access.

## Development

Requirements:

- macOS
- Xcode command line tools
- Swift 5.9 or newer

Build and test:

```bash
swift build
swift test
```

Run the native macOS preview app:

```bash
swift run Winmac
```

The app currently scans Steam libraries, validates Wine prefixes, previews launch plans, and exports diagnostics. It does not launch games yet.

Try the CLI:

```bash
swift run winmac-cli help
swift run winmac-cli scan
swift run winmac-cli bottle validate /path/to/wine-prefix
swift run winmac-cli launch-plan --exe /path/to/game.exe --prefix /path/to/wine-prefix
swift run winmac-cli diagnostics export --output diagnostics.json
```

## Repository Layout

```text
Sources/WinmacCore/      Shared core library
Sources/WinmacCLI/       CLI proof-of-life tool
Sources/WinmacApp/       Native macOS SwiftUI app
Sources/WinmacAppSupport/ Testable app services and view models
Tests/WinmacCoreTests/   Unit tests and fixtures
Tests/WinmacAppTests/    GUI support/view-model tests
docs/                    Architecture and project policy docs
```

## Runtime Policy

Winmac will only use open-source runtime components that can be redistributed or downloaded in a license-compatible way. See [docs/runtime-licensing.md](docs/runtime-licensing.md) for the current policy.

## Compatibility Policy

Compatibility will be tracked through local profiles first, then an optional community database later. See [docs/compatibility-scope.md](docs/compatibility-scope.md) for the initial boundaries.
