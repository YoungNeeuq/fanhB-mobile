// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "FHBNetworking",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "FHBNetworking", targets: ["FHBNetworking"]),
    ],
    dependencies: [
        .package(path: "../Foundation"),
    ],
    targets: [
        .target(
            name: "FHBNetworking",
            dependencies: [.product(name: "FHBFoundation", package: "Foundation")]
        ),
        .testTarget(name: "FHBNetworkingTests", dependencies: ["FHBNetworking"]),
    ]
)
