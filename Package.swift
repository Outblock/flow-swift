// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "flow",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
    ],
    products: [
        .library(
            name: "flow",
            targets: ["flow"]
        ),
    ],
    dependencies: [
        .package(name: "SwiftProtobuf", url: "https://github.com/apple/swift-protobuf.git", from: "1.6.0"),
        .package(name: "BigInt", url: "https://github.com/attaswift/BigInt.git", from: "5.2.1"),
    ],
    targets: [
        .target(
            name: "flow",
            dependencies: ["SwiftProtobuf", "BigInt"]
        ),
        .testTarget(
            name: "flowTests",
            dependencies: ["flow"]
        ),
    ]
)
