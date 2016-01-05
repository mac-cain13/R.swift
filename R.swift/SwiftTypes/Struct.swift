//
//  Struct.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 10-12-15.
//  Copyright © 2015 Mathijs Kadijk. All rights reserved.
//

import Foundation

struct Struct: TypeSequenceProvider, CustomStringConvertible {
  let type: Type
  var implements: [Type]
  let typealiasses: [Typealias]
  let properties: [Property]
  var functions: [Function]
  var structs: [Struct]

  var usedTypes: [UsedType] {
    return [
        type.usedTypes,
        implements.flatMap(getUsedTypes),
        typealiasses.flatMap(getUsedTypes),
        properties.flatMap(getUsedTypes),
        functions.flatMap(getUsedTypes),
        structs.flatMap(getUsedTypes),
      ].flatten()
  }

  init(type: Type, implements: [Type], typealiasses: [Typealias], properties: [Property], functions: [Function], structs: [Struct]) {
    self.type = type
    self.implements = implements
    self.typealiasses = typealiasses
    self.properties = properties
    self.functions = functions
    self.structs = structs
  }

  var description: String {
    let implementsString = implements.count > 0 ? ": " + implements.joinWithSeparator(", ") : ""

    let typealiasString = typealiasses
      .sort { $0.alias < $1.alias }
      .joinWithSeparator("\n")

    let varsString = properties
      .sort {  $0.callName < $1.callName }
      .map { $0.description }
      .joinWithSeparator("\n")
    let functionsString = functions
      .sort { $0.callName < $1.callName }
      .map { $0.description }
      .joinWithSeparator("\n\n")
    let structsString = structs
      .sort { $0.type.description < $1.type.description }
      .joinWithSeparator("\n\n")

    let bodyComponents = [typealiasString, varsString, functionsString, structsString].filter { $0 != "" }
    let bodyString = bodyComponents.joinWithSeparator("\n\n").indentWithString(IndentationString)
    return "struct \(type)\(implementsString) {\n\(bodyString)\n}"
  }
}
