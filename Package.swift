// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ChangeResolvers",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "ChangeResolvers",
            targets: ["ChangeResolvers"]),
    ],
    dependencies: [
        .package(url: "https://github.com/SyncServerII/ServerAccount.git", .branch("master")),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.4.0")
    ],
    targets: [
        .target(
            name: "ChangeResolvers",
            dependencies: [
                .product(name: "Logging", package: "swift-log"),
                "ServerAccount"
            ]),
        .testTarget(
            name: "ChangeResolversTests",
            dependencies: ["ChangeResolvers"]),
    ]
)
