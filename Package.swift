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
    ]
)
