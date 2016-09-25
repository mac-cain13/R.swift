//
//  ReuseIdentifier.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 10-12-15.
//  Copyright © 2015 Mathijs Kadijk. All rights reserved.
//

import Foundation

struct ReuseIdentifierGenerator: Generator {
  let externalStruct: Struct?
  let internalStruct: Struct? = nil

  init(reusables: [Reusable]) {
    let deduplicatedReusables = reusables
      .groupBy { $0.hashValue }
      .values
      .flatMap { $0.first }

    let groupedReusables = deduplicatedReusables.groupBySwiftIdentifiers { $0.identifier }
    groupedReusables.printWarningsForDuplicatesAndEmpties(source: "reuseIdentifier", result: "reuseIdentifier")

    let reuseIdentifierProperties = groupedReusables
      .uniques
      .map(ReuseIdentifierGenerator.letFromReusable)

    externalStruct = Struct(
      comments: ["This `R.reuseIdentifier` struct is generated, and contains static references to \(reuseIdentifierProperties.count) reuse identifiers."],
      type: Type(module: .host, name: "reuseIdentifier"),
      implements: [],
      typealiasses: [],
      properties: reuseIdentifierProperties.map(anyProperty),
      functions: [],
      structs: []
    )
  }

  fileprivate static func letFromReusable(_ reusable: Reusable) -> Let {
    return Let(
      comments: ["Reuse identifier `\(reusable.identifier)`."],
      isStatic: true,
      name: SwiftIdentifier(name: reusable.identifier),
      typeDefinition: .specified(Type.ReuseIdentifier.withGenericArgs([reusable.type])),
      value: "\(Type.ReuseIdentifier.name)(identifier: \"\(reusable.identifier)\")"
    )
  }
}
