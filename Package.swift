// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FlowFoundation",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
    ],
    products: [
        .library(
            name: "FlowFoundation",
            targets: ["FlowFoundation"]
        ),
    ],
    dependencies: [
        .package(name: "BigInt", url: "https://github.com/attaswift/BigInt.git", from: "5.2.1"),
        .package(url: "https://github.com/grpc/grpc-swift.git", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "FlowFoundation",
            dependencies: ["BigInt",
                           .product(name: "GRPC", package: "grpc-swift")],
            path: "Sources/Foundation"
        ),
        .testTarget(
            name: "FlowFoundationTests",
            dependencies: ["FlowFoundation"],
            path: "Tests"
        ),
    ]
)
