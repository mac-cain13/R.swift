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

    let groupedReusables = deduplicatedReusables.groupUniquesAndDuplicates { sanitizedSwiftName($0.identifier) }

    for duplicate in groupedReusables.duplicates {
      let names = duplicate.map { $0.identifier }.sort().joinWithSeparator(", ")
      warn("Skipping \(duplicate.count) reuseIdentifiers because symbol '\(sanitizedSwiftName(duplicate.first!.identifier))' would be generated for all of these reuseIdentifiers: \(names)")
    }

    let reuseIdentifierProperties: [Property] = groupedReusables
      .uniques
      .map(ReuseIdentifierGenerator.letFromReusable)

    externalStruct = Struct(
      type: Type(module: .Host, name: "reuseIdentifier"),
      implements: [],
      typealiasses: [],
      properties: reuseIdentifierProperties,
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
