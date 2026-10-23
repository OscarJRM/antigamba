// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "AntiGamba",
    platforms: [
        .macOS(.v13)
    ],
    targets: [
        .executableTarget(
            name: "AntiGamba"
        ),
        .testTarget(
            name: "AntiGambaTests",
            dependencies: ["AntiGamba"]
        ),
    ]
)
