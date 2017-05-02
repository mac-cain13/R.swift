import PackageDescription

let package = Package(
  name: "rswift",
  targets: [
    Target(
      name: "rswift",
      dependencies: ["RswiftCore"]
    ),
    Target(name: "RswiftCore"),
    Target(
      name: "RswiftCoreTests",
      dependencies: ["RswiftCore"]
    ),
  ],
  dependencies: [
    .Package(url: "https://github.com/kylef/Commander.git", majorVersion: 0, minor: 6),
    .Package(url: "https://github.com/tomlokhorst/XcodeEdit", majorVersion: 1)
  ]
)
