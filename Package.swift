// swift-tools-version: 5.9

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
        .package(url: "https://github.com/p-x9/EditValueView.git", .upToNextMinor(from: "0.4.0")),
        .package(url: "https://github.com/p-x9/KeyPathValue.git", .upToNextMinor(from: "0.0.1"))
    ],
    targets: [
        .target(
            name: "AppContainer",
            dependencies: [
                .product(name: "KeyPathValue", package: "KeyPathValue")
            ],
            swiftSettings: [
                .enableUpcomingFeature("ExistentialAny", .when(configuration: .debug))
            ],
            plugins: []
        ),
        .target(
            name: "AppContainerUI",
            dependencies: [
                "AppContainer",
                .product(name: "KeyPathValue", package: "KeyPathValue"),
                .product(name: "EditValueView", package: "EditValueView")
            ]
        ),
        .testTarget(
            name: "AppContainerTests",
            dependencies: ["AppContainer"]
        )
    ]
)
