// swift-tools-version:5.5
import PackageDescription

let package = Package(
  name: "rswift",
  platforms: [
    .macOS(.v10_11)
  ],
  products: [
    .executable(name: "rswift", targets: ["rswift"]),
    .plugin(name: "RswiftPlugin", targets: ["RswiftPlugin"])
  ],
  dependencies: [
    .package(url: "https://github.com/kylef/Commander.git", from: "0.8.0"),
    .package(url: "https://github.com/tomlokhorst/XcodeEdit", from: "2.8.0")
  ],
  targets: [
    .plugin(
      name: "RswiftPlugin",
      capability: .buildTool(),
      dependencies: ["rswift"]
    ),
    .executableTarget(name: "rswift", dependencies: ["RswiftCore"]),
    .target(name: "RswiftCore", dependencies: ["Commander", "XcodeEdit"]),
    .testTarget(name: "RswiftCoreTests", dependencies: ["RswiftCore"]),
  ]
)
