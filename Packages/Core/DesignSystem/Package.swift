// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "FHBDesignSystem",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "FHBDesignSystem", targets: ["FHBDesignSystem"]),
    ],
    targets: [
        .target(name: "FHBDesignSystem"),
        .testTarget(name: "FHBDesignSystemTests", dependencies: ["FHBDesignSystem"]),
    ]
)
