// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "FHBPush",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "FHBPush", targets: ["FHBPush"]),
    ],
    dependencies: [
        .package(path: "../Foundation"),
    ],
    targets: [
        .target(
            name: "FHBPush",
            dependencies: [.product(name: "FHBFoundation", package: "Foundation")]
        ),
        .testTarget(name: "FHBPushTests", dependencies: ["FHBPush"]),
    ]
)
