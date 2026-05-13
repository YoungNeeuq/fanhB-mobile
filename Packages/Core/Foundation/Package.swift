// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "FHBFoundation",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "FHBFoundation", targets: ["FHBFoundation"]),
    ],
    targets: [
        .target(name: "FHBFoundation"),
        .testTarget(name: "FHBFoundationTests", dependencies: ["FHBFoundation"]),
    ]
)
