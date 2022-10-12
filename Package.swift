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
    dependencies: [
        .package(url: "https://github.com/realm/SwiftLint.git", branch: "main")
    ],
    targets: [
        .target(
            name: "AppContainer",
            dependencies: [],
            plugins: [
                .plugin(name: "SwiftLintPlugin", package: "SwiftLint")
            ]
        ),
        .testTarget(
            name: "AppContainerTests",
            dependencies: ["AppContainer"]),
    ]
)
