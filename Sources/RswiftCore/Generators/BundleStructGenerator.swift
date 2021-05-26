//
//  NibStructGenerator.swift
//  R.swift
//
//  Created by Ivan Zezyulya on 18-05-21.
//  From: https://github.com/mac-cain13/R.swift
//  License: MIT License
//

import Foundation

struct BundleStructGenerator: ExternalOnlyStructGenerator {
  struct BundleInfo {
    let bundle: Bundle
    let structGenerators: [StructGenerator]
  }
  
  private let bundleInfos: [BundleInfo]

  init(bundleInfos: [BundleInfo]) {
    self.bundleInfos = bundleInfos
  }

  func generatedStruct(at externalAccessLevel: AccessLevel, prefix: SwiftIdentifier, bundle: String) -> Struct {
    let structName: SwiftIdentifier = "bundle"
    let qualifiedName = prefix + structName

    let structs = bundleInfos.compactMap { bundleInfo -> Struct? in
      return bundleStruct(info: bundleInfo, at: externalAccessLevel, prefix: qualifiedName)
    }

    return Struct(
      availables: [],
      comments: ["This `\(qualifiedName)` struct is generated, and contains static references to \(structs.count) bundles."],
      accessModifier: externalAccessLevel,
      type: Type(module: .host, name: structName),
      implements: [],
      typealiasses: [],
      properties: [],
      functions: [],
      structs: structs,
      classes: [],
      os: []
    )
  }
  
  private func bundleStruct(info: BundleInfo, at externalAccessLevel: AccessLevel, prefix: SwiftIdentifier) -> Struct? {
    let bundle = info.bundle.bundleName
    let structName = SwiftIdentifier(name: bundle)
    let qualifiedName = prefix + structName
    
    let structs = info.structGenerators.compactMap { generator -> Struct? in
      let resourceStructs = generator.generatedStructs(at: externalAccessLevel, prefix: qualifiedName, bundle: "\(qualifiedName).bundle")
      return resourceStructs.externalStruct
    }
    .filter {
      !$0.isEmpty
    }

    return Struct(
      availables: [],
      comments: ["This `\(qualifiedName)` struct is generated, and contains static references to \(structs.count) resource groups."],
      accessModifier: externalAccessLevel,
      type: Type(module: .host, name: structName),
      implements: [],
      typealiasses: [],
      properties: [bundleURLLet(bundle: bundle), bundleLet(bundle: bundle)],
      functions: [],
      structs: structs,
      classes: [],
      os: []
    )
  }
  
  private func bundleURLLet(bundle: String) -> Let {
    return Let(
      comments: [],
      accessModifier: .publicLevel,
      isStatic: true,
      name: SwiftIdentifier(name: "bundleURL"),
      typeDefinition: .inferred(Type._URL),
      value: "R.hostingBundle.bundleURL.appendingPathComponent(\"\(bundle).bundle\")"
    )
  }

  private func bundleLet(bundle: String) -> Let {
    return Let(
      comments: [],
      accessModifier: .publicLevel,
      isStatic: true,
      name: SwiftIdentifier(name: "bundle"),
      typeDefinition: .inferred(Type._Bundle),
      value: "Bundle(url: bundleURL)!"
    )
  }
}
