//
//  main.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 03-09-15.
//  From: https://github.com/mac-cain13/R.swift
//  License: MIT License
//

import Foundation

enum InputParsingError: ErrorType, CustomStringConvertible {
  case MissingArguments(String)
  case MissingEnvironmentVariables(String)
  case InvalidArgument(String)

  var description: String {
    switch self {
    case let .MissingArguments(desc):
      return desc
    case let .MissingEnvironmentVariables(desc):
      return desc
    case let .InvalidArgument(desc):
      return desc
    }
  }
}

struct CallInformation {
  let rswiftCall: String
  let outputFolderPath: String

  let xcodeprojPath: String
  let targetName: String

  let buildProductsDir: String
  let developerDir: String
  let sourceRoot: String
  let sdkRoot: String

  init(processInfo: NSProcessInfo) throws {
    let arguments = processInfo.arguments
    guard let rswiftCall = arguments[safe: 0],
      outputFolderPath = arguments[safe: 1]
    else {
      throw InputParsingError.MissingArguments("Incorrect call to R.swift, must be of format 'rswift [outputFolder]'")
    }

    let environment = processInfo.environment
    guard let xcodeprojPath = environment["PROJECT_FILE_PATH"],
      targetName = environment["TARGET_NAME"],
      buildProductsDir = environment["BUILT_PRODUCTS_DIR"],
      developerDir = environment["DEVELOPER_DIR"],
      sourceRoot = environment["SOURCE_ROOT"],
      sdkRoot = environment["SDKROOT"]
    else {
      throw InputParsingError.MissingArguments("Incompatible environment, the following variables must be available: PROJECT_FILE_PATH, TARGET_NAME, BUILT_PRODUCTS_DIR, DEVELOPER_DIR, SOURCE_ROOT, SDKROOT")
    }

    self.rswiftCall = rswiftCall
    self.outputFolderPath = outputFolderPath

    self.xcodeprojPath = xcodeprojPath
    self.targetName = targetName

    self.buildProductsDir = buildProductsDir
    self.developerDir = developerDir
    self.sourceRoot = sourceRoot
    self.sdkRoot = sdkRoot
  }

  func pathFromSourceTreeFolder(sourceTreeFolder: SourceTreeFolder) -> String {
    switch sourceTreeFolder {
    case .BuildProductsDir:
      return buildProductsDir
    case .DeveloperDir:
      return developerDir
    case .SDKRoot:
      return sdkRoot
    case .SourceRoot:
      return sourceRoot
    }
  }
}

func pathResolverWithSourceTreeToPathConverter(pathFromSourceTreeFolder: SourceTreeFolder -> String)(path: Path) -> NSURL {
  switch path {
  case let .Absolute(absolutePath):
    return NSURL(fileURLWithPath: absolutePath)
  case let .RelativeTo(sourceTreeFolder, relativePath):
    let sourceTreePath = pathFromSourceTreeFolder(sourceTreeFolder)
    return NSURL(fileURLWithPath: sourceTreePath).URLByAppendingPathComponent(relativePath)
  }
}

func resourceURLsInXcodeproj(xcodeprojPath: String, forTarget targetName: String, pathResolver: Path -> NSURL) throws -> [NSURL] {
  // Parse project file
  guard let projectFile = try? XCProjectFile(xcodeprojPath: xcodeprojPath) else {
    throw InputParsingError.InvalidArgument("Project file at '\(xcodeprojPath)' could not be parsed, is this a valid Xcode project file ending in *.xcodeproj?")
  }

  // Look for target in project file
  let allTargets = projectFile.project.targets
  guard let target = allTargets.filter({ $0.productName == targetName }).first else {
    let availableTargets = allTargets.map { $0.productName }.joinWithSeparator(", ")
    throw InputParsingError.InvalidArgument("Target '\(targetName)' not found in project file, available targets are: \(availableTargets)")
  }

  let resourcesFileRefs = target.buildPhases
    .flatMap { $0 as? PBXResourcesBuildPhase }
    .flatMap { $0.files }
    .map { $0.fileRef }

  let fileRefPaths = resourcesFileRefs
    .flatMap { $0 as? PBXFileReference }
    .map { $0.fullPath }

  let variantGroupPaths = resourcesFileRefs
    .flatMap { $0 as? PBXVariantGroup }
    .flatMap { $0.fileRefs }
    .map { $0.fullPath }
  
  return (fileRefPaths + variantGroupPaths)
    .map(pathResolver)
}
