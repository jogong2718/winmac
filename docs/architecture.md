# Architecture

Winmac starts with a shared Swift core, a CLI proof-of-life tool, and a native macOS app that wraps the same core services. The current app is intentionally a discovery, preview, and validation tool; Windows Steam installation, Wine runtime download, and process launch are future phases.

## Critical Steam Constraint

macOS Steam does not install Windows-only games. Native Steam on macOS is useful for discovery, account-local AppIDs, and already-installed Mac-compatible games, but it is not a source of Windows game files.

That means Winmac must model two separate concepts:

1. **Discovered games**: AppIDs visible from macOS Steam manifests or `localconfig.vdf`.
2. **Installed Windows game files**: game depots downloaded through a Windows-compatible Steam workflow, a manual path, or another verified source.

Discovery alone is not enough to launch a Windows-only Steam game.

## Components

```text
WinmacApp
  -> WinmacAppSupport
      -> view models
      -> service adapters
  -> WinmacCore

winmac-cli
  -> WinmacCore

WinmacCore
  -> Steam library scanner
  -> Bottle validator
  -> Runtime manifest validator
  -> Launch profile planner
  -> Diagnostics exporter

Future WinmacCore
  -> Wine runtime manager
  -> Windows Steam bottle manager
  -> Game install/index manager
  -> Process executor
  -> Session logger
```

## Native App Shape

The macOS app uses native SwiftUI/AppKit patterns:

- `NavigationSplitView` sidebar navigation.
- Native Settings scene.
- Toolbar and menu actions for refresh, diagnostics, and preview workflows.
- Standard `List`, `Form`, `Grid`, `DisclosureGroup`, `TextField`, `Toggle`, and file panels.
- `NSOpenPanel` and `NSSavePanel` for choosing Steam folders, prefixes, executables, and diagnostics output.

The app should feel like a compact macOS utility: predictable, keyboard-friendly, light/dark-mode compatible, responsive at smaller window sizes, and quiet.

## Current GUI Features

1. Scan installed Steam apps from local `appmanifest_*.acf` files.
2. Scan local Steam account AppIDs from `userdata/*/config/localconfig.vdf`, including Windows-only games that are owned/known but not installed on macOS.
3. Search and select games.
4. Inspect Steam AppID, install state, install path if present, library path, manifest path, or local config path.
5. Validate a Wine prefix/bottle.
6. Preview a launch plan with executable path, prefix path, working directory, environment variables, and arguments.
7. Generate and export diagnostics JSON.
8. Configure default Steam root, default bottle folder, and raw JSON preview preference.

## Current Implementation Boundary

The current package does not download runtimes, install Steam, install Windows game depots, or execute Wine. The UI must not imply a game can be played yet. Buttons use wording such as “Build Plan”, “Validate”, “Generate”, and “Export” until the runtime/install/launch phases exist.

## Game Installation Model

### Recommended Beta Path: Shared Windows Steam Bottle

The practical path for Windows-only Steam games is a Windows Steam client running inside Wine:

1. Winmac downloads or discovers an open-source Wine-compatible runtime.
2. Winmac creates a shared Steam bottle, for example `~/Library/Application Support/Winmac/bottles/steam-shared/`.
3. The user installs the official Windows Steam client inside that bottle and signs in.
4. Winmac launches Windows Steam with `steam://install/<appid>` or `steam.exe -applaunch <appid>` style workflows where appropriate.
5. Windows Steam downloads Windows depots and handles ownership, updates, Steamworks, redistributables, and DRM expectations.
6. Winmac indexes `steam-shared/drive_c/Program Files (x86)/Steam/steamapps/appmanifest_<appid>.acf` and the game install folder.
7. Winmac can then build launch profiles and eventually launch through Wine with Steam running when required.

This means the default future model should be **shared Steam bottle plus per-game profiles**, not native Mac Steam install paths. Per-game bottles can still exist later for problematic games, but duplicating Windows Steam per game is heavy and awkward.

### Manual Path Fallback

Advanced users may provide existing game files from a backup or another machine. Winmac can validate paths and build launch plans, but this does not solve ownership, updates, Steamworks APIs, or DRM by itself.

### SteamCMD Is Research, Not Default

SteamCMD with forced Windows depots may be useful for advanced automation, but it is not the default plan because account authentication, platform depot behavior, install scripts, and Steamworks/DRM expectations are more fragile than using the Windows Steam client.

## Revised Planned Launch Lifecycle

1. Discover Steam AppIDs from macOS Steam manifests and local account config.
2. Determine installation status: installed on macOS, known but not installed, installed in the shared Windows Steam bottle, or manually provided.
3. If not installed, offer installation through Windows Steam in the shared Wine bottle.
4. Index the Windows Steam bottle after installation and locate the game manifest/install folder.
5. Validate or create the relevant Wine prefix/bottle.
6. Resolve a Wine-compatible runtime and graphics translation components.
7. Merge launch settings in deterministic order: runtime defaults, global settings, compatibility profile, user overrides.
8. Build a launch plan with executable path, prefix path, environment variables, DLL overrides, runtime metadata, Steam AppID, and diagnostic metadata.
9. Launch and monitor the process once runtime execution lands, keeping Windows Steam available when the game needs Steamworks/DRM.
10. Store logs, exit code, and sanitized diagnostics for support.

## Data Locations

The intended production data root is `~/Library/Application Support/Winmac`.

Planned subdirectories:

- `bottles/steam-shared/`: shared Windows Steam bottle.
- `bottles/`: optional per-game Wine prefixes or repair/testing bottles.
- `runtimes/`: downloaded Wine-compatible runtime bundles and graphics translation components.
- `logs/`: per-session logs.
- `diagnostics/`: exported support bundles.
- `profiles/`: local compatibility profile cache.
