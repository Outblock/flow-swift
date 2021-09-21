// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FlowWalletKit",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "FlowWalletKit",
            targets: ["FlowWalletKit"]
        ),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", .upToNextMajor(from: "1.4.1")),
        .package(
            name: "secp256k1",
            url: "https://github.com/GigaBitcoin/secp256k1.swift.git",
            from: "0.3.0"
        ),
        .package(name: "FlowFoundation", path: "../FlowFoundation"),

    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "FlowWalletKit",
            dependencies: ["FlowFoundation", "CryptoSwift", "secp256k1"]
        ),

        .testTarget(
            name: "FlowSwiftTests",
            dependencies: ["FlowFoundation", "FlowWalletKit"]
        ),
    ]
)
