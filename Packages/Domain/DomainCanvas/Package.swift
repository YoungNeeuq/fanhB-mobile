// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "DomainCanvas",
    platforms: [.iOS(.v16)],
    products: [.library(name: "DomainCanvas", targets: ["DomainCanvas"])],
    targets: [
        .target(name: "DomainCanvas"),
        .testTarget(name: "DomainCanvasTests", dependencies: ["DomainCanvas"]),
    ]
)
