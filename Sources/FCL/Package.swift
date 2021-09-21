// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FCL",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
    ],
    products: [
        .library(
            name: "FCL",
            targets: ["FCL"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.0.0"),
        .package(path: "../FlowFoundation"),
    ],
    targets: [
        .target(
            name: "FCL",
            dependencies: ["FlowFoundation",
                           .product(name: "AsyncHTTPClient", package: "async-http-client")]
        ),
        .testTarget(
            name: "FCLTests",
            dependencies: ["FCL"],
            path: "Tests"
        ),
    ]
)
