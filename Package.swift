// swift-tools-version:5.6
import PackageDescription

let package = Package(
    name: "Rswift",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v11),
        .tvOS(.v11),
        .watchOS(.v4),
    ],
    products: [
        .executable(name: "rswift", targets: ["rswift"]),
        .library(name: "RswiftLibrary", targets: ["RswiftResources"]),
        .plugin(name: "RswiftGenerateInternalResources", targets: ["RswiftGenerateInternalResources"]),
        .plugin(name: "RswiftGeneratePublicResources", targets: ["RswiftGeneratePublicResources"]),
        .plugin(name: "RswiftGenerateResourcesCommand", targets: ["RswiftGenerateResourcesCommand"]),
        .plugin(name: "RswiftModifyXcodePackages", targets: ["RswiftModifyXcodePackages"]),
    ],
    dependencies: [
        .package(url: "https://github.com/tomlokhorst/XcodeEdit", from: "2.13.0"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.5.0"),
    ],
    targets: [
        .target(name: "RswiftResources"),
        .target(name: "RswiftGenerators", dependencies: ["RswiftResources"]),
        .target(name: "RswiftParsers", dependencies: ["RswiftResources", "XcodeEdit"]),

        .testTarget(name: "RswiftGeneratorsTests", dependencies: ["RswiftGenerators"]),
        .testTarget(name: "RswiftParsersTests", dependencies: ["RswiftParsers"], resources: [.copy("TestData")]),

        // Executable that brings all previous parts together
        .executableTarget(name: "rswift", dependencies: [
            .target(name: "RswiftParsers"),
            .target(name: "RswiftGenerators"),
            .product(name: "ArgumentParser", package: "swift-argument-parser"),
        ]),

        .plugin(name: "RswiftGenerateInternalResources", capability: .buildTool(), dependencies: ["rswift"]),
        .plugin(name: "RswiftGeneratePublicResources", capability: .buildTool(), dependencies: ["rswift"]),
        .plugin(
            name: "RswiftGenerateResourcesCommand",
            capability: .command(
                intent: .custom(
                    verb: "rswift-generate-resources",
                    description: "Rswift generate resources"
                ),
                permissions: [
                    .writeToPackageDirectory(reason: "Rswift generates a file with statically typed, autocompleted resources")
                ]
            ),
            dependencies: ["rswift"]
        ),
        .plugin(
            name: "RswiftModifyXcodePackages",
            capability: .command(
                intent: .custom(
                    verb: "rswift-modify-xcode-packages",
                    description: "Rswift modify Xcode packages"
                ),
                permissions: [
                    .writeToPackageDirectory(reason: "Modifies Xcode project to fix package reference for plugins")
                ]
            ),
            dependencies: ["rswift"]
        ),
    ]
)
