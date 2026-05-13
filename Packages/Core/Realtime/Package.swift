// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "FHBRealtime",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "FHBRealtime", targets: ["FHBRealtime"]),
    ],
    dependencies: [
        .package(path: "../Foundation"),
    ],
    targets: [
        .target(
            name: "FHBRealtime",
            dependencies: [.product(name: "FHBFoundation", package: "Foundation")]
        ),
        .testTarget(name: "FHBRealtimeTests", dependencies: ["FHBRealtime"]),
    ]
)
