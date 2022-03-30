//
//  main.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 11-12-14.
//  From: https://github.com/mac-cain13/R.swift
//  License: MIT License
//

import Foundation
import Commander
import RswiftCore
import XcodeEdit

// Argument convertibles
extension AccessLevel: ArgumentConvertible, CustomStringConvertible {
  public init(parser: ArgumentParser) throws {
    guard let value = parser.shift() else { throw ArgumentError.missingValue(argument: nil) }
    guard let level = AccessLevel(rawValue: value) else { throw ArgumentError.invalidType(value: value, type: "AccessLevel", argument: nil) }

    self = level
  }

  public var description: String {
    return rawValue
  }
}

enum PrintCommandArguments: String, ArgumentConvertible {
  case portable
  case complete

  public init(parser: ArgumentParser) throws {
    guard let value = parser.shift() else { throw ArgumentError.missingValue(argument: nil) }
    guard let level = PrintCommandArguments(rawValue: value) else { throw ArgumentError.invalidType(value: value, type: "PrintCommandArguments", argument: nil) }

    self = level
  }

  var description: String {
    return rawValue
  }
}

extension ProcessInfo {
  func environmentVariable(name: String) throws -> String {
    guard let value = self.environment[name] else { throw ArgumentError.missingValue(argument: name) }
    return value
  }

  func scriptInputFiles() throws -> [String] {
    let scriptInputFileCountString = try environmentVariable(name: EnvironmentKeys.scriptInputFileCount)
    guard let scriptInputFileCount = Int(scriptInputFileCountString) else {
      throw ArgumentError.invalidType(value: scriptInputFileCountString, type: "Int", argument: EnvironmentKeys.scriptInputFileCount)
    }

    return try (0..<scriptInputFileCount)
      .map(EnvironmentKeys.scriptInputFile)
      .map(environmentVariable)
  }

  func scriptOutputFiles() throws -> [String] {
    let scriptOutputFileCountString = try environmentVariable(name: EnvironmentKeys.scriptOutputFileCount)
    guard let scriptOutputFileCount = Int(scriptOutputFileCountString) else {
      throw ArgumentError.invalidType(value: scriptOutputFileCountString, type: "Int", argument: EnvironmentKeys.scriptOutputFileCount)
    }

    return try (0..<scriptOutputFileCount)
      .map(EnvironmentKeys.scriptOutputFile)
      .map(environmentVariable)
  }
}

// Flags grouped in struct for readability
struct CommanderFlags {
  static let version = Flag("version", description: "Prints version information about this release.")
}

// Default values for non-optional Commander Options
struct EnvironmentKeys {
  static let action = "ACTION"

  static let bundleIdentifier = "PRODUCT_BUNDLE_IDENTIFIER"
  static let productModuleName = "PRODUCT_MODULE_NAME"
  static let scriptInputFileCount = "SCRIPT_INPUT_FILE_COUNT"
  static let scriptOutputFileCount = "SCRIPT_OUTPUT_FILE_COUNT"
  static let target = "TARGET_NAME"
  static let swiftPackage = "SWIFT_PACKAGE"
  static let xcodeproj = "PROJECT_FILE_PATH"
  static let infoPlistFile = "INFOPLIST_FILE"
  static let codeSignEntitlements = "CODE_SIGN_ENTITLEMENTS"

  static let builtProductsDir = SourceTreeFolder.buildProductsDir.rawValue
  static let developerDir = SourceTreeFolder.developerDir.rawValue
  static let platformDir = SourceTreeFolder.platformDir.rawValue
  static let sdkRoot = SourceTreeFolder.sdkRoot.rawValue
  static let sourceRoot = SourceTreeFolder.sourceRoot.rawValue

  static func scriptInputFile(number: Int) -> String {
    return "SCRIPT_INPUT_FILE_\(number)"
  }

  static func scriptOutputFile(number: Int) -> String {
    return "SCRIPT_OUTPUT_FILE_\(number)"
  }
}

