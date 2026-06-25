# Compatibility Scope

Winmac is a compatibility manager, not a guarantee that every Windows game will run on macOS.

## Initial Target

- Single-player Windows Steam games.
- Indie and older games without invasive DRM.
- Games that work with Wine-compatible runtimes and available DirectX translation layers.

## Expected Problem Areas

- Kernel or invasive anti-cheat such as EAC, BattlEye, Vanguard-style systems, and similar drivers.
- DRM that depends on unsupported Windows kernel behavior.
- D3D12 titles that require Vulkan/Metal features unavailable on the user's hardware or macOS version.
- Apple Silicon systems where x86 Windows games depend on several translation layers.

## Compatibility Profiles

Profiles will be local JSON data first. A profile can define:

- Steam AppID
- expected status
- recommended runtime
- executable override
- environment variables
- DLL overrides
- known issues
- notes for tested hardware and macOS versions

Remote/community profile sync should only be added after the local profile format is stable and validated in CI.# Compatibility Scope

The beta should be honest about what it can and cannot run.

## Target First

- Single-player Windows Steam games.
- Older multiplayer games without invasive anti-cheat.
- Indie games with simple launchers.
- DirectX 9, 10, and 11 games before DirectX 12-heavy titles.

## Expected Problem Areas

- Kernel or invasive anti-cheat.
- DRM systems that detect Wine-like environments.
- Launchers that require unsupported browser, media, or service components.
- DirectX 12 games that require Vulkan or Metal features not available through the selected runtime stack.
- Apple Silicon workflows that depend on x86 translation behavior outside this project control.

## Beta Reporting Standard

Compatibility profiles should describe observed behavior, runtime version, macOS version, Mac architecture, graphics settings, known workarounds, and whether failure is graceful.
