// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ReadabilitySwift",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6)
    ],
    products: [
        .library(
            name: "ReadabilitySwift",
            targets: ["ReadabilitySwift"]),
    ],
    dependencies: [
        .package(url: "https://github.com/scinfu/SwiftSoup.git", from: "2.6.0")
    ],
    targets: [
        .target(
            name: "ReadabilitySwift",
            dependencies: ["SwiftSoup"]),
        .testTarget(
            name: "ReadabilitySwiftTests",
            dependencies: ["ReadabilitySwift"]
        ),
    ]
)
