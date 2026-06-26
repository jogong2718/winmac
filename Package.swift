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
        ),
        .executable(
            name: "Winmac",
            targets: ["WinmacApp"]
        )
    ],
    targets: [
        .target(
            name: "WinmacCore"
        ),
        .target(
            name: "WinmacAppSupport",
            dependencies: ["WinmacCore"]
        ),
        .executableTarget(
            name: "WinmacApp",
            dependencies: ["WinmacAppSupport"]
        ),
        .executableTarget(
            name: "WinmacCLI",
            dependencies: ["WinmacCore"]
        ),
        .testTarget(
            name: "WinmacCoreTests",
            dependencies: ["WinmacCore"]
        ),
        .testTarget(
            name: "WinmacAppTests",
            dependencies: ["WinmacAppSupport"]
        )
    ]
)