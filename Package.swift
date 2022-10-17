// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "AppContainer",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        .library(
            name: "AppContainer",
            targets: ["AppContainer"]
        ),
        .library(
            name: "AppContainerUI",
            targets: ["AppContainerUI"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "AppContainer",
            dependencies: []
        ),
        .target(
            name: "AppContainerUI",
            dependencies: ["AppContainer"]
        ),
        .testTarget(
            name: "AppContainerTests",
            dependencies: ["AppContainer"]
        ),
    ]
)
