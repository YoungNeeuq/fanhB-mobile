// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "FHBDesignSystem",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "FHBDesignSystem", targets: ["FHBDesignSystem"]),
    ],
    dependencies: [
        .package(url: "https://github.com/nalexn/ViewInspector", from: "0.9.8"),
    ],
    targets: [
        .target(name: "FHBDesignSystem"),
        .testTarget(
            name: "FHBDesignSystemTests",
            dependencies: [
                "FHBDesignSystem",
                .product(name: "ViewInspector", package: "ViewInspector"),
            ]
        ),
    ]
)
