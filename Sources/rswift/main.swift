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
extension AccessLevel : ArgumentConvertible, CustomStringConvertible {
  public init(parser: ArgumentParser) throws {
    guard let value = parser.shift() else { throw ArgumentError.missingValue(argument: nil) }
    guard let level = AccessLevel(rawValue: value) else { throw ArgumentError.invalidType(value: value, type: "AccessLevel", argument: nil) }

    self = level
  }

  public var description: String {
    return rawValue
  }
}


extension ProcessInfo {
  func environmentVariable(name: String) throws -> String {
    guard let value = self.environment[name] else { throw ArgumentError.missingValue(argument: name) }
    return value
  }
}

// Flags grouped in struct for readability
struct CommanderFlags {
  static let version = Flag("version", description: "Prints version information about this release.")
}

// Default values for non-optional Commander Options
struct EnvironmentKeys {
  static let xcodeproj = "PROJECT_FILE_PATH"
  static let target = "TARGET_NAME"
  static let bundleIdentifier = "PRODUCT_BUNDLE_IDENTIFIER"
  static let productModuleName = "PRODUCT_MODULE_NAME"
  static let buildProductsDir = SourceTreeFolder.buildProductsDir.rawValue
  static let developerDir = SourceTreeFolder.developerDir.rawValue
  static let sourceRoot = SourceTreeFolder.sourceRoot.rawValue
  static let sdkRoot = SourceTreeFolder.sdkRoot.rawValue
  static let platformDir = SourceTreeFolder.platformDir.rawValue
}

// Options grouped in struct for readability
struct CommanderOptions {
  static let importModules = Option("import", default: "", description: "Add extra modules as import in the generated file, comma seperated.")
  static let accessLevel = Option("accessLevel", default: AccessLevel.internalLevel, description: "The access level [public|internal] to use for the generated R-file.")
  static let rswiftIgnore = Option("rswiftignore", default: ".rswiftignore", description: "Path to pattern file that describes files that should be ignored.")
}

// Options grouped in struct for readability
struct CommanderArguments {
  static let outputPath = Argument<String>("outputPath", description: "Output path for the generated file.")
}

let generate = command(
  CommanderOptions.importModules,
  CommanderOptions.accessLevel,
  CommanderOptions.rswiftIgnore,

  CommanderArguments.outputPath
) { importModules, accessLevel, rswiftIgnore, outputPath in

  let processInfo = ProcessInfo()

  let xcodeprojPath = try processInfo.environmentVariable(name: EnvironmentKeys.xcodeproj)
  let targetName = try processInfo.environmentVariable(name: EnvironmentKeys.target)
  let bundleIdentifier = try processInfo.environmentVariable(name: EnvironmentKeys.bundleIdentifier)
  let productModuleName = try processInfo.environmentVariable(name: EnvironmentKeys.productModuleName)

  let buildProductsDirPath = try processInfo.environmentVariable(name: EnvironmentKeys.buildProductsDir)
  let developerDirPath = try processInfo.environmentVariable(name: EnvironmentKeys.developerDir)
  let sourceRootPath = try processInfo.environmentVariable(name: EnvironmentKeys.sourceRoot)
  let sdkRootPath = try processInfo.environmentVariable(name: EnvironmentKeys.sdkRoot)
  let platformPath = try processInfo.environmentVariable(name: EnvironmentKeys.platformDir)

  let outputURL = URL(fileURLWithPath: outputPath)
  let rswiftIgnoreURL = URL(fileURLWithPath: sourceRootPath).appendingPathComponent(rswiftIgnore, isDirectory: false)
  let modules = importModules
    .components(separatedBy: ",")
    .map { $0.trimmingCharacters(in: CharacterSet.whitespaces) }
    .filter { !$0.isEmpty }
    .map { Module.custom(name: $0) }

  let callInformation = CallInformation(
    outputURL: outputURL,
    rswiftIgnoreURL: rswiftIgnoreURL,

    accessLevel: accessLevel,
    imports: Set(modules),

    xcodeprojURL: URL(fileURLWithPath: xcodeprojPath),
    targetName: targetName,
    bundleIdentifier: bundleIdentifier,
    productModuleName: productModuleName,

    buildProductsDirURL: URL(fileURLWithPath: buildProductsDirPath),
    developerDirURL: URL(fileURLWithPath: developerDirPath),
    sourceRootURL: URL(fileURLWithPath: sourceRootPath),
    sdkRootURL: URL(fileURLWithPath: sdkRootPath),
    platformURL: URL(fileURLWithPath: platformPath)
  )

  try RswiftCore.run(callInformation)
}

// Temporary warning message during migration to R.swift 4
let parser = ArgumentParser(arguments: CommandLine.arguments)
_ = parser.shift()
let exception = parser.hasOption("version") || parser.hasOption("help")

if !exception && parser.shift() != "generate" {
  var arguments = CommandLine.arguments
  arguments.insert("generate", at: 1)
  let command = arguments
    .map { $0.contains(" ") ? "\"\($0)\"" : $0 }
    .joined(separator: " ")

  let message = "error: R.swift 4 requires \"generate\" command as first argument to the executable.\n"
    + "Change your call to something similar to this:\n\n"
    + "\(command)"
    + "\n"

  fputs("\(message)\n", stderr)
  exit(EXIT_FAILURE)
}

let group = Group()
group.addCommand("generate", "Generates R.generated.swift file", generate)
group.run(Rswift.version)
