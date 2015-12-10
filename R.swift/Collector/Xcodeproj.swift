//
//  Xcodeproj.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 09-12-15.
//  Copyright © 2015 Mathijs Kadijk. All rights reserved.
//

import Foundation

struct Xcodeproj {
  private let projectFile: XCProjectFile

  init(url: NSURL) throws {
    // Parse project file
    guard let projectFile = try? XCProjectFile(xcodeprojURL: url) else {
      throw ResourceParsingError.ParsingFailed("Project file at '\(url)' could not be parsed, is this a valid Xcode project file ending in *.xcodeproj?")
    }

    self.projectFile = projectFile
  }

  func resourcePathsForTarget(targetName: String) throws -> [Path] {
    // Look for target in project file
    let allTargets = projectFile.project.targets
    guard let target = allTargets.filter({ $0.name == targetName }).first else {
      let availableTargets = allTargets.map { $0.name }.joinWithSeparator(", ")
      throw ResourceParsingError.ParsingFailed("Target '\(targetName)' not found in project file, available targets are: \(availableTargets)")
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
}
