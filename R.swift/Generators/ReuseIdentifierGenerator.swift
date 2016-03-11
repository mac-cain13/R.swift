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

    let groupedReusables = deduplicatedReusables.groupBySwiftNames { $0.identifier }

    for (name, duplicates) in groupedReusables.duplicates {
      let names = duplicates.map { $0.identifier }.sort().joinWithSeparator(", ")
      warn("Skipping \(duplicates.count) reuseIdentifiers because symbol '\(name)' would be generated for all of these reuseIdentifiers: \(names)")
    }

    let reuseIdentifierProperties = groupedReusables
      .uniques
      .map(ReuseIdentifierGenerator.letFromReusable)

    externalStruct = Struct(
      type: Type(module: .Host, name: "reuseIdentifier"),
      implements: [],
      typealiasses: [],
      properties: reuseIdentifierProperties.map(anyProperty),
      functions: [],
      structs: []
    )
  }

  private static func letFromReusable(reusable: Reusable) -> Let {
    return Let(
      isStatic: true,
      name: reusable.identifier,
      typeDefinition: .Specified(Type.ReuseIdentifier.withGenericArgs([reusable.type])),
      value: "\(Type.ReuseIdentifier.name)(identifier: \"\(reusable.identifier)\")"
    )
  }
}
