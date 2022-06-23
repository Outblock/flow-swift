// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Flow",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
    ],
    products: [
        .library(name: "Flow", targets: ["Flow"]),
        .library(name: "FlowGRPC", targets: ["FlowGRPC"]),
    ],
    dependencies: [
        .package(name: "BigInt", url: "https://github.com/attaswift/BigInt.git", from: "5.2.1"),
        .package(url: "https://github.com/grpc/grpc-swift.git", from: "1.8.0"),
    ],
    targets: [
        .target(
            name: "Flow",
            dependencies: ["BigInt", .product(name: "GRPC", package: "grpc-swift")],
            path: "Sources/Flow"
        ),
        .target(name: "FlowGRPC",
                dependencies: ["Flow",
                               .product(name: "GRPC", package: "grpc-swift")],
                path: "Sources/FlowGRPC"),
        .testTarget(
            name: "FlowTests",
            dependencies: ["Flow", "FlowGRPC"],
            path: "Tests"
        ),
    ]
)
