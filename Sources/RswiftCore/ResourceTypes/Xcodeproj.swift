//
//  Xcodeproj.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 09-12-15.
//  From: https://github.com/mac-cain13/R.swift
//  License: MIT License
//

import Foundation
import XcodeEdit

struct Xcodeproj: WhiteListedExtensionsResourceType {
  static let supportedExtensions: Set<String> = ["xcodeproj"]

  private let projectFile: XCProjectFile

  init(url: URL) throws {
    try Xcodeproj.throwIfUnsupportedExtension(url.pathExtension)
    let projectFile: XCProjectFile

    // Parse project file
    do {
      do {
        projectFile = try XCProjectFile(xcodeprojURL: url)
      }
      catch let error as ProjectFileError {
        warn(error.description)

        projectFile = try XCProjectFile(xcodeprojURL: url, ignoreReferenceErrors: true)
      }
    }
    catch {
      throw ResourceParsingError.parsingFailed("Project file at '\(url)' could not be parsed, is this a valid Xcode project file ending in *.xcodeproj?")
    }

    self.projectFile = projectFile
  }

  func resourcePathsForTarget(_ targetName: String) throws -> [Path] {
    // Look for target in project file
    let allTargets = projectFile.project.targets.flatMap { $0.value }
    guard let target = allTargets.filter({ $0.name == targetName }).first else {
      let availableTargets = allTargets.flatMap { $0.name }.joined(separator: ", ")
      throw ResourceParsingError.parsingFailed("Target '\(targetName)' not found in project file, available targets are: \(availableTargets)")
    }

    let resourcesFileRefs = target.buildPhases
      .flatMap { $0.value as? PBXResourcesBuildPhase }
      .flatMap { $0.files }
      .flatMap { $0.value?.fileRef }

    let fileRefPaths = resourcesFileRefs
      .flatMap { $0.value as? PBXFileReference }
      .flatMap { $0.fullPath }

    let variantGroupPaths = resourcesFileRefs
      .flatMap { $0.value as? PBXVariantGroup }
      .flatMap { $0.fileRefs }
      .flatMap { $0.value?.fullPath }

    return fileRefPaths + variantGroupPaths
  }
}
