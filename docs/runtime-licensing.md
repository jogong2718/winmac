# Runtime Licensing

Winmac should only use runtime components that can be redistributed or downloaded in a license-compatible way. The project must preserve notices, ship license text when required, and make source/offers available for copyleft components when distribution requires it.

## Allowed Runtime Strategy

- Open-source Wine-compatible runtimes when their licenses and binary distribution terms are understood.
- DXVK, VKD3D-Proton, MoltenVK, and similar components only with required notices and source/offers.
- Runtime downloads with checksum verification, source URLs, license metadata, and versioned manifests.
- User-provided Wine paths for development/testing, provided Winmac clearly labels them as user-managed.

## Not Allowed for the Beta

- Bundling CrossOver, Whisky internals, Porting Kit internals, Apple Game Porting Toolkit, Steam installers, or proprietary game assets.
- Copying GPL project code into Winmac unless the project license is changed to a compatible license.
- Shipping opaque binary blobs without provenance, checksums, and license metadata.
- Presenting proprietary runtimes as Winmac-managed open-source components.

## Steam Client and SteamCMD

Winmac must not bundle or redistribute Steam client binaries. The safer product boundary is:

- Winmac may create a Wine bottle suitable for the user's own Windows Steam installation.
- The user installs/signs into the official Windows Steam client inside that bottle.
- Winmac can launch or index that user-installed Steam client, but it does not present Steam as a Winmac-owned runtime.
- Future SteamCMD support, if any, should require explicit user setup or a documented Valve-approved download path.

Game files remain subject to Steam's terms and the user's license. Winmac is a launcher and compatibility manager, not a distributor of Steam games or Steam binaries.

## Manifest Requirements

Every downloadable runtime component needs a manifest entry with:

- component name
- version
- platform and CPU architecture
- download URL
- SHA-256 checksum
- license name
- license file or notice URL
- unpack/install instructions

The current code validates this metadata before a manifest can be accepted. Future CI should reject runtime manifests with missing checksums, unknown licenses, unsupported architectures, or placeholder URLs.

## Before Shipping Runtime Downloads

1. Pick a license for original project code.
2. Add third-party notices to release artifacts.
3. Store source-offer or source-link metadata for LGPL components.
4. Verify every runtime manifest has a checksum and license identifier.
5. Confirm quarantine/signing behavior for downloaded executables before exposing launch in the GUI.
