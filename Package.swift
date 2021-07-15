// swift-tools-version:5.4
import PackageDescription

let package = Package(
    name: "rswift",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v11)
    ],
    products: [
        .executable(name: "rswift", targets: ["rswift"]),
        .executable(name: "rswift5", targets: ["rswift5"])
    ],
    dependencies: [
        .package(name: "Commander", url: "https://github.com/kylef/Commander.git", from: "0.8.0"),
        .package(name: "XcodeEdit", url: "https://github.com/tomlokhorst/XcodeEdit.git", from: "2.7.0"),
        .package(name: "swift-argument-parser", url: "https://github.com/apple/swift-argument-parser.git", from: "0.4.3"),
        .package(name: "swift-format", url: "https://github.com/apple/swift-format.git", .branch("swift-5.4-branch")),
        .package(name: "SwiftSyntax", url: "https://github.com/apple/swift-syntax.git", .exact("0.50400.0")),
    ],
    targets: [
        .target(name: "RswiftResources"),
        .target(name: "RswiftParsers", dependencies: ["RswiftResources", "XcodeEdit"]),
        .testTarget(name: "RswiftParsersTests", dependencies: ["RswiftParsers"], resources: [
            .copy("Fixtures"), // 'Fixtures' folder is copied as-is, so we can use the untouched asset catalog etc in tests
            .process("Resources") // 'Resources' folder is processed
        ]),
        .target(name: "RswiftGenerators", dependencies: [
            "RswiftResources",
            .product(name: "SwiftFormat", package: "swift-format"),
            .product(name: "SwiftSyntax", package: "SwiftSyntax"),
            .product(name: "SwiftSyntaxBuilder", package: "SwiftSyntax")
        ]),

        // Core of R.swift, brings all previous parts together
        .target(name: "RswiftCore", dependencies: ["RswiftParsers", "RswiftGenerators"]),
        .testTarget(name: "RswiftCoreTests", dependencies: ["RswiftCore"]),

        // Executable that calls Core
        .executableTarget(name: "rswift", dependencies: [
            "RswiftCore",
            .product(name: "ArgumentParser", package: "swift-argument-parser")
        ]),

        // R.swift 5 stuff
        .executableTarget(name: "rswift5", dependencies: ["Commander", "RswiftCore5"]),
        .target(name: "RswiftCore5", dependencies: ["XcodeEdit"]),
        .testTarget(name: "RswiftCore5Tests", dependencies: ["RswiftCore5"]),
    ]
)
