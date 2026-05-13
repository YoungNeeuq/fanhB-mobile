// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "DomainCouple",
    platforms: [.iOS(.v16)],
    products: [.library(name: "DomainCouple", targets: ["DomainCouple"])],
    targets: [
        .target(name: "DomainCouple"),
        .testTarget(name: "DomainCoupleTests", dependencies: ["DomainCouple"]),
    ]
)
