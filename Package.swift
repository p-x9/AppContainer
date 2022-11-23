// swift-tools-version: 5.6

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
        .package(url: "https://github.com/realm/SwiftLint.git", revision: "0.50.0"),
        .package(url: "https://github.com/p-x9/EditValueView.git", exact: "0.0.2"),
        .package(url: "https://github.com/p-x9/KeyPathValue.git", exact: "0.0.1")
    ],
    targets: [
        .target(
            name: "AppContainer",
            dependencies: [
                .product(name: "KeyPathValue", package: "KeyPathValue")
            ],
            plugins: [
                .plugin(name: "SwiftLintPlugin", package: "SwiftLint")
            ]
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
