//
//  ReuseIdentifier.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 10-12-15.
//  Copyright © 2015 Mathijs Kadijk. All rights reserved.
//

import Foundation

struct ReuseIdentifierGenerator: StructGenerator {
  private let reusables: [Reusable]

  init(reusables: [Reusable]) {
    self.reusables = reusables
  }

  func generateStruct(at externalAccessLevel: AccessModifier) -> Struct? {
    let deduplicatedReusables = reusables
      .groupBy { $0.hashValue }
      .values
      .flatMap { $0.first }

    let groupedReusables = deduplicatedReusables.groupedBySwiftIdentifier { $0.identifier }
    groupedReusables.printWarningsForDuplicatesAndEmpties(source: "reuseIdentifier", result: "reuseIdentifier")

    let reuseIdentifierProperties = groupedReusables
      .uniques
      .map { letFromReusable($0, at: externalAccessLevel) }

    return Struct(
      comments: ["This `R.reuseIdentifier` struct is generated, and contains static references to \(reuseIdentifierProperties.count) reuse identifiers."],
      accessModifier: externalAccessLevel,
      type: Type(module: .host, name: "reuseIdentifier"),
      implements: [],
      typealiasses: [],
      properties: reuseIdentifierProperties,
      functions: [],
      structs: []
    )
  }

  private func letFromReusable(_ reusable: Reusable, at externalAccessLevel: AccessModifier) -> Let {
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
