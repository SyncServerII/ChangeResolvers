// swift-tools-version:5.2
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
        .package(url: "https://github.com/IBM-Swift/HeliumLogger.git", .upToNextMajor(from: "1.8.1")),
        .package(url: "https://github.com/SyncServerII/ServerAccount.git", .branch("master")),
    ],
    targets: [
        .target(
            name: "ChangeResolvers",
            dependencies: ["HeliumLogger", "ServerAccount"]),
        .testTarget(
            name: "ChangeResolversTests",
            dependencies: ["ChangeResolvers"]),
    ]
)
