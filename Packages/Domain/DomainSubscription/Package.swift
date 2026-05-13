// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "DomainSubscription",
    platforms: [.iOS(.v16)],
    products: [.library(name: "DomainSubscription", targets: ["DomainSubscription"])],
    targets: [
        .target(name: "DomainSubscription"),
        .testTarget(name: "DomainSubscriptionTests", dependencies: ["DomainSubscription"]),
    ]
)
