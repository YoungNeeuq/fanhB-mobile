// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "FHBAppGroupStore",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "FHBAppGroupStore", targets: ["FHBAppGroupStore"]),
    ],
    targets: [
        .target(name: "FHBAppGroupStore"),
        .testTarget(name: "FHBAppGroupStoreTests", dependencies: ["FHBAppGroupStore"]),
    ]
)
