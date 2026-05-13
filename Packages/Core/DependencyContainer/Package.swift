// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "FHBDependencyContainer",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "FHBDependencyContainer", targets: ["FHBDependencyContainer"]),
    ],
    dependencies: [
        .package(path: "../Networking"),
        .package(path: "../Realtime"),
        .package(path: "../Persistence"),
        .package(path: "../AppGroupStore"),
        .package(path: "../Push"),
        .package(path: "../Analytics"),
    ],
    targets: [
        .target(
            name: "FHBDependencyContainer",
            dependencies: [
                .product(name: "FHBNetworking", package: "Networking"),
                .product(name: "FHBRealtime", package: "Realtime"),
                .product(name: "FHBPersistence", package: "Persistence"),
                .product(name: "FHBAppGroupStore", package: "AppGroupStore"),
                .product(name: "FHBPush", package: "Push"),
                .product(name: "FHBAnalytics", package: "Analytics"),
            ]
        ),
    ]
)
