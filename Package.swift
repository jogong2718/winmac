// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "Winmac",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "WinmacCore",
            targets: ["WinmacCore"]
        ),
        .executable(
            name: "winmac-cli",
            targets: ["WinmacCLI"]
        )
    ],
    targets: [
        .target(
            name: "WinmacCore"
        ),
        .executableTarget(
            name: "WinmacCLI",
            dependencies: ["WinmacCore"]
        ),
        .testTarget(
            name: "WinmacCoreTests",
            dependencies: ["WinmacCore"]
        )
    ]
)