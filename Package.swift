// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "flow-swift",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
    ],
    products: [
        .library(name: "flow-swift", targets: ["Flow"]),
    ],
    dependencies: [
        .package(name: "BigInt", url: "https://github.com/attaswift/BigInt.git", from: "5.2.1"),
    ],
    targets: [
        .target(
            name: "Flow",
            dependencies: ["BigInt"],
            path: "Sources/Flow"
        ),
        .testTarget(
            name: "FlowTests",
            dependencies: ["Flow"],
            path: "Tests"
        ),
    ]
)