// Options grouped in struct for readability
struct CommanderOptions {
  static let generators = Option("generators", default: "", description: "Only run specified generators, comma seperated")
  static let uiTest = Option("generateUITestFile", default: "", description: "Output path for an extra generated file that contains resources commonly used in UI tests such as accessibility identifiers")
  static let importModules = Option("import", default: "", description: "Add extra modules as import in the generated file, comma seperated")
  static let accessLevel = Option("accessLevel", default: AccessLevel.internalLevel, description: "The access level [public|internal] to use for the generated R-file")
  static let rswiftIgnore = Option("rswiftignore", default: ".rswiftignore", description: "Path to pattern file that describes files that should be ignored")

  // Project specific - Environment variable overrides
  static let xcodeproj: Option<String?> = Option("xcodeproj", default: nil, description: "Defaults to environment variable \(EnvironmentKeys.xcodeproj)")
  static let swiftPackage: Option<String?> = Option("swiftPackage", default: nil, description: "Defaults to environment variable \(EnvironmentKeys.swiftPackage)")
  static let target: Option<String?> = Option("target", default: nil, description: "Defaults to environment variable \(EnvironmentKeys.target)")
  static let bundleIdentifier: Option<String?> = Option("bundleIdentifier", default: nil, description: "Defaults to environment variable \(EnvironmentKeys.bundleIdentifier)")
  static let productModuleName: Option<String?> = Option("productModuleName", default: nil, description: "Defaults to environment variable \(EnvironmentKeys.productModuleName)")
  static let infoPlistFile: Option<String?> = Option("infoPlistFile", default: nil, description: "Defaults to environment variable \(EnvironmentKeys.infoPlistFile)")
  static let codeSignEntitlements: Option<String?> = Option("codeSignEntitlements", default: nil, description: "Defaults to environment variable \(EnvironmentKeys.codeSignEntitlements)")

  // Xcode build - Environment variable overrides
  static let builtProductsDir: Option<String?> = Option("builtProductsDir", default: nil, description: "Defaults to environment variable \(EnvironmentKeys.builtProductsDir)")
  static let developerDir: Option<String?> = Option("developerDir", default: nil, description: "Defaults to environment variable \(EnvironmentKeys.developerDir)")
  static let platformDir: Option<String?> = Option("platformDir", default: nil, description: "Defaults to environment variable \(EnvironmentKeys.platformDir)")
  static let sdkRoot: Option<String?> = Option("sdkRoot", default: nil, description: "Defaults to environment variable \(EnvironmentKeys.sdkRoot)")
  static let sourceRoot: Option<String?> = Option("sourceRoot", default: nil, description: "Defaults to environment variable \(EnvironmentKeys.sourceRoot)")

  // Print-command
  static let arguments: Option<PrintCommandArguments> = Option("arguments", default: .portable, description: "Which arguments are printed [portable|complete]")
}

// Options grouped in struct for readability
struct CommanderArguments {
  static let outputPath = Argument<String>("outputPath", description: "Output path for the generated file")
}

func parseGenerators(_ generatorNames: String) -> ([RswiftGenerator], [String]) {
  var generators: [Generator] = []
  var unknowns: [String] = []

  let parts = generatorNames.components(separatedBy: ",")
    .map { $0.trimmingCharacters(in: CharacterSet.whitespaces) }
    .filter { !$0.isEmpty }

  for part in parts {
    if let generator = RswiftGenerator(rawValue: part) {
      generators.append(generator)
    } else {
      unknowns.append(part)
    }
  }

  return (generators, unknowns)
}

func parseValidateGenerators(_ generatorNames: String) -> [RswiftGenerator] {
  let (knownGenerators, unknownGenerators) = parseGenerators(generatorNames)
  if !unknownGenerators.isEmpty {
    warn("Unknown generator options: \(unknownGenerators.joined(separator: ", "))")
    if knownGenerators.isEmpty {
      warn("No known generators, falling back to all generators")
    }
  }

  return knownGenerators.isEmpty ? RswiftGenerator.allCases : knownGenerators
}

