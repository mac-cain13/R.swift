// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "rswift",
    platforms: [
        .macOS(.v10_12)
    ],
    products: [
        .executable(name: "rswift", targets: ["rswift"]),
        .executable(name: "rswift5", targets: ["rswift5"])
    ],
    dependencies: [
        .package(url: "https://github.com/kylef/Commander.git", from: "0.8.0"),
        .package(url: "https://github.com/tomlokhorst/XcodeEdit", from: "2.7.0"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", .branch("main")),
        .package(url: "https://github.com/apple/swift-format.git", .branch("swift-5.3-branch"))
    ],
    targets: [
        .target(name: "RswiftResources"),
        .target(name: "RswiftParsers", dependencies: ["RswiftResources", "XcodeEdit"]),
        .target(name: "RswiftGenerators", dependencies: ["RswiftResources", "SwiftFormat"]),

        // Core of R.swift, brings all previous parts together
        .target(name: "RswiftCore", dependencies: ["RswiftParsers", "RswiftGenerators"]),
        .testTarget(name: "RswiftCoreTests", dependencies: ["RswiftCore"]),

        // Executable that calls Core
        .target(name: "rswift", dependencies: ["RswiftCore", "ArgumentParser"]),

        // R.swift 5 stuff
        .target(name: "rswift5", dependencies: ["Commander", "RswiftCore5"]),
        .target(name: "RswiftCore5", dependencies: ["XcodeEdit"]),
        .testTarget(name: "RswiftCore5Tests", dependencies: ["RswiftCore5"]),
    ]
)
