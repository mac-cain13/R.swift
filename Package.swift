// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "rswift",
    platforms: [
        .macOS(.v10_11)
    ],
    products: [
        .executable(name: "rswift", targets: ["rswift"]),
        .executable(name: "rswift5", targets: ["rswift5"])
    ],
    dependencies: [
        .package(url: "https://github.com/kylef/Commander.git", from: "0.8.0"),
        .package(url: "https://github.com/tomlokhorst/XcodeEdit", from: "2.7.0")
    ],
    targets: [
        .target(name: "RswiftResources"),
        .target(name: "RswiftParsers", dependencies: ["RswiftResources", "XcodeEdit"]),
        .target(name: "RswiftGenerators", dependencies: ["RswiftResources"]),

        // Core of R.swift, brings all previous parts together
        .target(name: "RswiftCore", dependencies: ["RswiftParsers", "RswiftGenerators"]),
        .testTarget(name: "RswiftCoreTests", dependencies: ["RswiftCore"]),

        // Executable that calls Core
        .target(name: "rswift", dependencies: ["RswiftCore"]),

        // R.swift 5 stuff
        .target(name: "rswift5", dependencies: ["RswiftCore5"]),
        .target(name: "RswiftCore5", dependencies: ["Commander", "XcodeEdit"]),
        .testTarget(name: "RswiftCore5Tests", dependencies: ["RswiftCore5"]),
    ]
)
