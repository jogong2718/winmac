# Compatibility Scope

Winmac is a compatibility manager, not a guarantee that every Windows game will run on macOS.

## Installation Requirement

Windows-only Steam games must be installed through a Windows-compatible Steam workflow before first play. Native macOS Steam does not install Windows-only depots, so Winmac must not assume a Mac Steam install folder exists.

Supported or planned installation paths:

1. **Windows Steam inside Wine**: recommended beta path. The user signs in to Windows Steam in a shared Wine bottle and installs games there.
2. **Manual game path**: advanced fallback for game files the user already has from a backup or another machine.
3. **SteamCMD**: future research path, not the default, because it may not satisfy Steamworks/DRM expectations for many games.

Many Steam games expect the Steam client to be running for ownership checks, Steamworks APIs, cloud saves, achievements, multiplayer, or overlay behavior. The shared Windows Steam bottle exists to satisfy those expectations as much as Wine allows.

## Initial Target

- Single-player Windows Steam games.
- Indie and older games without invasive DRM.
- Games that work with Wine-compatible runtimes and available DirectX translation layers.
- Games that can install and run through Windows Steam inside Wine.

## Expected Problem Areas

- Kernel or invasive anti-cheat such as EAC, BattlEye, Vanguard-style systems, and similar drivers.
- DRM that depends on unsupported Windows kernel behavior.
- Games that fail when Steam is not running or cannot initialize Steamworks under Wine.
- Launchers that require unsupported browser, media, or service components.
- D3D12 titles that require Vulkan/Metal features unavailable on the user's hardware or macOS version.
- Apple Silicon systems where x86 Windows games depend on several translation layers.

## Compatibility Profiles

Profiles will be local JSON data first. A profile can define:

- Steam AppID
- expected status
- install method notes
- recommended runtime
- executable override
- environment variables
- DLL overrides
- known issues
- notes for tested hardware and macOS versions

Remote/community profile sync should only be added after the local profile format is stable and validated in CI.

## Beta Reporting Standard

Compatibility reports should describe observed behavior, install method, runtime version, Steam client state, macOS version, Mac architecture, graphics settings, known workarounds, and whether failure is graceful.
