# Runtime Licensing

Winmac should only use runtime components that can be redistributed or downloaded in a license-compatible way. The project must preserve notices, ship license text when required, and make source/offers available for copyleft components when distribution requires it.

## Allowed Runtime Strategy

- Open-source Wine-compatible runtimes when their licenses and binary distribution terms are understood.
- DXVK, VKD3D-Proton, MoltenVK, and similar components only with their required notices and source/offers.
- Runtime downloads with checksum verification and clear source URLs.

## Not Allowed for the Beta

- Bundling CrossOver, Whisky internals, Porting Kit internals, Apple Game Porting Toolkit, Steam installers, or proprietary game assets.
- Copying GPL project code into Winmac unless the project license is changed to a compatible license.
- Shipping opaque binary blobs without provenance, checksums, and license metadata.

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

The current code validates this metadata before a manifest can be accepted.# Runtime Licensing

`winmac` should only use runtime components that can be redistributed or downloaded under clear license terms.

## Allowed Direction

- Wine-compatible builds with source and license obligations satisfied.
- DXVK with its license notice retained.
- VKD3D-Proton with LGPL obligations satisfied.
- MoltenVK with Apache 2.0 notices retained.
- Runtime downloads with checksums, versioned manifests, and license metadata.

## Not Allowed For Bundling

- CrossOver binaries or proprietary CrossOver assets.
- Whisky internals copied as product code.
- Apple Game Porting Toolkit redistribution unless Apple grants terms that explicitly allow it.
- Steam installers, Steam client binaries, or game assets.

## Before Shipping Runtime Downloads

1. Pick a license for original project code.
2. Add third-party notices to release artifacts.
3. Store source-offer or source-link metadata for LGPL components.
4. Verify every runtime manifest has a checksum and license identifier.
