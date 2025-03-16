//
//  App.swift
//  rswift
//
//  Created by Tom Lokhorst on 2021-04-18.
//

import ArgumentParser
import Foundation
import RswiftParsers
import RswiftShared
import XcodeEdit

@main
struct App: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "rswift",
        abstract: "Generate static references for autocompleted resources like images, fonts and localized strings in Swift projects",
        version: Config.version,
        subcommands: [Generate.self, ModifyXcodePackages.self]
    )
}

enum InputType: String, ExpressibleByArgument {
    case xcodeproj = "xcodeproj"
    case inputFiles = "input-files"
}

struct GlobalOptions: ParsableArguments {

    @Option(help: "The type of input for generation")
    var inputType: InputType = .xcodeproj

    @Option(help: "Only run specified generators, options: \(generatorsString)", transform: parseGenerators)
    var generators: [ResourceType] = []

    @Flag(help: "Don't generate main `R` let")
    var omitMainLet = false

    @Option(name: .customLong("import", withSingleDash: false), help: "Add extra modules as import in the generated file")
    var imports: [String] = []

    @Option(help: "The access level [public|internal] to use for the generated R-file")
    var accessLevel: AccessLevel = .internalLevel

    @Option(help: "Path to pattern file that describes files that should be ignored")
    var rswiftignore = ".rswiftignore"

    @Option(help: "Paths of files for which resources should be generated")
    var inputFiles: [String] = []

    @Option(help: "Source of default bundle to use")
    var bundleSource: BundleSource = .finder

    // MARK: Project specific - Environment variable overrides

    @Option(help: "Override environment variable \(EnvironmentKeys.targetName)")
    var target: String?
}

private let generatorsString = ResourceType.allCases.map(\.rawValue).joined(separator: ", ")
private func parseGenerators(_ str: String) -> [ResourceType] {
    str.components(separatedBy: ",").map { ResourceType(rawValue: $0)! }
}

extension App {
    struct Generate: ParsableCommand {
        static let configuration = CommandConfiguration(abstract: "Generates R.generated.swift file")

        @OptionGroup
        var globals: GlobalOptions

        @Option(help: "Override environment variable \(EnvironmentKeys.productFilePath)")
        var xcodeproj: String?

        @Argument(help: "Output path for the generated file")
        var outputPath: String

        mutating func run() throws {
            let processInfo = ProcessInfo.processInfo

            let productModuleName = processInfo.environment[EnvironmentKeys.productModuleName]
            let infoPlistFile = processInfo.environment[EnvironmentKeys.infoPlistFile]
            let codeSignEntitlements = processInfo.environment[EnvironmentKeys.codeSignEntitlements]


            // If no environment is provided, we're not running inside Xcode, fallback to names
            let sourceTreeURLs = SourceTreeURLs(
                builtProductsDirURL: URL(fileURLWithPath: processInfo.environment[EnvironmentKeys.builtProductsDir] ?? EnvironmentKeys.builtProductsDir),
                developerDirURL: URL(fileURLWithPath: processInfo.environment[EnvironmentKeys.developerDir] ?? EnvironmentKeys.developerDir),
                sourceRootURL: URL(fileURLWithPath: processInfo.environment[EnvironmentKeys.sourceRoot] ?? "."),
                sdkRootURL: URL(fileURLWithPath: processInfo.environment[EnvironmentKeys.sdkRoot] ?? EnvironmentKeys.sdkRoot),
                platformURL: URL(fileURLWithPath: processInfo.environment[EnvironmentKeys.platformDir] ?? EnvironmentKeys.platformDir)
            )

            let outputURL = URL(fileURLWithPath: outputPath)
            let rswiftIgnoreURL = sourceTreeURLs.sourceRootURL
                .appendingPathComponent(globals.rswiftignore, isDirectory: false)

            let core = RswiftCore(
                outputURL: outputURL,
                generators: globals.generators.isEmpty ? ResourceType.allCases : globals.generators,
                accessLevel: globals.accessLevel,
                bundleSource: globals.bundleSource,
                importModules: globals.imports,
                productModuleName: productModuleName,
                infoPlistFile: infoPlistFile.map(URL.init(fileURLWithPath:)),
                codeSignEntitlements: codeSignEntitlements.map(URL.init(fileURLWithPath:)),
                omitMainLet: globals.omitMainLet,
                rswiftIgnoreURL: rswiftIgnoreURL,
                sourceTreeURLs: sourceTreeURLs
            )

            do {
                switch globals.inputType {
                case .xcodeproj:
                    let xcodeprojPath = try xcodeproj ?? ProcessInfo.processInfo
                        .environmentVariable(name: EnvironmentKeys.productFilePath)
                    let xcodeprojURL = URL(fileURLWithPath: xcodeprojPath)
                    let targetName = try getTargetName(xcodeprojURL: xcodeprojURL)
                    try core.generateFromXcodeproj(url: xcodeprojURL, targetName: targetName)

                case .inputFiles:
                    try core.generateFromFiles(inputFileURLs: globals.inputFiles.map(URL.init(fileURLWithPath:)))
                }
            } catch let error as ResourceParsingError {
                throw ValidationError(error.description)
            }
        }

        func getTargetName(xcodeprojURL: URL) throws -> String {
            if let targetName = globals.target ?? ProcessInfo.processInfo
                .environment[EnvironmentKeys.targetName] {
                return targetName
            }

            do {
                let xcodeproj = try Xcodeproj(url: xcodeprojURL, warning: { _ in })
                let targets = xcodeproj.allTargets

                if let target = targets.first, targets.count == 1 {
                    return target.name
                }

                if targets.count > 0 {
                    let lines = [
                        "Missing argument --target",
                        "Available targets:"
                    ] + targets.map { "- \($0.name)" }

                    throw ValidationError(lines.joined(separator: "\n"))
                }

                throw ValidationError("Missing argument --target")
            } catch {
                throw ValidationError("Missing argument --target")
            }
        }
    }
}

extension App {
    struct ModifyXcodePackages: ParsableCommand {
        static let configuration = CommandConfiguration(abstract: "Modifies Xcode project to fix package reference for plugins")

        @Option(help: "Path to xcodeproj file")
        var xcodeproj: String

        @Option(help: "Targets for which to remove package reference")
        var target: [String] = []

        mutating func run() throws {
            let url = URL(fileURLWithPath: xcodeproj)
            let file = try XCProjectFile(xcodeprojURL: url, ignoreReferenceErrors: true)

            for target in file.project.targets.compactMap(\.value) {
                guard self.target.contains(target.name) else { continue }

                for product in target.dependencies.compactMap(\.value?.productRef?.value) {
                    let plugins = ["plugin:RswiftGenerateInternalResources", "plugin:RswiftGeneratePublicResources"]
                    if let name = product.productName, plugins.contains(name) {
                        product.removePackage()
                    }
                }
            }

            try file.write(to: url)
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

extension ResourceType: ExpressibleByArgument {}
extension AccessLevel: ExpressibleByArgument {}
extension BundleSource: ExpressibleByArgument {}
