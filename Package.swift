// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Flow",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
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
        .library(
            name: "FlowFoundation",
            targets: ["FlowFoundation"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "WalletKit",
            dependencies: ["FlowFoundation"],
            path: "WalletKit/Sources"
        ),
        .target(
            name: "FCL",
            dependencies: ["FlowFoundation"],
            path: "FCL/Sources"
        ),
        .target(
            name: "FlowFoundation",
            dependencies: [],
            path: "FlowFoundation/Sources"
        ),
    ]
)
