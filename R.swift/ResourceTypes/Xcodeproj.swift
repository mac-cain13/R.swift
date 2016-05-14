//
//  Xcodeproj.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 09-12-15.
//  Copyright © 2015 Mathijs Kadijk. All rights reserved.
//

import Foundation

enum TargetType {
  case iOS
  case watchOS
}

extension TargetType {

  static func fromSdkRoot(sdkRoot: String) -> TargetType? {
    switch sdkRoot {
    case "ios":
      return .iOS
    case "watchos":
      return .watchOS

    default:
      return nil
    }
  }

  var fileName: String {
    switch self {
    case .iOS:
      return "R.generated.swift"
    case .watchOS:
      return "R.watchOS.generated.swift"
    }
  }
}


struct Xcodeproj: WhiteListedExtensionsResourceType {
  static let supportedExtensions: Set<String> = ["xcodeproj"]

  private let projectFile: XCProjectFile

  init(url: NSURL) throws {
    try Xcodeproj.throwIfUnsupportedExtension(url.pathExtension)

    // Parse project file
    guard let projectFile = try? XCProjectFile(xcodeprojURL: url) else {
      throw ResourceParsingError.ParsingFailed("Project file at '\(url)' could not be parsed, is this a valid Xcode project file ending in *.xcodeproj?")
    }

    self.projectFile = projectFile
  }

  func targetTypeForTarget(targetName: String) throws -> TargetType {
    // Look for target in project file
    let allTargets = projectFile.project.targets
    guard let target = allTargets.filter({ $0.name == targetName }).first else {
      let availableTargets = allTargets.map { $0.name }.joinWithSeparator(", ")
      throw ResourceParsingError.ParsingFailed("Target '\(targetName)' not found in project file, available targets are: \(availableTargets)")
    }

    let configs = target.buildConfigurationList.buildConfigurations

    configs.forEach {
      print($0.buildSettings)
    }

    switch (configs.first?.buildSettings.SDKROOT, configs.first?.buildSettings.IPHONEOS_DEPLOYMENT_TARGET) {
    case let (sdkRoot?, _):
      guard let targetType = TargetType.fromSdkRoot(sdkRoot) else {
        fail("\(sdkRoot) not jet supported!")
        throw NSError(domain: "", code: 0, userInfo: nil)
      }

      return targetType

    case (_, _?):
      return .iOS

    default:
      fail("No SDKROOT nor IPHONEOS_DEPLOYMENT_TARGET defined.")
      throw NSError(domain: "", code: 0, userInfo: nil)
    }
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
