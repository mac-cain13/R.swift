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
  func value(from current: String, name: String, key: String) throws -> String {
    if current != key { return current }
    guard let value = self.environment[key] else { throw ArgumentError.missingValue(argument: name) }

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
}

// Options grouped in struct for readability
struct CommanderOptions {
  static let importModules = Option("import", default: "", description: "Add extra modules as import in the generated file, comma seperated.")
  static let accessLevel = Option("accessLevel", default: AccessLevel.internalLevel, description: "The access level [public|internal] to use for the generated R-file.")
  static let rswiftIgnore = Option("rswiftignore", default: ".rswiftignore", description: "Path to pattern file that describes files that should be ignored.")

  static let xcodeproj = Option("xcodeproj", default: EnvironmentKeys.xcodeproj, flag: "p", description: "Path to the xcodeproj file.")
  static let target = Option("target", default: EnvironmentKeys.target, flag: "t", description: "Target the R-file should be generated for.")

  static let bundleIdentifier = Option("bundleIdentifier", default: EnvironmentKeys.bundleIdentifier, description: "Bundle identifier the R-file is be generated for.")
  static let productModuleName = Option("productModuleName", default: EnvironmentKeys.productModuleName, description: "Product module name the R-file is generated for.")
  static let buildProductsDir = Option("buildProductsDir", default: EnvironmentKeys.buildProductsDir, description: "Build products folder that Xcode uses during build.")
  static let developerDir = Option("developerDir", default: EnvironmentKeys.developerDir, description: "Developer folder that Xcode uses during build.")
  static let sourceRoot = Option("sourceRoot", default: EnvironmentKeys.sourceRoot, description: "Source root folder that Xcode uses during build.")
  static let sdkRoot = Option("sdkRoot", default: EnvironmentKeys.sdkRoot, description: "SDK root folder that Xcode uses during build.")
  
  static let storyboardAdditionsParams = Option("storyboardInstantiationAdditions", default: "", description: "Control storyboard instantiation functions in the generated storyboards struct, comma separated")
}


// Options grouped in struct for readability
struct CommanderArguments {
  static let outputDir = Argument<String>("outputDir", description: "Output directory for the 'R.generated.swift' file.")
}

let generate = command(

  CommanderOptions.importModules,
  CommanderOptions.accessLevel,
  CommanderOptions.rswiftIgnore,

  CommanderOptions.xcodeproj,
  CommanderOptions.target,

  CommanderOptions.bundleIdentifier,
  CommanderOptions.productModuleName,
  CommanderOptions.buildProductsDir,
  CommanderOptions.developerDir,
  CommanderOptions.sourceRoot,
  CommanderOptions.sdkRoot,
  
  CommanderOptions.storyboardAdditionsParams,

  CommanderArguments.outputDir
) { importModules, accessLevel, rswiftIgnore, xcodeproj, target, bundle, productModule, buildProductsDir, developerDir, sourceRoot, sdkRoot, storyboardAdditionsParams, outputDir in

  let info = ProcessInfo()

  let xcodeprojPath = try info.value(from: xcodeproj, name: "xcodeproj", key: EnvironmentKeys.xcodeproj)
  let targetName = try info.value(from: target, name: "target", key: EnvironmentKeys.target)
  let bundleIdentifier = try info.value(from: bundle, name: "bundleIdentifier", key: EnvironmentKeys.bundleIdentifier)
  let productModuleName = try info.value(from: productModule, name: "productModuleName", key: EnvironmentKeys.productModuleName)

  let buildProductsDirPath = try info.value(from: buildProductsDir, name: "buildProductsDir", key: EnvironmentKeys.buildProductsDir)
  let developerDirPath = try info.value(from: developerDir, name: "developerDir", key: EnvironmentKeys.developerDir)
  let sourceRootPath = try info.value(from: sourceRoot, name: "sourceRoot", key: EnvironmentKeys.sourceRoot)
  let sdkRootPath = try info.value(from: sdkRoot, name: "sdkRoot", key: EnvironmentKeys.sdkRoot)


  let outputURL = URL(fileURLWithPath: outputDir).appendingPathComponent(Rswift.resourceFileName, isDirectory: false)
  let rswiftIgnoreURL = URL(fileURLWithPath: sourceRootPath).appendingPathComponent(rswiftIgnore, isDirectory: false)
  let storyboardAdditions: [StoryboardInstantiationAdditions] = storyboardAdditionsParams
    .components(separatedBy: ",")
    .map { $0.trimmingCharacters(in: CharacterSet.whitespaces) }
    .filter { !$0.isEmpty }
    .flatMap { StoryboardInstantiationAdditions.load(name: $0) }
  let storyboardAdditionsImports: [Module] = storyboardAdditions.flatMap { $0.requiredImportModules() }
  let modulesFromImportModules: [Module] = importModules
    .components(separatedBy: ",")
    .map { $0.trimmingCharacters(in: CharacterSet.whitespaces) }
    .filter { !$0.isEmpty }
    .map { Module.custom(name: $0) }
  
  let modules: [Module] = [modulesFromImportModules, storyboardAdditionsImports].flatMap { $0 }


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
    
    storyboardAdditions: Set(storyboardAdditions)
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
