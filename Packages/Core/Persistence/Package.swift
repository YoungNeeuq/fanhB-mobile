// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "FHBPersistence",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "FHBPersistence", targets: ["FHBPersistence"]),
    ],
    dependencies: [
        .package(path: "../Foundation"),
    ],
    targets: [
        .target(
            name: "FHBPersistence",
            dependencies: [.product(name: "FHBFoundation", package: "Foundation")],
            resources: [.process("Resources")]
        ),
        .testTarget(name: "FHBPersistenceTests", dependencies: ["FHBPersistence"]),
    ]
)
