// swift-tools-version:5.0
import PackageDescription

let package = Package(
  name: "rswift",
  platforms: [
    .macOS(.v10_11)
  ],
  products: [
    .executable(name: "rswift-legacy", targets: ["rswift-legacy"])
  ],
  dependencies: [
    .package(url: "https://github.com/kylef/Commander.git", from: "0.8.0"),
    .package(url: "https://github.com/tomlokhorst/XcodeEdit", from: "2.8.0")
  ],
  targets: [
    .target(name: "RswiftResources"),
    .target(name: "RswiftParsers", dependencies: ["RswiftResources", "XcodeEdit"]),

    // Legacy code
    .target(name: "rswift-legacy", dependencies: ["RswiftCoreLegacy"]),
    .target(name: "RswiftCoreLegacy", dependencies: ["Commander", "XcodeEdit"]),
    .testTarget(name: "RswiftCoreLegacyTests", dependencies: ["RswiftCoreLegacy"]),
  ]
)
