//
//  AggregatedStructGenerator.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 05-10-16.
//  From: https://github.com/mac-cain13/R.swift
//  License: MIT License
//

import Foundation

class AggregatedStructGenerator: StructGenerator {
  private let subgenerators: [StructGenerator]

  init(subgenerators: [StructGenerator]) {
    self.subgenerators = subgenerators
  }

  func generatedStructs(at externalAccessLevel: AccessLevel, prefix: SwiftIdentifier) -> StructGenerator.Result {
    let structName: SwiftIdentifier = "R"
    let qualifiedName = structName
    let internalStructName: SwiftIdentifier = "_R"

    let collectedResult = subgenerators
      .compactMap {
        let result = $0.generatedStructs(at: externalAccessLevel, prefix: qualifiedName)
        if result.externalStruct.isEmpty { return nil }
        if let internalStruct = result.internalStruct, internalStruct.isEmpty { return nil }

        return result
      }
      .reduce(StructGeneratorResultCollector()) { collector, result in collector.appending(result) }

    let externalStruct = Struct(
      availables: [],
      comments: ["This `\(qualifiedName)` struct is generated and contains references to static resources."],
      accessModifier: externalAccessLevel,
      type: Type(module: .host, name: structName),
      implements: [],
      typealiasses: [],
      properties: [],
      functions: [],
      structs: collectedResult.externalStructs,
      classes: [],
      os: []
    )

    let internalStruct = Struct(
      availables: [],
      comments: [],
      accessModifier: externalAccessLevel,
      type: Type(module: .host, name: internalStructName),
      implements: [],
      typealiasses: [],
      properties: [],
      functions: [],
      structs: collectedResult.internalStructs,
      classes: [],
      os: []
    )

    return (externalStruct, internalStruct)
  }
}

private struct StructGeneratorResultCollector {
  let externalStructs: [Struct]
  let internalStructs: [Struct]

  init() {
    self.externalStructs = []
    self.internalStructs = []
  }

  private init(externalStructs: [Struct], internalStructs: [Struct]) {
    self.externalStructs = externalStructs
    self.internalStructs = internalStructs
  }

  func appending(_ result: StructGenerator.Result) -> StructGeneratorResultCollector {
    return StructGeneratorResultCollector(
      externalStructs: externalStructs + [result.externalStruct],
      internalStructs: internalStructs + [result.internalStruct].compactMap { $0 }
    )
  }
}

