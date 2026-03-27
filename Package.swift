	// swift-tools-version:6.2

import PackageDescription

let package = Package(

	name: "Flow",
	platforms: [
		.iOS(.v15),
		.macOS(.v13),
	],
	products: [
		.library(name: "Flow", targets: ["Flow"]),
	],
	dependencies: [
		.package(url: "https://github.com/attaswift/BigInt.git", from: "5.2.1"),
		.package(url: "https://github.com/apple/swift-async-algorithms", from: "1.1.3"),
		// Only this NIO repo is needed
		.package(url: "https://github.com/apple/swift-nio.git", from: "2.67.0"),
		.package(url: "https://github.com/apple/swift-nio-ssl.git", from: "2.26.0"),
	],
	targets: [
		.target(
			name: "Flow",
			dependencies: [
				.product(name: "BigInt", package: "BigInt"),
				.product(name: "AsyncAlgorithms", package: "swift-async-algorithms"),
				// NIO core
				.product(name: "NIOCore", package: "swift-nio"),
				.product(name: "NIOPosix", package: "swift-nio"),
				.product(name: "NIOHTTP1", package: "swift-nio"),
				.product(name: "NIOWebSocket", package: "swift-nio"),

				// TLS
				.product(name: "NIOSSL", package: "swift-nio-ssl"),
			],
			path: "Sources",
			resources: [
				.copy("Cadence/CommonCadence/"),
			]
		),
		.testTarget(
			name: "FlowTests",
			dependencies: ["Flow"],
			path: "Tests"
		),
	]

)
