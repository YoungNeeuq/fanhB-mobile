// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "DomainNudge",
    platforms: [.iOS(.v16)],
    products: [.library(name: "DomainNudge", targets: ["DomainNudge"])],
    targets: [
        .target(name: "DomainNudge"),
        .testTarget(name: "DomainNudgeTests", dependencies: ["DomainNudge"]),
    ]
)
