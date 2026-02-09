// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CoreDataClient",
    platforms: [
        .iOS(.v17),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "CoreDataClient",
            targets: ["CoreDataClient"]),
    ],
    targets: [
        .target(
            name: "CoreDataClient"),
        .testTarget(
            name: "CoreDataClientTests",
            dependencies: ["CoreDataClient"]
        ),
    ]
)
