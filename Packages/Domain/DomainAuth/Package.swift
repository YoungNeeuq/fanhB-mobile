// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "DomainAuth",
    platforms: [.iOS(.v16)],
    products: [.library(name: "DomainAuth", targets: ["DomainAuth"])],
    targets: [
        .target(name: "DomainAuth"),
        .testTarget(name: "DomainAuthTests", dependencies: ["DomainAuth"]),
    ]
)
