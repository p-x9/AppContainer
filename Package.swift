// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "AppContainer",
    platforms: [
        .iOS(.v14)
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
    dependencies: [
        .package(url: "https://github.com/p-x9/EditValueView.git", .upToNextMinor(from: "0.0.6")),
        .package(url: "https://github.com/p-x9/KeyPathValue.git", .upToNextMinor(from: "0.0.1"))
    ],
    targets: [
        .target(
            name: "AppContainer",
            dependencies: [
                .product(name: "KeyPathValue", package: "KeyPathValue")
            ],
            plugins: []
        ),
        .target(
            name: "AppContainerUI",
            dependencies: [
                "AppContainer",
                .product(name: "EditValueView", package: "EditValueView")
            ]
        ),
        .testTarget(
            name: "AppContainerTests",
            dependencies: ["AppContainer"]
        )
    ]
)
