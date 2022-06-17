//
//  AccessibilityIdentifierStructGenerator.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 04/06/2019.
//  From: https://github.com/mac-cain13/R.swift
//  License: MIT License
//

import Foundation

private protocol AccessibilityIdentifierContainer {
  var name: String { get }
  var usedAccessibilityIdentifiers: [String] { get }
}

extension Nib: AccessibilityIdentifierContainer {}
extension Storyboard: AccessibilityIdentifierContainer {}

struct AccessibilityIdentifierStructGenerator: ExternalOnlyStructGenerator {
  private let accessibilityIdentifierContainers: [AccessibilityIdentifierContainer]

  init(nibs: [Nib], storyboards: [Storyboard]) {
    accessibilityIdentifierContainers = nibs + storyboards
  }

  func generatedStruct(at externalAccessLevel: AccessLevel, prefix: SwiftIdentifier) -> Struct {
    let structName: SwiftIdentifier = "id"
    let qualifiedName = prefix + structName
    let structsForMergedContainers = accessibilityIdentifierContainers
      .grouped(by: { SwiftIdentifier(name: $0.name) })
      .mapValues {
        $0.flatMap { $0.usedAccessibilityIdentifiers }
      }
      .filter { $0.value.count > 0 }
      .map { self.structFromContainer(identifier: $0.key, accessibilityIdentifiers: $0.value, at: externalAccessLevel) }

    return Struct(
      availables: [],
      comments: ["This `\(qualifiedName)` struct is generated, and contains static references to accessibility identifiers."],
      accessModifier: externalAccessLevel,
      type: Type(module: .host, name: structName),
      implements: [],
      typealiasses: [],
      properties: [],
      functions: [],
      structs: structsForMergedContainers,
      classes: [],
      os: []
    )
  }

  private func structFromContainer(identifier: SwiftIdentifier, accessibilityIdentifiers: [String], at externalAccessLevel: AccessLevel) -> Struct {
    let groupedAccessibilityIdentifiers = Set(accessibilityIdentifiers)
      .array()
      .grouped(bySwiftIdentifier: { $0 })
    groupedAccessibilityIdentifiers.printWarningsForDuplicatesAndEmpties(source: "accessibility identifier", result: "accessibility identifier")

    let accessibilityIdentifierLets = groupedAccessibilityIdentifiers
      .uniques
      .map { letFromAccessibilityIdentifier($0, at: externalAccessLevel) }

    return Struct(
      availables: [],
      comments: [],
      accessModifier: externalAccessLevel,
      type: Type(module: .host, name: identifier),
      implements: [],
      typealiasses: [],
      properties: accessibilityIdentifierLets,
      functions: [],
      structs: [],
      classes: [],
      os: []
    )
  }

  private func letFromAccessibilityIdentifier(_ accessibilityIdentifier: String, at externalAccessLevel: AccessLevel) -> Let {
    return Let(
      comments: ["Accessibility identifier `\(accessibilityIdentifier)`."],
      accessModifier: externalAccessLevel,
      isStatic: true,
      name: SwiftIdentifier(name: accessibilityIdentifier),
      typeDefinition: .specified(._String),
      value: "\"\(accessibilityIdentifier)\""
    )
  }
}

private extension Sequence {
  func groupedWithExactDuplicatesAllowed(bySwiftIdentifier identifierSelector: @escaping (Iterator.Element) -> String) -> SwiftNameGroups<Iterator.Element> {
    var groupedBy = grouped { SwiftIdentifier(name: identifierSelector($0)) }
    let empty = SwiftIdentifier(name: "")
    let empties = groupedBy[empty]?.map { "'\(identifierSelector($0))'" }.sorted()
    groupedBy[empty] = nil

    let uniques = Array(groupedBy.values.filter { $0.count == 1 }.joined())
      .sorted { identifierSelector($0) < identifierSelector($1) }
    let duplicates = groupedBy
      .filter { $0.1.count > 1 }
      .map { ($0.0, $0.1.map(identifierSelector).sorted()) }
      .sorted { $0.0.description < $1.0.description }

    return SwiftNameGroups(uniques: uniques, duplicates: duplicates, empties: empties ?? [])
  }
}
