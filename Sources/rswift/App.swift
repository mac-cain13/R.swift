//
//  App.swift
//  rswift
//
//  Created by Tom Lokhorst on 2021-04-18.
//

import ArgumentParser
import Foundation
import RswiftCore
import RswiftParsers
import XcodeEdit


@main
struct App: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "rswift",
        abstract: "Generate static references for autocompleted resources like images, fonts and localized strings in Swift projects",
        version: Config.version,
        subcommands: [Generate.self, PrintCommand.self]
    )
}

extension App {
    struct Generate: ParsableCommand {
        static var configuration = CommandConfiguration(abstract: "Generates R.generated.swift file")

        @Option(help: "Only run specified generators, options: \(Generator.allCases.map(\.rawValue).joined(separator: ", "))")
        var generators: [Generator] = []

//        @Option(help: "Output path for an extra generated file that contains resources commonly used in UI tests such as accessibility identifiers")
//        var generateUITestFile: String?

        @Option(help: "Add extra modules as import in the generated file")
        var imports: [String] = []

        @Option(help: "The access level [public|internal] to use for the generated R-file")
        var accessLevel: AccessLevel = .internalLevel

        @Option(help: "Path to pattern file that describes files that should be ignored")
        var rswiftignore = ".rswiftignore"

        @Option(help: "Override bundle from which resources are loaded")
        var hostingBundle: String?


        // MARK: Project specific - Environment variable overrides

        @Option(help: "Override environment variable \(EnvironmentKeys.xcodeproj)")
        var xcodeproj: String?

        @Option(help: "Override environment variable \(EnvironmentKeys.target)")
        var target: String?

//        @Option(help: "Override environment variable \(EnvironmentKeys.productModuleName)")
//        var productModuleName: String?

        @Option(help: "Override environment variable \(EnvironmentKeys.infoPlistFile)")
        var infoPlistFile: String?

        @Option(help: "Override environment variable \(EnvironmentKeys.codeSignEntitlements)")
        var codeSignEntitlements: String?


        // MARK: Xcode build - Environment variable overrides

        @Option(help: "Override environment variable \(EnvironmentKeys.builtProductsDir)")
        var builtProductsDir: String?

        @Option(help: "Override environment variable \(EnvironmentKeys.developerDir)")
        var developerDir: String?

        @Option(help: "Override environment variable \(EnvironmentKeys.platformDir)")
        var platformDir: String?

        @Option(help: "Override environment variable \(EnvironmentKeys.sdkRoot)")
        var sdkRoot: String?

        @Option(help: "Override environment variable \(EnvironmentKeys.sourceRoot)")
        var sourceRoot: String?


        // MARK: Output path argument

        @Argument(help: "Output path for the generated file")
        var outputPath: String

        mutating func run() throws {
            let processInfo = ProcessInfo()

            let xcodeprojPath = try self.xcodeproj ?? processInfo.environmentVariable(name: EnvironmentKeys.xcodeproj)
            let targetName = try self.target ?? processInfo.environmentVariable(name: EnvironmentKeys.target)
//            let productModuleName = try self.productModuleName ?? processInfo.environmentVariable(name: EnvironmentKeys.productModuleName)
            let infoPlistFile = self.infoPlistFile ?? processInfo.environment[EnvironmentKeys.infoPlistFile]
            let codeSignEntitlements = self.codeSignEntitlements ?? processInfo.environment[EnvironmentKeys.codeSignEntitlements]

            let sourceTreeURLs = try SourceTreeURLs(
                builtProductsDirURL: URL(fileURLWithPath: builtProductsDir ?? processInfo.environmentVariable(name: EnvironmentKeys.builtProductsDir)),
                developerDirURL: URL(fileURLWithPath: developerDir ?? processInfo.environmentVariable(name: EnvironmentKeys.developerDir)),
                sourceRootURL: URL(fileURLWithPath: sourceRoot ?? processInfo.environmentVariable(name: EnvironmentKeys.sourceRoot)),
                sdkRootURL: URL(fileURLWithPath: sdkRoot ?? processInfo.environmentVariable(name: EnvironmentKeys.sdkRoot)),
                platformURL: URL(fileURLWithPath: platformDir ?? processInfo.environmentVariable(name: EnvironmentKeys.platformDir))
            )

            let outputURL = URL(fileURLWithPath: outputPath)
//            let uiTestOutputURL = generateUITestFile.map(URL.init(fileURLWithPath:))
            let rswiftIgnoreURL = sourceTreeURLs.sourceRootURL.appendingPathComponent(rswiftignore, isDirectory: false)

            let core = RswiftCore(
                outputURL: outputURL,
                generators: generators.isEmpty ? Generator.allCases : generators,
                xcodeprojURL: URL(fileURLWithPath: xcodeprojPath),
                targetName: targetName,
                productModuleName: nil,
                infoPlistFile: infoPlistFile.map(URL.init(fileURLWithPath:)),
                codeSignEntitlements: codeSignEntitlements.map(URL.init(fileURLWithPath:)),
                rswiftIgnoreURL: rswiftIgnoreURL,
                sourceTreeURLs: sourceTreeURLs
            )

//            print("RSWIFT", outputURL)
            try core.developRun()
        }
    }
}

extension App {
    struct PrintCommand: ParsableCommand {
        static var configuration = CommandConfiguration(abstract: "Prints the command rswift for use in CLI")


        mutating func run() {
            print("PRINT COMMAND")
        }
    }
}

struct EnvironmentKeys {
    static let action = "ACTION"

    static let bundleIdentifier = "PRODUCT_BUNDLE_IDENTIFIER"
    static let productModuleName = "PRODUCT_MODULE_NAME"
    static let target = "TARGET_NAME"
    static let xcodeproj = "PROJECT_FILE_PATH"
    static let infoPlistFile = "INFOPLIST_FILE"
    static let codeSignEntitlements = "CODE_SIGN_ENTITLEMENTS"

    static let builtProductsDir = SourceTreeFolder.buildProductsDir.rawValue
    static let developerDir = SourceTreeFolder.developerDir.rawValue
    static let platformDir = SourceTreeFolder.platformDir.rawValue
    static let sdkRoot = SourceTreeFolder.sdkRoot.rawValue
    static let sourceRoot = SourceTreeFolder.sourceRoot.rawValue
}

extension ProcessInfo {
    func environmentVariable(name: String) throws -> String {
        guard let value = self.environment[name] else { throw ValidationError("Missing argument \(name)") }
        return value
    }
}

