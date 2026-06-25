# Architecture

Winmac starts with a CLI and shared core library before adding a native app. That keeps the launch mechanics testable and scriptable while the product surface is still forming.

## Components

```text
winmac-cli
  -> WinmacCore
      -> Steam library scanner
      -> Bottle validator
      -> Runtime manifest validator
      -> Launch profile planner
      -> Diagnostics exporter
```

The native macOS app will eventually call the same core services as the CLI. A helper process can be added later if long-running process monitoring, cancellation, or background updates require it.

## Launch Lifecycle

1. Discover installed Steam apps from local Steam library manifests.
2. Resolve a per-game Wine prefix, creating it when runtime management is implemented.
3. Validate the prefix before launch.
4. Merge launch settings in deterministic order: runtime defaults, global settings, compatibility profile, user overrides.
5. Build a launch plan with executable path, prefix path, environment variables, DLL overrides, runtime metadata, and diagnostic metadata.
6. Launch and monitor the process once runtime execution lands.
7. Store logs, exit code, and sanitized diagnostics for support.

## Data Locations

The intended production data root is `~/Library/Application Support/Winmac`.

Planned subdirectories:

- `bottles/`: per-game Wine prefixes.
- `runtimes/`: downloaded Wine-compatible runtime bundles and graphics translation components.
- `logs/`: per-session logs.
- `diagnostics/`: exported support bundles.
- `profiles/`: local compatibility profile cache.

## Current Implementation Slice

The first implementation slice includes Steam scanning, bottle validation, runtime manifest validation, launch plan generation, and diagnostics export. It does not yet download runtimes or execute Wine.# Architecture

`winmac` starts as a testable core plus CLI, then grows into a native macOS app.

## Components

- `WinmacCore`: shared models, Steam parsing, bottle validation, runtime metadata, launch environment generation, and diagnostics primitives.
- `winmac-cli`: developer and automation interface for scanning, validating, and launching.
- Future macOS app: SwiftUI/AppKit shell over the same core services.
- Future helper process: optional, only if background monitoring or process coordination requires it.

## Launch Lifecycle

1. Discover installed Steam games from `libraryfolders.vdf` and `appmanifest_*.acf` files.
2. Resolve or create a per-game Wine prefix.
3. Validate the prefix before launch.
4. Resolve a runtime and any graphics translation components.
5. Merge launch settings in deterministic order: base environment, runtime defaults, global settings, compatibility profile, user overrides.
6. Start the game process and capture stdout, stderr, exit state, and selected environment metadata.
7. Export diagnostics with private paths and secrets scrubbed.

## Initial Implementation Boundary

The current package does not download runtimes or launch Wine processes yet. It creates the primitives needed to make those steps safe: parsing, validation, path selection, and launch environment construction.
