// swift-tools-version:5.6
import PackageDescription

let package = Package(
  name: "rswift",
  platforms: [
    .macOS("10.15.4")
  ],
  products: [
    .executable(name: "rswift", targets: ["rswift"])
  ],
  dependencies: [
    .package(url: "https://github.com/kylef/Commander.git", from: "0.8.0"),
    .package(url: "https://github.com/tomlokhorst/XcodeEdit", from: "2.8.0"),
    .package(url: "https://github.com/apple/swift-package-manager", branch: "release/5.6")
  ],
  targets: [
    .executableTarget(name: "rswift", dependencies: ["RswiftCore"]),
    .target(name: "RswiftCore", dependencies: [
        .product(name: "Commander", package: "Commander"),
        .product(name: "XcodeEdit", package: "XcodeEdit"),
        .product(name: "SwiftPMDataModel-auto", package: "swift-package-manager")
    ]),
    .testTarget(name: "RswiftCoreTests", dependencies: ["RswiftCore"]),
  ]
)
