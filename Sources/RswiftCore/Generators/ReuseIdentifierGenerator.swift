//
//  ReuseIdentifierStructGenerator.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 10-12-15.
//  From: https://github.com/mac-cain13/R.swift
//  License: MIT License
//

import Foundation

struct ReuseIdentifierStructGenerator: ExternalOnlyStructGenerator {
  private let reusables: [Reusable]

  init(reusables: [Reusable]) {
    self.reusables = reusables
  }

  func generatedStruct(at externalAccessLevel: AccessLevel, prefix: SwiftIdentifier, bundle: BundleExpression) -> Struct {
    let structName: SwiftIdentifier = "reuseIdentifier"
    let qualifiedName = prefix + structName
    let deduplicatedReusables = reusables
      .grouped { $0.hashValue }
      .values
      .compactMap { $0.first }

    let groupedReusables = deduplicatedReusables.grouped(bySwiftIdentifier: { $0.identifier })
    groupedReusables.printWarningsForDuplicatesAndEmpties(source: "reuseIdentifier", result: "reuseIdentifier")

    let reuseIdentifierProperties = groupedReusables
      .uniques
      .map { letFromReusable($0, at: externalAccessLevel) }

    return Struct(
      availables: [],
      comments: ["This `\(qualifiedName)` struct is generated, and contains static references to \(reuseIdentifierProperties.count) reuse identifiers."],
      accessModifier: externalAccessLevel,
      type: Type(module: .host, name: structName),
      implements: [],
      typealiasses: [],
      properties: reuseIdentifierProperties,
      functions: [],
      structs: [],
      classes: [],
      os: []
    )
  }

  private func letFromReusable(_ reusable: Reusable, at externalAccessLevel: AccessLevel) -> Let {
    return Let(
      comments: ["Reuse identifier `\(reusable.identifier)`."],
      accessModifier: externalAccessLevel,
      isStatic: true,
      name: SwiftIdentifier(name: reusable.identifier),
      typeDefinition: .specified(Type.ReuseIdentifier.withGenericArgs([reusable.type])),
      value: "Rswift.ReuseIdentifier(identifier: \"\(reusable.identifier)\")"
    )
  }
}
