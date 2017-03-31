import PackageDescription

let package = Package(
  name: "rswift",
  dependencies: [
    .Package(url: "https://github.com/tomlokhorst/XcodeEdit", majorVersion: 1)
  ]
)
