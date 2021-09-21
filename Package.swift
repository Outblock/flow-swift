// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FlowSwift",
    platforms: [
        .iOS(.v13),
    ],
    products: [
        .library(
            name: "WalletKit",
            targets: ["WalletKit"]
        ),
        .library(
            name: "FCL",
            targets: ["FCL"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", .upToNextMajor(from: "1.4.1")),
        .package(name: "secp256k1", url: "https://github.com/GigaBitcoin/secp256k1.swift.git", from: "0.3.0"),
        .package(name: "BigInt", url: "https://github.com/attaswift/BigInt.git", from: "5.2.1"),
        .package(url: "https://github.com/grpc/grpc-swift.git", from: "1.0.0"),
        .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "WalletKit",
            dependencies: ["FlowFoundation", "CryptoSwift", "secp256k1"],
            path: "Sources/WalletKit/Sources"
        ),
        .target(
            name: "FCL",
            dependencies: ["FlowFoundation",
                           .product(name: "AsyncHTTPClient", package: "async-http-client")],
            path: "Sources/FCL/Sources"
        ),
        .target(
            name: "FlowFoundation",
            dependencies: ["BigInt",
                           .product(name: "GRPC", package: "grpc-swift")],
            path: "Sources/FlowFoundation/Sources"
        ),
    ]
)
