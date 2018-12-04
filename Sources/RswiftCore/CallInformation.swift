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
  let rswiftIgnoreURL: URL

  let accessLevel: AccessLevel
  let imports: Set<Module>

  let xcodeprojURL: URL
  let targetName: String
  let bundleIdentifier: String
  let productModuleName: String

  private let buildProductsDirURL: URL
  private let developerDirURL: URL
  private let sourceRootURL: URL
  private let sdkRootURL: URL
  private let platformURL: URL

  let parsingInformation: ParsingInformation
  
  public init(
    outputURL: URL,
    rswiftIgnoreURL: URL,

    accessLevel: AccessLevel,
    imports: Set<Module>,

    xcodeprojURL: URL,
    targetName: String,
    bundleIdentifier: String,
    productModuleName: String,

    buildProductsDirURL: URL,
    developerDirURL: URL,
    sourceRootURL: URL,
    sdkRootURL: URL,
    platformURL: URL,
    parsingInformation: ParsingInformation
  ) {
    self.outputURL = outputURL
    self.rswiftIgnoreURL = rswiftIgnoreURL

    self.accessLevel = accessLevel
    self.imports = imports

    self.xcodeprojURL = xcodeprojURL
    self.targetName = targetName
    self.bundleIdentifier = bundleIdentifier
    self.productModuleName = productModuleName

    self.buildProductsDirURL = buildProductsDirURL
    self.developerDirURL = developerDirURL
    self.sourceRootURL = sourceRootURL
    self.sdkRootURL = sdkRootURL
    self.platformURL = platformURL
    self.parsingInformation = parsingInformation
  }


  func urlForSourceTreeFolder(_ sourceTreeFolder: SourceTreeFolder) -> URL {
    switch sourceTreeFolder {
    case .buildProductsDir:
      return buildProductsDirURL
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