func parseModules(_ importModules: String) -> [Module] {
  return importModules
    .components(separatedBy: ",")
    .map { $0.trimmingCharacters(in: CharacterSet.whitespaces) }
    .filter { !$0.isEmpty }
    .map { Module.custom(name: $0) }
}

func escapePath(_ path: String) -> String {
  path.replacingOccurrences(of: " ", with: "\\ ")
}

let generate = command(
  CommanderOptions.generators,
  CommanderOptions.uiTest,
  CommanderOptions.importModules,
  CommanderOptions.accessLevel,
  CommanderOptions.rswiftIgnore,

  CommanderOptions.xcodeproj,
  CommanderOptions.swiftPackage,
  CommanderOptions.target,
  CommanderOptions.bundleIdentifier,
  CommanderOptions.productModuleName,
  CommanderOptions.infoPlistFile,
  CommanderOptions.codeSignEntitlements,

  CommanderOptions.builtProductsDir,
  CommanderOptions.developerDir,
  CommanderOptions.platformDir,
  CommanderOptions.sdkRoot,
  CommanderOptions.sourceRoot,

  CommanderArguments.outputPath
) {
  generatorNames,
  uiTestOutputPath,
  importModules,
  accessLevel,
  rswiftIgnore,

  xcodeprojOption,
  swiftPackageOption,
  targetOption,
  bundleIdentifierOption,
  productModuleNameOption,
  infoPlistFileOption,
  codeSignEntitlementsOption,

  builtProductsDirOption,
  developerDirOption,
  platformDirOption,
  sdkRootOption,
  sourceRootOption,

  outputPath in

  let processInfo = ProcessInfo()

  if let action = try? processInfo.environmentVariable(name: EnvironmentKeys.action), action == "indexbuild" {
    warn("Not generating code during index build")
    exit(EXIT_SUCCESS)
  }

  if let scriptInputFile = try? processInfo.environmentVariable(name: EnvironmentKeys.scriptInputFile(number: 0)),
     scriptInputFile.hasSuffix("/rswift-lastrun")
  {
    warn("For updating to R.swift 6.0, read our migration guide: https://github.com/mac-cain13/R.swift/blob/master/Documentation/Migration.md")
  }

  let xcodeproj = try? processInfo.environmentVariable(name: EnvironmentKeys.xcodeproj)
  let swiftPackage = try? processInfo.environmentVariable(name: EnvironmentKeys.swiftPackage)

  let resourcesOrigin: ResourcesOrigin

  if let xcodeprojPath = xcodeprojOption ?? xcodeproj {
    resourcesOrigin = .xcodeproj(URL(fileURLWithPath: xcodeprojPath))
  } else if let swiftPackagePath = swiftPackageOption ?? swiftPackage {
    resourcesOrigin = .swiftPackage(URL(fileURLWithPath: swiftPackagePath))
  } else {
    fatalError()
  }

  let targetName = try targetOption ?? processInfo.environmentVariable(name: EnvironmentKeys.target)
  let bundleIdentifier = (try? bundleIdentifierOption ?? processInfo.environmentVariable(name: EnvironmentKeys.bundleIdentifier)) ?? ""
  let productModuleName = (try? productModuleNameOption ?? processInfo.environmentVariable(name: EnvironmentKeys.productModuleName)) ?? ""
  let infoPlistFile = infoPlistFileOption ?? processInfo.environment[EnvironmentKeys.infoPlistFile]
  let codeSignEntitlements = codeSignEntitlementsOption ?? processInfo.environment[EnvironmentKeys.codeSignEntitlements]

  let builtProductsDirPath = (try? builtProductsDirOption ?? processInfo.environmentVariable(name: EnvironmentKeys.builtProductsDir)) ?? ""
  let developerDirPath = (try? developerDirOption ?? processInfo.environmentVariable(name: EnvironmentKeys.developerDir)) ?? ""
  let sourceRootPath = (try? sourceRootOption ?? processInfo.environmentVariable(name: EnvironmentKeys.sourceRoot)) ?? ""
  let sdkRootPath = (try? sdkRootOption ?? processInfo.environmentVariable(name: EnvironmentKeys.sdkRoot)) ?? ""
  let platformPath = (try? platformDirOption ?? processInfo.environmentVariable(name: EnvironmentKeys.platformDir)) ?? ""

  let outputURL = URL(fileURLWithPath: outputPath)
  let uiTestOutputURL = uiTestOutputPath.count > 0 ? URL(fileURLWithPath: uiTestOutputPath) : nil
  let rswiftIgnoreURL = URL(fileURLWithPath: sourceRootPath).appendingPathComponent(rswiftIgnore, isDirectory: false)
  let generators = parseValidateGenerators(generatorNames)
  let modules = parseModules(importModules)

  let errors = validateRswiftEnvironment(
    outputURL: outputURL,
    uiTestOutputURL: uiTestOutputURL,
    sourceRootPath: sourceRootPath,
    podsRoot: processInfo.environment["PODS_ROOT"],
    podsTargetSrcroot: processInfo.environment["PODS_TARGET_SRCROOT"],
    commandLineArguments: CommandLine.arguments)

  guard errors.isEmpty else {
    for error in errors {
      fail(error)
    }
    exit(EXIT_FAILURE)
  }

  let callInformation = CallInformation(
    outputURL: outputURL,
    uiTestOutputURL: uiTestOutputURL,
    rswiftIgnoreURL: rswiftIgnoreURL,

    generators: generators,
    accessLevel: accessLevel,
    imports: modules,

    resourcesOrigin: resourcesOrigin,
    targetName: targetName,
    bundleIdentifier: bundleIdentifier,
    productModuleName: productModuleName,
    infoPlistFile: infoPlistFile.map { URL(fileURLWithPath: $0) },
    codeSignEntitlements: codeSignEntitlements.map { URL(fileURLWithPath: $0) },

    builtProductsDirURL: URL(fileURLWithPath: builtProductsDirPath),
    developerDirURL: URL(fileURLWithPath: developerDirPath),
    sourceRootURL: URL(fileURLWithPath: sourceRootPath),
    sdkRootURL: URL(fileURLWithPath: sdkRootPath),
    platformURL: URL(fileURLWithPath: platformPath)
  )

  try RswiftCore(callInformation).run()
}

