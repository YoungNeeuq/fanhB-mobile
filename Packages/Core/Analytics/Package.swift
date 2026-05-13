// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "FHBAnalytics",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "FHBAnalytics", targets: ["FHBAnalytics"]),
    ],
    targets: [
        .target(name: "FHBAnalytics"),
        .testTarget(name: "FHBAnalyticsTests", dependencies: ["FHBAnalytics"]),
    ]
)
