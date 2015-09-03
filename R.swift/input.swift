//
//  main.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 03-09-15.
//  From: https://github.com/mac-cain13/R.swift
//  License: MIT License
//

import Foundation

enum InputParsingError: ErrorType {
  case MissingArguments(String)
  case InvalidArgument(String)
}

struct CallInformation {
  let rswiftCall: String
  let xcodeprojPath: String
  let targetName: String
  let outputFolderPath: String

  init(processInfo: NSProcessInfo) throws {
    let arguments = processInfo.arguments
    guard let rswiftCall = arguments[safe: 0],
      xcodeprojPath = arguments[safe: 1],
      targetName = arguments[safe: 2],
      outputFolderPath = arguments[safe: 3] else {
        throw InputParsingError.MissingArguments("Incorrect call to R.swift, must be of format 'rswift [projectFile] [targetName] [outputFolder]'")
    }

    self.rswiftCall = rswiftCall
    self.xcodeprojPath = xcodeprojPath
    self.targetName = targetName
    self.outputFolderPath = outputFolderPath
  }
}

func resourcePathsInXcodeproj(xcodeprojPath: String, forTarget targetName: String) throws -> [String] {
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
  
  return fileRefPaths + variantGroupPaths
}
