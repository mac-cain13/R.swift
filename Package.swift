// swift-tools-version:5.6
import PackageDescription

let package = Package(
  name: "rswift",
  platforms: [
    .macOS(.v10_15),
    .iOS(.v11),
    .tvOS(.v11),
    .watchOS(.v4),
  ],
  products: [
    .executable(name: "rswift", targets: ["rswift"]),
    .library(name: "RswiftLibrary", targets: ["RswiftResources"]),
    .plugin(name: "RswiftGenerateResources", targets: ["RswiftGenerateResources"]),
  ],
  dependencies: [
    .package(url: "https://github.com/tomlokhorst/XcodeEdit", from: "2.8.0"),
    .package(url: "https://github.com/apple/swift-argument-parser", from: "1.1.0"),
  ],
  targets: [
    .target(name: "RswiftResources"),
    .target(name: "RswiftGenerators", dependencies: ["RswiftResources"]),
    .target(name: "RswiftParsers", dependencies: ["RswiftResources", "XcodeEdit"]),

    // Core of R.swift, brings all previous parts together
    .target(name: "RswiftCore", dependencies: [
        .target(name: "RswiftParsers"),
        .target(name: "RswiftGenerators"),
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
    ]),

    // Executable that calls Core
    .executableTarget(name: "rswift", dependencies: [
        .target(name: "RswiftCore"),
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
    ]),

    .plugin(name: "RswiftGenerateResources", capability: .buildTool(), dependencies: ["rswift", "RswiftCore"]),
  ]
)
