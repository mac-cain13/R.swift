// swift-tools-version:5.0
import PackageDescription

let package = Package(
  name: "rswift",
  platforms: [
    .macOS(.v10_11)
  ],
  products: [
    .executable(name: "rswift", targets: ["rswift"]),
    .executable(name: "rswift-legacy", targets: ["rswift-legacy"])
  ],
  dependencies: [
    .package(url: "https://github.com/kylef/Commander.git", from: "0.8.0"),
    .package(url: "https://github.com/tomlokhorst/XcodeEdit", from: "2.8.0")
  ],
  targets: [
    .target(name: "RswiftResources"),
    .target(name: "RswiftParsers", dependencies: ["RswiftResources", "XcodeEdit"]),
    .target(name: "RswiftGenerators", dependencies: ["RswiftResources"]),

    // Core of R.swift, brings all previous parts together
    .target(name: "RswiftCore", dependencies: ["RswiftParsers", "RswiftGenerators"]),

    // Executable that calls Core
    .target(name: "rswift", dependencies: ["RswiftCore"]),

    // Legacy code
    .target(name: "rswift-legacy", dependencies: ["RswiftCoreLegacy"]),
    .target(name: "RswiftCoreLegacy", dependencies: ["Commander", "XcodeEdit"]),
    .testTarget(name: "RswiftCoreLegacyTests", dependencies: ["RswiftCoreLegacy"]),
  ]
)
