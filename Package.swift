// swift-tools-version:5.0
import PackageDescription

let package = Package(
  name: "rswift",
  platforms: [
    .macOS(.v10_11)
  ],
  products: [
    .executable(name: "rswift5", targets: ["rswift5"])
  ],
  dependencies: [
    .package(url: "https://github.com/kylef/Commander.git", from: "0.8.0"),
    .package(url: "https://github.com/tomlokhorst/XcodeEdit", from: "2.7.0")
  ],
  targets: [
    .target(name: "RswiftCore", dependencies: ["XcodeEdit"]),
    .testTarget(name: "RswiftCoreTests", dependencies: ["RswiftCore"]),
    
    .target(name: "rswift5", dependencies: ["RswiftCore5"]),
    .target(name: "RswiftCore5", dependencies: ["Commander", "XcodeEdit"]),
    .testTarget(name: "RswiftCore5Tests", dependencies: ["RswiftCore5"]),
  ]
)
