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

struct GlobalOptions: ParsableArguments {

    @Option(help: "Only run specified generators, options: \(Generator.allCases.map(\.rawValue).joined(separator: ", "))", transform: { str in
        str.components(separatedBy: ",").map { Generator(rawValue: $0)! }
    })
    var generators: [Generator] = []

//        @Option(help: "Output path for an extra generated file that contains resources commonly used in UI tests such as accessibility identifiers")
//        var generateUITestFile: String?

    @Option(help: "Add extra modules as import in the generated file")
    var imports: [String] = []

    @Option(help: "The access level [public|internal] to use for the generated R-file")
    var accessLevel: AccessLevel = .internalLevel

    @Option(help: "Path to pattern file that describes files that should be ignored")
    var rswiftignore = ".rswiftignore"

//        @Option(help: "Override bundle from which resources are loaded")
//        var hostingBundle: String?


    // MARK: Project specific - Environment variable overrides

    @Option(help: "Override environment variable \(EnvironmentKeys.targetName)")
    var target: String?

//    @Option(help: "Override environment variable \(EnvironmentKeys.productModuleName)")
//    var productModuleName: String?
//
//    @Option(help: "Override environment variable \(EnvironmentKeys.infoPlistFile)")
//    var infoPlistFile: String?
//
//    @Option(help: "Override environment variable \(EnvironmentKeys.codeSignEntitlements)")
//    var codeSignEntitlements: String?

    @Option()
    var inputFiles: [String] = []

    // MARK: Xcode build - Environment variable overrides

//    @Option(help: "Override environment variable \(EnvironmentKeys.builtProductsDir)")
//    var builtProductsDir: String?
//
//    @Option(help: "Override environment variable \(EnvironmentKeys.developerDir)")
//    var developerDir: String?
//
//    @Option(help: "Override environment variable \(EnvironmentKeys.platformDir)")
//    var platformDir: String?
//
//    @Option(help: "Override environment variable \(EnvironmentKeys.sdkRoot)")
//    var sdkRoot: String?
//
//    @Option(help: "Override environment variable \(EnvironmentKeys.sourceRoot)")
//    var sourceRoot: String?
}

extension App {
    struct Generate: ParsableCommand {
        static var configuration = CommandConfiguration(abstract: "Generates R.generated.swift file")

        @OptionGroup var globals: GlobalOptions


        @Option(help: "Override environment variable \(EnvironmentKeys.productFilePath)")
        var xcodeproj: String?

        // MARK: Output path argument

        @Argument(help: "Output path for the generated file")
//        @Option(name: .shortAndLong, help: "Output path for the generated file")
        var outputPath: String

        mutating func run() throws {
            let processInfo = ProcessInfo()

            let xcodeprojPath = try xcodeproj ?? processInfo.environmentVariable(name: EnvironmentKeys.productFilePath)
            let xcodeprojURL = URL(fileURLWithPath: xcodeprojPath)

            let targetName = try getTargetName(xcodeprojURL: xcodeprojURL)
            let productModuleName = processInfo.environment[EnvironmentKeys.productModuleName]
            let infoPlistFile = processInfo.environment[EnvironmentKeys.infoPlistFile]
            let codeSignEntitlements = processInfo.environment[EnvironmentKeys.codeSignEntitlements]


            // If no environment is provided, we're not running inside Xcode, fallback to names
            let sourceTreeURLs = SourceTreeURLs(
                builtProductsDirURL: URL(fileURLWithPath: processInfo.environment[EnvironmentKeys.builtProductsDir] ?? EnvironmentKeys.builtProductsDir),
                developerDirURL: URL(fileURLWithPath: processInfo.environment[EnvironmentKeys.developerDir] ?? EnvironmentKeys.developerDir),
                sourceRootURL: URL(fileURLWithPath: processInfo.environment[EnvironmentKeys.sourceRoot] ?? EnvironmentKeys.sourceRoot),
                sdkRootURL: URL(fileURLWithPath: processInfo.environment[EnvironmentKeys.sdkRoot] ?? EnvironmentKeys.sdkRoot),
                platformURL: URL(fileURLWithPath: processInfo.environment[EnvironmentKeys.platformDir] ?? EnvironmentKeys.platformDir)
            )

            let outputURL = URL(fileURLWithPath: outputPath)
//            let uiTestOutputURL = generateUITestFile.map(URL.init(fileURLWithPath:))
            let rswiftIgnoreURL = sourceTreeURLs.sourceRootURL
                .appendingPathComponent(globals.rswiftignore, isDirectory: false)

            let core = RswiftCore(
                outputURL: outputURL,
                generators: globals.generators.isEmpty ? Generator.allCases : globals.generators,
                accessLevel: globals.accessLevel,
                importModules: globals.imports,
                targetName: targetName,
                productModuleName: productModuleName,
                infoPlistFile: infoPlistFile.map(URL.init(fileURLWithPath:)),
                codeSignEntitlements: codeSignEntitlements.map(URL.init(fileURLWithPath:)),
                rswiftIgnoreURL: rswiftIgnoreURL,
                sourceTreeURLs: sourceTreeURLs
            )

            print("RSWIFT inputfiles", globals.inputFiles)
            do {
                try core.generateFromXcodeproj(url: xcodeprojURL)
            } catch let error as ResourceParsingError {
                throw ValidationError(error.description)
            }
        }

        func getTargetName(xcodeprojURL: URL) throws -> String {
            let processInfo = ProcessInfo()
            if let targetName = globals.target ?? processInfo.environment[EnvironmentKeys.targetName] {
                return targetName
            }

            let targets = try? Xcodeproj(url: xcodeprojURL, warning: { _ in }).allTargets

            if let targets, let target = targets.first, targets.count == 1 {
                return target.name
            }

            if let targets, targets.count > 0 {
                let lines = [
                    "Missing argument --target",
                    "Available targets:"
                ] + targets.map { "- \($0.name)" }

                throw ValidationError(lines.joined(separator: "\n"))
            }

            throw ValidationError("Missing argument --target")
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

    static let targetName = "TARGET_NAME"
    static let infoPlistFile = "INFOPLIST_FILE"
    static let productFilePath = "PROJECT_FILE_PATH"
    static let productModuleName = "PRODUCT_MODULE_NAME"
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

