//
//  CallInformation.swift
//  R.swift
//
//  Created by Tom Lokhorst on 2017-04-22.
//  From: https://github.com/mac-cain13/R.swift
//  License: MIT License
//

import Foundation
import XcodeEdit

public struct CallInformation {
  let outputURL: URL
  let uiTestOutputURL: URL?
  let rswiftIgnoreURL: URL

  let generators: [Generator]
  let accessLevel: AccessLevel
  let imports: [Module]

  let xcodeprojURL: URL
  let targetName: String
  let bundleIdentifier: String
  let productModuleName: String
  let hostingBundleName: String?
  let infoPlistFile: URL?
  let codeSignEntitlements: URL?

  let builtProductsDirURL: URL
  let developerDirURL: URL
  let sourceRootURL: URL
  let sdkRootURL: URL
  let platformURL: URL

  public init(
    outputURL: URL,
    uiTestOutputURL: URL?,
    rswiftIgnoreURL: URL,

    generators: [Generator],
    accessLevel: AccessLevel,
    imports: [Module],

    xcodeprojURL: URL,
    targetName: String,
    bundleIdentifier: String,
    productModuleName: String,
    hostingBundleName: String?,
    infoPlistFile: URL?,
    codeSignEntitlements: URL?,

    builtProductsDirURL: URL,
    developerDirURL: URL,
    sourceRootURL: URL,
    sdkRootURL: URL,
    platformURL: URL
  ) {
    self.outputURL = outputURL
    self.uiTestOutputURL = uiTestOutputURL
    self.rswiftIgnoreURL = rswiftIgnoreURL

    self.accessLevel = accessLevel
    self.imports = imports
    self.generators = generators

    self.xcodeprojURL = xcodeprojURL
    self.targetName = targetName
    self.bundleIdentifier = bundleIdentifier
    self.productModuleName = productModuleName
    self.hostingBundleName = hostingBundleName
    self.infoPlistFile = infoPlistFile
    self.codeSignEntitlements = codeSignEntitlements

    self.builtProductsDirURL = builtProductsDirURL
    self.developerDirURL = developerDirURL
    self.sourceRootURL = sourceRootURL
    self.sdkRootURL = sdkRootURL
    self.platformURL = platformURL
  }


  func urlForSourceTreeFolder(_ sourceTreeFolder: SourceTreeFolder) -> URL {
    switch sourceTreeFolder {
    case .buildProductsDir:
      return builtProductsDirURL
    case .developerDir:
      return developerDirURL
    case .sdkRoot:
      return sdkRootURL
    case .sourceRoot:
      return sourceRootURL
    case .platformDir:
      return platformURL
    }
  }
}
