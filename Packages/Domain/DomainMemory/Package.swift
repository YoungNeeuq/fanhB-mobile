// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "DomainMemory",
    platforms: [.iOS(.v16)],
    products: [.library(name: "DomainMemory", targets: ["DomainMemory"])],
    targets: [
        .target(name: "DomainMemory"),
        .testTarget(name: "DomainMemoryTests", dependencies: ["DomainMemory"]),
    ]
)
