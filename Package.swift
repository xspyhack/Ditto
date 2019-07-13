// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "Ditto",
    products: [
        .library(
            name: "Ditto",
            targets: ["Ditto"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "Ditto",
            dependencies: []),
        .testTarget(
            name: "DittoTests",
            dependencies: ["Ditto"]),
    ]
)
