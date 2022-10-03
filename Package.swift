// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AppContainer",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        .library(
            name: "AppContainer",
            targets: ["AppContainer"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "AppContainer",
            dependencies: []),
        .testTarget(
            name: "AppContainerTests",
            dependencies: ["AppContainer"]),
    ]
)
