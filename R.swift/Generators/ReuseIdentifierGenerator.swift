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
      warn(warning: "Skipping \(duplicates.count) reuseIdentifiers because symbol '\(name)' would be generated for all of these reuseIdentifiers: \(duplicates.joined(separator: ", "))")
    }

    let empties = groupedReusables.empties
    if let empty = empties.first where empties.count == 1 {
      warn(warning: "Skipping 1 reuseIdentifier because no swift identifier can be generated for reuseIdentifier: \(empty)")
    }
    else if empties.count > 1 {
      warn(warning: "Skipping \(empties.count) reuseIdentifiers because no swift identifier can be generated for all of these reuseIdentifiers: \(empties.joined(separator: ", "))")
    }

    let reuseIdentifierProperties = groupedReusables
      .uniques
      .map(ReuseIdentifierGenerator.letFromReusable)

    externalStruct = Struct(
      comments: ["This `R.reuseIdentifier` struct is generated, and contains static references to \(reuseIdentifierProperties.count) reuse identifiers."],
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
      comments: ["Reuse identifier `\(reusable.identifier)`."],
      isStatic: true,
      name: reusable.identifier,
      typeDefinition: .Specified(Type.ReuseIdentifier.withGenericArgs([reusable.type])),
      value: "\(Type.ReuseIdentifier.name)(identifier: \"\(reusable.identifier)\")"
    )
  }
}
