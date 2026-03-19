// swift-tools-version:6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Flow",
    platforms: [
        .iOS(.v13),
        .macOS(.v12),
    ],
    products: [
        .library(name: "Flow", targets: ["Flow"]),
    ],
    dependencies: [
        .package("BigInt", url: "https://github.com/attaswift/BigInt.git", from: "5.2.1"),
        .package( url: "https://github.com/daltoniam/Starscream", from: "3.1.1")
    ],
    targets: [
        .target(
            name: "Flow",
            dependencies: ["BigInt", "Starscream"],
            path: "Sources",
            resources: [
                .copy("Cadence/CommonCadence"),
            ]
        ),
        .testTarget(
            name: "FlowTests",
            dependencies: ["Flow"],
            path: "Tests",
            resources: [
                .copy("Cadence/CommonCadence"),
            ]
        ),
    ]
)
