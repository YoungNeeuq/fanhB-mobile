// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "DomainGamification",
    platforms: [.iOS(.v16)],
    products: [.library(name: "DomainGamification", targets: ["DomainGamification"])],
    targets: [
        .target(name: "DomainGamification"),
        .testTarget(name: "DomainGamificationTests", dependencies: ["DomainGamification"]),
    ]
)