let printCommand = command(
  CommanderOptions.arguments,

  CommanderOptions.generators,
  CommanderOptions.uiTest,
  CommanderOptions.importModules,
  CommanderOptions.accessLevel,
  CommanderOptions.rswiftIgnore,

  CommanderArguments.outputPath
) {
  arguments,

  generatorNames,
  uiTestOutputPath,
  importModules,
  accessLevel,
  rswiftIgnore,

  outputPath in

  let processInfo = ProcessInfo()

  let targetName = try processInfo.environmentVariable(name: EnvironmentKeys.target)
  let bundleIdentifier = try processInfo.environmentVariable(name: EnvironmentKeys.bundleIdentifier)
  let productModuleName = try processInfo.environmentVariable(name: EnvironmentKeys.productModuleName)
  let infoPlistFile = processInfo.environment[EnvironmentKeys.infoPlistFile]
  let codeSignEntitlements = processInfo.environment[EnvironmentKeys.codeSignEntitlements]

  let xcodeprojPath = try processInfo.environmentVariable(name: EnvironmentKeys.xcodeproj)
  let builtProductsDirPath = try processInfo.environmentVariable(name: EnvironmentKeys.builtProductsDir)
  let developerDirPath = try processInfo.environmentVariable(name: EnvironmentKeys.developerDir)
  let sourceRootPath = try processInfo.environmentVariable(name: EnvironmentKeys.sourceRoot)
  let sdkRootPath = try processInfo.environmentVariable(name: EnvironmentKeys.sdkRoot)
  let platformPath = try processInfo.environmentVariable(name: EnvironmentKeys.platformDir)

  var args: [String] = ["generate"]

  // Add args that differ from defaults
  if generatorNames != CommanderOptions.generators.default {
    args.append("--\(CommanderOptions.generators.name) \(generatorNames)")
  }
  if uiTestOutputPath != CommanderOptions.uiTest.default {
    args.append("--\(CommanderOptions.uiTest.name) \(escapePath(uiTestOutputPath))")
  }
  if importModules != CommanderOptions.importModules.default {
    args.append("--\(CommanderOptions.importModules.name) \(importModules)")
  }
  if accessLevel != CommanderOptions.accessLevel.default {
    args.append("--\(CommanderOptions.accessLevel.name) \(accessLevel.rawValue)")
  }
  if rswiftIgnore != CommanderOptions.rswiftIgnore.default {
    args.append("--\(CommanderOptions.rswiftIgnore.name) \(rswiftIgnore)")
  }

  // Add args for environment variables
  args.append("--\(CommanderOptions.target.name) \(escapePath(targetName))")
  args.append("--\(CommanderOptions.bundleIdentifier.name) \(escapePath(bundleIdentifier))")
  args.append("--\(CommanderOptions.productModuleName.name) \(escapePath(productModuleName))")
  if let infoPlistFile = infoPlistFile {
    args.append("--\(CommanderOptions.infoPlistFile.name) \(escapePath(infoPlistFile))")
  }
  if let codeSignEntitlements = codeSignEntitlements {
    args.append("--\(CommanderOptions.codeSignEntitlements.name) \(escapePath(codeSignEntitlements))")
  }

  let rswiftCommand: String

  switch arguments {
  case .portable:
    let libraryDirPath = try processInfo.environmentVariable(name: "USER_LIBRARY_DIR")
    rswiftCommand = CommandLine.arguments.first?.replacingOccurrences(of: "\(sourceRootPath)/", with: "") ?? "rswift"

    args.append("--\(CommanderOptions.xcodeproj.name) \(escapePath(xcodeprojPath.replacingOccurrences(of: "\(sourceRootPath)/", with: "")))")
    args.append("--\(CommanderOptions.developerDir.name) $(xcrun xcode-select --print-path)")
    args.append("--\(CommanderOptions.platformDir.name) $(xcrun xcode-select --print-path)\(platformPath.replacingOccurrences(of: developerDirPath, with: ""))")
    args.append("--\(CommanderOptions.sdkRoot.name) $(xcrun xcode-select --print-path)\(sdkRootPath.replacingOccurrences(of: developerDirPath, with: ""))")
    args.append("--\(CommanderOptions.builtProductsDir.name) \(builtProductsDirPath.replacingOccurrences(of: libraryDirPath, with: "~/Library"))")
    args.append("--\(CommanderOptions.sourceRoot.name) .")

    args.append(escapePath(outputPath.replacingOccurrences(of: "\(sourceRootPath)/", with: "")))

  case .complete:
    rswiftCommand = CommandLine.arguments.first ?? "rswift"

    args.append("--\(CommanderOptions.xcodeproj.name) \(escapePath(xcodeprojPath))")
    args.append("--\(CommanderOptions.developerDir.name) \(escapePath(developerDirPath))")
    args.append("--\(CommanderOptions.platformDir.name) \(escapePath(platformPath))")
    args.append("--\(CommanderOptions.sdkRoot.name) \(escapePath(sdkRootPath))")
    args.append("--\(CommanderOptions.builtProductsDir.name) \(escapePath(builtProductsDirPath))")
    args.append("--\(CommanderOptions.sourceRoot.name) \(escapePath(sourceRootPath))")

    args.append(escapePath(outputPath))
  }

  print("\(rswiftCommand) \(args.joined(separator: " \\\n  "))")
  print("error: R.swift command logged (see build log)")
}

struct FailErrorsCommand: CommandType {
  let original: CommandType

  func run(_ parser: ArgumentParser) throws {
    do {
      try original.run(parser)
    } catch {
      fail("\(error)")
      exit(EXIT_FAILURE)
    }
  }
}

// Start parsing the launch arguments
let group = Group()
group.addCommand("generate", "Generates R.generated.swift file", FailErrorsCommand(original: generate))
group.addCommand("print-command", "Prints the command rswift for use in CLI", FailErrorsCommand(original: printCommand))
group.run(Rswift.version)
