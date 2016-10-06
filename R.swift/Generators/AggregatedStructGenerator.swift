//
//  AggregatedStructGenerator.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 05-10-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation

class AggregatedStructGenerator: StructGenerator {
  private let subgenerators: [StructGenerator]

  init(subgenerators: [StructGenerator]) {
    self.subgenerators = subgenerators
  }

  func generatedStructs(at externalAccessLevel: AccessLevel) -> StructGenerator.Result {
    let collectedResult = subgenerators
      .map { $0.generatedStructs(at: externalAccessLevel) }
      .reduce(StructGeneratorResultCollector()) { collector, result in collector.appending(result) }

    let externalStruct = Struct(
      comments: ["This `R` struct is generated and contains references to static resources."],
      accessModifier: externalAccessLevel,
      type: Type(module: .host, name: "R"),
      implements: [],
      typealiasses: [],
      properties: [],
      functions: [],
      structs: collectedResult.externalStructs
    )

    let internalStruct = Struct(
      comments: [],
      accessModifier: externalAccessLevel,
      type: Type(module: .host, name: "_R"),
      implements: [],
      typealiasses: [],
      properties: [],
      functions: [],
      structs: collectedResult.internalStructs
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
      internalStructs: internalStructs + [result.internalStruct].flatMap { $0 }
    )
  }
}

